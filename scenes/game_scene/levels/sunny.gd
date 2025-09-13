class_name Sunny
extends CharacterBody3D

@export var speed: float = 3.0
@export var acceleration: float = 5.0
@export var stop_distance: float = 0.5
@export var jump_velocity: float = 8.0
@export var player_path: NodePath
@export var fall_threshold: float = -20.0
@export var fall_check_time: float = 1.0

@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AvatarSample_E/AnimationPlayer
@onready var avatar_sample_e: VRMTopLevel = $AvatarSample_E
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback
@onready var chat_interface: Control = $CanvasLayer/ChatInterface
@onready var player_2ainpc: Player2AINPC = $Player2AINPC

var target_position: Vector3
var has_target: bool = false
var is_following_player: bool = false
var initial_position: Vector3
var is_falling: bool = false
var fall_timer: float = 0.0
var is_jumping: bool = false
var jump_target: Vector3
var preparing_jump: bool = false

enum State { IDLE, WANDER, MOVE_TO_CHECKPOINT, CHASE_PLAYER }
var state: State = State.WANDER

var player: Node3D
var current_animation: String = ""

func _ready():
	player = get_node_or_null(player_path)
	state_machine = animation_tree.get("parameters/playback")
	animation_tree.active = true
	initial_position = global_position
	
	# Configure NavigationAgent3D
	navigation_agent.target_desired_distance = stop_distance
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.path_max_distance = 0
	navigation_agent.avoidance_enabled = false  # Disable avoidance during jumps
	
	# Connect signals
	navigation_agent.link_reached.connect(_on_link_reached)
	navigation_agent.velocity_computed.connect(_on_velocity_computed)
	
	call_deferred("actor_setup")
	print("Sunny spawned at: ", initial_position)

func actor_setup():
	await get_tree().physics_frame

func _physics_process(delta: float) -> void:
	_check_fall_status(delta)
	
	# Handle jumping state separately
	if is_jumping:
		_handle_jump_physics(delta)
		return
	
	match state:
		State.IDLE:
			has_target = false
			_play_idle()
			_apply_gravity(delta)

		State.WANDER:
			if not has_target:
				_pick_random_target()
			_navigate_to_target(delta)

		State.MOVE_TO_CHECKPOINT:
			_navigate_to_target(delta)

		State.CHASE_PLAYER:
			if player:
				_set_navigation_target(player.global_position)
				_navigate_to_target(delta)

func _navigate_to_target(delta: float) -> void:
	if not has_target and navigation_agent.is_navigation_finished():
		return
	
	if navigation_agent.is_navigation_finished():
		has_target = false
		preparing_jump = false
		_play_idle()
		_apply_gravity(delta)
		return
	
	# Don't move if preparing to jump
	if preparing_jump:
		_apply_gravity(delta)
		move_and_slide()
		return
	
	var current_agent_position = global_position
	var next_path_position = navigation_agent.get_next_path_position()
	
	# Calculate movement direction (horizontal only)
	var direction = (next_path_position - current_agent_position)
	direction.y = 0  # Remove vertical component
	var horizontal_distance = direction.length()
	
	# If we're very close horizontally but there's a height difference, we might need to jump
	var height_diff = next_path_position.y - current_agent_position.y
	
	if horizontal_distance < 1.0 and height_diff > 0.5 and is_on_floor():
		# We're close horizontally but need to go up - likely a jump scenario
		preparing_jump = true
		_play_idle()
		_apply_gravity(delta)
		move_and_slide()
		return
	
	# Normal movement
	if horizontal_distance > 0.1:
		direction = direction.normalized()
		velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
		
		_rotate_towards_movement()
		_play_walking()
	else:
		# Close enough, stop horizontal movement
		velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, acceleration * delta)
		_play_idle()
	
	_apply_gravity(delta)
	move_and_slide()

func _handle_jump_physics(delta: float) -> void:
	# During jump, move towards the jump target
	var direction_to_target = (jump_target - global_position)
	direction_to_target.y = 0  # Only horizontal movement
	
	if direction_to_target.length() > 0.1:
		direction_to_target = direction_to_target.normalized()
		velocity.x = direction_to_target.x * speed
		velocity.z = direction_to_target.z * speed
	
	# Apply gravity
	velocity.y += get_gravity().y * delta
	
	move_and_slide()
	
	# Check if we've landed
	if is_on_floor() and velocity.y <= 0:
		print("Sunny landed!")
		is_jumping = false
		preparing_jump = false
		
		# Resume normal navigation
		await get_tree().create_timer(0.2).timeout  # Brief pause after landing

func _on_link_reached(details: Dictionary):
	print("Navigation link reached - initiating jump")
	print("Link details: ", details)
	
	# Use the EXIT position, not the entry position!
	var link_end = Vector3.ZERO
	
	if details.has("link_exit_position"):
		link_end = details["link_exit_position"]
		print("Using link_exit_position: ", link_end)
	elif details.has("position"):
		link_end = details["position"]
		print("Using position as fallback: ", link_end)
	else:
		# Last resort fallback
		link_end = navigation_agent.target_position
		print("Using navigation target as fallback: ", link_end)
	
	# Validate the jump target
	if link_end == Vector3.ZERO:
		print("ERROR: Invalid jump target, aborting jump")
		return
	
	# Set jump target to the EXIT position
	jump_target = link_end
	print("Set jump_target to: ", jump_target)
	
	# Prepare for jump
	_perform_jump()

func _perform_jump():
	if not is_on_floor() or is_jumping:
		return
		
	print("Sunny is jumping!")
	print("Jump from: ", global_position)
	print("Jump to: ", jump_target)
	
	is_jumping = true
	preparing_jump = false
	
	# Calculate jump direction and distance
	var jump_direction = (jump_target - global_position)
	var horizontal_distance = Vector2(jump_direction.x, jump_direction.z).length()
	jump_direction.y = 0
	jump_direction = jump_direction.normalized()
	
	print("Jump direction: ", jump_direction)
	print("Horizontal distance: ", horizontal_distance)
	
	# Set vertical jump velocity
	velocity.y = jump_velocity
	
	# Add forward momentum for longer jumps
	var forward_boost = speed * 5  # Adjust this multiplier as needed
	velocity.x = jump_direction.x * forward_boost
	velocity.z = jump_direction.z * forward_boost
	
	# Orient towards jump target
	if jump_direction.length() > 0.1:
		var model_root = avatar_sample_e
		var facing = Transform3D().looking_at(jump_direction, Vector3.UP)
		model_root.basis = facing.basis
		model_root.rotate_y(deg_to_rad(180))
	
	_play_jump()
	
func _on_velocity_computed(safe_velocity: Vector3):
	# This can help with smoother movement, but we'll handle jumping manually
	if not is_jumping and not preparing_jump:
		velocity.x = safe_velocity.x
		velocity.z = safe_velocity.z

func _rotate_towards_movement():
	var model_root = avatar_sample_e
	var dir = Vector3(velocity.x, 0, velocity.z).normalized()
	if dir.length() > 0.1:
		var facing = Transform3D().looking_at(dir, Vector3.UP)
		model_root.basis = facing.basis
		model_root.rotate_y(deg_to_rad(180))

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += get_gravity().y * delta

func _set_navigation_target(target: Vector3) -> void:
	navigation_agent.target_position = target
	has_target = true

func _pick_random_target() -> void:
	var random_offset = Vector3(
		randf_range(-10, 10),
		0,
		randf_range(-10, 10)
	)
	var potential_target = global_position + random_offset
	_set_navigation_target(potential_target)

# Add jump animation (you'll need to create this in your AnimationTree)
func _play_jump() -> void:
	if current_animation != "Jump":
		# If you don't have a jump animation, use walking or idle
		state_machine.travel("Walking")  # or create a "Jump" state
		current_animation = "Jump"

# Keep all your existing methods...
func _play_walking() -> void:
	if current_animation != "Walking":
		state_machine.travel("Walking")
		current_animation = "Walking"

func _play_idle() -> void:
	if current_animation != "Idle":
		state_machine.travel("Idle")
		current_animation = "Idle"
		
func _check_fall_status(delta: float) -> void:
	# Check if NPC is below the fall threshold
	if global_position.y < fall_threshold:
		if not is_falling:
			is_falling = true
			fall_timer = 0.0
			print("WARNING: Sunny is falling into the void!")
			player_2ainpc.notify("You fell into the void. You will be teleported back to the start. React accordingly.")
		else:
			fall_timer += delta
			if fall_timer >= fall_check_time:
				_rescue_from_void()
	else:
		# Reset fall status if back on safe ground
		if is_falling and is_on_floor():
			is_falling = false
			fall_timer = 0.0
			print("Sunny is back on safe ground")

func _rescue_from_void() -> void:
	print("Rescuing Sunny from the void - teleporting to initial position")
	
	# Reset position and physics
	global_position = initial_position
	velocity = Vector3.ZERO
	
	# Reset AI state
	state = State.IDLE
	has_target = false
	is_falling = false
	fall_timer = 0.0
	
	# Brief pause before resuming normal behavior
	await get_tree().create_timer(2.0).timeout
	if state == State.IDLE:  # Only resume if still idle (not overridden)
		state = State.WANDER
		print("Sunny resumed normal behavior after rescue")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and not is_following_player:
		state = State.IDLE

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		state = State.WANDER
		
func move_to_position(pos: Vector3) -> void:
	_set_navigation_target(pos)
	state = State.MOVE_TO_CHECKPOINT

func start_following_player() -> void:
	state = State.CHASE_PLAYER
	is_following_player = true
	print("Sunny is now following the player")

func stop_following_player() -> void:
	state = State.WANDER
	is_following_player = false
	has_target = false
	print("Sunny stopped following the player")

class_name Sunny
extends CharacterBody3D

@export var speed: float = 3.0
@export var acceleration: float = 5.0
@export var stop_distance: float = 0.5
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
	
	# Wait for navigation map to be ready
	call_deferred("actor_setup")
	print("Sunny spawned at: ", initial_position)
	
func actor_setup():
	# Wait for the first physics frame so the NavigationServer can sync
	await get_tree().physics_frame

func _physics_process(delta: float) -> void:
	# Check for falling into void
	_check_fall_status(delta)
	
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

func _move_to_target(delta: float) -> void:
	if not has_target:
		# Still apply gravity when idle
		if not is_on_floor():
			velocity.y += get_gravity().y * delta
		move_and_slide()
		return
	
	var direction = (target_position - global_position)
	direction.y = 0  # Keep this for horizontal movement
	var distance = direction.length()
	
	if distance < stop_distance:
		has_target = false
		_play_idle()
		# Apply gravity even when reaching target
		if not is_on_floor():
			velocity.y += get_gravity().y * delta
		move_and_slide()
		return
	
	direction = direction.normalized()
	velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
	velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	
	move_and_slide()
	
	# Debug output
	#print("Velocity length: ", velocity.length())
	
	# Rotate model towards movement
	if velocity.length() > 0.1:
		var model_root = avatar_sample_e
		var dir = velocity.normalized()
		var facing = Transform3D().looking_at(dir, Vector3.UP)
		model_root.basis = facing.basis
		model_root.rotate_y(deg_to_rad(180))
		_play_walking()
	else:
		_play_idle()
		
func _navigate_to_target(delta: float) -> void:
	if not has_target and not navigation_agent.is_navigation_finished():
		return
	
	if navigation_agent.is_navigation_finished():
		has_target = false
		_play_idle()
		_apply_gravity(delta)
		return
	
	var current_agent_position = global_position
	var next_path_position = navigation_agent.get_next_path_position()
	
	var direction = (next_path_position - current_agent_position).normalized()
	direction.y = 0  # Keep movement horizontal
	
	velocity.x = lerp(velocity.x, direction.x * speed, acceleration * delta)
	velocity.z = lerp(velocity.z, direction.z * speed, acceleration * delta)
	
	_apply_gravity(delta)
	move_and_slide()
	
	# Rotate model towards movement
	if velocity.length() > 0.1:
		var model_root = avatar_sample_e
		var dir = velocity.normalized()
		var facing = Transform3D().looking_at(dir, Vector3.UP)
		model_root.basis = facing.basis
		model_root.rotate_y(deg_to_rad(180))
		_play_walking()
	else:
		_play_idle()

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
	
# --- Animation helpers ---
func _play_walking() -> void:
	if current_animation != "Walking":
		state_machine.travel("Walking")  # Use your state names
		current_animation = "Walking"

func _play_idle() -> void:
	if current_animation != "Idle":
		state_machine.travel("Idle")  # Use your state names
		current_animation = "Idle"

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

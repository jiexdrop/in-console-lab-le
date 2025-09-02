extends CharacterBody3D

@export var speed: float = 3.0
@export var acceleration: float = 5.0
@export var stop_distance: float = 0.5
@export var player_path: NodePath
@onready var animation_player: AnimationPlayer = $AvatarSample_E/AnimationPlayer
@onready var avatar_sample_e: VRMTopLevel = $AvatarSample_E
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback
@onready var chat_interface: Control = $CanvasLayer/ChatInterface

var target_position: Vector3
var has_target: bool = false

# AI states
enum State { IDLE, WANDER, MOVE_TO_CHECKPOINT, CHASE_PLAYER }
var state: State = State.WANDER

var player: Node3D
var current_animation: String = ""

func _ready():
	player = get_node_or_null(player_path)
	state_machine = animation_tree.get("parameters/playback")
	animation_tree.active = true

func _physics_process(delta: float) -> void:
	match state:
		State.IDLE:
			# Just stop moving
			has_target = false
			_play_idle()

		State.WANDER:
			if not has_target:
				_pick_random_target()
			_move_to_target(delta)

		State.MOVE_TO_CHECKPOINT:
			_move_to_target(delta)

		State.CHASE_PLAYER:
			if player:
				target_position = player.global_position
				has_target = true
				_move_to_target(delta)


func _move_to_target(delta: float) -> void:
	if not has_target:
		return
		
	var direction = (target_position - global_position)
	direction.y = 0
	var distance = direction.length()
	
	if distance < stop_distance:
		has_target = false
		_play_idle()
		return
	
	direction = direction.normalized()
	velocity = velocity.lerp(direction * speed, acceleration * delta)
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

func _pick_random_target() -> void:
	var max_attempts = 10
	var attempt = 0
	
	while attempt < max_attempts:
		var random_offset = Vector3(
			randf_range(-10, 10),  # Increased range for more variety
			0,
			randf_range(-10, 10)
		)
		var potential_target = global_position + random_offset
		
		# Cast a ray downward to check for ground
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(
			potential_target + Vector3(0, 2, 0),  # Start above the target
			potential_target + Vector3(0, -10, 0)  # Cast down
		)
		
		var result = space_state.intersect_ray(query)
		if result:
			# Found ground! Adjust target to be on the surface
			target_position = result.position
			has_target = true
			return
		
		attempt += 1
	
	# Fallback: stay in current position if no valid target found
	target_position = global_position
	has_target = true


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
	if body.is_in_group("player"):
		state = State.IDLE

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		state = State.WANDER

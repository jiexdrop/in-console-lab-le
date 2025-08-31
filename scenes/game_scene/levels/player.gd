extends CharacterBody3D

@export var speed: float = 5.0
@export var mouse_sensitivity: float = 0.003
@export var jump_velocity: float = 4.5

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var cam: Camera3D = $Camera3D
@onready var chat_interface: Control = $"../Sunny/CanvasLayer/ChatInterface"

var yaw: float = 0.0
var pitch: float = 0.0

var input_disabled: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if chat_interface:
		chat_interface.connect("chat_closed", _on_chat_closed)

func _on_chat_closed():
	input_disabled = false

func _input(event: InputEvent) -> void:
	if input_disabled:
		return
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, -1.2, 1.2) # limit looking up/down

		rotation.y = yaw
		cam.rotation.x = pitch


func _physics_process(delta: float) -> void:
	if input_disabled:
		return
	var input_dir = Vector2.ZERO
	
	if Input.is_action_pressed("move_up"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1

	input_dir = input_dir.normalized()

	# Convert 2D input to 3D relative to camera yaw
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	# gravity + jumping
	if not is_on_floor():
		velocity.y -= gravity * delta
	elif Input.is_action_just_pressed("ui_accept"): # default: Space
		velocity.y = jump_velocity

	move_and_slide()

func set_input_disabled(value: bool):
	input_disabled = value

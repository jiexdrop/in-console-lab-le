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

# How close the player must be to interact
@export var interact_distance: float = 5.0
var current_lever: Lever = null
var outline_material: ShaderMaterial


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if chat_interface:
		chat_interface.connect("chat_closed", _on_chat_closed)
		
	setup_outline_shader()

func _on_chat_closed():
	input_disabled = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	# Continuously raycast to find levers
	var lever := get_raycast_lever()
	
	# Handle outline display
	if lever != current_lever:
		# Remove outline from previous lever
		if current_lever:
			remove_outline(current_lever)
		
		# Add outline to new lever
		current_lever = lever
		if current_lever:
			add_outline(current_lever)
	
	# Handle interaction
	if Input.is_action_just_pressed("interact") and current_lever:
		# Toggle lever state
		if current_lever.activated:
			current_lever.deactivate_lever()
		else:
			current_lever.activate_lever()

func get_raycast_lever() -> Lever:
	# Cast a ray from the camera/player forward
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return null
	
	var from = camera.global_position
	var to = from + (-camera.global_transform.basis.z * interact_distance)
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result and result.collider is Lever:
		return result.collider
	
	return null

func setup_outline_shader():
	outline_material = ShaderMaterial.new()
	var shader = load("res://resources/shader/outline_shader_2.gdshader")
	outline_material.shader = shader
	outline_material.set_shader_parameter("shadow_color", Color.BLACK)
	outline_material.set_shader_parameter("shadow_thickness", 5)

func add_outline(lever: Lever):
	# Assuming the lever has a MeshInstance3D node
	var mesh_instance = lever.find_child("LeverBase_Material #27_0")
	var mesh_instance_2 = lever.find_child("Lever_Material #30_0")
	if mesh_instance and mesh_instance_2:
		mesh_instance.material_overlay = outline_material
		mesh_instance_2.material_overlay = outline_material
	

func remove_outline(lever: Lever):
	# Remove the outline material
	var mesh_instance = lever.find_child("LeverBase_Material #27_0") 
	var mesh_instance_2 = lever.find_child("Lever_Material #30_0")
	if mesh_instance:
		mesh_instance.material_overlay = null
		mesh_instance_2.material_overlay = null

func _input(event: InputEvent) -> void:
	# Handle escape key for chat closing with highest priority
	if chat_interface.is_chat_open and event.is_action_pressed("ui_cancel"):
		chat_interface.hide_chat()
		input_disabled = false
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		get_viewport().set_input_as_handled()  # Consume the event
		return
	
	if input_disabled:
		return
	if chat_interface.is_chat_open:
		return
	
	# Add this section for the talk input
	if event.is_action_pressed("talk"):
		chat_interface.show_chat()
		input_disabled = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_viewport().set_input_as_handled()  # This consumes the event
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

	var old_velocity = velocity
	move_and_slide()
	
	# Real-time pushing
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		
		if collider is CharacterBody3D:
			var push_vector = old_velocity.normalized() # Adjust strength
			collider.velocity = push_vector
			collider.move_and_slide()  # Move immediately

func set_input_disabled(value: bool):
	input_disabled = value
	if value:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

class_name Lever
extends Node3D

@onready var lever: Node3D = $"Sketchfab_model/189d8c5f728f4537ad3f9f920e79e82e_fbx/RootNode/Lever"
@onready var cylinder_002: Node3D = $"Sketchfab_model/189d8c5f728f4537ad3f9f920e79e82e_fbx/RootNode/Cylinder002"
@onready var root_node: Node3D = $"Sketchfab_model/189d8c5f728f4537ad3f9f920e79e82e_fbx/RootNode"

var activated = false
var lever_default_rotation: Vector3
var cylinder_default_rotation: Vector3
var lever_activated_rotation: Vector3
var cylinder_activated_rotation: Vector3

var lever_height = 49.213 - 9.843

func _ready():
	# Store the default rotations
	lever_default_rotation = lever.rotation
	cylinder_default_rotation = cylinder_002.rotation
	
	# Create a RemoteTransform3D to link cylinder to lever
	var remote_transform = RemoteTransform3D.new()
	lever.add_child(remote_transform)
	remote_transform.remote_path = cylinder_002.get_path()
	remote_transform.update_rotation = true
	remote_transform.update_position = true
	
	# Position the RemoteTransform at the lever tip
	remote_transform.position = Vector3(0, lever_height, -3.89)  # Adjust based on lever dimensions
	
	lever_activated_rotation = lever_default_rotation + Vector3(0, 0, deg_to_rad(-45))
	
func activate_lever():
	if not activated:
		activated = true
		animate_lever(lever_activated_rotation, cylinder_activated_rotation)

func deactivate_lever():
	if activated:
		activated = false
		animate_lever(lever_default_rotation, cylinder_default_rotation)

func animate_lever(target_lever_rotation: Vector3, target_cylinder_rotation: Vector3):
	var tween = create_tween()
	# Only animate the lever - cylinder will follow automatically
	tween.tween_property(lever, "rotation", target_lever_rotation, 0.5)
	tween.tween_callback(_on_lever_animation_complete).set_delay(0.5)

func _on_lever_animation_complete():
	print("Lever animation complete. Activated: ", activated)

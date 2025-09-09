class_name Cube
extends StaticBody3D

# List of Marker3D nodes
@export var markers: Array[NodePath] = []

func _ready():
	randomize()
	# Move to a random marker at start
	move_to_random_marker()

func move_to_random_marker():
	if markers.size() == 0:
		return

	# Pick a random marker
	var marker_node = get_node(markers[randi() % markers.size()]) as Marker3D
	if marker_node:
		global_transform.origin = marker_node.global_transform.origin

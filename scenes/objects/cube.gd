class_name Cube
extends StaticBody3D

# List of Marker3D nodes
@export var markers: Array[NodePath] = []

var _last_index: int = -1  # stores the last chosen marker index

func _ready():
	randomize()
	move_to_random_marker()

func move_to_random_marker():
	if markers.is_empty():
		return

	var new_index: int = _last_index
	while new_index == _last_index and markers.size() > 1:
		new_index = randi() % markers.size()

	_last_index = new_index
	var marker_node = get_node(markers[new_index]) as Marker3D
	if marker_node:
		global_transform.origin = marker_node.global_transform.origin

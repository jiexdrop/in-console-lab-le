class_name Cube
extends StaticBody3D

# List of Marker3D nodes
@export var markers: Array[NodePath] = []

var _last_index: int = -1
var tween: Tween

func _ready():
	randomize()
	move_to_random_marker()

func move_to_random_marker():
	if markers.is_empty():
		return

	# Pick a new random index that isn't the same as last time
	var new_index: int = _last_index
	while new_index == _last_index and markers.size() > 1:
		new_index = randi() % markers.size()
	_last_index = new_index

	var marker_node = get_node(markers[new_index]) as Marker3D
	if marker_node:
		var target_pos = marker_node.global_transform.origin

		# Kill old tween if still running
		if tween and tween.is_running():
			tween.kill()

		# Create new tween
		tween = get_tree().create_tween()
		tween.tween_property(self, "global_transform:origin", target_pos, 0.8) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

extends Node
var door_a : Area3D
var sunny : Sunny
var door1_target : Marker3D

func _ready() -> void:
	var level1_node = get_tree().root  # This should be Level1
	door_a = level1_node.find_child("Door_A", true, false)
	sunny = level1_node.find_child("Sunny", true, false)
	door1_target = level1_node.find_child("Door1Target", true, false)
	
## Will open the door for the player
func open_door() -> void:
	print("OPENING DOOOOOOOOOOOOOR")
	door_a.queue_free()
	
	# Tell Sunny to move to the door target
	if sunny and door1_target:
		sunny.move_to_position(door1_target.global_position)

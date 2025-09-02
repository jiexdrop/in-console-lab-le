extends Node

var door_a : Area3D

func _ready() -> void:
	var level1_node = get_tree().root  # This should be Level1
	door_a = level1_node.find_child("Door_A", true, false)

	
## Will open the door for the player
func open_door() -> void:
	print("OPENING DOOOOOOOOOOOOOR")
	door_a.queue_free()

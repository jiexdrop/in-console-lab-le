extends Node
var door_a : StaticBody3D
var sunny : Sunny
var door1_target : Marker3D
var waiting_for_sunny : bool = false

func _ready() -> void:
	var level1_node = get_tree().root  # This should be Level1
	door_a = level1_node.find_child("Door_A", true, false)
	sunny = level1_node.find_child("Sunny", true, false)
	door1_target = level1_node.find_child("Door1Target", true, false)

func _process(_delta: float) -> void:
	# Check if we're waiting for Sunny and if she's reached the destination
	if waiting_for_sunny and sunny and door1_target:
		var distance = sunny.global_position.distance_to(door1_target.global_position)
		if distance <= sunny.stop_distance * 2:
			print("Sunny reached destination - opening door!")
			door_a.queue_free()
			waiting_for_sunny = false

## Will open the door once Sunny reaches the target
func open_door() -> void:
	print("Telling Sunny to move to door target...")
	
	# Tell Sunny to move to the door target
	if sunny and door1_target:
		sunny.move_to_position(door1_target.global_position)
		waiting_for_sunny = true
	else:
		print("Could not find Sunny or Door1Target")
		

## Will follow the player
func follow_player() -> void:
	if sunny:
		sunny.start_following_player()
	else:
		print("Could not find Sunny")

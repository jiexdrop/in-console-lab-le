extends Node

var sunny : Sunny
var lever_1 : Lever
var lever_1_target : Marker3D
var door1_target : Marker3D

var waiting_for_lever : bool = false
var waiting_for_sunny : bool = false
var lever_1_state = true
var door_a : StaticBody3D

func _ready() -> void:
	var level2_node = get_tree().root  # This should be Level1
	sunny = level2_node.find_child("Sunny", true, false)
	lever_1 = level2_node.find_child("Lever", true, false)
	lever_1_target = level2_node.find_child("Lever1Target", true, false)
	door1_target = level2_node.find_child("Door1Target", true, false)
	door_a = level2_node.find_child("Door_A", true, false)

func _process(delta: float) -> void:
	# Check if we're waiting for Sunny and if she's reached the door destination
	if waiting_for_lever and sunny and lever_1_target:
		var distance = sunny.global_position.distance_to(lever_1_target.global_position)
		if distance <= sunny.stop_distance * 2:
			print("Sunny reached destination - opening door!")
			if not lever_1_state:
				lever_1.activate_lever()
			else:
				lever_1.deactivate_lever()
			waiting_for_lever = false
			
	if waiting_for_sunny and sunny and door1_target:
		var distance = sunny.global_position.distance_to(door1_target.global_position)
		if distance <= sunny.stop_distance * 2:
			if lever_1_state == false:
				print("Sunny reached destination - opening door!")
				door_a.queue_free()
			waiting_for_sunny = false

## Will activate/deactivate lever 1
func toggle_lever_1() -> void:
	print("Telling Sunny to move to bridge target...")
	
	# Tell Sunny to move to the bridge target
	if sunny and lever_1_target:
		sunny.move_to_position(lever_1_target.global_position)
		waiting_for_lever = true
		lever_1_state = not lever_1_state
	else:
		print("Could not find Sunny or Bridge1Target")
	
## Will open the door once Sunny reaches the target
func open_door() -> void:
	print("Telling Sunny to move to door target...")
	
	# Tell Sunny to move to the door target
	if sunny and door1_target:
		sunny.move_to_position(door1_target.global_position)
		waiting_for_sunny = true
	else:
		print("Could not find Sunny or Door1Target")
		

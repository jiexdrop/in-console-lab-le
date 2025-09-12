extends Node

var sunny : Sunny
var lever_1 : Lever
var lever_1_target : Marker3D
var pallet_large_8: Pallet
var pallet_large_9: Pallet

var waiting_for_lever : bool = false
var lever_1_state = true

func _ready() -> void:
	var level3_node = get_tree().root  # This should be Level1
	sunny = level3_node.find_child("Sunny", true, false)
	lever_1 = level3_node.find_child("Lever", true, false)
	lever_1_target = level3_node.find_child("Lever1Target", true, false)
	pallet_large_8 = level3_node.find_child("Pallet_Large8", true, false)
	pallet_large_9 = level3_node.find_child("Pallet_Large9", true, false)
	
	
func _process(delta: float) -> void:
	# Check if we're waiting for Sunny and if she's reached the door destination
	if waiting_for_lever and sunny and lever_1_target:
		var distance = sunny.global_position.distance_to(lever_1_target.global_position)
		if distance <= sunny.stop_distance * 2:
			print("Sunny reached destination - opening door!")
			if not lever_1_state:
				lever_1.activate_lever()
				pallet_large_8.toggle(true)
				pallet_large_9.toggle(true)
			else:
				lever_1.deactivate_lever()
				pallet_large_8.toggle(false)
				pallet_large_9.toggle(false)
			waiting_for_lever = false
	
## Will follow the player
func follow_player() -> void:
	if sunny:
		sunny.start_following_player()
	else:
		print("Could not find Sunny")

## Will stop following the player
func stop_follow_player() -> void:
	if sunny:
		sunny.stop_following_player()
	else:
		print("Could not find Sunny")

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
	

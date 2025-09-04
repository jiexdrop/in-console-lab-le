extends Node
var sunny : Sunny
var waiting_for_sunny : bool = false
var waiting_for_bridge : bool = false  
var door_a : StaticBody3D
var bridge : Bridge
var door1_target : Marker3D
var bridge1_target : Marker3D

func _ready() -> void:
	var level1_node = get_tree().root  # This should be Level1
	door_a = level1_node.find_child("Door_A", true, false)
	bridge = level1_node.find_child("Bridge", true, false)
	sunny = level1_node.find_child("Sunny", true, false)
	door1_target = level1_node.find_child("Door1Target", true, false)
	bridge1_target = level1_node.find_child("Bridge1Target", true, false)
	
	# Make sure bridge starts invisible
	if bridge:
		bridge.visible = false
		bridge.enable_collision(false)

func _process(delta: float) -> void:
	# Check if we're waiting for Sunny and if she's reached the door destination
	if waiting_for_sunny and sunny and door1_target:
		var distance = sunny.global_position.distance_to(door1_target.global_position)
		if distance <= sunny.stop_distance * 2:
			print("Sunny reached destination - opening door!")
			door_a.queue_free()
			waiting_for_sunny = false
	
	# Check if we're waiting for Sunny and if she's reached the bridge destination
	if waiting_for_bridge and sunny and bridge1_target:
		var distance = sunny.global_position.distance_to(bridge1_target.global_position)
		if distance <= sunny.stop_distance * 2:
			print("Sunny reached bridge destination - creating bridge!")
			bridge.visible = true
			bridge.enable_collision(true)
			waiting_for_bridge = false

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
		
## Will create a bridge for the player to go to next stage
func create_bridge() -> void:
	print("Telling Sunny to move to bridge target...")
	
	# Tell Sunny to move to the bridge target
	if sunny and bridge1_target:
		sunny.move_to_position(bridge1_target.global_position)
		waiting_for_bridge = true
	else:
		print("Could not find Sunny or Bridge1Target")

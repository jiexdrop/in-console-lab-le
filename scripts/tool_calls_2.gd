extends Node

var sunny : Sunny
var lever_1 : Lever
var lever_1_target : Marker3D
var door1_target : Marker3D
var end_goal_target : Marker3D

var waiting_for_lever : bool = false
var waiting_for_sunny : bool = false
var waiting_for_end_goal : bool = false  

var lever_1_state = true
var door_a : StaticBody3D
var player_2ainpc: Player2AINPC 

var big_cube_1 : Cube
var big_cube_2 : Cube
var big_cube_3 : Cube

func _ready() -> void:
	var level2_node = get_tree().root  # This should be Level1
	sunny = level2_node.find_child("Sunny", true, false)
	player_2ainpc = sunny.find_child("Player2AINPC", true, false)
	door1_target = level2_node.find_child("Door1Target", true, false)
	end_goal_target = level2_node.find_child("EndGoalTarget", true, false)
	door_a = level2_node.find_child("Door_A", true, false)
	big_cube_1 = level2_node.find_child("BigCube", true, false)
	big_cube_2 = level2_node.find_child("BigCube2", true, false)
	big_cube_3 = level2_node.find_child("BigCube3", true, false)


func _process(delta: float) -> void:
	if waiting_for_sunny and sunny and door1_target:
		var distance = sunny.global_position.distance_to(door1_target.global_position)
		if distance <= sunny.stop_distance * 2:
			if lever_1_state == false:
				print("Sunny reached destination - opening door!")
				door_a.queue_free()
			waiting_for_sunny = false
			
			
	if waiting_for_end_goal and sunny and end_goal_target:
		var distance = sunny.global_position.distance_to(end_goal_target.global_position)
		if distance <= sunny.stop_distance * 2:
			print("Sunny reached end_goal destination!")
			waiting_for_end_goal = false

	
## Will open the door once Sunny reaches the target
func open_door() -> void:
	if lever_1_state:
		player_2ainpc.notify("The player tried to open a locked door. It failed.")
		return
	
	print("Telling Sunny to move to door target...")
	
	# Tell Sunny to move to the door target
	if sunny and door1_target:
		sunny.move_to_position(door1_target.global_position)
		waiting_for_sunny = true
	else:
		print("Could not find Sunny or Door1Target")
	
## Will move big_cube_1
func move_big_cube_1():
	big_cube_1.move_to_random_marker()
	
## Will move big_cube_2
func move_big_cube_2():
	big_cube_2.move_to_random_marker()
	
## Will move big_cube_3
func move_big_cube_3():
	big_cube_3.move_to_random_marker()
	
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

## Sunny will be placed in the end goal platform to upload to next level
func follow_me_to_the_end() -> void:
	print("Telling Sunny to move to goal target...")
	
	# Tell Sunny to move to the bridge target
	if sunny and end_goal_target:
		sunny.move_to_position(end_goal_target.global_position)
		waiting_for_end_goal = true
	else:
		print("Could not find Sunny or end_goal_target")

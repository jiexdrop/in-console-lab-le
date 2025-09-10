extends Node

var sunny : Sunny

func _ready() -> void:
	var level3_node = get_tree().root  # This should be Level1
	sunny = level3_node.find_child("Sunny", true, false)
	
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

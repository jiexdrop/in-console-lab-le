extends Area3D

@export var sunny : Sunny
var player_2ainpc: Player2AINPC 

func _ready() -> void:
	player_2ainpc = sunny.find_child("Player2AINPC", true, false)
	

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_2ainpc.notify("Tell the player he now has to pick the right combination of levers.")

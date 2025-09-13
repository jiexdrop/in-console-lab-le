class_name GoalForSunny
extends Area3D

@export var scene_goal: Area3D 
var collision : CollisionShape3D

func _ready() -> void:
	print("Disabling collision for Scene Goal!")
	collision = scene_goal.get_node("CollisionShape3D")
	collision.set_deferred("disabled", true)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("Sunny"):
		print("Enabling collision for Scene Goal to end level!")
		collision.set_deferred("disabled", false)


func _on_body_exited(body: Node3D) -> void:
	if body.is_in_group("Sunny"):
		print("Disabling collision for Scene Goal!")
		collision.set_deferred("disabled", true)

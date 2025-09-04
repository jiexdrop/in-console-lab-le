class_name Bridge
extends Node3D

@onready var floor_11: StaticBody3D = $Floor11
@onready var floor_12: StaticBody3D = $Floor12

func enable_collision(value: bool) -> void:
	floor_11.get_node("CollisionShape3D").disabled = not value
	floor_12.get_node("CollisionShape3D").disabled = not value

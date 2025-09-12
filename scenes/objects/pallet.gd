class_name Pallet
extends StaticBody3D

@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

func toggle(value : bool):
	visible = value
	collision_shape_3d.disabled = not value

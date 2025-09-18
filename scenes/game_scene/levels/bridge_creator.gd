extends Node3D

@export var sunny : Sunny
@onready var lever: Lever = $"../Levers/Lever"
@onready var pallet_large_8: Pallet = $"../Pallets/Pallet_Large8"
@onready var pallet_large_9: Pallet = $"../Pallets/Pallet_Large9"
var player_2ainpc: Player2AINPC 

func _ready() -> void:
	lever.on_activated.connect(_activated_lever)
	lever.on_deactivated.connect(_deactivated_lever)
	player_2ainpc = sunny.find_child("Player2AINPC", true, false)
	
func _activated_lever():
	pallet_large_8.toggle(true)
	pallet_large_9.toggle(true)

func _deactivated_lever():
	pallet_large_8.toggle(false)
	pallet_large_9.toggle(false)

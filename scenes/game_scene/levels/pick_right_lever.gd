extends Area3D

@export var sunny : Sunny
var player_2ainpc: Player2AINPC 
@onready var lever_3: Lever = $"../Levers/Lever3"
@onready var lever_4: Lever = $"../Levers/Lever4"
@onready var lever_5: Lever = $"../Levers/Lever5"
@onready var lever_6: Lever = $"../Levers/Lever6"

@onready var pallet_smal_decorated_2: StaticBody3D = $"../PalletSmalDecorated2"

func _ready() -> void:
	player_2ainpc = sunny.find_child("Player2AINPC", true, false)
	for lever in [lever_3, lever_4, lever_5, lever_6]:
		lever.on_activated.connect(_validate_levers)
		lever.on_deactivated.connect(_validate_levers)

func _validate_levers() -> void:
	if lever_3.activated and not lever_4.activated and lever_5.activated \
		and not lever_6.activated:
		player_2ainpc.notify("Tell the player he has the correct combination")
		_move_pallet()

func _move_pallet() -> void:
	# Create a tween and move pallet 3 units up over 1 second
	var tween := create_tween()
	var target_pos := pallet_smal_decorated_2.position + Vector3(0, 0, -3)
	tween.tween_property(
		pallet_smal_decorated_2, "position", target_pos, 1.0
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		player_2ainpc.notify("Tell the player he now has to pick the right combination of levers.")

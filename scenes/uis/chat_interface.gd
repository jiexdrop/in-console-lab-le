extends Control

@onready var animation_player = $AnimationPlayer
@onready var chat_input = $ChatPanel/VBoxContainer/HBoxContainer/ChatInput

func _ready() -> void:
	hide_chat()

func show_chat():
	visible = true
	animation_player.play("slide_up")
	chat_input.grab_focus()

func hide_chat():
	animation_player.play("slide_down")
	await animation_player.animation_finished
	visible = false

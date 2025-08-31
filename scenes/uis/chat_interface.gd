extends Control

@onready var animation_player = $AnimationPlayer
@onready var chat_input = $ChatPanel/VBoxContainer/HBoxContainer/ChatInput
@onready var send_button = $ChatPanel/VBoxContainer/HBoxContainer/SendButton
@onready var chat_history = $ChatPanel/VBoxContainer/ChatHistory

@export var deselect_on_send : bool = true
@export var player2_agent : Node  # Assign your Player2Agent in the inspector

signal text_sent(text: String)

func _ready() -> void:
	hide_chat()
	send_button.pressed.connect(send)
	
	# Make enter key send message
	chat_input.gui_input.connect(
		func(event: InputEvent):
			if event is InputEventKey and event.pressed and event.keycode == KEY_ENTER:
				chat_input.accept_event()
				send()
	)
	
	# Connect to Player2Agent if assigned
	if player2_agent:
		text_sent.connect(player2_agent.chat)
		player2_agent.chat_received.connect(append_line_agent)

func show_chat():
	visible = true
	animation_player.play("slide_up")
	chat_input.grab_focus()

func hide_chat():
	animation_player.play("slide_down")
	await animation_player.animation_finished
	visible = false

func send() -> void:
	_send(chat_input.text)

func _send(text: String) -> void:
	if text.strip_edges() == "":
		return
		
	append_line_user(text)
	text_sent.emit(text)
	chat_input.text = ""
	
	if deselect_on_send:
		chat_input.release_focus()

func append_line_user(line: String) -> void:
	print("got user: " + line)
	chat_history.text += "User: " + line + "\n"

func append_line_agent(line: String) -> void:
	print("got agent: " + line)
	chat_history.text += "Agent: " + line + "\n"

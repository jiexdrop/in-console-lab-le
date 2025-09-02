extends Control
@onready var animation_player = $AnimationPlayer
@onready var chat_input = $ChatPanel/VBoxContainer/HBoxContainer/ChatInput
@onready var send_button = $ChatPanel/VBoxContainer/HBoxContainer/SendButton
@onready var chat_history = $ChatPanel/VBoxContainer/ChatHistory
@export var deselect_on_send : bool = true
@export var player2_agent : Player2AINPC  # Assign your Player2Agent in the inspector

signal text_sent(text: String)
signal chat_closed()  # New signal to notify when chat closes

var is_chat_open: bool = false

func _ready() -> void:
	hide_chat()
	send_button.pressed.connect(send)
	
	# Make enter key send message and escape key close chat
	chat_input.gui_input.connect(_on_chat_input_gui_input)
	
	# Connect to Player2Agent if assigned
	if player2_agent:
		text_sent.connect(player2_agent.chat)
		player2_agent.chat_received.connect(append_line_agent)


func _on_chat_input_gui_input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER:
			chat_input.accept_event()
			send()
		elif event.keycode == KEY_ESCAPE:
			chat_input.accept_event()
			hide_chat()

# Also handle escape when chat is open but input doesn't have focus
func _unhandled_key_input(event: InputEvent):
	if is_chat_open and event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		hide_chat()

func show_chat():
	visible = true
	is_chat_open = true
	animation_player.play("slide_up")
	chat_input.grab_focus()
	

func hide_chat():
	is_chat_open = false
	animation_player.play("slide_down")
	await animation_player.animation_finished
	visible = false
	
	# Emit signal so NPC can handle state change
	chat_closed.emit()

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

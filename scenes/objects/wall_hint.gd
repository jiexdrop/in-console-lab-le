extends Area3D

@onready var interaction_label = $UI/Panel
@onready var mesh_instance: MeshInstance3D = $Target/target_wall_small

var is_player_nearby = false
var hint_text = "This is your hint text when pressing E!"

# For outline shader
var outline_material: ShaderMaterial
var original_material: Material

func _ready():
	# Connect area signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Hide interaction label initially
	interaction_label.visible = false
	
	# Setup outline shader
	setup_outline_shader()
	
	# Store original material (if any)
	if mesh_instance.material_override:
		original_material = mesh_instance.material_override

func _on_body_entered(body):
	if body.is_in_group("player"):
		is_player_nearby = true
		interaction_label.visible = true
		# Enable outline using material_overlay
		mesh_instance.material_overlay = outline_material

func _on_body_exited(body):
	if body.is_in_group("player"):
		is_player_nearby = false
		interaction_label.visible = false
		# Disable outline
		mesh_instance.material_overlay = null

func setup_outline_shader():
	outline_material = ShaderMaterial.new()
	var shader = load("res://resources/shader/outline_shader.gdshader")
	outline_material.shader = shader
	outline_material.set_shader_parameter("outline_color", Color(1.0, 0.8, 0.2, 1.0))
	outline_material.set_shader_parameter("outline_width", 0.02)

# res://scripts/mtoon_auto_apply.gd
extends Node

@export var base_mtoon: ShaderMaterial   # assign your blank MToon ShaderMaterial (using mtoon.gdshader)
const MTOON_SHADER_MATERIAL = preload("res://resources/mtoon_shader_material.tres")

func _ready() -> void:
	base_mtoon = MTOON_SHADER_MATERIAL
	if base_mtoon == null:
		push_warning("MToonApplier: 'base_mtoon' is not assigned.")
		return

	# Apply to the current scene
	var current: Node = get_tree().current_scene
	if current != null:
		_apply_to_branch(current)

	# Apply to anything added later (spawned, instanced scenes, etc.)
	get_tree().node_added.connect(_on_node_added)


func _on_node_added(node: Node) -> void:
	_apply_to_branch(node)


func _apply_to_branch(node: Node) -> void:
	if node is MeshInstance3D:
		_convert_mesh_instance(node as MeshInstance3D)
	for child in node.get_children():
		_apply_to_branch(child)


func _convert_mesh_instance(mi: MeshInstance3D) -> void:
	var mesh: Mesh = mi.mesh
	if mesh == null:
		return

	var surf_count: int = mesh.get_surface_count()
	for i in range(surf_count):
		# Prefer override material; fall back to mesh surface material
		var mat: Material = mi.get_surface_override_material(i)
		if mat == null:
			mat = mesh.surface_get_material(i)
		if mat == null:
			continue

		# Skip if it's already an MToon ShaderMaterial
		if mat is ShaderMaterial:
			var sm: ShaderMaterial = mat as ShaderMaterial
			var shader_path: String = sm.shader.resource_path if sm.shader != null else ""
			if shader_path.find("mtoon") != -1:
				continue

		# Convert StandardMaterial3D -> MToon
		if mat is StandardMaterial3D:
			var std: StandardMaterial3D = mat as StandardMaterial3D
			var new_mat: ShaderMaterial = base_mtoon.duplicate() as ShaderMaterial

			# Albedo / base color
			var albedo_tex: Texture2D = std.albedo_texture
			if albedo_tex != null:
				new_mat.set_shader_parameter("_MainTex", albedo_tex)
			var albedo_col: Color = std.albedo_color
			new_mat.set_shader_parameter("_Color", albedo_col)

			# Normal map
			var ntex: Texture2D = std.normal_texture
			if ntex != null:
				new_mat.set_shader_parameter("_BumpMap", ntex)
				new_mat.set_shader_parameter("_BumpScale", std.normal_scale)

			# Emission
			var etex: Texture2D = std.emission_texture
			if etex != null:
				new_mat.set_shader_parameter("_EmissionMap", etex)
			var ecolor: Color = std.emission
			if ecolor != Color(0, 0, 0, 1):
				new_mat.set_shader_parameter("_EmissionColor", ecolor)

			mi.set_surface_override_material(i, new_mat)

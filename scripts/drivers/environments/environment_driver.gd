@tool
class_name EnvironmentDriver
extends Node3D

@export var current_preset: EnvironmentPresetData:
	set(value):
		current_preset = value
		apply_preset(current_preset)

func _ready() -> void:
	if not Engine.is_editor_hint():
		var env_service := get_node_or_null("/root/EnvironmentService")
		if env_service:
			env_service.register_driver(self)
	apply_preset(current_preset)

func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		var env_service := get_node_or_null("/root/EnvironmentService")
		if env_service:
			env_service.unregister_driver(self)

func apply_preset(preset: EnvironmentPresetData) -> void:
	if preset == null:
		return

	var world_environment := get_node_or_null("WorldEnvironment") as WorldEnvironment
	var sun := get_node_or_null("Sun") as DirectionalLight3D
	var lighting_night := get_node_or_null("LightingNight") as Node3D
	if world_environment == null or sun == null:
		return

	world_environment.environment = preset.environment
	sun.rotation_degrees = preset.sun_rotation_degrees
	sun.light_color = preset.sun_color
	sun.light_energy = preset.sun_energy
	sun.visible = preset.sun_visible

	if lighting_night:
		lighting_night.visible = preset.street_lights_visible

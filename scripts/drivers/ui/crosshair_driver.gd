class_name CrosshairDriver
extends Control

@export var idle_radius: float = 3.0
@export var hover_radius: float = 6.0

var is_hovering: bool = false

func _draw() -> void:
	var radius := hover_radius if is_hovering else idle_radius
	var alpha := 1.0 if is_hovering else 0.75
	draw_circle(size / 2.0, radius, Color(1, 1, 1, alpha))

func set_hovering(value: bool) -> void:
	if value == is_hovering:
		return
	is_hovering = value
	queue_redraw()

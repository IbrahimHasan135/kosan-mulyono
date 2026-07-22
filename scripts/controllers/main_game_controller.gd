extends Node

func _ready() -> void:
	print("MainGameController: Foundation OK")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

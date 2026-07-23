extends Node

func _ready() -> void:
	print("MainGameController: Foundation OK")
	#EnvironmentService.set_time_of_day("sore_maghrib")
	#EnvironmentService.set_time_of_day("siang")
	EnvironmentService.set_time_of_day("malam")
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

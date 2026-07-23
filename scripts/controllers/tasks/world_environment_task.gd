class_name WorldEnvironmentTask
extends Node

var story_task: StoryTask # di-inject MainGameController (query, buat nentuin preset sesuai flag/chapter nanti)

func _ready() -> void:
	set_time_of_day("siang")
	#set_time_of_day("sore_maghrib")
	#set_time_of_day("malam")

func set_time_of_day(preset_name: String) -> void:
	EnvironmentService.set_time_of_day(preset_name)

func on_flag_changed(_flag_name: String, _value: bool) -> void:
	pass # mapping flag cerita -> preset waktu (mis. "malam_tiba" -> set_time_of_day("malam")), diisi pas Fitur 08

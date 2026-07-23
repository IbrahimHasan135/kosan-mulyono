class_name HUDTask
extends Node

var story_task: StoryTask # di-inject MainGameController (query)

func on_flag_changed(_flag_name: String, _value: bool) -> void:
	pass # update teks objective/skor evidence via HUDService, diisi pas Fitur 10

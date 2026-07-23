class_name SaveTask
extends Node

const SAVE_PATH := "user://savegame.json"

var story_task: StoryTask # di-inject MainGameController
var dialogue_task: DialogueTask # di-inject MainGameController

func get_save_data() -> Dictionary:
	return {
		"story": story_task.get_save_data(),
		"dialogue": dialogue_task.get_save_data(),
	}

func load_save_data(data: Dictionary) -> void:
	story_task.load_save_data(data.get("story", {}))
	dialogue_task.load_save_data(data.get("dialogue", {}))

func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(get_save_data()))
	file.close()

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	file.close()
	load_save_data(data)

extends Node

var _dialogue_box: DialogueBoxDriver = null

func register_dialogue_box(driver: DialogueBoxDriver) -> void:
	_dialogue_box = driver

func unregister_dialogue_box(driver: DialogueBoxDriver) -> void:
	if _dialogue_box == driver:
		_dialogue_box = null

func get_dialogue_box() -> DialogueBoxDriver:
	return _dialogue_box

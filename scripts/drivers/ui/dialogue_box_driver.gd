class_name DialogueBoxDriver
extends Control

@onready var speaker_label: Label = $Panel/SpeakerName
@onready var text_label: Label = $Panel/DialogueText

func _ready() -> void:
	visible = false
	DialogueService.register_dialogue_box(self)

func _exit_tree() -> void:
	DialogueService.unregister_dialogue_box(self)

func show_line(speaker_name: String, text: String) -> void:
	speaker_label.text = speaker_name
	text_label.text = text
	visible = true

func hide_box() -> void:
	visible = false

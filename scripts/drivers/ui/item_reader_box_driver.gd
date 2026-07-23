class_name ItemReaderBoxDriver
extends Control

@onready var name_label: Label = $Panel/ItemName
@onready var text_label: RichTextLabel = $Panel/ReadText

func _ready() -> void:
	visible = false
	ItemReaderService.register_reader_box(self)

func _exit_tree() -> void:
	ItemReaderService.unregister_reader_box(self)

func show_text(item_name: String, text: String) -> void:
	name_label.text = item_name
	text_label.text = text
	visible = true

func hide_box() -> void:
	visible = false

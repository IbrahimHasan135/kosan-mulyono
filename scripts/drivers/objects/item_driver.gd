class_name ItemDriver
extends InteractableDriver

signal interacted(item_id: String)

@export var item_id: String = "item_dummy_01"

func _ready() -> void:
	ItemService.register_item(item_id, self)

func _exit_tree() -> void:
	ItemService.unregister_item(item_id)

func interact() -> void:
	# BUKAN mutusin sendiri (misal queue_free) — itu keputusan bisnis InteractionTask.
	# ItemService relay ke atas, InteractionTask yang mutusin konsekuensinya (lihat Engine_Design.md §3.C).
	interacted.emit(item_id)

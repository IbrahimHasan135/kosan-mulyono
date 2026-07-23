class_name InteractionTask
extends Node

signal item_collected(item_id: String)
signal door_unlocked(door_id: String)

var story_task: StoryTask # di-inject MainGameController (query sinkron)

func _ready() -> void:
	ItemService.item_interacted.connect(_on_item_interacted)
	# DoorService belum ada sampai Fitur 06 — sambungin _on_door_interacted() pas itu udah dibangun.

func _on_item_interacted(item_id: String) -> void:
	print("[InteractionTask] item %s diambil" % item_id)
	item_collected.emit(item_id)
	ItemService.set_item_visible(item_id, false)

func _on_door_interacted(door_id: String) -> void:
	# Placeholder — diisi pas DoorService/DoorDriver ada (Fitur 06).
	# Pola: cek door.is_locked, query story_task.has_evidence(door.key_id_required),
	# baru DoorService.unlock_door(door_id) kalau punya kunci.
	pass

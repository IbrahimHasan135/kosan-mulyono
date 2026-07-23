class_name InteractionTask
extends Node

signal item_collected(item_id: String)
signal door_unlocked(door_id: String)

var story_task: StoryTask # di-inject MainGameController (query sinkron)

var _reading_item_id: String = ""

func _ready() -> void:
	ItemService.item_interacted.connect(_on_item_interacted)
	# DoorService belum ada sampai Fitur 06 — sambungin _on_door_interacted() pas itu udah dibangun.

func _unhandled_input(event: InputEvent) -> void:
	if _reading_item_id == "":
		return
	if event.is_action_pressed("dialogue_next"):
		_finish_reading()

func _on_item_interacted(item_id: String) -> void:
	if _reading_item_id != "":
		return # lagi baca sesuatu, abaikan interaksi lain

	var item := ItemService.get_item(item_id)
	if item == null or item.item_data == null:
		return

	var data: ItemData = item.item_data

	if data.is_readable:
		_reading_item_id = item_id
		var player := PlayerService.get_player()
		if player:
			player.set_movement_locked(true)
		InteractionService.set_crosshair_visible(false)
		var reader := ItemReaderService.get_reader_box()
		if reader:
			reader.show_text(data.item_name, data.read_text)
	else:
		_resolve_item(item_id, data)

func _finish_reading() -> void:
	var item_id := _reading_item_id
	_reading_item_id = ""

	var reader := ItemReaderService.get_reader_box()
	if reader:
		reader.hide_box()

	var player := PlayerService.get_player()
	if player:
		player.set_movement_locked(false)
	InteractionService.set_crosshair_visible(true)

	var item := ItemService.get_item(item_id)
	if item and item.item_data:
		_resolve_item(item_id, item.item_data)

func _resolve_item(item_id: String, data: ItemData) -> void:
	if data.is_evidence or data.is_key:
		item_collected.emit(item_id)

	if data.equipment_grant != "":
		_grant_equipment(data.equipment_grant)

	if data.is_pickupable:
		ItemService.remove_item(item_id) # beneran hapus, bukan cuma hide — collision ikut mati
	# kalau is_pickupable == false (mis. coretan tembok), item TETAP di dunia, bisa diinteraksi lagi

func _grant_equipment(equipment_grant: String) -> void:
	var player := PlayerService.get_player()
	if player == null:
		return
	match equipment_grant:
		"flashlight":
			player.grant_flashlight()

func _on_door_interacted(door_id: String) -> void:
	# Placeholder — diisi pas DoorService/DoorDriver ada (Fitur 06).
	# Pola: cek door.is_locked, query story_task.has_evidence(door.key_id_required),
	# baru DoorService.unlock_door(door_id) kalau punya kunci.
	pass

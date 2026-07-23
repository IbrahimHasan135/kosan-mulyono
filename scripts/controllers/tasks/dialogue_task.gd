class_name DialogueTask
extends Node

signal dialogue_finished(npc_id: String)

var yono_interaction_count: int = 0
var _current_npc_id: String = ""
var _current_data: DialogueData = null
var _current_line_index: int = 0

func _ready() -> void:
	NPCService.npc_interacted.connect(_on_npc_interacted)

func _unhandled_input(event: InputEvent) -> void:
	if _current_data == null:
		return
	if event.is_action_pressed("dialogue_next"):
		_advance()

func _on_npc_interacted(npc_id: String) -> void:
	if _current_data != null:
		return # udah lagi ngobrol — interact diabaikan, lanjut baris pakai dialogue_next

	var npc := NPCService.get_npc(npc_id)
	if npc == null or npc.dialogue_data == null or npc.dialogue_data.lines.is_empty():
		return

	_current_npc_id = npc_id
	_current_data = npc.dialogue_data
	_current_line_index = 0

	if npc_id == "npc_yono":
		yono_interaction_count += 1

	var player := PlayerService.get_player()
	if player:
		player.set_movement_locked(true)
	InteractionService.set_crosshair_visible(false)

	_show_current_line()

func _advance() -> void:
	_current_line_index += 1
	if _current_line_index >= _current_data.lines.size():
		_end_dialogue()
	else:
		_show_current_line()

func _show_current_line() -> void:
	var line: DialogueLine = _current_data.lines[_current_line_index]
	var player := PlayerService.get_player()

	if line.speaker_id != "player":
		var speaker_npc := NPCService.get_npc(line.speaker_id)
		if speaker_npc and player:
			speaker_npc.look_at_player(player.get_camera_global_position())
			player.set_look_target(speaker_npc.global_position)

	var dialogue_box := DialogueService.get_dialogue_box()
	if dialogue_box:
		dialogue_box.show_line(line.speaker_display_name, line.text)

func _end_dialogue() -> void:
	var dialogue_box := DialogueService.get_dialogue_box()
	if dialogue_box:
		dialogue_box.hide_box()

	var player := PlayerService.get_player()
	if player:
		player.set_movement_locked(false)
		player.clear_look_target()
	InteractionService.set_crosshair_visible(true)

	var finished_npc_id := _current_npc_id
	_current_npc_id = ""
	_current_data = null
	dialogue_finished.emit(finished_npc_id)

func get_save_data() -> Dictionary:
	return {"yono_interaction_count": yono_interaction_count}

func load_save_data(data: Dictionary) -> void:
	yono_interaction_count = data.get("yono_interaction_count", 0)

class_name StoryTask
extends Node

signal flag_changed(flag_name: String, value: bool)

var current_chapter: String = "Prologue"
var story_flags: Dictionary = {}
var evidence_score: int = 0
var collected_evidence: Array[String] = []
var truth_unlocked: bool = false

func set_chapter(chapter_name: String) -> void:
	current_chapter = chapter_name

func set_flag(flag_name: String, value: bool) -> void:
	story_flags[flag_name] = value
	flag_changed.emit(flag_name, value)
	_apply_checkpoint_effect(flag_name, value)

func check_flag(flag_name: String) -> bool:
	return story_flags.get(flag_name, false)

func has_evidence(item_id: String) -> bool:
	return item_id in collected_evidence

func on_item_collected(item_id: String) -> void:
	if item_id in collected_evidence:
		return
	collected_evidence.append(item_id)
	evidence_score += 1

func on_door_unlocked(door_id: String) -> void:
	set_flag("door_%s_unlocked" % door_id, true)

func on_dialogue_finished(_npc_id: String) -> void:
	pass # cek syarat ending, dll. — diisi pas Fitur 08/14

func _apply_checkpoint_effect(_flag_name: String, _value: bool) -> void:
	pass # mapping flag -> efek dunia (move_npc, spawn_item, dst.) — diisi pas Fitur 08

func get_save_data() -> Dictionary:
	return {
		"chapter": current_chapter,
		"flags": story_flags,
		"evidence": collected_evidence,
		"evidence_score": evidence_score,
		"truth_unlocked": truth_unlocked,
	}

func load_save_data(data: Dictionary) -> void:
	current_chapter = data.get("chapter", "Prologue")
	story_flags = data.get("flags", {})
	collected_evidence = data.get("evidence", [])
	evidence_score = data.get("evidence_score", 0)
	truth_unlocked = data.get("truth_unlocked", false)

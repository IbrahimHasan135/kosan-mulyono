extends Node

signal npc_interacted(npc_id: String) # relay — Task subscribe ke sini, bukan ke Driver satu-satu

var _npcs: Dictionary = {} # npc_id (String) -> NPCDriver

func register_npc(npc_id: String, driver: NPCDriver) -> void:
	_npcs[npc_id] = driver
	driver.interacted.connect(_on_npc_interacted)

func unregister_npc(npc_id: String) -> void:
	if _npcs.has(npc_id):
		_npcs[npc_id].interacted.disconnect(_on_npc_interacted)
	_npcs.erase(npc_id)

func get_npc(npc_id: String) -> NPCDriver:
	return _npcs.get(npc_id, null)

func move_npc(npc_id: String, target: Vector3) -> void:
	if _npcs.has(npc_id):
		_npcs[npc_id].move_to(target)

func _on_npc_interacted(npc_id: String) -> void:
	npc_interacted.emit(npc_id)

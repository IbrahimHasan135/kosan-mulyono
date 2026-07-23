extends Node

var _npcs: Dictionary = {} # npc_id (String) -> NPCDriver

func register_npc(npc_id: String, driver: NPCDriver) -> void:
	_npcs[npc_id] = driver

func unregister_npc(npc_id: String) -> void:
	_npcs.erase(npc_id)

func get_npc(npc_id: String) -> NPCDriver:
	return _npcs.get(npc_id, null)

func move_npc(npc_id: String, target: Vector3) -> void:
	if _npcs.has(npc_id):
		_npcs[npc_id].move_to(target)

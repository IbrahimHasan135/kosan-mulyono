class_name NPCDriver
extends InteractableDriver

signal interacted(npc_id: String)

@export var npc_id: String = "npc_dummy_01"
@export var dialogue_data: DialogueData

func _ready() -> void:
	NPCService.register_npc(npc_id, self)

func _exit_tree() -> void:
	NPCService.unregister_npc(npc_id)

func move_to(target: Vector3) -> void:
	global_position = target

func look_at_player(player_pos: Vector3) -> void:
	look_at(Vector3(player_pos.x, global_position.y, player_pos.z), Vector3.UP)

func interact() -> void:
	# BUKAN manggil Service/Task buat keputusan bisnis — cuma lapor lewat Signal.
	# NPCService relay ke atas, DialogueTask yang dengerin & mutusin (lihat Engine_Design.md §3.C).
	interacted.emit(npc_id)

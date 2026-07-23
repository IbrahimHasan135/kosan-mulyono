class_name NPCDriver
extends InteractableDriver

@export var npc_id: String = "npc_dummy_01"

func _ready() -> void:
	NPCService.register_npc(npc_id, self)

func _exit_tree() -> void:
	NPCService.unregister_npc(npc_id)

func move_to(target: Vector3) -> void:
	global_position = target

func interact() -> void:
	print("[NPC] %s diajak bicara (dummy — dialog asli nunggu Fitur 04)" % npc_id)

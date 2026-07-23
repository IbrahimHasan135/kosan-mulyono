class_name ItemDriver
extends InteractableDriver

@export var item_id: String = "item_dummy_01"

func _ready() -> void:
	ItemService.register_item(item_id, self)

func _exit_tree() -> void:
	ItemService.unregister_item(item_id)

func interact() -> void:
	print("[Item] %s diambil (dummy — evidence asli nunggu Fitur 05)" % item_id)
	queue_free()

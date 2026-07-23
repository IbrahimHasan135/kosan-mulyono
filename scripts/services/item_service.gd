extends Node

var _items: Dictionary = {} # item_id (String) -> ItemDriver

func register_item(item_id: String, driver: ItemDriver) -> void:
	_items[item_id] = driver

func unregister_item(item_id: String) -> void:
	_items.erase(item_id)

func get_item(item_id: String) -> ItemDriver:
	return _items.get(item_id, null)

func move_item(item_id: String, target: Vector3) -> void:
	if _items.has(item_id):
		_items[item_id].global_position = target

func set_item_visible(item_id: String, is_visible: bool) -> void:
	if _items.has(item_id):
		_items[item_id].visible = is_visible

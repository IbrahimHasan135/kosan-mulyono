extends Node

signal item_interacted(item_id: String) # relay — Task subscribe ke sini, bukan ke Driver satu-satu

var _items: Dictionary = {} # item_id (String) -> ItemDriver

func register_item(item_id: String, driver: ItemDriver) -> void:
	_items[item_id] = driver
	driver.interacted.connect(_on_item_interacted)

func unregister_item(item_id: String) -> void:
	if _items.has(item_id):
		_items[item_id].interacted.disconnect(_on_item_interacted)
	_items.erase(item_id)

func get_item(item_id: String) -> ItemDriver:
	return _items.get(item_id, null)

func move_item(item_id: String, target: Vector3) -> void:
	if _items.has(item_id):
		_items[item_id].global_position = target

func set_item_visible(item_id: String, is_visible: bool) -> void:
	if _items.has(item_id):
		_items[item_id].visible = is_visible

func _on_item_interacted(item_id: String) -> void:
	item_interacted.emit(item_id)

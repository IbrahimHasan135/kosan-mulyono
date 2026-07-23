extends Node

var _reader_box: ItemReaderBoxDriver = null

func register_reader_box(driver: ItemReaderBoxDriver) -> void:
	_reader_box = driver

func unregister_reader_box(driver: ItemReaderBoxDriver) -> void:
	if _reader_box == driver:
		_reader_box = null

func get_reader_box() -> ItemReaderBoxDriver:
	return _reader_box

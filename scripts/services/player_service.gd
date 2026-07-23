extends Node

var _player: PlayerMovementDriver = null

func register_player(driver: PlayerMovementDriver) -> void:
	_player = driver

func unregister_player(driver: PlayerMovementDriver) -> void:
	if _player == driver:
		_player = null

func get_player() -> PlayerMovementDriver:
	return _player

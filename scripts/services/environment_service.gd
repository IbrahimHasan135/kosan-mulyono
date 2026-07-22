extends Node

const PRESETS := {
	"siang": preload("res://resources/environment/siang.tres"),
	"sore_maghrib": preload("res://resources/environment/sore_maghrib.tres"),
	"malam": preload("res://resources/environment/malam.tres"),
}

var _driver: EnvironmentDriver = null

func register_driver(driver: EnvironmentDriver) -> void:
	_driver = driver

func unregister_driver(driver: EnvironmentDriver) -> void:
	if _driver == driver:
		_driver = null

func set_time_of_day(preset_name: String) -> void:
	if _driver == null or not PRESETS.has(preset_name):
		return
	_driver.apply_preset(PRESETS[preset_name])

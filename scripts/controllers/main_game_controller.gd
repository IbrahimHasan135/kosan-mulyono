extends Node

@onready var story_task: StoryTask = $Tasks/StoryTask
@onready var dialogue_task: DialogueTask = $Tasks/DialogueTask
@onready var interaction_task: InteractionTask = $Tasks/InteractionTask
@onready var world_environment_task: WorldEnvironmentTask = $Tasks/WorldEnvironmentTask
@onready var hud_task: HUDTask = $Tasks/HUDTask
@onready var save_task: SaveTask = $Tasks/SaveTask

func _ready() -> void:
	_wire_tasks()

	print("MainGameController: Foundation OK")
	story_task.set_chapter("Prologue")

func _wire_tasks() -> void:
	# Query sinkron: siapa butuh nanya StoryTask langsung
	interaction_task.story_task = story_task
	world_environment_task.story_task = story_task
	hud_task.story_task = story_task
	save_task.story_task = story_task
	save_task.dialogue_task = dialogue_task

	# Notifikasi: StoryTask bereaksi ke kejadian dari Task lain
	dialogue_task.dialogue_finished.connect(story_task.on_dialogue_finished)
	interaction_task.item_collected.connect(story_task.on_item_collected)
	interaction_task.door_unlocked.connect(story_task.on_door_unlocked)

	# Task lain yang dengerin perubahan flag/chapter dari StoryTask
	story_task.flag_changed.connect(world_environment_task.on_flag_changed)
	story_task.flag_changed.connect(hud_task.on_flag_changed)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()

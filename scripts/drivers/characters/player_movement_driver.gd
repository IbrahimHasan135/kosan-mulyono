class_name PlayerMovementDriver
extends CharacterBody3D

@export var speed: float = 4.0
@export var sprint_speed: float = 7.0
@export var mouse_sensitivity: float = 0.003
@export var pitch_limit_deg: float = 80.0
@export var bob_frequency: float = 10.0
@export var bob_amplitude: float = 0.045
@export var look_turn_speed: float = 4.0

@onready var head: Node3D = $Head
@onready var flashlight: SpotLight3D = $Head/Camera3D/FlashLight
@onready var camera: Camera3D = $Head/Camera3D
@onready var camera_base_y: float = camera.position.y

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var bob_time: float = 0.0

var movement_locked: bool = false
var _look_target: Vector3 = Vector3.ZERO
var _has_look_target: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	InteractionService.raycast = $Head/Camera3D/RayCast3D
	InteractionService.crosshair = get_tree().current_scene.get_node("CanvasLayer/Crosshair")
	PlayerService.register_player(self)

func _exit_tree() -> void:
	PlayerService.unregister_player(self)

func get_camera_global_position() -> Vector3:
	return camera.global_position

func set_movement_locked(locked: bool) -> void:
	movement_locked = locked
	if locked:
		velocity.x = 0.0
		velocity.z = 0.0
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func set_look_target(target_position: Vector3) -> void:
	_look_target = target_position
	_has_look_target = true

func clear_look_target() -> void:
	_has_look_target = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not movement_locked:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-pitch_limit_deg), deg_to_rad(pitch_limit_deg))
	if event.is_action_pressed("flashlight_toggle"):
		flashlight.visible = not flashlight.visible

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

	if movement_locked:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		_apply_look_target(delta)
	else:
		var input_dir := Vector2(
			Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
			Input.get_action_strength("move_back") - Input.get_action_strength("move_forward")
		)
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		var current_speed := sprint_speed if Input.is_action_pressed("sprint") else speed

		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()

	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	var is_walking := horizontal_speed > 0.1 and is_on_floor() and not movement_locked
	if is_walking:
		bob_time += delta * bob_frequency * (horizontal_speed / speed)
	else:
		bob_time = 0.0
	camera.position.y = camera_base_y + sin(bob_time) * bob_amplitude

func _apply_look_target(delta: float) -> void:
	if not _has_look_target:
		return

	var to_target := _look_target - head.global_position
	var horizontal_dist := Vector2(to_target.x, to_target.z).length()
	if horizontal_dist < 0.01 and absf(to_target.y) < 0.01:
		return

	var desired_yaw := atan2(-to_target.x, -to_target.z)
	var desired_pitch: float = clamp(atan2(to_target.y, horizontal_dist), deg_to_rad(-pitch_limit_deg), deg_to_rad(pitch_limit_deg))

	rotation.y = lerp_angle(rotation.y, desired_yaw, look_turn_speed * delta)
	head.rotation.x = lerp_angle(head.rotation.x, desired_pitch, look_turn_speed * delta)

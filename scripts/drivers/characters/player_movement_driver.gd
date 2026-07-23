class_name PlayerMovementDriver
extends CharacterBody3D

@export var speed: float = 4.0
@export var sprint_speed: float = 7.0
@export var mouse_sensitivity: float = 0.003
@export var pitch_limit_deg: float = 80.0
@export var bob_frequency: float = 10.0
@export var bob_amplitude: float = 0.045

@onready var head: Node3D = $Head
@onready var flashlight: SpotLight3D = $Head/Camera3D/FlashLight
@onready var camera: Camera3D = $Head/Camera3D
@onready var camera_base_y: float = camera.position.y

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var bob_time: float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	InteractionService.raycast = $Head/Camera3D/RayCast3D
	InteractionService.crosshair = get_tree().current_scene.get_node("CanvasLayer/Crosshair")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * mouse_sensitivity)
		head.rotate_x(-event.relative.y * mouse_sensitivity)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-pitch_limit_deg), deg_to_rad(pitch_limit_deg))
	if event.is_action_pressed("flashlight_toggle"):
		flashlight.visible = not flashlight.visible

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta

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
	var is_walking := horizontal_speed > 0.1 and is_on_floor()
	if is_walking:
		bob_time += delta * bob_frequency * (horizontal_speed / speed)
	else:
		bob_time = 0.0
	camera.position.y = camera_base_y + sin(bob_time) * bob_amplitude

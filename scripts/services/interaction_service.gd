extends Node

@export var raycast: RayCast3D
@export var crosshair: CrosshairDriver
var current_interactable: InteractableDriver = null

func _process(_delta: float) -> void:
	if raycast == null:
		return
	_check_raycast()
	if Input.is_action_just_pressed("interact") and current_interactable:
		current_interactable.interact()

func _check_raycast() -> void:
	if not raycast.is_colliding():
		current_interactable = null
	else:
		var collider = raycast.get_collider()
		current_interactable = collider if collider is InteractableDriver else null

	if crosshair:
		crosshair.set_hovering(current_interactable != null)

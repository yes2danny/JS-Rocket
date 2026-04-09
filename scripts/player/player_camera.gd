extends Camera3D
## First-person mouse look. Rotates the parent CharacterBody3D on Y, self on X.

const MOUSE_SENSITIVITY := 0.002
const VERTICAL_CLAMP := 89.0

var rotation_x: float = 0.0


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		# Yaw — rotate the whole player body
		get_parent().get_parent().rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		# Pitch — rotate just the camera
		rotation_x -= event.relative.y * MOUSE_SENSITIVITY
		rotation_x = clamp(rotation_x, deg_to_rad(-VERTICAL_CLAMP), deg_to_rad(VERTICAL_CLAMP))
		rotation.x = rotation_x

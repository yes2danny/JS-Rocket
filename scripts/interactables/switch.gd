extends InteractableBase
## Wall switch that sets a condition in GameManager when toggled.

@export var switch_id: String = ""
@export var condition_to_set: String = ""
@export var is_on: bool = false

@onready var lever_mesh: CSGBox3D = $LeverMesh


func _ready() -> void:
	interaction_prompt = "Flip Switch"
	_update_visual()


func interact() -> void:
	is_on = !is_on
	if condition_to_set != "":
		GameManager.set_condition(condition_to_set, is_on)
	EventBus.switch_toggled.emit(switch_id, is_on)
	interaction_prompt = "Flip Switch OFF" if is_on else "Flip Switch"
	_update_visual()


func _update_visual() -> void:
	if lever_mesh:
		lever_mesh.rotation_degrees.x = 30.0 if is_on else -30.0

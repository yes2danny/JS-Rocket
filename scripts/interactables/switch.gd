extends InteractableBase
## Wall switch that sets a condition in GameManager when toggled.
## To swap in your own model: replace the children of PlaceholderModel.
## The LeverPivot node is rotated by the script — put your lever mesh inside it.

@export var switch_id: String = ""
@export var condition_to_set: String = ""
@export var is_on: bool = false
@export var on_rotation: float = 30.0
@export var off_rotation: float = -30.0

@onready var lever_pivot: Node3D = get_node_or_null("LeverPivot")


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
	if lever_pivot:
		lever_pivot.rotation_degrees.x = on_rotation if is_on else off_rotation

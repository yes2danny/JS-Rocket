extends InteractableBase
## Sci-fi sliding door. Slides upward when opened. Can require a condition to unlock.

@export var is_open: bool = false
@export var locked_prompt: String = "Locked — No Power"
@export var open_speed: float = 2.0
@export var door_id: String = ""
@export var slide_distance: float = 2.5

@onready var door_panel: Node3D = $DoorPanel
var closed_y: float
var open_y: float
var target_y: float


func _ready() -> void:
	interaction_prompt = "Open Door"
	closed_y = door_panel.position.y
	open_y = closed_y + slide_distance
	target_y = open_y if is_open else closed_y


func _physics_process(delta: float) -> void:
	if not is_equal_approx(door_panel.position.y, target_y):
		door_panel.position.y = move_toward(door_panel.position.y, target_y, open_speed * delta)


func get_locked_prompt() -> String:
	return locked_prompt


func interact() -> void:
	if not can_interact():
		return
	is_open = !is_open
	target_y = open_y if is_open else closed_y
	interaction_prompt = "Close Door" if is_open else "Open Door"
	if is_open:
		EventBus.door_opened.emit(door_id)

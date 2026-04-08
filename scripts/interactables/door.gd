extends InteractableBase
## Sci-fi sliding door. Slides upward when opened. Can require a condition to unlock.
## Opened via access panel (toggle_door) or direct interaction.
## Color strip matches the cable and access panel for the visual puzzle.

@export var is_open: bool = false
@export var locked_prompt: String = "Locked — No Power"
@export var open_speed: float = 2.0
@export var door_id: String = ""
@export var slide_distance: float = 2.5
@export var door_color: Color = Color(1, 0.3, 0.1)
@export var use_panel_only: bool = false  ## If true, door can't be opened directly

@onready var door_panel: Node3D = $DoorPanel
var closed_y: float
var open_y: float
var target_y: float


func _ready() -> void:
	interaction_prompt = "Open Door"
	closed_y = door_panel.position.y
	open_y = closed_y + slide_distance
	target_y = open_y if is_open else closed_y
	_apply_door_color()


func _physics_process(delta: float) -> void:
	if not is_equal_approx(door_panel.position.y, target_y):
		door_panel.position.y = move_toward(door_panel.position.y, target_y, open_speed * delta)


func get_interaction_prompt() -> String:
	if use_panel_only:
		return "Find Access Panel"
	return interaction_prompt


func get_locked_prompt() -> String:
	return locked_prompt


func interact() -> void:
	if use_panel_only:
		return
	if not can_interact():
		return
	toggle_door()


func toggle_door() -> void:
	## Called by access panels. Skips can_interact check (panel handles that).
	is_open = !is_open
	target_y = open_y if is_open else closed_y
	interaction_prompt = "Close Door" if is_open else "Open Door"
	if is_open:
		EventBus.door_opened.emit(door_id)


func _apply_door_color() -> void:
	var strip := get_node_or_null("ColorStrip")
	if strip:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = door_color
		mat.emission_enabled = true
		mat.emission = door_color
		mat.emission_energy_multiplier = 2.0
		strip.material = mat

extends InteractableBase
## Wall-mounted access panel that opens a linked door via a unique puzzle.
## Each panel has a puzzle_scene — the door only opens when the puzzle is solved.

@export_node_path("Node3D") var target_door_path: NodePath
@export var panel_color: Color = Color(1, 0.3, 0.1)
@export var puzzle_scene: PackedScene  ## The puzzle UI to show when interacted with

var _door: Node = null
var _puzzle_active: bool = false


func _ready() -> void:
	interaction_prompt = "Use Access Panel"
	_door = get_node_or_null(target_door_path)
	_apply_color()


func can_interact() -> bool:
	if _puzzle_active:
		return false
	# Check if door is already open
	if _door and _door.get("is_open"):
		return false
	if _door and _door.has_method("can_interact"):
		return _door.can_interact()
	return true


func get_locked_prompt() -> String:
	if _door and _door.get("is_open"):
		return "Already Open"
	if _door and _door.has_method("get_locked_prompt"):
		return _door.get_locked_prompt()
	return "No Power"


func interact() -> void:
	if _puzzle_active:
		return
	if puzzle_scene:
		# Show the puzzle overlay
		var puzzle := puzzle_scene.instantiate()
		get_tree().root.add_child(puzzle)
		_puzzle_active = true
		puzzle.puzzle_solved.connect(_on_puzzle_solved)
		puzzle.puzzle_closed.connect(_on_puzzle_closed)
	elif _door and _door.has_method("toggle_door"):
		# Fallback: no puzzle assigned, direct toggle
		_door.toggle_door()


func _on_puzzle_solved() -> void:
	if _door and _door.has_method("toggle_door"):
		_door.toggle_door()
	_puzzle_active = false


func _on_puzzle_closed() -> void:
	_puzzle_active = false


func _apply_color() -> void:
	var strip := get_node_or_null("PlaceholderModel/ColorStrip")
	if strip:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = panel_color
		mat.emission_enabled = true
		mat.emission = panel_color
		mat.emission_energy_multiplier = 2.5
		strip.material = mat

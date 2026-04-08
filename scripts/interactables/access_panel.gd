extends InteractableBase
## Wall-mounted access panel that opens a linked door via color-coded cable.
## The player must find the matching panel to open each door.

@export_node_path("Node3D") var target_door_path: NodePath
@export var panel_color: Color = Color(1, 0.3, 0.1)

var _door: Node = null


func _ready() -> void:
	interaction_prompt = "Use Access Panel"
	_door = get_node_or_null(target_door_path)
	_apply_color()


func can_interact() -> bool:
	if _door and _door.has_method("can_interact"):
		return _door.can_interact()
	return true


func get_locked_prompt() -> String:
	if _door and _door.has_method("get_locked_prompt"):
		return _door.get_locked_prompt()
	return "No Power"


func interact() -> void:
	if _door and _door.has_method("toggle_door"):
		_door.toggle_door()


func _apply_color() -> void:
	var strip := get_node_or_null("PlaceholderModel/ColorStrip")
	if strip:
		var mat := StandardMaterial3D.new()
		mat.albedo_color = panel_color
		mat.emission_enabled = true
		mat.emission = panel_color
		mat.emission_energy_multiplier = 2.5
		strip.material = mat

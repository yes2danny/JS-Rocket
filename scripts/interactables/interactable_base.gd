class_name InteractableBase
extends StaticBody3D
## Base class for all interactable objects. Extend this and override interact().

@export var interaction_prompt: String = "Interact"
@export var interactable_id: String = ""
@export var requires_condition: String = ""


func get_interaction_prompt() -> String:
	return interaction_prompt


func can_interact() -> bool:
	if requires_condition == "":
		return true
	return GameManager.has_condition(requires_condition)


func get_locked_prompt() -> String:
	return "Locked"


func interact() -> void:
	pass

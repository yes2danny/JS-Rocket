extends RayCast3D
## Raycast-based interaction system. Detects InteractableBase objects and calls interact() on E.

var current_target: Node = null


func _physics_process(_delta: float) -> void:
	if is_colliding():
		var collider := get_collider()
		if collider and collider.has_method("get_interaction_prompt") and collider.has_method("interact"):
			if current_target != collider:
				current_target = collider
				var prompt: String = collider.get_interaction_prompt()
				if collider.has_method("can_interact") and not collider.can_interact():
					if collider.has_method("get_locked_prompt"):
						prompt = collider.get_locked_prompt()
					else:
						prompt = "Locked"
				EventBus.interaction_prompt_show.emit("[E] " + prompt)
		else:
			_clear_target()
	else:
		_clear_target()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and current_target:
		if current_target.has_method("can_interact") and not current_target.can_interact():
			return
		current_target.interact()


func _clear_target() -> void:
	if current_target:
		current_target = null
		EventBus.interaction_prompt_hide.emit()

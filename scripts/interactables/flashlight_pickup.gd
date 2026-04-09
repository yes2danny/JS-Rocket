extends InteractableBase
class_name FlashlightPickup
## Flashlight item the player can pick up from the floor.

func _ready() -> void:
	interaction_prompt = "Pick Up Flashlight"


func interact() -> void:
	var player = get_tree().current_scene.find_child("Player", true, false)
	if player and player.has_method("pickup_flashlight"):
		player.pickup_flashlight()
		queue_free()

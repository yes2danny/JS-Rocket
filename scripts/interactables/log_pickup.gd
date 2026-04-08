extends InteractableBase
## Physical datapad that can be picked up to collect a crew log.

@export var log_entry_id: String = ""


func _ready() -> void:
	interaction_prompt = "Pick Up Datapad"


func interact() -> void:
	if not can_interact():
		return
	var entry := LogDatabase.get_log(log_entry_id)
	if entry:
		GameManager.collect_log(log_entry_id)
		EventBus.log_display_requested.emit(entry)
		visible = false
		set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
		# Disable collision so the ray doesn't hit it anymore
		var col := get_node_or_null("CollisionShape3D")
		if col:
			col.set_deferred("disabled", true)

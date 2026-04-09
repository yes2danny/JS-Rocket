extends InteractableBase
## Computer terminal that displays a crew log when interacted with.

@export var log_entry_id: String = ""


func _ready() -> void:
	interaction_prompt = "Read Terminal"


func interact() -> void:
	if not can_interact():
		return
	var entry := LogDatabase.get_log(log_entry_id)
	if entry:
		GameManager.collect_log(log_entry_id)
		EventBus.log_display_requested.emit(entry)

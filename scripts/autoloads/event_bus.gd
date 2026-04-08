extends Node
## Global signal bus — decouples systems so interactables never reference UI directly.

signal interaction_prompt_show(text: String)
signal interaction_prompt_hide()

signal log_display_requested(log_entry: Resource)
signal log_display_closed()

signal door_opened(door_id: String)
signal switch_toggled(switch_id: String, state: bool)

signal game_paused(is_paused: bool)

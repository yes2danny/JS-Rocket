extends CanvasLayer
## Pause menu with resume and quit. Toggles on Escape.

@onready var panel: CenterContainer = $CenterContainer
var is_open: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if is_open:
			_resume()
		else:
			_pause()
		get_viewport().set_input_as_handled()


func _pause() -> void:
	panel.visible = true
	is_open = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	EventBus.game_paused.emit(true)


func _resume() -> void:
	panel.visible = false
	is_open = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	EventBus.game_paused.emit(false)


func _on_resume_pressed() -> void:
	_resume()


func _on_quit_pressed() -> void:
	get_tree().quit()

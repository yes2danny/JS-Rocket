class_name PuzzleBase
extends CanvasLayer
## Base class for all door puzzles. Shows as a UI overlay, pauses game, emits signals.

signal puzzle_solved
signal puzzle_closed

var is_solved: bool = false


func _ready() -> void:
	layer = 15
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not is_solved:
		_close()
		get_viewport().set_input_as_handled()


func _solve() -> void:
	is_solved = true
	puzzle_solved.emit()
	# Brief delay so the player sees the "solved" state
	await get_tree().create_timer(0.8).timeout
	_close()


func _close() -> void:
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	puzzle_closed.emit()
	queue_free()

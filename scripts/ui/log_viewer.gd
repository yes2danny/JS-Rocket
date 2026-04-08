extends CanvasLayer
## Full-screen overlay for reading crew logs. Pauses game tree while open.

@onready var panel: PanelContainer = $PanelContainer
@onready var header_label: Label = $PanelContainer/MarginContainer/VBoxContainer/HeaderLabel
@onready var content_label: RichTextLabel = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ContentLabel
@onready var close_hint: Label = $PanelContainer/MarginContainer/VBoxContainer/CloseHint

var is_open: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	panel.visible = false
	EventBus.log_display_requested.connect(_on_log_requested)


func _unhandled_input(event: InputEvent) -> void:
	if is_open and (event.is_action_pressed("interact") or event.is_action_pressed("pause")):
		_close()
		get_viewport().set_input_as_handled()


func _on_log_requested(entry: Resource) -> void:
	if not entry:
		return
	header_label.text = "CREW LOG — %s — %s" % [entry.author.to_upper(), entry.date]
	content_label.text = entry.content
	panel.visible = true
	is_open = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true


func _close() -> void:
	panel.visible = false
	is_open = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	EventBus.log_display_closed.emit()

extends PuzzleBase
## Simon Says pattern memory puzzle for the Bridge door.
## Buttons flash in a sequence — player must repeat it.

const COLORS := [
	Color(0.1, 0.85, 0.3),   # Green
	Color(0.9, 0.15, 0.15),  # Red
	Color(0.2, 0.4, 1.0),    # Blue
	Color(1.0, 0.85, 0.1),   # Yellow
]
const DIM_FACTOR := 0.25
const FLASH_DURATION := 0.5
const PAUSE_BETWEEN := 0.3
const SEQUENCE := [2, 0, 3, 1, 0]  # Fixed security pattern

var buttons: Array[Button] = []
var status_label: Label
var player_index: int = 0
var showing_pattern: bool = false


func _ready() -> void:
	super._ready()
	_build_ui()
	_show_pattern()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.92)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "SECURITY OVERRIDE — PATTERN LOCK"
	title.add_theme_color_override("font_color", Color(0.1, 0.85, 0.3))
	title.add_theme_font_size_override("font_size", 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	status_label = Label.new()
	status_label.text = "Watch the pattern..."
	status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
	status_label.add_theme_font_size_override("font_size", 16)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(status_label)

	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 12)
	grid.add_theme_constant_override("v_separation", 12)
	vbox.add_child(grid)

	for i in 4:
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(120, 120)
		btn.add_theme_color_override("font_color", Color.TRANSPARENT)
		var style := StyleBoxFlat.new()
		style.bg_color = COLORS[i] * DIM_FACTOR
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_left = 8
		style.corner_radius_bottom_right = 8
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)
		btn.add_theme_stylebox_override("pressed", style)
		btn.pressed.connect(_on_button_pressed.bind(i))
		grid.add_child(btn)
		buttons.append(btn)

	var hint := Label.new()
	hint.text = "[ESC] to cancel"
	hint.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45, 0.6))
	hint.add_theme_font_size_override("font_size", 13)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)


func _show_pattern() -> void:
	showing_pattern = true
	status_label.text = "Watch the pattern..."

	await get_tree().create_timer(0.6).timeout

	for idx in SEQUENCE:
		_flash_button(idx, COLORS[idx])
		await get_tree().create_timer(FLASH_DURATION + PAUSE_BETWEEN).timeout

	showing_pattern = false
	player_index = 0
	status_label.text = "Your turn — repeat the pattern"


func _flash_button(idx: int, color: Color) -> void:
	var style := buttons[idx].get_theme_stylebox("normal") as StyleBoxFlat
	var original := style.bg_color
	style.bg_color = color
	await get_tree().create_timer(FLASH_DURATION).timeout
	style.bg_color = original


func _on_button_pressed(idx: int) -> void:
	if showing_pattern or is_solved:
		return

	if idx == SEQUENCE[player_index]:
		# Correct
		_flash_button(idx, COLORS[idx])
		player_index += 1
		status_label.text = "Correct... %d/%d" % [player_index, SEQUENCE.size()]

		if player_index >= SEQUENCE.size():
			status_label.text = "ACCESS GRANTED"
			status_label.add_theme_color_override("font_color", Color(0.1, 1.0, 0.3))
			# Flash all buttons green
			for i in 4:
				var s := buttons[i].get_theme_stylebox("normal") as StyleBoxFlat
				s.bg_color = Color(0.1, 0.85, 0.3)
			_solve()
	else:
		# Wrong — flash all red and restart
		status_label.text = "INCORRECT — Replaying..."
		status_label.add_theme_color_override("font_color", Color(0.9, 0.15, 0.15))
		for i in 4:
			var s := buttons[i].get_theme_stylebox("normal") as StyleBoxFlat
			s.bg_color = Color(0.9, 0.15, 0.15, 0.5)
		await get_tree().create_timer(0.8).timeout
		for i in 4:
			var s := buttons[i].get_theme_stylebox("normal") as StyleBoxFlat
			s.bg_color = COLORS[i] * DIM_FACTOR
		status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
		_show_pattern()

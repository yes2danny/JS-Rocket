extends PuzzleBase
## Wire matching puzzle for the Crew Quarters door.
## Connect 4 colored wires on the left to their matching terminals on the right.

const WIRE_COLORS := [
	Color(0.9, 0.15, 0.15),  # Red
	Color(0.2, 0.5, 1.0),    # Blue
	Color(1.0, 0.85, 0.1),   # Yellow
	Color(0.1, 0.85, 0.3),   # Green
]
const WIRE_NAMES := ["RED", "BLUE", "YLW", "GRN"]
# Right side is shuffled: Green, Red, Yellow, Blue
const RIGHT_ORDER := [3, 0, 2, 1]

var left_buttons: Array[Button] = []
var right_buttons: Array[Button] = []
var connected: Array[bool] = [false, false, false, false]
var selected_left: int = -1
var status_label: Label


func _ready() -> void:
	super._ready()
	_build_ui()


func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.92)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(center)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 16)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "JUNCTION BOX — MATCH WIRE CONNECTIONS"
	title.add_theme_color_override("font_color", Color(0.2, 0.5, 1.0))
	title.add_theme_font_size_override("font_size", 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	status_label = Label.new()
	status_label.text = "Click a left terminal, then its matching right terminal"
	status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
	status_label.add_theme_font_size_override("font_size", 15)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(status_label)

	# Wire grid: left column — spacer — right column
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 60)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(hbox)

	# Left terminals (ordered)
	var left_vbox := VBoxContainer.new()
	left_vbox.add_theme_constant_override("separation", 10)
	hbox.add_child(left_vbox)

	var left_label := Label.new()
	left_label.text = "SOURCE"
	left_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	left_label.add_theme_font_size_override("font_size", 12)
	left_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left_vbox.add_child(left_label)

	for i in 4:
		var btn := _make_wire_button(WIRE_COLORS[i], WIRE_NAMES[i])
		btn.pressed.connect(_on_left_pressed.bind(i))
		left_vbox.add_child(btn)
		left_buttons.append(btn)

	# Right terminals (shuffled)
	var right_vbox := VBoxContainer.new()
	right_vbox.add_theme_constant_override("separation", 10)
	hbox.add_child(right_vbox)

	var right_label := Label.new()
	right_label.text = "TARGET"
	right_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	right_label.add_theme_font_size_override("font_size", 12)
	right_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right_vbox.add_child(right_label)

	for i in 4:
		var color_idx := RIGHT_ORDER[i]
		var btn := _make_wire_button(WIRE_COLORS[color_idx] * 0.4, "???")
		btn.pressed.connect(_on_right_pressed.bind(i))
		right_vbox.add_child(btn)
		right_buttons.append(btn)

	var hint := Label.new()
	hint.text = "[ESC] to cancel"
	hint.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45, 0.6))
	hint.add_theme_font_size_override("font_size", 13)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)


func _make_wire_button(color: Color, label_text: String) -> Button:
	var btn := Button.new()
	btn.text = label_text
	btn.custom_minimum_size = Vector2(90, 50)
	var style := StyleBoxFlat.new()
	style.bg_color = color * 0.5
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.border_color = color
	style.corner_radius_top_left = 4
	style.corner_radius_top_right = 4
	style.corner_radius_bottom_left = 4
	style.corner_radius_bottom_right = 4
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style.duplicate())
	btn.add_theme_stylebox_override("pressed", style.duplicate())
	btn.add_theme_color_override("font_color", Color(0.9, 0.9, 0.95))
	btn.add_theme_font_size_override("font_size", 14)
	return btn


func _on_left_pressed(idx: int) -> void:
	if is_solved or connected[idx]:
		return
	selected_left = idx
	status_label.text = "Selected %s — now click the matching target" % WIRE_NAMES[idx]
	# Highlight selected
	for i in 4:
		var s := left_buttons[i].get_theme_stylebox("normal") as StyleBoxFlat
		if i == idx and not connected[i]:
			s.bg_color = WIRE_COLORS[i] * 0.8
		elif not connected[i]:
			s.bg_color = WIRE_COLORS[i] * 0.5


func _on_right_pressed(right_idx: int) -> void:
	if is_solved or selected_left == -1:
		return

	var right_color_idx := RIGHT_ORDER[right_idx]

	if right_color_idx == selected_left:
		# Correct match
		connected[selected_left] = true
		# Light up both sides
		var ls := left_buttons[selected_left].get_theme_stylebox("normal") as StyleBoxFlat
		ls.bg_color = WIRE_COLORS[selected_left]
		left_buttons[selected_left].text = WIRE_NAMES[selected_left] + " ✓"

		var rs := right_buttons[right_idx].get_theme_stylebox("normal") as StyleBoxFlat
		rs.bg_color = WIRE_COLORS[right_color_idx]
		rs.border_color = WIRE_COLORS[right_color_idx]
		right_buttons[right_idx].text = WIRE_NAMES[right_color_idx] + " ✓"

		selected_left = -1
		status_label.text = "Connected! %d/4" % connected.count(true)
		status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))

		# Check win
		if connected.count(true) == 4:
			status_label.text = "ALL CONNECTIONS MADE — ACCESS GRANTED"
			status_label.add_theme_color_override("font_color", Color(0.1, 1.0, 0.3))
			_solve()
	else:
		# Wrong match — flash red
		status_label.text = "WRONG MATCH — try again"
		status_label.add_theme_color_override("font_color", Color(0.9, 0.15, 0.15))
		var rs := right_buttons[right_idx].get_theme_stylebox("normal") as StyleBoxFlat
		var orig_color := rs.bg_color
		rs.bg_color = Color(0.9, 0.1, 0.1, 0.6)
		await get_tree().create_timer(0.4).timeout
		rs.bg_color = orig_color
		selected_left = -1
		status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
		status_label.text = "Click a left terminal, then its matching right terminal"

extends PuzzleBase
## Wire matching puzzle for the Crew Quarters door.
## Connect 4 colored wires on the left to their matching terminals on the right.

const WIRE_COLORS := [
	Color(1.0, 0.2, 0.2),    # Red
	Color(0.3, 0.6, 1.0),    # Blue
	Color(1.0, 0.9, 0.2),    # Yellow
	Color(0.2, 1.0, 0.4),    # Green
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
	# Full screen dark background
	var bg := ColorRect.new()
	bg.color = Color(0, 0, 0, 0.92)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Main container — use a Panel to ensure visibility
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -280
	panel.offset_top = -260
	panel.offset_right = 280
	panel.offset_bottom = 260
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.03, 0.03, 0.06, 0.95)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(0.2, 0.4, 0.9, 0.5)
	panel_style.content_margin_left = 30
	panel_style.content_margin_top = 25
	panel_style.content_margin_right = 30
	panel_style.content_margin_bottom = 25
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 18)
	panel.add_child(vbox)

	# Title
	var title := Label.new()
	title.text = "JUNCTION BOX — MATCH WIRE CONNECTIONS"
	title.add_theme_color_override("font_color", Color(0.3, 0.6, 1.0))
	title.add_theme_font_size_override("font_size", 20)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep := HSeparator.new()
	sep.add_theme_color_override("separator_color", Color(0.2, 0.4, 0.8, 0.3))
	vbox.add_child(sep)

	# Status
	status_label = Label.new()
	status_label.text = "Click a SOURCE wire, then click its matching TARGET"
	status_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
	status_label.add_theme_font_size_override("font_size", 14)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(status_label)

	# Wire columns: SOURCE | gap | TARGET
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 80)
	columns.alignment = BoxContainer.ALIGNMENT_CENTER
	columns.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(columns)

	# LEFT — Source terminals
	var left_col := VBoxContainer.new()
	left_col.add_theme_constant_override("separation", 8)
	columns.add_child(left_col)

	var src_label := Label.new()
	src_label.text = "SOURCE"
	src_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))
	src_label.add_theme_font_size_override("font_size", 13)
	src_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left_col.add_child(src_label)

	for i in 4:
		var btn := _make_wire_button(WIRE_COLORS[i], WIRE_NAMES[i], true)
		btn.pressed.connect(_on_left_pressed.bind(i))
		left_col.add_child(btn)
		left_buttons.append(btn)

	# RIGHT — Target terminals (shuffled, dimmed until matched)
	var right_col := VBoxContainer.new()
	right_col.add_theme_constant_override("separation", 8)
	columns.add_child(right_col)

	var tgt_label := Label.new()
	tgt_label.text = "TARGET"
	tgt_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.65))
	tgt_label.add_theme_font_size_override("font_size", 13)
	tgt_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right_col.add_child(tgt_label)

	for i in 4:
		var color_idx := RIGHT_ORDER[i]
		var btn := _make_wire_button(WIRE_COLORS[color_idx], "? ? ?", false)
		btn.pressed.connect(_on_right_pressed.bind(i))
		right_col.add_child(btn)
		right_buttons.append(btn)

	# Close hint
	var hint := Label.new()
	hint.text = "[ESC] to cancel"
	hint.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45, 0.5))
	hint.add_theme_font_size_override("font_size", 12)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)


func _make_wire_button(color: Color, label_text: String, is_source: bool) -> Button:
	var btn := Button.new()
	btn.text = label_text
	btn.custom_minimum_size = Vector2(100, 50)

	var style := StyleBoxFlat.new()
	if is_source:
		style.bg_color = color * 0.6
		style.border_color = color
	else:
		# Dimmed for target — shows the color faintly
		style.bg_color = Color(0.08, 0.08, 0.12)
		style.border_color = color * 0.35
	style.border_width_left = 3
	style.border_width_right = 3
	style.border_width_top = 3
	style.border_width_bottom = 3
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_left = 6
	style.corner_radius_bottom_right = 6

	# Apply to all button states
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style.duplicate())
	btn.add_theme_stylebox_override("pressed", style.duplicate())
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn.add_theme_color_override("font_color", Color(0.95, 0.95, 1.0))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_pressed_color", Color(1, 1, 1))
	btn.add_theme_font_size_override("font_size", 15)

	return btn


func _on_left_pressed(idx: int) -> void:
	if is_solved or connected[idx]:
		return
	selected_left = idx
	status_label.text = "Selected %s — now click matching TARGET" % WIRE_NAMES[idx]
	status_label.add_theme_color_override("font_color", WIRE_COLORS[idx])
	# Highlight selected, dim others
	for i in 4:
		if connected[i]:
			continue
		var s := left_buttons[i].get_theme_stylebox("normal") as StyleBoxFlat
		if i == idx:
			s.bg_color = WIRE_COLORS[i] * 0.9
			s.border_color = Color(1, 1, 1)
		else:
			s.bg_color = WIRE_COLORS[i] * 0.3
			s.border_color = WIRE_COLORS[i] * 0.5


func _on_right_pressed(right_idx: int) -> void:
	if is_solved or selected_left == -1:
		return

	var right_color_idx := RIGHT_ORDER[right_idx]

	if right_color_idx == selected_left:
		# Correct match!
		connected[selected_left] = true

		# Light up left button fully
		var ls := left_buttons[selected_left].get_theme_stylebox("normal") as StyleBoxFlat
		ls.bg_color = WIRE_COLORS[selected_left]
		ls.border_color = WIRE_COLORS[selected_left]
		left_buttons[selected_left].text = WIRE_NAMES[selected_left]

		# Light up right button with matching color
		var rs := right_buttons[right_idx].get_theme_stylebox("normal") as StyleBoxFlat
		rs.bg_color = WIRE_COLORS[right_color_idx] * 0.7
		rs.border_color = WIRE_COLORS[right_color_idx]
		right_buttons[right_idx].text = WIRE_NAMES[right_color_idx]

		# Reset unconnected left buttons to normal brightness
		for i in 4:
			if not connected[i]:
				var s := left_buttons[i].get_theme_stylebox("normal") as StyleBoxFlat
				s.bg_color = WIRE_COLORS[i] * 0.6
				s.border_color = WIRE_COLORS[i]

		selected_left = -1
		var count := connected.count(true)
		status_label.text = "Connected %d / 4" % count
		status_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))

		if count == 4:
			status_label.text = "ALL WIRES CONNECTED — ACCESS GRANTED"
			status_label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4))
			_solve()
	else:
		# Wrong match
		status_label.text = "WRONG MATCH — try again"
		status_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
		var rs := right_buttons[right_idx].get_theme_stylebox("normal") as StyleBoxFlat
		var orig_bg := rs.bg_color
		var orig_border := rs.border_color
		rs.bg_color = Color(0.7, 0.05, 0.05)
		rs.border_color = Color(1.0, 0.1, 0.1)
		selected_left = -1

		await get_tree().create_timer(0.5).timeout

		rs.bg_color = orig_bg
		rs.border_color = orig_border
		# Reset left buttons
		for i in 4:
			if not connected[i]:
				var s := left_buttons[i].get_theme_stylebox("normal") as StyleBoxFlat
				s.bg_color = WIRE_COLORS[i] * 0.6
				s.border_color = WIRE_COLORS[i]
		status_label.add_theme_color_override("font_color", Color(0.75, 0.75, 0.8))
		status_label.text = "Click a SOURCE wire, then click its matching TARGET"

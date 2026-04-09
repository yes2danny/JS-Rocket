extends PuzzleBase
## Circuit routing puzzle for the Engineering door.
## Flip 5 switches into the correct ON/OFF pattern to route power.
## Correct pattern: ON-OFF-ON-ON-OFF (sectors 1, 3, 4 active)

const TARGET := [true, false, true, true, false]
const SWITCH_LABELS := ["SEC-1", "SEC-2", "SEC-3", "SEC-4", "SEC-5"]

var switches: Array[Button] = []
var indicators: Array[ColorRect] = []
var switch_states: Array[bool] = [false, false, false, false, false]
var status_label: Label
var power_bar: ColorRect


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
	title.text = "POWER ROUTING — CIRCUIT CONFIGURATION"
	title.add_theme_color_override("font_color", Color(1.0, 0.5, 0.1))
	title.add_theme_font_size_override("font_size", 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	status_label = Label.new()
	status_label.text = "Route power to the door — activate the correct sectors"
	status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
	status_label.add_theme_font_size_override("font_size", 15)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(status_label)

	# Switch grid
	var switch_container := HBoxContainer.new()
	switch_container.add_theme_constant_override("separation", 16)
	switch_container.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(switch_container)

	for i in 5:
		var switch_vbox := VBoxContainer.new()
		switch_vbox.add_theme_constant_override("separation", 8)
		switch_container.add_child(switch_vbox)

		# Indicator light
		var indicator := ColorRect.new()
		indicator.custom_minimum_size = Vector2(60, 12)
		indicator.color = Color(0.15, 0.15, 0.15)
		switch_vbox.add_child(indicator)
		indicators.append(indicator)

		# Switch button
		var btn := Button.new()
		btn.text = SWITCH_LABELS[i] + "\nOFF"
		btn.custom_minimum_size = Vector2(60, 70)
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.08, 0.08, 0.1)
		style.corner_radius_top_left = 4
		style.corner_radius_top_right = 4
		style.corner_radius_bottom_left = 4
		style.corner_radius_bottom_right = 4
		btn.add_theme_stylebox_override("normal", style.duplicate())
		btn.add_theme_stylebox_override("hover", style.duplicate())
		btn.add_theme_stylebox_override("pressed", style.duplicate())
		btn.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
		btn.add_theme_font_size_override("font_size", 12)
		btn.pressed.connect(_on_switch_toggled.bind(i))
		switch_vbox.add_child(btn)
		switches.append(btn)

	# Power flow bar
	power_bar = ColorRect.new()
	power_bar.custom_minimum_size = Vector2(340, 6)
	power_bar.color = Color(0.15, 0.15, 0.15)
	vbox.add_child(power_bar)

	var hint := Label.new()
	hint.text = "[ESC] to cancel"
	hint.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45, 0.6))
	hint.add_theme_font_size_override("font_size", 13)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)


func _on_switch_toggled(idx: int) -> void:
	if is_solved:
		return

	switch_states[idx] = !switch_states[idx]
	_update_visuals()
	_check_solution()


func _update_visuals() -> void:
	for i in 5:
		var is_on := switch_states[i]
		switches[i].text = SWITCH_LABELS[i] + ("\nON" if is_on else "\nOFF")

		var style := switches[i].get_theme_stylebox("normal") as StyleBoxFlat
		style.bg_color = Color(0.3, 0.15, 0.02) if is_on else Color(0.08, 0.08, 0.1)
		switches[i].add_theme_color_override("font_color",
			Color(1.0, 0.6, 0.2) if is_on else Color(0.5, 0.5, 0.55))

		# Indicator: orange if on and matches target, red if on and wrong
		if is_on:
			if switch_states[i] == TARGET[i]:
				indicators[i].color = Color(1.0, 0.5, 0.1)
			else:
				indicators[i].color = Color(0.7, 0.1, 0.1)
		else:
			if switch_states[i] == TARGET[i]:
				indicators[i].color = Color(0.1, 0.3, 0.1)  # dim green = correct off
			else:
				indicators[i].color = Color(0.15, 0.15, 0.15)

	# Power bar shows progress
	var correct_count := 0
	for i in 5:
		if switch_states[i] == TARGET[i]:
			correct_count += 1
	var progress := float(correct_count) / 5.0
	power_bar.color = Color(1.0, 0.5, 0.1).lerp(Color(0.1, 1.0, 0.3), progress) * progress


func _check_solution() -> void:
	for i in 5:
		if switch_states[i] != TARGET[i]:
			return
	# All correct
	status_label.text = "POWER ROUTED — ACCESS GRANTED"
	status_label.add_theme_color_override("font_color", Color(0.1, 1.0, 0.3))
	power_bar.color = Color(0.1, 1.0, 0.3)
	for i in 5:
		indicators[i].color = Color(0.1, 1.0, 0.3)
	_solve()

extends PuzzleBase
## Frequency dial tuning puzzle for the Observation Deck door.
## Player turns a dial to find the correct frequency (14.6 GHz — Vey's signal).

const TARGET_FREQ := 14.6
const LOCK_THRESHOLD := 0.25
const MIN_FREQ := 1.0
const MAX_FREQ := 30.0

var dial_slider: HSlider
var freq_label: Label
var signal_bar: ColorRect
var signal_label: Label
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
	vbox.add_theme_constant_override("separation", 18)
	center.add_child(vbox)

	var title := Label.new()
	title.text = "FREQUENCY LOCK — TUNE TO TARGET SIGNAL"
	title.add_theme_color_override("font_color", Color(0.9, 0.1, 0.1))
	title.add_theme_font_size_override("font_size", 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)

	var sep := HSeparator.new()
	vbox.add_child(sep)

	status_label = Label.new()
	status_label.text = "Tune the dial to lock onto the anomalous signal"
	status_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
	status_label.add_theme_font_size_override("font_size", 15)
	status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(status_label)

	# Frequency display
	freq_label = Label.new()
	freq_label.text = "1.0 GHz"
	freq_label.add_theme_color_override("font_color", Color(0.9, 0.1, 0.1))
	freq_label.add_theme_font_size_override("font_size", 36)
	freq_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(freq_label)

	# Dial slider
	dial_slider = HSlider.new()
	dial_slider.min_value = MIN_FREQ
	dial_slider.max_value = MAX_FREQ
	dial_slider.step = 0.1
	dial_slider.value = MIN_FREQ
	dial_slider.custom_minimum_size = Vector2(400, 30)
	dial_slider.value_changed.connect(_on_dial_changed)
	vbox.add_child(dial_slider)

	# Signal strength bar
	var bar_container := HBoxContainer.new()
	bar_container.add_theme_constant_override("separation", 10)
	bar_container.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(bar_container)

	var bar_label := Label.new()
	bar_label.text = "SIGNAL:"
	bar_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	bar_label.add_theme_font_size_override("font_size", 13)
	bar_container.add_child(bar_label)

	signal_bar = ColorRect.new()
	signal_bar.custom_minimum_size = Vector2(300, 20)
	signal_bar.color = Color(0.15, 0.15, 0.15)
	bar_container.add_child(signal_bar)

	signal_label = Label.new()
	signal_label.text = "NO SIGNAL"
	signal_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45))
	signal_label.add_theme_font_size_override("font_size", 13)
	signal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(signal_label)

	var hint := Label.new()
	hint.text = "[ESC] to cancel"
	hint.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45, 0.6))
	hint.add_theme_font_size_override("font_size", 13)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(hint)


func _on_dial_changed(value: float) -> void:
	if is_solved:
		return

	freq_label.text = "%.1f GHz" % value

	var distance := absf(value - TARGET_FREQ)

	if distance > 5.0:
		# Far — no signal
		signal_bar.color = Color(0.15, 0.15, 0.15)
		signal_label.text = "NO SIGNAL"
		signal_label.add_theme_color_override("font_color", Color(0.4, 0.4, 0.45))
		freq_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	elif distance > 2.0:
		# Faint
		signal_bar.color = Color(0.5, 0.1, 0.1)
		signal_label.text = "FAINT SIGNAL"
		signal_label.add_theme_color_override("font_color", Color(0.7, 0.2, 0.2))
		freq_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2))
	elif distance > 0.8:
		# Medium
		signal_bar.color = Color(0.8, 0.6, 0.1)
		signal_label.text = "SIGNAL DETECTED"
		signal_label.add_theme_color_override("font_color", Color(0.9, 0.7, 0.1))
		freq_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.1))
	elif distance > LOCK_THRESHOLD:
		# Close
		signal_bar.color = Color(0.6, 0.9, 0.2)
		signal_label.text = "SIGNAL STRONG — ALMOST LOCKED"
		signal_label.add_theme_color_override("font_color", Color(0.7, 1.0, 0.2))
		freq_label.add_theme_color_override("font_color", Color(0.5, 1.0, 0.2))
	else:
		# Locked
		signal_bar.color = Color(0.1, 1.0, 0.3)
		signal_label.text = "SIGNAL LOCKED"
		signal_label.add_theme_color_override("font_color", Color(0.1, 1.0, 0.3))
		freq_label.add_theme_color_override("font_color", Color(0.1, 1.0, 0.3))
		status_label.text = "FREQUENCY LOCKED — ACCESS GRANTED"
		status_label.add_theme_color_override("font_color", Color(0.1, 1.0, 0.3))
		_solve()

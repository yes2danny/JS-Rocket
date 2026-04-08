extends Node
## Manages ambient audio crossfading and SFX playback pool.

var _ambient_a: AudioStreamPlayer
var _ambient_b: AudioStreamPlayer
var _current_ambient: AudioStreamPlayer
var _sfx_pool: Array[AudioStreamPlayer] = []
var _sfx_index: int = 0
var _fade_tween: Tween

const SFX_POOL_SIZE := 8


func _ready() -> void:
	_ambient_a = AudioStreamPlayer.new()
	_ambient_a.bus = "Master"
	_ambient_a.volume_db = -80.0
	add_child(_ambient_a)

	_ambient_b = AudioStreamPlayer.new()
	_ambient_b.bus = "Master"
	_ambient_b.volume_db = -80.0
	add_child(_ambient_b)

	_current_ambient = _ambient_a

	for i in SFX_POOL_SIZE:
		var player := AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		_sfx_pool.append(player)


func play_ambient(stream: AudioStream, fade_time: float = 2.0) -> void:
	if stream == null:
		return

	var next: AudioStreamPlayer
	if _current_ambient == _ambient_a:
		next = _ambient_b
	else:
		next = _ambient_a

	next.stream = stream
	next.volume_db = -80.0
	next.play()

	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()

	_fade_tween = create_tween().set_parallel(true)
	_fade_tween.tween_property(_current_ambient, "volume_db", -80.0, fade_time)
	_fade_tween.tween_property(next, "volume_db", -6.0, fade_time)

	var old := _current_ambient
	_current_ambient = next
	_fade_tween.finished.connect(func(): old.stop())


func play_sfx(stream: AudioStream) -> void:
	if stream == null:
		return
	var player := _sfx_pool[_sfx_index]
	player.stream = stream
	player.play()
	_sfx_index = (_sfx_index + 1) % SFX_POOL_SIZE

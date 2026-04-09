extends OmniLight3D
## Organic noise-based flickering light for horror atmosphere.

@export var min_energy: float = 0.05
@export var max_energy: float = 1.0
@export var flicker_speed: float = 8.0
@export var flicker_intensity: float = 0.6

var base_energy: float
var noise: FastNoiseLite


func _ready() -> void:
	base_energy = light_energy
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.01


func _process(_delta: float) -> void:
	var t := Time.get_ticks_msec() * 0.001 * flicker_speed
	var n := noise.get_noise_1d(t)
	light_energy = lerp(base_energy, base_energy * (0.5 + n * 0.5), flicker_intensity)
	light_energy = clamp(light_energy, min_energy, max_energy)

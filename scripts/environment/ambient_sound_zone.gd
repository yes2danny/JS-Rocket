extends Area3D
## Triggers an ambient audio crossfade when the player enters this zone.

@export var ambient_stream: AudioStream
@export var fade_time: float = 2.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		AudioManager.play_ambient(ambient_stream, fade_time)

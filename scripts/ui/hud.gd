extends CanvasLayer
## In-game HUD showing crosshair and interaction prompt.

@onready var interaction_label: Label = $Control/InteractionPrompt
@onready var crosshair: ColorRect = $Control/Crosshair


func _ready() -> void:
	EventBus.interaction_prompt_show.connect(_on_prompt_show)
	EventBus.interaction_prompt_hide.connect(_on_prompt_hide)
	interaction_label.visible = false


func _on_prompt_show(text: String) -> void:
	interaction_label.text = text
	interaction_label.visible = true


func _on_prompt_hide() -> void:
	interaction_label.visible = false

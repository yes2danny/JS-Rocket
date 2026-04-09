extends CharacterBody3D
## First-person player controller with WASD movement, sprint, gravity, and head bob.

const WALK_SPEED := 3.0
const SPRINT_SPEED := 5.5
const GRAVITY := 9.8
const HEAD_BOB_FREQ := 2.4
const HEAD_BOB_AMP := 0.04
const FOOTSTEP_INTERVAL_WALK := 0.55
const FOOTSTEP_INTERVAL_SPRINT := 0.35

var has_flashlight: bool = false

@onready var head: Node3D = $Head
@onready var hand: Node3D = $Head/Camera3D/Hand
@onready var flashlight_light: SpotLight3D = $Head/Camera3D/Hand/FlashlightLight
var head_bob_timer: float = 0.0
var footstep_timer: float = 0.0
var head_bob_base_y: float


func _ready() -> void:
	head_bob_base_y = head.position.y


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_flashlight") and has_flashlight:
		flashlight_light.visible = !flashlight_light.visible


func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y -= GRAVITY * delta

	# Movement input
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	var is_sprinting := Input.is_action_pressed("sprint")
	var speed := SPRINT_SPEED if is_sprinting else WALK_SPEED

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * delta * 10.0)
		velocity.z = move_toward(velocity.z, 0, speed * delta * 10.0)

	move_and_slide()

	# Head bob
	var is_moving := direction.length() > 0.1 and is_on_floor()
	if is_moving:
		head_bob_timer += delta * HEAD_BOB_FREQ * (1.4 if is_sprinting else 1.0)
		var bob_offset := sin(head_bob_timer * TAU) * HEAD_BOB_AMP
		head.position.y = head_bob_base_y + bob_offset
	else:
		head_bob_timer = 0.0
		head.position.y = lerp(head.position.y, head_bob_base_y, delta * 10.0)

	# Footsteps
	if is_moving:
		var interval := FOOTSTEP_INTERVAL_SPRINT if is_sprinting else FOOTSTEP_INTERVAL_WALK
		footstep_timer += delta
		if footstep_timer >= interval:
			footstep_timer = 0.0
			_play_footstep()
	else:
		footstep_timer = 0.0


func _play_footstep() -> void:
	# AudioManager handles null streams gracefully
	pass


func pickup_flashlight() -> void:
	has_flashlight = true
	flashlight_light.visible = true
	if hand.has_node("FlashlightMesh"):
		hand.get_node("FlashlightMesh").visible = true

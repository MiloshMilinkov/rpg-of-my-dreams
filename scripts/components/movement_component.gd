class_name MovementComponent extends Node

@export var body: CharacterBody2D
@export var base_speed: float = 100.0

var flat_speed_bonus: float = 0.0
var stats_speed_multiplier: float = 1.0
var movement_enabled: bool = true
var facing_direction: Vector2 = Vector2.DOWN
var _move_direction: Vector2 = Vector2.ZERO
var _mode_multiplier: float = 1.0

func _ready() -> void:
	if not is_instance_valid(body):
		push_error("MovementComponent: Assign a CharacterBody2D to body.")
		set_physics_process(false)
		return
		
	body.motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	process_physics_priority = 100

func set_move_intent(direction: Vector2, mode_multiplier: float = 1.0) -> void:
	_move_direction = direction.limit_length(1.0)
	_mode_multiplier = maxf(mode_multiplier, 0.0)

	if _move_direction.is_zero_approx():
		return

	if absf(_move_direction.x) > absf(_move_direction.y):
		facing_direction = Vector2.RIGHT if _move_direction.x > 0.0 else Vector2.LEFT
	else:
		facing_direction = Vector2.DOWN if _move_direction.y > 0.0 else Vector2.UP

func get_effective_speed() -> float:
	var adjusted_base: float = maxf(base_speed + flat_speed_bonus, 0.0)
	return adjusted_base * maxf(stats_speed_multiplier, 0.0)

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(body):
		set_physics_process(false)
		return

	var current_speed: float = get_effective_speed() * _mode_multiplier

	if movement_enabled:
		body.velocity = _move_direction * current_speed
	else:
		body.velocity = Vector2.ZERO

	body.move_and_slide()
	clear_move_intent()

func clear_move_intent() -> void:
	_move_direction = Vector2.ZERO
	_mode_multiplier = 1.0

func stop() -> void:
	clear_move_intent()

	if is_instance_valid(body):
		body.velocity = Vector2.ZERO

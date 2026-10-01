class_name MovementComponent extends Node

@export var body: CharacterBody2D
@export var stats: StatsComponent
@export var health: HealthComponent

var movement_enabled: bool = true
var facing_direction: Vector2 = Vector2.DOWN
var _move_direction: Vector2 = Vector2.ZERO
var _mode_multiplier: float = 1.0


func _ready() -> void:
	if not is_instance_valid(body) or not is_instance_valid(stats):
		push_error("MovementComponent: Assign body and stats.")
		set_physics_process(false)
		return
		
	stats.initialize()
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
	return stats.get_stat(StatProfile.Stat.MOVE_SPEED)

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(body) or not is_instance_valid(stats):
		stop()
		set_physics_process(false)
		return

	var can_move: bool = movement_enabled

	if is_instance_valid(health):
		can_move = can_move and health.is_alive()

	if can_move:
		body.velocity = (_move_direction * get_effective_speed() * _mode_multiplier)
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

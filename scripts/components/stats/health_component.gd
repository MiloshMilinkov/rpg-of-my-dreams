class_name HealthComponent extends Node

signal health_changed(current_health: int, max_health: int)
signal died
signal revived

@export var stats: StatsComponent

var current_health: int:
	get: return _current_health
var max_health: int:
	get: return _max_health
	
var _current_health: int = 0
var _max_health: int = 1

func _ready() -> void:
	if not is_instance_valid(stats):
		push_error("HealthComponent: Assing a StatsComponents")
		return
	
	stats.initialize()
	
	_max_health = roundi(stats.get_stat(StatProfile.Stat.MAX_HEALTH))
	_current_health = _max_health
	
	stats.stats_changed.connect(_on_stats_changed)
	health_changed.emit(_current_health, _max_health)

func is_alive() -> bool:
	return _current_health > 0
	
func take_damage(amount: int) -> void:
	if amount <= 0 or not is_alive():return
	_set_health(_current_health - amount)

func heal(health_amount: int) -> void:
	if health_amount <= 0 or not is_alive(): return
		
	_set_health(clampi(health_amount, 1, _max_health))
	revived.emit()

func _set_health(value: int) -> void:
	var next_health: int = clampi(value, 0, _max_health)
	if next_health == _current_health: return

	var was_alive: bool = is_alive()
	_current_health = next_health
	var became_dead: bool = was_alive and not is_alive()

	health_changed.emit(_current_health, _max_health)

	if became_dead:
		died.emit()
		
func _on_stats_changed() -> void:
	var next_max: int = roundi(
		stats.get_stat(StatProfile.Stat.MAX_HEALTH)
	)

	if next_max == _max_health:return

	_max_health = next_max
	_current_health = mini(_current_health, _max_health)

	health_changed.emit(_current_health, _max_health)

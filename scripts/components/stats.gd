extends Resource
class_name Stats

enum BuffableStats{
	MAX_HEALTH,
	DEFENSE,
	ATTACK
}

signal health_depleted
signal health_change(current_health:int, max_health: int)

@export var base_max_health: int = 100
@export var base_defense: int = 10
@export var base_attack: int = 10
@export var experience: int = 0: set = _on_experience_set

var level: int:
	get(): return floor(max(1.0, sqrt(experience /100.0) + 0.5))
var current_max_health: int = 100
var current_defense: int = 10
var current_attack: int = 10
var health: int = 0: set = _on_health_set
var stat_buffs: Array[StatBuff]

func _init() -> void:
	setup_stats.call_deferred()
		
func setup_stats() -> void:
	recalculate_stats()
	health = current_max_health

func add_buff(buff: StatBuff) -> void:
	stat_buffs.append(buff)

func remove_buff(buff: StatBuff) -> void:
	stat_buffs.erase(buff)

func 	recalculate_stats() -> void:
	var stat_multipliers: Dictionary = {}
	var stat_addends: Dictionary = {}
	for buff in stat_buffs:
		var stat_name: String = BuffableStats.keys()[buff.stat].to_lower()
		match buff.buff_type:
			StatBuff.BuffType.ADD:
				if not stat_addends.has(stat_name):
					stat_multipliers[stat_name] = 0.0
				stat_multipliers[stat_name] += buff.buff_amonut
			StatBuff.BuffType.MULTIPLY:
				if not stat_addends.has(stat_name):
					stat_multipliers[stat_name] = 1.0
				stat_multipliers[stat_name] += buff.buff_amonut
			
				if stat_multipliers[stat_name] < 0.0:
					stat_multipliers[stat_name] = 0.0
	for stat_name in stat_multipliers:
		var cur_propert_name: String = str("current_" + stat_name)
		set(cur_propert_name, get(cur_propert_name) * stat_multipliers[stat_name])
	for stat_name in stat_addends:
		var cur_propert_name: String = str("current_" + stat_name)
		set(cur_propert_name, get(cur_propert_name) * stat_multipliers[stat_name])
		
func _on_health_set(new_value: int) -> void:
	health = clampi(new_value, 0, current_max_health)
	health_change.emit(health, current_max_health)
	if health <= 0:
		health_depleted.emit()

func _on_experience_set(new_value: int) -> void:
	var old_level: int = level
	experience = new_value
	
	if not old_level == level:
		recalculate_stats()
	

class_name StatsComponent extends Node

signal stats_changed
signal attributes_changed

@export var profile: StatProfile

var _attributes: Dictionary[StatProfile.Attribute, int] = {}
var _stat_values: Dictionary[StatProfile.Stat, float] = {}
var _modifiers: Dictionary[int, StatModifier]
var _next_modifier_id: int = 1
var _initialized: bool = false

func _ready() -> void:
	initialize()
	
func initialize() -> void:
	if _initialized:
		return
	if profile == null:
		profile = StatProfile.new()
	
	for attribute: StatProfile.Attribute in StatProfile.Attribute.values():
		_attributes[attribute] = maxi(profile.starting_attributes.get(attribute,0), 0)
		
	_initialized = true
	recalculate()

func recalculate() -> void:
	if not _initialized:
		initialize()
		return
	
	var next_stat_values: Dictionary[StatProfile.Stat, float] = (profile.calculate_base_stats(_attributes))
	
	for stat: StatProfile.Stat in next_stat_values:
		var flat_bonus: float = 0.0
		var percent_bonus: float = 0.0
		var multiplier: float = 1.0
		
		for modifier: StatModifier in _modifiers.values():
			if modifier.stat != stat:
				continue
			
			match modifier.operation:
				StatModifier.Operation.FLAT:
					flat_bonus += modifier.amount
				StatModifier.Operation.PERCENT:
					percent_bonus += modifier.amount
				StatModifier.Operation.MULTIPLIER:
					multiplier *= modifier.amount
		
		var value: float = ((next_stat_values[stat] + flat_bonus) * maxf(1.0 + percent_bonus, 0.0) * multiplier)
		next_stat_values[stat] = maxf(value, 0.0)
	next_stat_values[StatProfile.Stat.MAX_HEALTH] = maxf( roundf(next_stat_values[StatProfile.Stat.MAX_HEALTH]), 1.0)
	if next_stat_values == _stat_values:
		return
	
	_stat_values = next_stat_values
	stats_changed.emit()
	
func remove_modifier(modifier_id: int) -> bool:
	if not _modifiers.erase(modifier_id): return false
		
	recalculate()
	return true
		
func add_modifier(modifier: StatModifier) -> int:
	initialize()
	
	if modifier == null or not is_finite(modifier.amount):
		return -1
	if not StatProfile.Stat.values().has(modifier.stat):
		return -1
	if not StatModifier.Operation.values().has(modifier.operation):
		return -1
	if modifier.operation == StatModifier.Operation.MULTIPLIER and modifier.amount <0.0:
		return -1

	var modifier_id: int = _next_modifier_id
	_next_modifier_id += 1
	
	_modifiers[modifier_id] = modifier.duplicate() as StatModifier
	recalculate()
	return modifier_id

func get_stat(stat: StatProfile.Stat) -> int:
	initialize()
	return _stat_values.get(stat, 0.0)

func get_attribute(attrbiute: StatProfile.Attribute) -> int:
	initialize()
	return _attributes.get(attrbiute, 0)
	
func increase_attribute( attribute: StatProfile.Attribute, amount: int = 1) -> bool:
	initialize()
	if amount <= 0 or not StatProfile.Attribute.values().has(attribute):
		return false
		
	_attributes[attribute] += amount
	recalculate()
	attributes_changed.emit()
	return true

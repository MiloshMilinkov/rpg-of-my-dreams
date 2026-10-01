class_name ProgressionComponenet extends Node

signal attribute_points_changed(point: int)
signal character_level_changed(old_level:int, new_level: int)

@export var stats: StatsComponent
@export_range(0, 100) var starting_attribute_points: int = 0
@export_range(1, 100000) var first_level_cost: int = 100
@export_range(0, 100000) var cost_increase: int = 50
@export_range(1, 1000) var level_cap: int = 100

var character_track: ProgressionTrack:
	get: return _character_track
var unspent_attribute_points: int:
	get: return _unspent_attribute_points

var _character_track: ProgressionTrack
var _unspent_attribute_points: int = 0

func _ready() -> void:
	if not is_instance_valid(stats):
		push_error("ProgressionComponent: Assign a StatsComponent")
		return
	
	stats.initialize()
	
	_unspent_attribute_points = maxi(starting_attribute_points, 0)
	_character_track = ProgressionTrack.new(first_level_cost, cost_increase, level_cap)
	_character_track.level_changed.connect(_on_character_level_changed)
	attribute_points_changed.emit(_unspent_attribute_points)

func add_character_xp(amount: int) -> void:
	if _character_track != null:
		_character_track.add_xp(amount)
		
func spend_attribute_point(attribute: StatProfile.Attribute) -> bool:
	if _character_track == null or not is_instance_valid(stats):
		return false
	if _unspent_attribute_points <= 0:
		return false
	if not StatProfile.Attribute.values().has(attribute):
		return false

	_unspent_attribute_points -= 1

	if not stats.increase_attribute(attribute):
		_unspent_attribute_points += 1
		return false

	attribute_points_changed.emit(_unspent_attribute_points)
	return true

func _on_character_level_changed(old_level: int, new_level: int) -> void:
	_unspent_attribute_points += new_level - old_level

	attribute_points_changed.emit(_unspent_attribute_points)
	character_level_changed.emit(old_level, new_level)

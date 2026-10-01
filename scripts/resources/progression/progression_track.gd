class_name ProgressionTrack extends Resource

signal experience_changed(total_xp: int)
signal level_changed(old_level: int, new_level: int)

var total_xp: int:
	get: return _total_xp
	
var level: int:
	get: return _level
	
var xp_in_level: int:
	get: return _xp_in_level

var max_level: int:
	get: return _max_level

var _total_xp: int = 0
var _level: int = 1
var _xp_in_level: int = 0
var _first_level_cost: int = 100
var _cost_increase: int = 50
var _max_level: int = 100

func _init(first_level_cost: int = 100, cost_increase: int = 50, level_cap: int = 100) -> void:
	_first_level_cost = maxi(first_level_cost, 1)
	_cost_increase = maxi(cost_increase, 0)
	_max_level = maxi(level_cap, 1)

func xp_required_for_next_level() -> int:
	if _level >= _max_level:
		return 0
	
	return _first_level_cost + (_level - 1) * _cost_increase
	
func get_progress_ratio() -> float:
	if _level >= max_level:
		return 1.0
	
	return float(_xp_in_level) / float(xp_required_for_next_level())
	
func add_xp(amount: int) -> void:
	if amount <= 0 or _level >= _max_level:
		return
	var old_level: int = _level	
	_total_xp += amount
	_xp_in_level += amount
	
	while _level < _max_level:
		var required: int = xp_required_for_next_level()
		if _xp_in_level < required:
			break
		
		_xp_in_level -= required
		_level += 1
		
	if _level == _max_level:
		_total_xp -= _xp_in_level
		_xp_in_level = 0
		
	if _level != old_level:
		level_changed.emit(old_level, level)
		
	experience_changed.emit(_total_xp)	
	
	

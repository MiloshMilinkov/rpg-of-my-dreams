class_name StatProfile extends Resource
#Starting attributes and calculation rules
#This Resource contains configuration. Each character’s actual attributes live in its StatsComponent.
#These are starting balance values you can change in the Inspector:

enum Attribute {
	STRENGTH,
	ENDURANCE,
	INTELLIGENCE,
	AGILITY
	#Will add more in time, if changed then the change should be reflected in @export_group("Attribute contributions")...also calculate each new attribute
}

enum Stat {
	MAX_HEALTH,
	PHYSICAL_ATTACK,
	MAGIC_ATTACK,
	DEFENSE,
	MAGIC_RESISTANCE,
	MOVE_SPEED
	#Will add more in time, if changed then the change should be reflected in @export_group("Base stats")...also calculate each new stat
}

@export var starting_attributes: Dictionary[Attribute, int] = {
	Attribute.STRENGTH: 0,
	Attribute.ENDURANCE: 0,
	Attribute.INTELLIGENCE: 0,
	Attribute.AGILITY: 0
}

@export_group("Base stats")
@export var base_max_health: float = 100.0
@export var base_physical_attack: float = 10.0
@export var base_magic_attack: float = 10.0
@export var base_defense: float = 0.0
@export var base_magic_resistance: float = 0.0
@export var base_move_speed: float = 100.0

@export_group("Attribute contributions")
@export var attack_per_strength: float = 2.0
@export var health_per_endurance: float = 10.0
@export var defense_per_endurance: float = 0.5
@export var magic_attack_per_intelligence: float = 2.0
@export var resistance_per_intelligence: float = 1.0
@export var speed_per_agility: float = 1.0

func calculate_base_stats(attributes: Dictionary[Attribute, int]) -> Dictionary[Stat, float]:
	var strength: int = attributes.get(Attribute.STRENGTH, 0)
	var endurance: int = attributes.get(Attribute.ENDURANCE, 0)
	var intelligence: int = attributes.get(Attribute.INTELLIGENCE, 0)
	var agility: int = attributes.get(Attribute.AGILITY, 0)

	return {
		Stat.MAX_HEALTH: base_max_health + endurance * health_per_endurance,
		Stat.PHYSICAL_ATTACK: base_physical_attack + strength * attack_per_strength,
		Stat.MAGIC_ATTACK: base_magic_attack + intelligence * magic_attack_per_intelligence,
		Stat.DEFENSE: base_defense + endurance * defense_per_endurance,
		Stat.MAGIC_RESISTANCE: base_magic_resistance + intelligence * resistance_per_intelligence,
		Stat.MOVE_SPEED: base_move_speed + agility * speed_per_agility
	}

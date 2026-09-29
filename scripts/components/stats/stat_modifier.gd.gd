class_name StatModifier extends Resource
#handles equipment bonus, buff, or debuff
#all bonues/buff are sequential (Two PERCENT bonuses of 0.20 produce +40%. Two MULTIPLIER bonuses of 1.20 produce ×1.44.)

#FLAT	20.0	Add 20
#PERCENT	0.20	Add 20% to the percentage pool
#MULTIPLIER	1.20	Multiply the result by 1.2
enum Operation {
	FLAT ,
	PERCENT,
	MULTIPLIER
}

@export var stat: StatProfile.Stat = StatProfile.Stat.MAX_HEALTH
@export var operation: Operation = Operation.FLAT
@export var amount: float = 0.0

func _init(target_stat: StatProfile.Stat = StatProfile.Stat.MAX_HEALTH,
		modifier_operation: Operation = Operation.FLAT,
		modifier_amount: float = 0.0) -> void:
	stat = target_stat
	operation = modifier_operation
	amount = modifier_amount

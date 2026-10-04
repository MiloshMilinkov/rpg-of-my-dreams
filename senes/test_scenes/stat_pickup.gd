class_name StatPickup extends Area2D

@export var modifier: StatModifier
@export_range(0.0, 600.0, 0.1) var duration: float = 0.0

var _collected: bool = false

func _ready() -> void:
	print('ready')
	if modifier == null:
		push_error("StatPickup: Assign a StatModifier in the Inspector.")
		return

	body_entered.connect(_on_body_entered)

func _draw() -> void:
	draw_circle(Vector2.ZERO, 12.0, Color(0.2, 1.0, 0.3))

func _on_body_entered(body: Node2D) -> void:
	print('entered')
	if _collected or not body.is_in_group("player"):
		return

	var stats: StatsComponent = (
		body.get_node_or_null("StatsComponent") as StatsComponent
	)

	if stats == null:
		push_warning("StatPickup: Player needs a child named StatsComponent.")
		return

	_collected = true
	var modifier_id: int = stats.add_modifier(modifier)

	if modifier_id < 0:
		_collected = false
		push_warning("StatPickup: The modifier was rejected.")
		return

	if duration > 0.0:
		var timer: SceneTreeTimer = get_tree().create_timer(
			duration, false
		)
		timer.timeout.connect(
			stats.remove_modifier.bind(modifier_id)
		)

	print(
		"Move speed: ", stats.get_stat(StatProfile.Stat.MOVE_SPEED),
		" | Max health: ", stats.get_stat(StatProfile.Stat.MAX_HEALTH)
	)

	queue_free()

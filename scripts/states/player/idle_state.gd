extends State

@export var movement: MovementComponent
@export var walk_state: State
# @export var animated_sprite: AnimatedSprite2D

func enter_state() -> void:
	movement.stop()
	_update_animation()

func physics_update(_delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if not direction.is_zero_approx():
		movement.set_move_intent(direction)
		switch_state.emit(walk_state)
		return

	movement.clear_move_intent()

func _update_animation() -> void:
	pass
	# if movement.facing_direction == Vector2.UP:
	# 	animated_sprite.play("idle_back")
	# elif movement.facing_direction == Vector2.DOWN:
	# 	animated_sprite.play("idle_front")
	# elif movement.facing_direction == Vector2.LEFT:
	# 	animated_sprite.play("idle_left")
	# else:
	# 	animated_sprite.play("idle_right")

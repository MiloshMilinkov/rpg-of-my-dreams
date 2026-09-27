extends State
@export var movement: MovementComponent
@export var idle_state: State
# @export var animated_sprite: AnimatedSprite2D

func enter_state() -> void:
	_update_animation()

func physics_update(_delta: float) -> void:
	var direction: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction.is_zero_approx():
		switch_state.emit(idle_state)
		return

	movement.set_move_intent(direction)
	_update_animation()

func exit_state() -> void:
	movement.clear_move_intent()

func _update_animation() -> void:
	pass
	# if movement.facing_direction == Vector2.UP:
	# 	animated_sprite.play("walk_back")
	# elif movement.facing_direction == Vector2.DOWN:
	# 	animated_sprite.play("walk_front")
	# elif movement.facing_direction == Vector2.LEFT:
	# 	animated_sprite.play("walk_left")
	# else:
	# 	animated_sprite.play("walk_right")

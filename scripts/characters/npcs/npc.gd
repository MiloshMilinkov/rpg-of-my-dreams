class_name NPC extends CharacterBody2D

@export var animated_sprite: AnimatedSprite2D
@export var state_machine: StateMachine
@export var idle_state: State
@export var talking_state: State
@export var movement: MovementComponent

var _resume_state: State


func start_talking() -> bool:
	if not _can_use_state(talking_state):
		push_error("NPC: Assign Talking as a child of this NPC's StateMachine.")
		return false

	if not is_instance_valid(state_machine.active_state) or is_talking():
		return false

	var previous_state: State = state_machine.active_state
	state_machine.change_state(talking_state)

	if state_machine.active_state != talking_state:
		return false

	_resume_state = previous_state
	return true


func finish_talking() -> bool:
	if not is_talking():
		return false

	var destination: State = _resume_state

	if not _can_use_state(destination):
		destination = idle_state

	if not _can_use_state(destination) or destination == talking_state:
		push_error("NPC: Assign a valid Idle state to return to.")
		return false

	state_machine.change_state(destination)

	if state_machine.active_state != destination:
		return false

	_resume_state = null
	return true


func is_talking() -> bool:
	return (
		is_instance_valid(state_machine)
		and is_instance_valid(talking_state)
		and state_machine.active_state == talking_state
	)


func stop_moving() -> void:
	if is_instance_valid(movement):
		movement.stop()

	velocity = Vector2.ZERO


func play_animation(animation_name: StringName) -> void:
	if not is_instance_valid(animated_sprite) or animated_sprite.sprite_frames == null:
		push_warning("NPC: Assign an AnimatedSprite2D with a SpriteFrames resource.")
		return

	if not animated_sprite.sprite_frames.has_animation(animation_name):
		push_warning("NPC: Animation '%s' does not exist." % animation_name)
		return

	animated_sprite.play(animation_name)


func _can_use_state(state: State) -> bool:
	return (
		is_instance_valid(state_machine)
		and is_instance_valid(state)
		and not state.is_queued_for_deletion()
		and state.get_parent() == state_machine
	)

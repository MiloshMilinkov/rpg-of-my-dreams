class_name StateMachine extends Node

@export var initial_state: State

var active_state: State
var _states: Array[State] = []
var _is_changing_state: bool = false

func _ready() -> void:
	for child: Node in get_children():
		if child is State:
			var child_state: State = child as State
			_states.append(child_state)
			child_state.switch_state.connect(_on_state_requested.bind(child_state))
			
	_start.call_deferred()

func _start() -> void:
	change_state(initial_state)

func _process(delta: float) -> void:
	if is_instance_valid(active_state):
		active_state.update(delta)

func _physics_process(delta: float) -> void:
	if is_instance_valid(active_state):
		active_state.physics_update(delta)

func _on_state_requested(new_state: State, requesting_state: State) -> void:
	if requesting_state != active_state:
		return
	change_state(new_state)

func change_state(new_state: State) -> void:
	if _is_changing_state:
		push_warning("StateMachine: Cannot change state during enter_state or exit_state.")
		return

	if not is_instance_valid(new_state):
		push_error("StateMachine: Destination state is missing or invalid.")
		return

	if not _states.has(new_state):
		push_error("StateMachine: Destination is not registered with this machine.")
		return

	if new_state.get_parent() != self:
		push_error("StateMachine: Destination is no longer a direct child.")
		return

	if new_state.is_queued_for_deletion():
		push_error("StateMachine: Destination is queued for deletion.")
		return

	if new_state == active_state:
		return

	_is_changing_state = true

	if is_instance_valid(active_state):
		active_state.exit_state()

	active_state = new_state
	active_state.enter_state()
	_is_changing_state = false

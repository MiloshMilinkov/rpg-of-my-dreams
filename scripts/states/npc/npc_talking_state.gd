class_name NpcTalkingState extends State

@export var npc: NPC
@export var animation_name: StringName = &"talking"


func enter_state() -> void:
	if not is_instance_valid(npc):
		push_error("NpcTalkingState: Assign the NPC root.")
		return

	npc.stop_moving()
	npc.play_animation("talking")


func physics_update(_delta: float) -> void:
	if is_instance_valid(npc):
		npc.stop_moving()

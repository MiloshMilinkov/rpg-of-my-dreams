class_name Utilities extends Node

static func center_pivot(control_node: Control) -> void:
	control_node.pivot_offset_ratio = Vector2(0.5, 0.5)

static func clear_all_children(parent: Node) -> void:
	for child: Node in parent.get_children():
		child.queue_free()

static func reset_tween(tween: Tween, parent:Node) -> Tween:
	if tween != null and tween.is_valid():
		tween.kill()
	return parent.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)

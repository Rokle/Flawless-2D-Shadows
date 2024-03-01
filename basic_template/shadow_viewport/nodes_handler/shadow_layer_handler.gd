extends "generic_handler.gd"

func handle_node(node: Node, add_node_to: Node) -> void:
	if shadow_viewport.autofill_distance_from_origin:
		shadow_viewport.object_between_shadow_layers.append([])
	
	shadow_viewport.shadow_layers.append(node)

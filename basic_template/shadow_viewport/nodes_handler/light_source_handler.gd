extends "generic_handler.gd"

func handle_node(node: Node, add_child_to: Node) -> void:
	if not node.autosearch:
		return
	
	node.get_data_from_shadow_viewport(shadow_viewport)

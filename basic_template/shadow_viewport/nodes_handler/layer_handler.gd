extends "generic_handler.gd"

const LAYER_PATH = "res://basic_template/layer/layer.tscn"

func handle_node(node: Node, add_node_to: Node) -> void:
	var layer = load(LAYER_PATH).instantiate()
	
	layer.show_behind_parent = node.show_behind_parent
	
	add_node_to.add_child(layer)
	
	for child in node.get_children():
		add_node_to = layer
		nodes_handler.handle_node(child, add_node_to)

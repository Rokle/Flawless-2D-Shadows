extends Node

var shadow_viewport: ShadowViewport
var nodes_handler: Node

func handle_node(node: Node, add_node_to: Node) -> void:
	add_node_to.add_child(node.duplicate())

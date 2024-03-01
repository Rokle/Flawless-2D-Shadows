extends "generic_handler.gd"

const MOVABLE_ITEM_PIN_PATH = "res://basic_template/movable_item_pin/movable_item_pin.tscn"

func handle_node(node: Node, add_node_to: Node) -> void:
	if node.has_shadow:
		shadow_viewport.object_between_shadow_layers[-1].append(node)
		shadow_viewport.objects_with_shadow.append(node)
	
	var node_duplicate = node.duplicate()
	
	node_duplicate.disabled = true
	node_duplicate.in_shadow_viewport = true
	
	if node.has_animation:
		node_duplicate.animated_sprite = node_duplicate.get_node(str(node_duplicate.animated_sprite.name))
	
	var movable_item_pin = load(MOVABLE_ITEM_PIN_PATH).instantiate()
	
	movable_item_pin.name = node.name
	
	movable_item_pin.movable_item = node_duplicate
	
	movable_item_pin.position = node.position
	node_duplicate.position = Vector2.ZERO
	
	movable_item_pin.add_child(node_duplicate)
	
	add_node_to.add_child(movable_item_pin)
	
	node.move_together_with_nodes = true
	
	node.linked_nodes_in_shadow_layers.append(movable_item_pin)

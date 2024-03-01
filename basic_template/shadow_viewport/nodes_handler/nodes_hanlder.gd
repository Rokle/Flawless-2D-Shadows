extends Node

@export var shadow_viewport: ShadowViewport
@export var layer_handler: Node
@export var light_source_handler: Node
@export var movabel_item_handler: Node
@export var shadow_layer_handler: Node
@export var generic_handler: Node
@export var ignore_handler: Node

var handlers_map = {}

func _ready() -> void:
	set_up()

func set_up() -> void:
	handlers_map[ShadowViewport.NODE_TYPES.LAYER] = layer_handler
	handlers_map[ShadowViewport.NODE_TYPES.LIGHT_SOURCE] = light_source_handler
	handlers_map[ShadowViewport.NODE_TYPES.MOVABLE_ITEM] = movabel_item_handler
	handlers_map[ShadowViewport.NODE_TYPES.SHADOW_LAYER] = shadow_layer_handler
	handlers_map[ShadowViewport.NODE_TYPES.GENERIC] = generic_handler
	handlers_map[ShadowViewport.NODE_TYPES.IGNORE] = ignore_handler
	
	for handler in handlers_map.values():
		handler.shadow_viewport = shadow_viewport
		handler.nodes_handler = self

func handle_node(node: Node, add_node_to: Node) -> void:
	var node_type = get_node_type(node)
	
	handlers_map[node_type].handle_node(node, add_node_to)

func get_node_type(node: Node) -> ShadowViewport.NODE_TYPES:
	if not node.has_method("get_type_for_shadow_viewport"):
		return ShadowViewport.NODE_TYPES.GENERIC
	
	return node.get_type_for_shadow_viewport()

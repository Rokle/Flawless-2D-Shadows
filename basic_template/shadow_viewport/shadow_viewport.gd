extends Control

class_name ShadowViewport

signal viewport_created()

enum NODE_TYPES{
	LAYER,
	LIGHT_SOURCE,
	MOVABLE_ITEM,
	SHADOW_LAYER,
	GENERIC,
	IGNORE
}

const TYPE_FOR_SHADOW_VIEWPORT = NODE_TYPES.IGNORE
const LAYER_PATH = "res://cases/layers/layer/Layer.tscn"
const SHADOW_VIEWPORT_COVER_PATH = "res://basic_template/shadow_viewport/shadow_viewport_cover.tscn"

@export var autofill_distance_from_origin := false
@export var shadow_color: Color = Color(0, 0, 0, 0.49803921580315) : set = change_shadow_color

@export var nodes_handler: Node

var shadow_layers = []

var objects_with_shadow = []

var object_between_shadow_layers = []

var shadow_color_rect: ColorRect

func create_shadow_viewport(main_scene_node: Node) -> void:
	set_up_shadow_viewport(main_scene_node)
	
	add_cover()

func add_cover() -> void:
	var shadow_viewport_cover = load(SHADOW_VIEWPORT_COVER_PATH).instantiate()
	
	shadow_color_rect = shadow_viewport_cover.get_child(0)
	
	add_child(shadow_viewport_cover)
	
	change_shadow_color(shadow_color)
	
	emit_signal("viewport_created")

func change_shadow_color(new_color: Color) -> void:
	if shadow_color_rect == null:
		return
	
	shadow_color = new_color
	shadow_color_rect.color = shadow_color

func set_up_shadow_viewport(main_scene_node: Node) -> void:
	var found_self = false
	
	for child in main_scene_node.get_children():
		if child == self:
			found_self = true
			continue
		
		if not found_self:
			continue
		
		nodes_handler.handle_node(child, self)

func get_type_for_shadow_viewport() -> NODE_TYPES:
	return TYPE_FOR_SHADOW_VIEWPORT

func _on_StartTimer_timeout():
	call_deferred("create_shadow_viewport",get_parent())

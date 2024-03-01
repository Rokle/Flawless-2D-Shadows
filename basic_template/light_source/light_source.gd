extends Node2D

const TYPE_FOR_SHADOW_VIEWPORT = ShadowViewport.NODE_TYPES.LIGHT_SOURCE
# Path to shadow scene
const shadow_preset_path = "res://basic_template/shadow/shadow.tscn"
const default_step_between_shadow_layers = 1

# Distance from pseudo-background plane z = 0
@export var distance_from_origin: float = 10
# Enable autosearch all objects_with_shadows and shadow_layers
@export var autosearch: bool = false
# Array of nodes that have shadows 
@export var objects_with_shadow: Array = []
# Array of shadow_layer nodes
@export var shadow_layers: Array = []
# Steps between shadow_layer nodes to calculate difference in hight
@export var steps_between_shadow_layers: Array[int] = []

@onready var preload_shadow_node = preload(shadow_preset_path)

func _ready() -> void:
	if autosearch:
		return
	
	call_deferred("set_up_shadows")
	call_deferred("set_up_steps_between_shadow_layers")

func set_up_steps_between_shadow_layers() -> void:
	if len(steps_between_shadow_layers) > len(shadow_layers):
		return
	
	for _i in range(len(shadow_layers)-len(steps_between_shadow_layers)):
		steps_between_shadow_layers.append(default_step_between_shadow_layers)

func get_data_from_shadow_viewport(shadow_viewport: ShadowViewport) -> void:
	shadow_layers = shadow_viewport.shadow_layers
	set_up_steps_between_shadow_layers()
	objects_with_shadow = shadow_viewport.objects_with_shadow
	
	var current_distance_from_origin = 0
	
	for i in range(len(shadow_viewport.object_between_shadow_layers)):
		current_distance_from_origin += steps_between_shadow_layers[i]
		
		for object in shadow_viewport.object_between_shadow_layers[i]:
			object.shadow_nodes[Vector2(0,current_distance_from_origin)] = []
	
	set_up_shadows()

# Creates all necessary nodes for shadows to work
func set_up_shadows() -> void:
	var total_layer_offset = 0
	
	for i in range(len(shadow_layers)):
		for object_with_shadow in objects_with_shadow:
			if object_with_shadow.in_shadow_viewport:
				continue
			
			var object_with_shadow_distance = object_with_shadow.shadow_nodes.keys()[0]
			
			if object_with_shadow_distance.y - total_layer_offset <= 0:
				continue
			
			var shadow_distance_from_origin = Vector2(object_with_shadow_distance.y-total_layer_offset,object_with_shadow_distance.y)
			
			create_shadow(shadow_layers[i], object_with_shadow, shadow_distance_from_origin)
			
			if object_with_shadow_distance.y - total_layer_offset - steps_between_shadow_layers[i] <= 0 or i == 0:
				create_shadow(shadow_layers[i], object_with_shadow, Vector2.ZERO)
		
		create_bbc(shadow_layers[i])
		
		total_layer_offset += steps_between_shadow_layers[i]
	
	call_deferred("create_shadows")

func create_shadow(shadow_layer: Node, object_with_shadow: Node, shadow_distance_from_origin: Vector2) -> void:
	var shadow = preload_shadow_node.instantiate()
	
	if object_with_shadow.has_animation:
		shadow.set_up_anim(object_with_shadow)
	else:
		shadow.animated_sprite.queue_free()
	
	if not object_with_shadow.has_label:
		shadow.label.queue_free()
	
	shadow_layer.add_child(shadow)
	
	if not shadow_distance_from_origin in object_with_shadow.shadow_nodes.keys():
		object_with_shadow.shadow_nodes[shadow_distance_from_origin] = []
	
	object_with_shadow.shadow_nodes[shadow_distance_from_origin].append(shadow)

func create_bbc(shadow_layer: Node) -> void:
	var bbc = BackBufferCopy.new()
	bbc.copy_mode = bbc.COPY_MODE_VIEWPORT
	shadow_layer.add_child(bbc)

func reset_movable_item_params(movable_item: Node) -> Node:
	movable_item.disabled = true
	return movable_item

# For testing purposes if you want to change lighting source position
func _input(event):
	if Input.is_action_pressed("ui_left") and Input.is_action_pressed("left_click"):
		global_position = get_global_mouse_position()
		call_deferred("force_update_shadows")

# Creates all shadows
func create_shadows() -> void:
	for i in range(len(objects_with_shadow)):
		var object_with_shadow = objects_with_shadow[i]
		object_with_shadow.connect("shadow_changed", Callable(self, "change_shadow"))
		var shadow_texture = object_with_shadow.get_shadow_texture()
		
		for shadow_array in object_with_shadow.shadow_nodes.values():
			for shadow in shadow_array:
				shadow.texture = shadow_texture
				
				shadow.set_up_material()
	
	call_deferred("force_update_shadows")

# Force updates all shadows
func force_update_shadows() -> void:
	for object_with_shadow in objects_with_shadow:
		object_with_shadow.call_deferred("update_shadow")

# Updates shadow params
func change_shadow(shadow_holder: Node, params: Dictionary) -> void:
	for shadow_distance_from_origin in shadow_holder.shadow_nodes.keys():
		for shadow in shadow_holder.shadow_nodes[shadow_distance_from_origin]:
			var new_params = params.duplicate()
			
			if "position" in params:
				new_params = resize_shadow(shadow_distance_from_origin,new_params)
			
			shadow.update_shadow(new_params)

# Calculates shadow size and position on pseudo-background plane
func resize_shadow(shadow_distance_from_origin: Vector2, params: Dictionary) -> Dictionary:
	var light_pos = Vector3(global_position.x,global_position.y,distance_from_origin)
	var object_top_left_pos = Vector3(params["position"].x,params["position"].y,shadow_distance_from_origin.y)
	
	if shadow_distance_from_origin.x != 0:
		object_top_left_pos.z = shadow_distance_from_origin.x
		light_pos.z += shadow_distance_from_origin.x-shadow_distance_from_origin.y
	
	params["position"] = get_intersection_with_background(light_pos,object_top_left_pos)
	
	var object_top_right_pos = Vector3(object_top_left_pos.x+params["size"].x*cos(deg_to_rad(params["rotation"])), object_top_left_pos.y+params["size"].x*sin(deg_to_rad(params["rotation"])),object_top_left_pos.z)
	
	params["size"].x = params["position"].distance_to(get_intersection_with_background(light_pos,object_top_right_pos))
	
	var object_bottom_left_pos = Vector3(object_top_left_pos.x+params["size"].y*sin(deg_to_rad(params["rotation"])), object_top_left_pos.y+params["size"].y*cos(deg_to_rad(params["rotation"])),object_top_left_pos.z)
	
	params["size"].y = params["position"].distance_to(get_intersection_with_background(light_pos,object_bottom_left_pos))
	
	return params

# Get's intersections point between line and pseudo-background plane z = 0
func get_intersection_with_background(point_1: Vector3, point_2: Vector3) -> Vector2:
	var pointing_vector = point_2 - point_1
	
	var line_const = -point_1.z/pointing_vector.z
	
	return Vector2(point_1.x + line_const*pointing_vector.x,point_1.y + line_const*pointing_vector.y)

# Basic function that tells shadow_viewport node what type of node this is to correctly
# generate shadows
func get_type_for_shadow_viewport() -> ShadowViewport.NODE_TYPES:
	return TYPE_FOR_SHADOW_VIEWPORT

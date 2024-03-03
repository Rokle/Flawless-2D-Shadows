extends TextureButton

signal moved_after_click()
signal shadow_changed(id,params)

const TYPE_FOR_SHADOW_VIEWPORT = ShadowViewport.NODE_TYPES.MOVABLE_ITEM

@export var add_to_shadow_viewport := true
@export var remove_texture_on_set_up := false
@export var has_shadow = true
@export var has_animation = false
@export var animated_sprite: AnimatedSprite2D
@export var has_label = false
@export var label: Label
@export var move_with_nodes: Array[Node] = []

var move_together_with_nodes = false

var interaction_rect: Node

var in_shadow_viewport = false

var linked_nodes_in_shadow_layers = []

var shadow_nodes = {}

var holding = false
var hold_point = Vector2.ZERO


func _ready() -> void:
	set_up()

func set_up() -> void:
	set_process_input(false)
	interaction_rect = get_child(0)
	
	if in_shadow_viewport:
		disabled = true
	
	if has_animation:
		animated_sprite.play("default")

func remove_texture() -> void:
	texture_normal = null

func update_anim(animation_holder: AnimatedSprite2D) -> void:
	if not has_animation:
		return
	
	if animated_sprite.animation != animation_holder.animation:
		animated_sprite.play(animation_holder.animation)
	
	if animated_sprite.speed_scale != animation_holder.speed_scale:
		animated_sprite.speed_scale = animation_holder.speed_scale
	
	if animated_sprite.centered != animation_holder.centered:
		animated_sprite.centered = animation_holder.centered
	
	if animated_sprite.flip_h != animation_holder.flip_h:
		animated_sprite.flip_h = animation_holder.flip_h
	
	animated_sprite.frame = animation_holder.frame

func get_shadow_texture() -> Texture:
	return texture_normal

func update_shadow() -> void:
	var params = {"position": position, "rotation": rotation, "size":size}
	
	if has_animation or has_label:
		params["owner"] = self
	
	emit_signal("shadow_changed",self,params)

func move_rect(point: Vector2) -> void:
	position = point
	
	for node in linked_nodes_in_shadow_layers:
		node.set_new_position(point)
	
	for node in move_with_nodes:
		node.move_rect(point)
	
	update_shadow()

func _input(event) -> void:
	if in_shadow_viewport:
		return
	
	if disabled:
		return
	
	if InteractionsManager.holding_something and not holding:
		return
	
	if Input.is_action_pressed("left_click"):
		if interaction_rect.get_rect().has_point(interaction_rect.get_local_mouse_position()) and not holding and visible:
			update_hold_point()
			holding = true
			InteractionsManager.holding_something = true
		
		if holding:
			try_move()
		return
	
	holding = false
	InteractionsManager.holding_something = false

func update_hold_point() -> void:
	if not Input.is_action_pressed("left_click"):
		return
	
	hold_point = interaction_rect.get_local_mouse_position() * scale
	pass

func try_move() -> void:
	var rect_position_buffer = get_global_mouse_position()-hold_point
	var move_distance = position.distance_to(rect_position_buffer)
	
	move_rect(rect_position_buffer)

func get_type_for_shadow_viewport() -> ShadowViewport.NODE_TYPES:
	return TYPE_FOR_SHADOW_VIEWPORT

func _on_MovableItem_button_up() -> void:
	set_process_input(false)

func _on_MovableItem_button_down() -> void:
	set_process_input(true)

func _on_animated_sprite_2d_frame_changed() -> void:
	if not has_animation:
		return
	
	for node in linked_nodes_in_shadow_layers:
		node.update_anim(animated_sprite)
	
	var params = {}
	params["owner"] = self
	
	emit_signal("shadow_changed",self,params)

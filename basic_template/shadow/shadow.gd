extends TextureRect

const PATH_TO_SHADOW_MATERIAL = "res://basic_template/shadow/shadow_material.tres"
const TYPE_FOR_SHADOW_VIEWPORT = ShadowViewport.NODE_TYPES.IGNORE

@export var animated_sprite: AnimatedSprite2D
@export var label: Label

# Updates shadow parameters
func update_shadow(params: Dictionary) -> void:
	for key in params.keys():
		match key:
			"position":
				global_position = params["position"]
			"rotation":
				rotation = params["rotation"]
			"size":
				size = params["size"]
			"owner":
				update_anim(params["owner"])
				update_label(params["owner"])

func set_up_anim(copy_params_from: Node) -> void:
	var animation_holder = copy_params_from.animated_sprite
	
	animated_sprite.sprite_frames = animation_holder.sprite_frames
	animated_sprite.scale = animation_holder.scale
	animated_sprite.position = animation_holder.position

func update_anim(copy_params_from: Node) -> void:
	if not copy_params_from.has_animation:
		return
	
	var animation_holder = copy_params_from.animated_sprite
	if animated_sprite.scale != animation_holder.scale*size/copy_params_from.size:
		animated_sprite.scale = animation_holder.scale*size/copy_params_from.size
	
	if animated_sprite.animation != animation_holder.animation:
		animated_sprite.play(animation_holder.animation)
	
	if animated_sprite.speed_scale != animation_holder.speed_scale:
		animated_sprite.speed_scale = animation_holder.speed_scale
	
	if animated_sprite.centered != animation_holder.centered:
		animated_sprite.centered = animation_holder.centered
	
	if animated_sprite.flip_h != animation_holder.flip_h:
		animated_sprite.flip_h = animation_holder.flip_h
	
	animated_sprite.frame = animation_holder.frame

func update_label(copy_params_from: Node) -> void:
	if not copy_params_from.has_label:
		return
	
	var new_label = copy_params_from.label
	
	label.text = new_label.text
	
	label.set("theme_override_font_sizes/font_size",new_label.get("theme_override_font_sizes/font_size")*size.x/copy_params_from.size.x)

# Sets shadow material
func set_up_material() -> void:
	material = load(PATH_TO_SHADOW_MATERIAL)
	animated_sprite.material = load(PATH_TO_SHADOW_MATERIAL)
	label.material = load(PATH_TO_SHADOW_MATERIAL)

# Basic function that tells shadow_viewport node what type of node this is to correctly
# generate shadows
func get_type_for_shadow_viewport() -> ShadowViewport.NODE_TYPES:
	return TYPE_FOR_SHADOW_VIEWPORT

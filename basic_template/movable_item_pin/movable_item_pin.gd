extends Marker2D

const TYPE_FOR_SHADOW_VIEWPORT = ShadowViewport.NODE_TYPES.IGNORE

var movable_item: Node

func show_self(state: bool) -> void:
	self.visible = state
	movable_item.show_self(state)

func set_new_position(new_pos: Vector2) -> void:
	self.global_position = new_pos
	
	if movable_item.has_shadow and not movable_item.in_shadow_viewport:
		movable_item.update_shadow()

func update_anim(animation_holder: AnimatedSprite2D) -> void:
	movable_item.update_anim(animation_holder)

func get_type_for_shadow_viewport() -> ShadowViewport.NODE_TYPES:
	return TYPE_FOR_SHADOW_VIEWPORT

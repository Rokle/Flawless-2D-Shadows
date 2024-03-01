extends Control
# For some reason if there isn't texture with shadow present on scene 
# directly below (not as child) first shadow viewport 
# (can be obstucted) movable item doesn't cast shadow on anything 
# that is higher than first shadow layer in scene tree. Probably this has 
# something to do with way godot handles shaders
#
# If location occupies more than one screen this node should be duplicated
# and placed such as it or it duplicate always on scene in viewport view

const TYPE_FOR_SHADOW_VIEWPORT = ShadowViewport.NODE_TYPES.IGNORE

func get_type_for_shadow_viewport() -> ShadowViewport.NODE_TYPES:
	return TYPE_FOR_SHADOW_VIEWPORT

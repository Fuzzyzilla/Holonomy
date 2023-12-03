extends Spatial

signal selection_changed(idx)

export var title : String
export var options : Array
export var idx := 0

func _ready():
	var sprite : Sprite3D = $Sprite3D
	var viewport : Viewport = $Viewport
	sprite.texture = viewport.get_texture()
	sprite.texture.flags = Texture.FLAG_FILTER
	$Viewport/Label.text = title
	$Viewport/Label2.text = options[idx]
	
func on_select() -> int:
	idx += 1
	idx %= options.size()
	$Viewport/Label2.text = options[idx]
	emit_signal("selection_changed", idx)
	return idx

func disable():
	$Viewport.render_target_clear_mode = Viewport.CLEAR_MODE_NEVER
	$Viewport.render_target_update_mode = Viewport.CLEAR_MODE_NEVER

extends Sprite

export var fill_ratio : float setget set_fill_ratio
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	self.scale = Vector2.ZERO
	self.modulate.a = 0
	pass # Replace with function body.

func _process(_delta):
	self.global_position = get_viewport_rect().size / 2.0
	
func set_fill_ratio(fill : float):
	var max_radius := (get_viewport_rect().size / 2.0).length()
	var radius := max_radius / sqrt(16*16*2) * fill
	self.scale = Vector2(radius, radius);
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

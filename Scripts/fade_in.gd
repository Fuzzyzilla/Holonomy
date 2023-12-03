extends Node2D

export var on_load : bool = true
export var on_load_delay : float = 0.0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var tween : Tween
var timer : SceneTreeTimer

var shown := false

var initial_y : float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.modulate.a = 0.0
	tween = Tween.new()
	self.add_child(tween)
	
	initial_y = position.y
	
	position.y += 10
	
	if on_load:
		if on_load_delay <= 0.0:
			show()
		else:
			timer = get_tree().create_timer(on_load_delay)
			timer.connect("timeout", self, "show")
		
func show():
	if shown: return
	shown = true
	tween.stop_all()
	tween.interpolate_property(self, "position:y", position.y, initial_y, 1.0, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.interpolate_property(self, "modulate:a", self.modulate.a, 1.0, 1.0, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()

func hide():
	if timer:
		timer.disconnect("timeout", self, "show")
		timer = null
	if not shown: return
	shown = false
	tween.stop_all()
	tween.interpolate_property(self, "position:y", position.y, initial_y + 10, 1.0, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.interpolate_property(self, "modulate:a", self.modulate.a, 0.0, 1.0, Tween.TRANS_SINE, Tween.EASE_OUT)
	tween.start()
	
func show_if_player(body):
	if body.is_in_group("Player"):
		show()
func hide_if_player(body):
	if body.is_in_group("Player"):
		hide()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

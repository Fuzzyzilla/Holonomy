extends Node2D

export var margin : float
var button_size : float = 50.0
var flip : bool = false

export var enabled : bool = false

func _ready():
	$BackBtn.global_position = Vector2(margin + button_size, margin + button_size) * 0.5

func _process(_delta):
	self.visible = enabled
	
	var viewport_size := get_viewport_rect().size
	
	var joystick = $Joystick
	joystick.enabled = enabled
	joystick.global_position.x = joystick.graphic_radius + margin if flip else viewport_size.x - (joystick.graphic_radius + margin)
	joystick.global_position.y = viewport_size.y - (joystick.graphic_radius + margin)
	
	var button = $"Jump btn"
	button.global_position.x = button_size + margin if not flip else viewport_size.x - (button_size + margin)
	button.global_position.y = get_viewport_rect().size.y - margin - button_size

func _input(event):
	if event is InputEventKey:
		animate_enable(false)
	elif event is InputEventScreenTouch:
		self.visible = enabled
		animate_enable(enabled)

func animate_enable(enable : bool):
	$Tween.interpolate_property(self, "modulate:a", self.modulate.a, 1.0 if enable else 0.0, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT);
	$Tween.start()

extends Node2D

export var enabled : bool = false setget set_enabled
export var touch_distance : float
export var graphic_radius : float setget set_radius

var touched_finger = -1;

var touch_pos := Vector2.ZERO

func _ready():
	self.visible = enabled

func _process(_delta):
	self.visible = enabled
	var cur_pos = $Rect.position
	
	var new_pos = lerp(cur_pos, touch_pos, 0.5)
	
	$Rect.position = new_pos
	$Line.scale.x = new_pos.length()
	$Line.rotation = 0.0 if $Line.scale.x < 0.01 else atan2(new_pos.y, new_pos.x)
	$Rect.rotation = ($Line.scale.x/graphic_radius) * $Line.rotation
	pass

func set_radius(rad : float):
	graphic_radius = rad
	var circle = get_node_or_null("Circle")
	if circle:
		circle.scale = Vector2(graphic_radius, graphic_radius)/20.0
	else:
		call_deferred("set_radius", rad)
func set_enabled(en : bool):
	enabled = en
	self.visible = en
	if not en:
		self.set_pressed(false)
		touched_finger = -1

func _input(event):
	if not enabled or not is_visible_in_tree(): return
	
	if event is InputEventScreenTouch:
		var e := event as InputEventScreenTouch
		
		if e.pressed and touched_finger == -1 and is_in_touch_range(e.position):
			touched_finger = e.index
			set_global_position(e.position)
			set_pressed(true)
		elif not e.pressed and touched_finger == e.index:
			touched_finger = -1
			set_pressed(false)
			set_position(Vector2.ZERO)
		
	elif event is InputEventScreenDrag:
		if event.index == touched_finger:
			set_global_position(event.position)

func is_in_touch_range(pos : Vector2) -> bool:
	return (self.transform.xform_inv(pos)).length_squared() < touch_distance * touch_distance

func set_global_position(pos : Vector2):
	set_position(self.transform.xform_inv(pos))

func set_position(pos : Vector2):
	if pos.length_squared() > 0:
		var length = min(pos.length(), graphic_radius)
		pos = pos.normalized() * length
	touch_pos = pos
	if pos.x > 0.5:
		Input.action_press("ui_right", pos.x/graphic_radius)
	elif pos.x < -0.5:
		Input.action_press("ui_left", -pos.x/graphic_radius)
	else:
		Input.action_release("ui_left")
		Input.action_release("ui_right")

func set_pressed(pressed: bool):
	$Tween.stop_all()
	if not pressed:
		$Tween.interpolate_property($Circle, "modulate:a", $Circle.modulate.a, 1.0, 2.0, Tween.TRANS_SINE, Tween.EASE_OUT)
	else:
		$Tween.interpolate_property($Circle, "modulate:a", $Circle.modulate.a, 0.0, 1.0, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
		

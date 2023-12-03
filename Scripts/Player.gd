extends KinematicBody2D

export(Color) var light_color;
export(Color) var dark_color;
export var damp := 1.0

const GRAVITY = 1000.0
const RESTITUTION = 0.2
const JUMP_STRENGTH = 400.0
const JUMP_CANCEL_FACTOR = 0.5
const MAX_HSPEED = 200.0
const AIR_FRICTION = 0.9
const GROUND_FRICTION = 0.7
const MOVEMENT_ACCELERATION = 1500.0
const TERMINAL_VELOCITY = 800
const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.2

var basis_y = Vector2.DOWN
var basis_x = Vector2.RIGHT

var velocity : Vector2
var can_jump : bool = false
var is_jumping : bool = false

var finishing_anim : bool = false
var anim_finished : bool = false
var goal_taken : Node2D

var coyote_time := 0.0
var jump_buffer := 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func get_vertical_velocity():
	return (velocity.dot(basis_y)/basis_y.length_squared())
func get_horizontal_velocity():
	return (velocity.dot(basis_x)/basis_x.length_squared())
func set_horizontal_velocity(x : float):
	velocity = get_vertical_velocity() * basis_y + x * basis_x
func set_vertical_velocity(y : float):
	velocity = get_horizontal_velocity() * basis_x + y * basis_y
	

func _physics_process(delta : float) -> void:
	#free_fly(delta)
	#return
	
	if not finishing_anim:
		if Input.is_action_just_pressed("ui_cancel"):
			var root = get_tree().get_nodes_in_group("3DRoot")[0]
			root.begin_load_anim(-1)
		velocity += GRAVITY * basis_y * delta
		
		if Input.is_action_just_pressed("ui_up"):
			jump_buffer = JUMP_BUFFER_TIME
		#jump start
		if not is_jumping and coyote_time > 0.0 and jump_buffer > 0.0:
			set_vertical_velocity(-JUMP_STRENGTH)
			is_jumping = true
			coyote_time = 0.0
			jump_buffer = 0.0
		#jump cancel
		if is_jumping and not Input.is_action_pressed("ui_up"):
			set_vertical_velocity(get_vertical_velocity() * JUMP_CANCEL_FACTOR)
			is_jumping = false
		
		#jump end
		if is_jumping and get_vertical_velocity() >= 0.0:
			is_jumping = false
		
		set_vertical_velocity(min(TERMINAL_VELOCITY, get_vertical_velocity()))
		
		var hmove_strength = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		#friction
		if hmove_strength == 0.0:
			if self.is_on_floor():
				set_horizontal_velocity(get_horizontal_velocity() * GROUND_FRICTION)
			else:
				set_horizontal_velocity(get_horizontal_velocity() * AIR_FRICTION)
		#movement
		else:
			velocity += hmove_strength * delta * MOVEMENT_ACCELERATION * basis_x
			set_horizontal_velocity(clamp(get_horizontal_velocity(), -MAX_HSPEED, MAX_HSPEED))
	else: #finished
		var diff = (goal_taken.global_position - self.global_position)
		velocity += diff * 40 * delta
		velocity *= 0.95
		
		if not anim_finished and diff.length_squared() < 100.0 and velocity.length_squared() < 100.0:
			$Tween.interpolate_property($CircleScalar/Circle, "scale", $CircleScalar/Circle.scale, Vector2.ONE, 1.0,Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			$Tween.interpolate_property(self, "modulate", self.modulate, Color(1.0,1.0,1.0,0.5), 1.0,Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
			$Tween.interpolate_property(self, "visible", true, true, 2.0) #just for delay
			$Tween.start()
			$Tween.connect("tween_all_completed", self, "exit_level")
			anim_finished = true
			
			
		
	coyote_time -= delta
	jump_buffer -= delta
		
	
	velocity *= damp
	
	var new_velocity = self.move_and_slide(velocity, -basis_y)
	if self.is_on_floor() and get_vertical_velocity() > 0.0:
		coyote_time = COYOTE_TIME
	
	#TODO: Restitution
	var applied_force = (new_velocity - velocity)
	var bounce = applied_force * RESTITUTION
	velocity = new_velocity
	velocity += bounce
	
	if applied_force.length_squared() > 10000:
		play_bonk(applied_force)
		
		
#	position.x = fmod(position.x, 2048.0)
#	if position.x < 0:
#		position.x += 2048.0 #should be handled by fmod but it's not???
	
	do_stretch()

func play_bonk(force: Vector2):
	var new_vol = linear2db(clamp((force.length_squared()-10000.0)/300000.0, 0.0, 1.0)) +1.0
	
	var sound := $KnockSound
	
	sound.volume_db = new_vol
	sound.play()
		

func get_axis_aligned_velocity() -> Vector2:
	return Vector2(get_horizontal_velocity(), get_vertical_velocity())
func set_axis_aligned_velocity(vel : Vector2):
	velocity = vel.x * basis_x + vel.y * basis_y

func free_fly(delta):
	var horiz = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var vert = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	self.position += (horiz * basis_x + vert * basis_y) * delta * MAX_HSPEED

func _process(_delta):
	unproject()
	do_stretch()

func get_face() -> int:
	var face := floor(position.x/512) as int
	if face < 0 or face > 5:
		print("Bad face index. %s" % face)
	
	return 0 if face < 0 else (5 if face > 5 else face)

func do_stretch():
	$CircleScalar.scale.x = 1.0 + velocity.length()/1500.0
	$CircleScalar.rotation = velocity.angle()
	
func exit_level():
	var root = get_tree().get_nodes_in_group("3DRoot")[0]
	root.begin_load_anim(goal_taken.next_level)

func on_goal_entered(goal : Node2D):
	finishing_anim = true
	goal_taken = goal
	$Tween.interpolate_property(goal, "scale", goal.scale, Vector2.ZERO, 2.0, Tween.TRANS_SINE, Tween.EASE_IN)
	$Tween.start()

func unproject() -> Vector3:
	var frame_id = get_face()
	var project_position = Vector2(self.position.x - frame_id * 512.0, self.position.y)
	
	var root = get_tree().get_nodes_in_group("3DRoot")[0]
	
	root.focus_unproject(frame_id, project_position, basis_x, basis_y)
	
	return Vector3.ZERO
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

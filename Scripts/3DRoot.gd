extends Spatial

var next_level : String
var next_level_decor : String

const MAIN_MENU = "mm"

export var global_volume : float = 0.0 setget set_global_volume
export var max_volume : float = 0.0 setget set_max_volume
export var high_contrast : bool = false

export(Color) var menu_light_color;
export(Color) var menu_dark_color;

var current_level : Node
var level_decor : Spatial

var actual_divisor : float = 100000.0
var selected_divisor : float = 1.0

func set_selected_divisor(quality : float):
	selected_divisor = quality
	if selected_divisor > actual_divisor:
		set_quality_divisor_immediate(quality)

func set_quality_divisor_immediate(quality : float):
	actual_divisor = quality
	selected_divisor = quality
	$Viewport.size = Vector2(6144, 1024)/(quality as float)
	$Viewport/Camera2D.zoom = Vector2(0.5,0.5) * quality as float
	
	var filter : bool = quality > 1.0
	var idx := 0
	var region_size = 1024 / quality as float
	for frame in $Frames.get_children():
		frame.texture.flags = Texture.FLAG_FILTER if filter else 0
		frame.region_rect.position.x = region_size * idx
		frame.region_rect.size = Vector2(region_size, region_size)
		frame.pixel_size = 0.01 * quality as float
		idx += 1

func _ready():
	set_viewport_enabled(false)
	$Frames.visible = false
	$CameraFocus.transform = $LevelSelectFocus.transform
	call_deferred("setup_color")
	
	$Camera/Menu/MenuFade.play_backwards("FadeOut")
	
	get_tree().set_auto_accept_quit(false)
	#begin_load_anim(0)

func set_viewport_enabled(enabled : bool):
	if enabled and actual_divisor != selected_divisor:
		set_quality_divisor_immediate(selected_divisor)
	$Viewport.render_target_clear_mode = Viewport.CLEAR_MODE_ALWAYS if enabled else Viewport.CLEAR_MODE_NEVER
	$Viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS if enabled else Viewport.UPDATE_DISABLED

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		quit()
	elif what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST:
		if current_level:
			begin_load_anim(-1)
		else:
			quit()
func quit():
	if OS.has_feature("HTML5"):
		OS.window_fullscreen = false
	else:
		get_tree().quit()

func _input(event):
	if event is InputEventKey:
		var key_event = event as InputEventKey
		if not key_event.pressed or key_event.echo:
			return
		
		if key_event.scancode == KEY_F or key_event.scancode == KEY_F11:
			OS.window_fullscreen = not OS.window_fullscreen
			
		if key_event.scancode == KEY_ESCAPE and current_level == null:
			quit()

func setup_color():
	$Colorizer.material.set_shader_param("light_color", color2vec3(menu_light_color))
	$Colorizer.material.set_shader_param("dark_color", color2vec3(menu_dark_color))

func focus_unproject(frame_id : int, position : Vector2, right_vec, up_vec : Vector2):
	if frame_id > 5 or frame_id < 0:
		return Vector3.ZERO
	
	var frame = $Frames.find_node("%s" % frame_id, false)
#
#	var frame_rotations = [
#		0.0,
#		deg2rad(90.0),
#		deg2rad(180.0),
#		deg2rad(270.0),
#	]
#
	var face_axes = [
		Vector3(1.0,1.0,0.0),
		Vector3(0.0,1.0,1.0),
		Vector3(1.0,1.0,0.0),
		Vector3(0.0,1.0,1.0),
		Vector3(1.0,0.0,1.0),
		Vector3(1.0,0.0,1.0),
	]

	position = position * 2 - Vector2.ONE * 512
#	$CameraFocus.transform.basis = Basis.IDENTITY.rotated(Vector3(0.0,1.0,0.0), frame_rotations[frame_id])
#	$CameraFocus.transform.origin = frame.transform.xform(Vector3(position.x, -position.y, 1.0) / 100.0)

	$CameraFocus.transform.origin = frame.transform.xform((Vector3(position.x, -position.y, 1.0))/ 100.0)
	$CameraFocus.look_at($CameraFocus.transform.origin * face_axes[frame_id], Vector3.UP if frame_id < 4 else Vector3.LEFT)

	var xformed_up = frame.transform.basis.xform(Vector3(-up_vec.x, up_vec.y, 0.0))
	var xformed_right = frame.transform.basis.xform(Vector3(right_vec.x, right_vec.y, 0.0))
	$CameraFocus.up_vec = xformed_up
	$CameraFocus.right_vec = xformed_right
	
	$TestVec.transform.origin = $CameraFocus.transform.origin
	$TestVec.transform.basis = Basis($CameraFocus.right_vec, Vector3(0.0,1.0,0.0), Vector3(0.0,0.0,1.0))
	
func begin_load_anim(next_idx : int):
	if self.next_level.empty():
		var is_level_idx : bool = next_idx >= 0 and next_idx < $LevelSelect.LEVELS.size()
		self.next_level = MAIN_MENU if not is_level_idx else $LevelSelect.LEVELS[next_idx].path
		$AnimationPlayer.stop()
		$AnimationPlayer.play("LevelTransition")
			
		if is_level_idx:
			$LevelSelect.set_current(next_idx)
		
		self.next_level_decor = "" if not is_level_idx else $LevelSelect.LEVELS[next_idx].decor
	
func load_next():
	if current_level:
		$Viewport.remove_child(current_level)
		current_level.queue_free()
	if level_decor:
		self.remove_child(level_decor)
		level_decor.queue_free()
		level_decor = null
	
	if next_level == MAIN_MENU:
		$LevelSelect.visible = true
		$"Mobile Controls".enabled = false
		$Frames.visible = false
		set_viewport_enabled(false)
		
		current_level = null
		$CameraFocus.transform = $LevelSelectFocus.transform
		$CameraFocus.up_vec = Vector3.UP
		
		transition_colors(menu_light_color, menu_dark_color)
		$Camera/Menu/MenuFade.play_backwards("FadeOut")
	else:
		#Leaving main menu
		if not current_level:
			$Camera/Menu/MenuFade.play("FadeOut")
			
		$LevelSelect.visible = false
		$"Mobile Controls".enabled = true
		$Frames.visible = true
		set_viewport_enabled(true)
		
		
		current_level = load(next_level).instance()
		$Viewport.add_child(current_level)
		
		if not next_level_decor.empty():
			level_decor = load(next_level_decor).instance()
			self.add_child_below_node(self.get_child(0), level_decor)
		
		var player = current_level.find_node("Player")
		if player:
			transition_colors(player.light_color, player.dark_color)
			#For thumbnail grabbing
			#transition_colors(Color.white, Color.black)
	next_level = ""

func transition_colors(light: Color, dark : Color):
	var colorizer = $Colorizer
	var cur_light = colorizer.material.get_shader_param("light_color")
	var cur_dark = colorizer.material.get_shader_param("dark_color")
	
	if high_contrast:
		var inverted := light.gray() < dark.gray()
		light = Color.white if not inverted else Color.black
		dark  = Color.white if inverted else Color.black
	
	var tweener = $Colorizer/ColorTween

	tweener.interpolate_method(self, "set_light_color", cur_light, color2vec3(light), 1.0)
	tweener.interpolate_method(self, "set_dark_color", cur_dark, color2vec3(dark), 1.0)
	tweener.start()
	

func color2vec3(color : Color) -> Vector3:
	return Vector3(color.r, color.g, color.b)

func set_light_color(col : Vector3):
		$Colorizer.material.set_shader_param("light_color", col)
func set_dark_color(col : Vector3):
		$Colorizer.material.set_shader_param("dark_color", col)
	
func set_global_volume(vol : float):
	global_volume = vol
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), global_volume + max_volume);

func set_max_volume(vol : float):
	max_volume = vol
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), global_volume + max_volume);

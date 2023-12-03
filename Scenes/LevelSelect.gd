extends MeshInstance

const DOT_SPACING = 0.6

var current_face = 0
var current_level = 0

var current_rotation = 0.0
var final_rotation = 0.0

var current_pane : Node
#const LEVELS := [
#	"res://Scenes/TestLevel.tscn", "res://Scenes/HolonomyIntro.tscn", 1, 1]

const OPTION_PANES := [
	{"func": "set_fullscreen", "title":"Fullscreen", "options":["Off", "On"]},
	{"func": "set_max_volume", "title":"Master\nVolume", "options":["High", "Mute", "Low","Medium"], "values":[0.0,-80.0,-20.0,-10.0]},
	{"func": "set_render_quality", "title":"Render\nQuality", "options":["100%", "50%", "25%", "200%"], "values":[1.0,2.0,4.0,0.5]},
	{"func": "set_mobile_handedness", "title":"Joystick\nPosition", "options":["Right", "Left"]},
	{"func": "set_high_contrast", "title":"High Contrast\n(Greyscale)", "options":["Off", "On"]},
]

const LEVELS := [
	{"path":"res://Scenes/TestLevel.tscn", "decor":"res://Scenes/TestLevelDecor.tscn", "title": "Cylindric."},
	{"path":"res://Scenes/HolonomyIntro.tscn", "decor":"res://Scenes/HolonomyIntroDecor.tscn", "title": "This way up."},
	{"path":"res://Scenes/Level3.tscn", "decor":"res://Scenes/Level3Decor.tscn", "title": "Freefall."},
	{"path":"res://Scenes/Level4.tscn", "decor":"res://Scenes/Level4Decor.tscn", "title": "Forest."},
	{"path":"res://Scenes/Level5.tscn", "decor":"res://Scenes/Level5Decor.tscn", "title": "Maze."},
	{"path":"res://Scenes/Level6.tscn", "decor":"res://Scenes/Level6Decor.tscn", "title": "Circuit."},
	{"path":"res://Scenes/End.tscn", "decor":"res://Scenes/EndDecor.tscn", "title": "End."},
]

func _ready():
	generate_face(current_face, current_level + 1)
	get_parent().get_node("Camera/Menu/LevelName").text = LEVELS[current_level].title

func set_current(level):
	current_level = level
	generate_face(current_face, current_level + 1)
	get_parent().get_node("Camera/Menu/LevelName").text = LEVELS[current_level].title
	
	get_parent().get_node("Camera/Menu/HBoxContainer/Left/Arrow").modulate.a = 0.5 if current_level == -OPTION_PANES.size() else 1.0
	get_parent().get_node("Camera/Menu/HBoxContainer/Right/Arrow").modulate.a = 0.5 if current_level == LEVELS.size() else 1.0
	
	
	if current_level == 0:
		get_parent().get_node("Camera/Menu/HBoxContainer/Left/OptionsLabel").show()
	else:
		get_parent().get_node("Camera/Menu/HBoxContainer/Left/OptionsLabel").hide()
		
	if current_level == LEVELS.size() - 1:
		get_parent().get_node("Camera/Menu/HBoxContainer/Right/CreditsLabel").show()
	else:
		get_parent().get_node("Camera/Menu/HBoxContainer/Right/CreditsLabel").hide()


func set_max_volume(idx) :
	OPTION_PANES[1].last_idx = idx
	get_parent().max_volume = OPTION_PANES[1].values[idx]
func set_high_contrast(idx) :
	OPTION_PANES[4].last_idx = idx
	get_parent().high_contrast = idx == 1
func set_mobile_handedness(idx) :
	OPTION_PANES[3].last_idx = idx
	get_parent().get_node("Mobile Controls").flip = idx == 1
func set_fullscreen(idx) :
	OS.window_fullscreen = idx == 1
func set_render_quality(idx):
	get_parent().set_selected_divisor(OPTION_PANES[2].values[idx])
	OPTION_PANES[2].last_idx = idx
	
func _process(_delta):
	if not self.visible:
		return
	
	if Input.is_action_just_pressed("ui_accept"):
		$ClickSound.play()
		if current_level >= 0 and current_level < LEVELS.size():
			get_parent().begin_load_anim(current_level)
		elif current_pane:
			current_pane.on_select()
			
			
	var rotate_to : float = final_rotation
	var right := deg2rad(-90.0)
	var left := deg2rad(90.0)

	var needs_update := false

	if Input.is_action_just_pressed("ui_left"):
		if final_rotation - current_rotation > deg2rad(180.0):
			return;
		if current_level == -OPTION_PANES.size():
			return;
		$ClickSound.play()
		current_face -= 1
		if current_face == -1: current_face = 3
		current_level -= 1
		rotate_to += left
		if current_pane:
			current_pane.disable()
			current_pane = null
		
		needs_update = true
		
	elif Input.is_action_just_pressed("ui_right"):
		if final_rotation - current_rotation < -deg2rad(180.0):
			return;
		if current_level == LEVELS.size():
			return;
		$ClickSound.play()
		current_face += 1
		current_face %= 4
		current_level += 1
		rotate_to += right
		if current_pane:
			current_pane.disable()
			current_pane = null
		
		needs_update = true
	else:
		return
	
	if needs_update:
			
		get_parent().get_node("Camera/Menu/HBoxContainer/Left").modulate.a = 0.5 if current_level == -OPTION_PANES.size() else 1.0
		get_parent().get_node("Camera/Menu/HBoxContainer/Right").modulate.a = 0.5 if current_level == LEVELS.size() else 1.0
		
		
		if current_level == 0:
			get_parent().get_node("Camera/Menu/HBoxContainer/Left/OptionsLabel").show()
		else:
			get_parent().get_node("Camera/Menu/HBoxContainer/Left/OptionsLabel").hide()
			
		if current_level == LEVELS.size() - 1:
			get_parent().get_node("Camera/Menu/HBoxContainer/Right/CreditsLabel").show()
		else:
			get_parent().get_node("Camera/Menu/HBoxContainer/Right/CreditsLabel").hide()
			
		var name_title = get_parent().get_node("Camera/Menu/LevelName")
		if current_level >= 0 and current_level < LEVELS.size():
			name_title.text = LEVELS[current_level].title
		elif current_level < 0:
			name_title.text = "Options."
		else: name_title.text = "Credits."
		
		generate_face(current_face, current_level+1)
		
		$Tween.interpolate_method(self, "set_rot", current_rotation, rotate_to, 0.5, Tween.TRANS_SINE, Tween.EASE_OUT);
		final_rotation = rotate_to
		$Tween.start()

func set_rot(rot : float):
	current_rotation = rot
	self.transform.basis = Basis.IDENTITY.scaled(Vector3(5.12, 5.12, 5.12)) \
		.rotated(Vector3(0.0,1.0,0.0), rot)

func generate_face(face : int, count : int):
	var face_group = get_node("%s" % face)
	
	for object in face_group.get_children():
		face_group.remove_child(object)
	
	var pip = preload("res://Objects/3DPip.tscn")
	
	if count <= 0:
		OPTION_PANES[0].last_idx = 1 if OS.window_fullscreen else 0
		
		var pane_config := OPTION_PANES[-count] as Dictionary
		current_pane = load("res://Objects/OptionPane.tscn").instance();
		current_pane.title = pane_config.title
		current_pane.options = pane_config.options
		current_pane.connect("selection_changed", self, pane_config.func)
		current_pane.idx = 0 if not pane_config.has("last_idx") else pane_config.last_idx
		face_group.add_child(current_pane)
		return
	
	if count == LEVELS.size() + 1:
		current_pane = load("res://Objects/CreditsText.tscn").instance();
		face_group.add_child(current_pane)
		return
	
	#odd numbers, put a pip in the middle
	if count & 1 != 0:
		face_group.add_child(pip.instance())
	
	var corner_offset = Vector3(DOT_SPACING,DOT_SPACING,0.0)
	if count >= 2:
		var obj = pip.instance()
		obj.transform.origin = corner_offset
		face_group.add_child(obj)
		obj = pip.instance()
		obj.transform.origin = -corner_offset
		face_group.add_child(obj)
	
	corner_offset = Vector3(-DOT_SPACING,DOT_SPACING,0.0)
	if count >= 4:
		var obj = pip.instance()
		obj.transform.origin = corner_offset
		face_group.add_child(obj)
		obj = pip.instance()
		obj.transform.origin = -corner_offset
		face_group.add_child(obj)
	
	corner_offset = Vector3(DOT_SPACING,0.0,0.0)
	if count >= 6:
		var obj = pip.instance()
		obj.transform.origin = corner_offset
		face_group.add_child(obj)
		obj = pip.instance()
		obj.transform.origin = -corner_offset
		face_group.add_child(obj)

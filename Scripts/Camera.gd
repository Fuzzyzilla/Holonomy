extends Camera

var noise = OpenSimplexNoise.new()
export var wiggle_amount := 0.5

func _ready():
	noise.period = 7.0
	noise.persistence = 0.8
	noise.octaves = 3

func _process(_delta):
	#For thumbnail grabbing
	#var target = get_parent().get_node("TestTarget")
	var target = get_tree().get_nodes_in_group("CameraTarget")[0]
	#For thumbnail grabbing
	#var target = get_parent().get_node("TestTarget")
	
	var target_xform = target.global_transform#.looking_at(Vector3.ZERO, Vector3(0.0,1.0,0.0))
	
	var origin = target_xform.xform(Vector3(0.0,0.0,8.5))
	
	var noise_offset = wiggle_amount * 3.0* Vector3(noise.get_noise_1d(OS.get_ticks_msec()/1000.0), 0.3 + 0.5 * noise.get_noise_1d(OS.get_ticks_msec()/1000.0 + 1522.634), 0.0)
	
	noise_offset = target_xform.basis.xform(noise_offset)
	origin += noise_offset
	
	var new_xform = Transform.IDENTITY.translated(origin).looking_at(target_xform.xform(Vector3.ZERO), target.up_vec)
	
	self.transform = self.transform.interpolate_with(new_xform, 0.05)
	
	"""
	var target = get_tree().get_nodes_in_group("CameraTarget")[0]
	var target_xform = target.global_transform.looking_at(Vector3.ZERO, Vector3(0.0,1.0,0.0))
	
	var camera_normal = target_xform.xform(Vector3.BACK * 0.1)#right_vec.cross(target.up_vec).normalized()
	
	var origin = camera_normal*8.5 + target_xform.origin
	
	var noise_offset = 3.0* Vector3(noise.get_noise_1d(OS.get_ticks_msec()/1000.0), 0.3 + 0.5 * noise.get_noise_1d(OS.get_ticks_msec()/1000.0 + 1522.634), 0.0)
	
	noise_offset = target_xform.basis.xform(noise_offset)
	
	#thumbnail grabbing:
	#noise_offset = Vector3.ZERO	
	origin += noise_offset
	
	var new_xform = Transform.IDENTITY.translated(origin).looking_at(target_xform.xform(Vector3.ZERO), target.up_vec)
	
	self.transform = self.transform.interpolate_with(new_xform, 0.06)"""

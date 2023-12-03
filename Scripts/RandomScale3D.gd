extends MeshInstance

export var min_scale : float
export var max_scale : float

var initial_basis : Basis
var period = 10000

func _ready():
	initial_basis = self.transform.basis

func _process(_delta):
	var new_scale = rand_range(min_scale, max_scale)
	self.transform.basis = initial_basis.scaled(Vector3(new_scale, new_scale, new_scale))
	
	if OS.get_ticks_msec() % period < rand_range(0,2000):
		self.transform.basis = self.transform.basis.rotated(random_vec(), 1.0)
		get_parent().find_node("BigParticles").emitting = true
		get_parent().find_node("ElectricNoise").volume_db = -2.0
	else:
		get_parent().find_node("BigParticles").emitting = false
		get_parent().find_node("ElectricNoise").volume_db = -15.0
		
	if OS.get_ticks_msec() % period <= 100:
		period = rand_range(2000,8000) as int
		
func random_vec() -> Vector3:
	var x = rand_range(-1.0,1.0)
	var y = rand_range(-1.0,1.0)
	var z = rand_range(-1.0,1.0)
	
	return Vector3(x,y,z).normalized()

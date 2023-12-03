extends MeshInstance

export(Vector3) var axis
export var speed : float

func _process(delta):
	self.rotate(axis.normalized(), speed * delta)

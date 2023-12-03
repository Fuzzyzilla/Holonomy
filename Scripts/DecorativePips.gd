extends Node2D

export var numPips : int

const PIP_OFFSET = 125


# Called when the node enters the scene tree for the first time.
func _ready():
	var pip_scene = preload("res://Objects/2DPip.tscn")
	#odd num, center pip
	if numPips & 1 != 0:
		self.add_child(pip_scene.instance())
	
	var offset := Vector2(PIP_OFFSET, -PIP_OFFSET)
	if numPips >= 2:
		var pip = pip_scene.instance()
		self.add_child(pip)
		pip.translate(offset)
		pip = pip_scene.instance()
		self.add_child(pip)
		pip.translate(-offset)
		
	offset = Vector2(-PIP_OFFSET, -PIP_OFFSET)
	if numPips >= 4:
		var pip = pip_scene.instance()
		pip.translate(offset)
		self.add_child(pip)
		pip = pip_scene.instance()
		pip.translate(-offset)
		self.add_child(pip)
		
	offset = Vector2(-PIP_OFFSET, 0.0)
	if numPips >= 6:
		var pip = pip_scene.instance()
		pip.translate(offset)
		self.add_child(pip)
		pip = pip_scene.instance()
		pip.translate(-offset)
		self.add_child(pip)
	

func remove_pip(idx : int):
	if idx != -1 and idx < self.get_child_count():
		self.remove_child(self.get_child(idx))

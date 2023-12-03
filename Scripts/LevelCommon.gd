extends Node2D

export var missing_face : int = -1
export var missing_pip : int = -1

func _ready():
	if missing_face != -1:
		$"Background Dots".find_node("%s" % missing_face).remove_pip(missing_pip)

extends Spatial

func on_select() -> int:
	$Programming.visible = not $Programming.visible
	$Sounds.visible = not $Sounds.visible
	
	return 0

func disable():
	pass

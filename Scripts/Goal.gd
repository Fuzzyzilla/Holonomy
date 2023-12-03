extends CPUParticles2D

export var next_level : int = 0

func _process(_delta):
	var scale = rand_range(0.4,0.6)
	$Sprite.scale = Vector2(scale, scale)


func on_body_entered(body : Node):
	if body.is_in_group("Player"):
		body.on_goal_entered(self)

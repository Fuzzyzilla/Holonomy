extends Area2D

export var warp_to : NodePath
export var new_y : Vector2
export var new_x : Vector2
export var face : int

func _ready():
	pass#self.global_position -= self.transform.basis_xform(Vector2.UP)*5
	
func _on_body_entered(body : Node2D):
	if not warp_to:
		return
	if body.is_in_group("Player"):
		if body.get_face() != face:
			return
			
		var kin_body := body as KinematicBody2D
		
		var out_portal := get_node(warp_to) as Area2D
		
		var pos = body.global_position
		var relative_pos = self.transform.xform_inv(pos)
		var vel = body.get_axis_aligned_velocity();	
			
		relative_pos.y = -10-18
		
		var out_pos = out_portal.transform.xform(relative_pos)
		
		var new_transform = kin_body.transform
		new_transform.origin = out_pos
		
		var do_basis_shift := true
		
		var normal_dir = self.transform.basis_xform(Vector2.UP).normalized()
		
#		out_portal.monitoring = false
#		if kin_body.test_move(new_transform, Vector2.ZERO):
#			out_portal.set_collidable(true)
#			out_pos = self.transform.xform(relative_pos)
#			do_basis_shift = false
#			vel.x *= normal_dir.x
#			vel.y *= normal_dir.y
#
#		out_portal.monitoring = true
		
		body.global_position = out_pos
		
		
		if do_basis_shift:
			
			var new_basis_x = new_x.x * body.basis_x + new_x.y * body.basis_y
			var new_basis_y = new_y.x * body.basis_x + new_y.y * body.basis_y
			body.basis_x = new_basis_x
			body.basis_y = new_basis_y
			
		
		body.set_axis_aligned_velocity(vel)
#
#
#func _on_body_exited(body):
#	if body.is_in_group("Player"):
#		if body.get_face() != face:
#			return
#		var out_portal := get_node(warp_to) as Area2D
#		out_portal.set_collidable(false)
#

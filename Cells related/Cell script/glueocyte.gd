extends BaseCell
class_name Glueocyte
func correct_appearance(delta, modify_color_radius = true):
	super(delta, modify_color_radius)
	$renders/glue.material.set_shader_parameter("cell_color", current_color * 0.5)
	$renders/glue.material.set_shader_parameter("cell_rot", angular_velocity * 0.01)
	$renders/glue.material.set_shader_parameter("cell_move", Vector2(-velocity.x, velocity.y) / 5000)
	$renders/glue.scale = Vector2(radius / 15, radius / 15)
func _cell_entered(area: Area2D) -> void:
	is_colliding = true
	colliding.append(area)
	
	if area is BaseCell and adhesion.size() <= 8:
		adhesion.append(area)
		area.adhesion.append(self)

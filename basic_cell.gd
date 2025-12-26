extends CharacterBody2D
#alredy assigned
@export var m_is_colliding_with: Node2D
func get_midpoint_intersection(c1: Vector2, c2: Vector2):
	#DOES NOT WORK WITH DIFFERENT RADIUS
	return (c1 + c2) / 2
func angle_to(c):
	return (c - position).angle() + PI * 0.5
func _process(_delta: float) -> void:
	$MeshInstance2D.global_position = get_midpoint_intersection(position, m_is_colliding_with.position)
	$render.material.set_shader_parameter("centers", PackedVector2Array([get_midpoint_intersection(position, m_is_colliding_with.position)]))
	$render.material.set_shader_parameter("rotations", PackedFloat32Array([get_angle_to(m_is_colliding_with.position)]))
	$render.material.set_shader_parameter("cell_count", 1)

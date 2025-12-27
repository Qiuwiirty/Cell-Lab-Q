extends CharacterBody2D
#already assigned the colliding with
#NOTE: THIS IS A TEMPORARY CODE, NEED WORK. THIS IS TO TEST IF IT WORK PROPERLY!! 
@export var m_is_colliding_with: Node2D
func get_midpoint_intersection(c1: Vector2, c2: Vector2):
	#DOES NOT WORK WITH DIFFERENT RADIUS
	return (c1 + c2) / 2
func _ready() -> void:
	$render.material = $render.material.duplicate()
func world_to_uv(world_pos: Vector2) -> Vector2:
	var local_pos = $render.to_local(world_pos)

	var size3 = $render/outie.mesh.get_aabb().size
	var size := Vector2(size3.x, size3.y)
	return (local_pos + size * 0.5) / size

func _process(_delta: float) -> void:
	var midpoint = get_midpoint_intersection(
		position,
		m_is_colliding_with.position
	)

	var center_uv = world_to_uv(midpoint)
	#Mark where the midpoint intersection are
	$MeshInstance2D.global_position = midpoint
	$render.material.set_shader_parameter(
		"centers",
		PackedVector2Array([center_uv])
	)

	$render.material.set_shader_parameter(
		"rotations",
		PackedFloat32Array([get_angle_to(m_is_colliding_with.position)])
	)

	$render.material.set_shader_parameter("cell_count", 1)

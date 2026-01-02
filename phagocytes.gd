extends CharacterBody2D
#These variables contain current collision with cells' position, and angle
var colliding_cells_position: PackedVector2Array = []
var colliding_cells_angle: PackedFloat32Array = []
func _ready() -> void:
	$render.material = $render.material.duplicate()
func _physics_process(delta: float) -> void:
	global_position += velocity * delta #Move the cell
	velocity *= pow(0.9, delta * 60.0) #Apply simple friction
	var collision = move_and_collide(velocity, true) #Second argument is true for 'test_only' to prevent move_and_collide make its own movement
	create_voronoi_effect()
	if collision:
		#Apply basic collision
		velocity += collision.get_normal() * collision.get_depth() * 10
#region To get the position for the shader
func get_midpoint_intersection(c1: Vector2, c2: Vector2):
	#DOES NOT WORK WITH DIFFERENT RADIUS
	return (c1 + c2) / 2
func world_to_screen(world_pos: Vector2) -> Vector2:
	var canvas_xform := get_viewport().get_canvas_transform()
	return canvas_xform * world_pos
func world_to_screen_uv(world_pos: Vector2) -> Vector2:
	var screen_pos := world_to_screen(world_pos)
	var viewport_size := get_viewport().get_visible_rect().size
	return screen_pos / viewport_size
#Very simple function just to adjust position to be correct! 
func simple_adjust_positions(positions: PackedVector2Array) -> PackedVector2Array:
	var adjusted_positions: PackedVector2Array = []
	for pos in positions:
		var midpoint = get_midpoint_intersection(position, pos) 
		adjusted_positions.append(world_to_screen_uv(midpoint))
	return adjusted_positions 
#endregion
#Ensure there's nothing wrong with current system.
func check_bug() -> void:
	if colliding_cells_angle.size() != colliding_cells_position.size():
		print("Incosistency with number of colliding cells angles and position!")
#Create voronoi effects of Cells (Cells shape are Circle so it is simple)
func create_voronoi_effect() -> void:
	#$render is a canvasgroup composed of mutiple object
	$render.material.set_shader_parameter("centers", simple_adjust_positions(colliding_cells_position))
	$render.material.set_shader_parameter("rotations", colliding_cells_angle)
	$render.material.set_shader_parameter("cell_count", colliding_cells_position.size()) #The size array of position and angle SHOULD be the same
	$render.material.set_shader_parameter("screen_size", get_viewport().get_visible_rect().size)
func _cell_entered(area: Area2D) -> void:
	colliding_cells_position.append(area.global_position)
	colliding_cells_angle.append(get_angle_to(area.global_position))
func _cell_exited(area: Area2D) -> void:
	colliding_cells_position.erase(area.global_position)
	colliding_cells_angle.erase(get_angle_to(area.global_position))

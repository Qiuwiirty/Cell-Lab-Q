extends CharacterBody2D
class_name BaseCell
#These variables contain current collision with cells' position, and angle
var colliding_cells: Array[Node2D]
@export var radius = 15
@export var mass = 3.6
@export var energy_loss_coefficient = 1

const MASS_EPSILON := 0.01
var last_mass = mass

func _ready() -> void:
	$render.material = $render.material.duplicate()
	$render/outie.mesh = $render/outie.mesh.duplicate()
	$render/innie.mesh = $render/innie.mesh.duplicate()
	$render/nucleus.mesh = $render/nucleus.mesh.duplicate()
	$collision.shape = $collision.shape.duplicate()
	$collision_detector/collison.shape = $collision_detector/collison.shape.duplicate()
func _physics_process(delta: float) -> void:
	metabolism(delta)
	if abs(mass - last_mass) > MASS_EPSILON:
		correct_size()
		last_mass = mass
	#global_position += velocity * delta #Move the cell
	var collision = move_and_collide(velocity, true) #Second argument is true for 'test_only' to prevent move_and_collide make its own movement
	create_voronoi_effect()
	if collision:
		#Apply basic collision
		velocity += collision.get_normal() * collision.get_depth() * 10
	velocity *= pow(0.9, delta * 60.0) #Apply simple damping
	global_position += velocity * delta
#region To get the position for the shader
func get_midpoint_intersection(c2: Vector2, r2: float) -> Vector2:
	var d := global_position.distance_to(c2)
	# No intersection or degenerate case
	if d == 0.0 or d > radius + r2 or d < abs(radius - r2):
		return Vector2.ZERO # or null / error handling

	var a = (radius * radius - r2 * r2 + d * d) / (2.0 * d)
	var direction := (c2 - global_position).normalized()

	return global_position + direction * a

func world_to_screen(world_pos: Vector2) -> Vector2:
	var canvas_xform := get_viewport().get_canvas_transform()
	return canvas_xform * world_pos
func world_to_screen_uv(world_pos: Vector2) -> Vector2:
	var screen_pos := world_to_screen(world_pos)
	var viewport_size := get_viewport().get_visible_rect().size
	return screen_pos / viewport_size
#UNUSED: Very simple function just to adjust position to be correct! 
#func simple_adjust_positions(positions: PackedVector2Array) -> PackedVector2Array:
	#var adjusted_positions: PackedVector2Array = []
	#for pos in positions:
		#var midpoint = get_midpoint_intersection(position, pos) 
		#adjusted_positions.append(world_to_screen_uv(midpoint))
	#return adjusted_positions 
#endregion
#Ensure there's nothing wrong with current system.
#Create voronoi effects of Cells (Cells shape are Circle so it is simple)
func create_voronoi_effect() -> void:
	var positions := PackedVector2Array()
	var angles := PackedFloat32Array()

	for cell in colliding_cells:
		var midpoint = get_midpoint_intersection(cell.global_position, cell.get_parent().radius)
		positions.append(world_to_screen_uv(midpoint))
		angles.append(get_angle_to(cell.global_position))

	var mat = $render.material
	mat.set_shader_parameter("centers", positions)
	mat.set_shader_parameter("rotations", angles)
	mat.set_shader_parameter("cell_count", colliding_cells.size())
	mat.set_shader_parameter("screen_size", get_viewport_rect().size)


#region Cell stuff
#Manage cell mass and clamp the mass. This also essential to decide whether cell should die
func metabolism(delta):
	var alpha = 0.021614
	var beta = 0.161532

	var metabolic = -energy_loss_coefficient \
		* (1.0778 - Game.salinity) \
		* (alpha * sqrt(mass) + beta)

	#apply metabolism!!
	mass += metabolic * delta

	#clamp so the mass cell won't go over 3.6
	mass = minf(3.60, mass)

	#check if cell should go bye bye
	if mass < 0.90:
		die()

#Scaling instead of changing radius and size which is rebuilding. Improve perfomances
#Old inefficient correct_size() can be seen in Misc/junkyard.txt
func correct_size():
	radius = mass * 4.166666667
	
	var multi = Vector2(radius / 15.0, radius / 15.0)
	$collision.scale = multi
	$collision_detector/collison.scale = multi
	#ORDER: NUCLEUS (first to render), INNIE, OUTIE
	$render/outie.scale = multi 
	$render/outie.scale = multi
	
	#Why - 0.11?: Because we want this outline width to stay consistent.
	$render/innie.scale = multi - Vector2(0.11, 0.11)
	$render/innie.scale = multi - Vector2(0.11, 0.11)
	
	#Nucleus don't change size..
func die():
	queue_free()
#endregion
#region Node signal
func _cell_entered(area: Area2D) -> void:
	colliding_cells.append(area)
func _cell_exited(area: Area2D) -> void:
	colliding_cells.erase(area)
#endregion

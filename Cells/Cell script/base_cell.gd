extends CharacterBody2D
class_name BaseCell
const split_audio = preload("uid://c2ncgpkfynhkk")
#These variables contain current collision with cells' position, and angle
var colliding_cells: Array[Node2D]
@export var radius = 15
@export var mass = 2.88
@export var color = Color(1.0,1.0,1.0)
@export var energy_loss_coefficient = 1

var is_colliding = false
var visible_on_screen = false
const MASS_EPSILON := 0.01
var last_mass = mass

const drag_speed := 25.0

var mouse_over := false
var dragging := false
var drag_offset := Vector2.ZERO
func _ready() -> void:
	
	set_physics_process(false if Game.temperature == Game.SubstrateTemperature.FREEZE else true)
	$render.modulate = color
	correct_size()
	$render.material = $render.material.duplicate()
	$render/outie.mesh = $render/outie.mesh.duplicate()
	$render/innie.mesh = $render/innie.mesh.duplicate()
	$render/nucleus.mesh = $render/nucleus.mesh.duplicate()
	$collision.shape = $collision.shape.duplicate()
	$collision_detector/collison.shape = $collision_detector/collison.shape.duplicate()
func _physics_process(delta: float) -> void:
	#If substrate is freezing prevent cell from doing anything
	if Game.temperature == Game.SubstrateTemperature.FREEZE:
		return
	#This will adjust according to temperature to speed/slow down the game
	delta /= timescale_modifier()
	#Change the modified color into its currect color
	if $render.modulate != color:
		$render.modulate = lerp($render.modulate, color, 3.5 * delta)
	
	if dragging:
		var target := get_global_mouse_position() + drag_offset
		velocity = (target - global_position) * drag_speed

	metabolism(delta)
	#The epsilon here basically function to update when the difference is noticeable
	if abs(mass - last_mass) > MASS_EPSILON:
		correct_size()
		last_mass = mass
	#global_position += velocity * delta #Move the cell
	var collision = move_and_collide(velocity, true) #Second argument is true for 'test_only' to prevent move_and_collide make its own movement
	if is_colliding and visible_on_screen and Game.use_voronoi:
		if !colliding_cells.is_empty():
			create_voronoi_effect()
		else:
			#Disable shader if no collision
			$render.material.set_shader_parameter("cell_count", 0)
			is_colliding = false
	if collision:
		#Apply basic collision
		velocity += collision.get_normal() * collision.get_depth() * 10
	velocity *= pow(0.9, delta * 60.0) #Apply simple damping
	global_position += velocity * delta
func _input(event):
	match get_parent().mode:
		Game.ToolSelector.OPTICAL_TWEEZERS:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
				if event.pressed and mouse_over:
					dragging = true
					drag_offset = global_position - get_global_mouse_position()
				elif not event.pressed:
					dragging = false
		Game.ToolSelector.CELL_BOOST:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and mouse_over and event.is_pressed():
				$render.modulate = Color(1, 0, 1)
				mass = 3.6
				play_split_sound()
		Game.ToolSelector.CELL_REMOVAL:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and mouse_over and event.is_pressed():
				play_split_sound()
				die()
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
		if midpoint == Vector2.ZERO:
			return
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

func play_split_sound():
	var sfx := AudioStreamPlayer2D.new()
	sfx.stream = split_audio
	get_parent().add_child(sfx)
	sfx.play()
	sfx.finished.connect(sfx.queue_free)

#endregion
#region Node signal
#This is for voronoi purposes
func _cell_entered(area: Area2D) -> void:
	is_colliding = true
	colliding_cells.append(area)
func _cell_exited(area: Area2D) -> void:
	if colliding_cells.size() == 1:
		$render.material.set_shader_parameter("cell_count", 0)
	colliding_cells.erase(area)
#Optimization method to perform less when not on screen
func _screen_entered_notifier() -> void:
	visible_on_screen = true
	$render.show()
func _screen_exited_notifier() -> void:
	visible_on_screen = false
	$render.hide()
	
#This is for dragging purposes
func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false
#endregion

func timescale_modifier() -> float:
	match Game.temperature:
		Game.SubstrateTemperature.SLOW_OBSERVE:
			return 1000
		Game.SubstrateTemperature.OBSERVE:
			return 1
		Game.SubstrateTemperature.INCUBATE:
			return 0.01
		_:
			print('No valid game.temperature')
			return 1

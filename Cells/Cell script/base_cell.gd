extends CharacterBody2D
class_name BaseCell
#TODO: IMPROVE THE ADHESION
const split_audio = preload("uid://c2ncgpkfynhkk")

var colliding_cells: Array[Node2D]

var radius = 15
@export var mass = 2.88
@export var color = Color(1.0,1.0,1.0)
@export var energy_loss_coefficient = 1 #Related to metabolism
@export var nutrient_priority = 1.0
@export var adhesion: Array[BaseCell]
@export var adhesion_stiffness = 5
var is_colliding = false
var visible_on_screen = false
const MASS_EPSILON := 0.01
var last_mass = mass

const drag_speed := 25.0

var mouse_over := false
var dragging := false
var drag_offset := Vector2.ZERO

var age = 0.0
##--Adhesion stuff--
#see this: https://cell-lab.fandom.com/wiki/User:CxrLol1/Formulas/Cellular
var delta_mass = 0.0
#how fast nutrients can flow through a connection
#you could make k different for each cell, but it is best to make same for all cells rn
@export var k = 0.1
#Current color is the color the cell is actually in. For example if cell get injected cell booster, it might turn pink but it only is current color. Quickly it will reverted to its original color
var current_color = color

var accumulator := 0.0
const FIXED_STEP := 1.0 / 60.0
# TODO: actually implementing DNA
var dna: DNA 
func _ready() -> void:
	$render_quad.material = $render_quad.material.duplicate()
	$render_quad.mesh = $render_quad.mesh.duplicate()
	#$render_quad.material.set_shader_parameter("u_use_decoration", 0.0)
	#$render_quad.material.set_shader_parameter("decoration", load("uid://dpuiru35vknq5"))
	set_physics_process(false if Game.temperature == Game.SubstrateTemperature.FREEZE else true)
	$collision.shape = $collision.shape.duplicate()
	$collision_detector/collison.shape = $collision_detector/collison.shape.duplicate()
	make_adhesion_mutual() #Fix adhesion that isn't symmterical 
	#current_color = color

func _process(delta: float) -> void:
	handle_drag()
	
	if Game.temperature == Game.SubstrateTemperature.FREEZE:
		correct_appearance(delta, false)
		create_voronoi_effect()
		return
		
	accumulator += delta * timescale_modifier()
	
	while accumulator >= FIXED_STEP:
		simulate_step(FIXED_STEP)
		accumulator -= FIXED_STEP

	update_voronoi_effect()
func simulate_step(delta: float) -> void:
	age += delta
	update_cell_state(delta)
	apply_collision_forces(delta)
	apply_motion(delta)
func _unhandled_input(event):
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
				current_color = Color(1, 0, 1)
				mass = 3.6
				play_split_sound()
				#This to prevent to spawn food when boosting on cell (Since cell boost both spawn food if on empty space and boosting cell)
				get_viewport().set_input_as_handled()
		Game.ToolSelector.CELL_REMOVAL:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and mouse_over and event.is_pressed():
				play_split_sound()
				die()
				get_viewport().set_input_as_handled()
		Game.ToolSelector.CELL_DIAGNOSTICS:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and mouse_over and event.is_pressed():
				if get_parent() is Plate:
					get_parent().discard_old_selected_cell()
					get_parent().selected_cell = self
					to_select(true)
					get_parent().tween_to_selected_cell_position()
					get_viewport().set_input_as_handled()
		Game.ToolSelector.BIND_ADHESION:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and mouse_over and event.is_pressed():
				if get_parent() is Plate:
					if get_parent().bind_adhesion_cell1 == null:
						get_parent().bind_adhesion_cell1 = self
						$selected_circle.color = Color.WEB_GREEN
						$selected_circle.show()
					elif get_parent().bind_adhesion_cell2 == null:
						get_parent().bind_adhesion_cell2 = self
						$selected_circle.color = Color.CYAN
						$selected_circle.show()
						Game.infonotice.show()
						# [i] is BBcode
						Game.infonotice.text = "[i] Press enter to bind/unbind adhesion"
#region To get the position for the shader
func get_midpoint_intersection(c2: Vector2, r2: float) -> Vector2:
	var d := global_position.distance_to(c2)
	# No intersection or degenerate case
	if d == 0.0 or d > radius + r2 or d < abs(radius - r2):
		return Vector2.ZERO # or null / error handling

	var a = (radius * radius - r2 * r2 + d * d) / (2.0 * d)
	var direction := (c2 - global_position).normalized()
	return to_local(global_position + direction * a)

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
	var rot_dirs := PackedVector2Array()
	for cell in colliding_cells:
		var midpoint = get_midpoint_intersection(cell.global_position, cell.get_parent().radius)
		if midpoint == Vector2.ZERO:
			return
		var uv = (midpoint + $render_quad.mesh.size * 0.5) / $render_quad.mesh.size
		uv.y = 1.0 - uv.y 
		positions.append(uv)
		var angle_to = get_angle_to(cell.global_position) 
		rot_dirs.append(Vector2(cos(angle_to), -sin(angle_to)))

	$render_quad.material.set_shader_parameter("centers", positions)
	$render_quad.material.set_shader_parameter("cell_count", colliding_cells.size())
	$render_quad.material.set_shader_parameter("rot_dirs", rot_dirs)
	$render_quad.material.set_shader_parameter("screen_size", get_viewport_rect().size)
func colors_are_close(a: Color, b: Color, tolerance := 0.001) -> bool:
	return abs(a.r - b.r) < tolerance \
		and abs(a.g - b.g) < tolerance \
		and abs(a.b - b.b) < tolerance \
		and abs(a.a - b.a) < tolerance
#region Cell stuff
#Manage cell mass and clamp the mass. This also essential to decide whether cell should die
func correct_appearance(delta, modify_color = true):
	radius = mass * 4.166666
	$collision.shape.radius = radius
	$collision_detector/collison.shape.radius = radius
	#I am not using current_color != color cuz there will be always digits that are different. Instead I use tolerance (0.001)
	if !colors_are_close(current_color, color) and modify_color:
		current_color = lerp(current_color, color, 3.5 * delta)
	else: #Snap it
		current_color = color
	$render_quad.material.set_shader_parameter("u_color", current_color)
	$render_quad.material.set_shader_parameter("u_size_mult", radius / 15.0)
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
	colliding_cells.erase(area)
#Optimization method to perform less when not on screen
func _screen_entered_notifier() -> void:
	visible_on_screen = true
	$render_quad.show()
func _screen_exited_notifier() -> void:
	visible_on_screen = false
	$render_quad.hide()
	
#This is for dragging purposes
func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false
#endregion
#region Process thing
func timescale_modifier() -> float:
	match Game.temperature:
		Game.SubstrateTemperature.SLOW_OBSERVE:
			return 0.1
		Game.SubstrateTemperature.OBSERVE:
			return 1
		Game.SubstrateTemperature.INCUBATE:
			return 3
		Game.SubstrateTemperature.CUSTOM:
			return Game.custom_temperature
		_:
			print('No valid game.temperature')
			return 1
func apply_motion(delta):
	velocity *= pow(0.9, delta * 60.0)
	global_position += velocity * delta
func apply_collision_forces(delta):
	for other in colliding_cells:
		if !adhesion.has(other.get_parent() as BaseCell):
			var dir = global_position - other.global_position
			var dist = dir.length()

			if dist == 0:
				continue

			var overlap = radius * 2 - dist
			if overlap <= 0:
				continue

			var normal = dir / dist
			velocity += normal * overlap * delta * 20
func update_cell_state(delta):
	correct_appearance(delta)
	metabolism(delta)
	
	if abs(mass - last_mass) > MASS_EPSILON:
		last_mass = mass
func handle_drag():
	if not dragging:
		return
	var target := get_global_mouse_position() + drag_offset
	if Game.temperature != Game.SubstrateTemperature.FREEZE:
		velocity = ((target - global_position) * drag_speed) * timescale_modifier()
	else:
		global_position = get_global_mouse_position() + drag_offset
func update_voronoi_effect():
	if not (is_colliding and visible_on_screen and Game.use_voronoi):
		return
	if colliding_cells.is_empty():
		$render_quad.material.set_shader_parameter("cell_count", 0)
		is_colliding = false
	else:
		create_voronoi_effect()
#endregion
func to_select(mode: bool, play_sound := true) -> void:
	$selected_circle.color = Color("ffa600")
	if mode:
		$selected_circle.show()
		if play_sound:
			$select_cell.play()
	else:
		$selected_circle.hide()
		if play_sound:
			$deselect_cell.play()
func discard_bind_selection():
	$selected_circle.hide()
func diagnostics() -> StringName:
	return """\
	Age: %s
	Mass: %s
	Diameter: %s
	Type: %s""" % [snappedf(age, 0.001), snappedf(mass, 0.001), snappedf(radius * 2, 0.001), get_script().get_global_name()]
#region Adhesion
#compute and apply flows are managed by a singleton (Game)
func compute_flows():
	var index = 0
	for neighbor in adhesion:
		if !is_instance_valid(neighbor):
			##For some reason, using erase cause an error. So I use remove_at instead
			adhesion.remove_at(index)
			return
		#avoid double calculation: only lower ID cell do the calculations, higher ID skips it
		if get_instance_id() < neighbor.get_instance_id():
			
			var pressure_self = mass / nutrient_priority
			var pressure_neighbor = neighbor.mass / neighbor.nutrient_priority
			
			var flow = k * (pressure_neighbor - pressure_self)
			
			#clamp
			flow = clamp(flow, -neighbor.mass, mass)
			
			# store instead of applying immediately
			delta_mass += flow
			neighbor.delta_mass -= flow
		index += 1

func apply_flows():
	mass += delta_mass
	delta_mass = 0.0

func apply_adhesion_force(rest_length: float = 20, damping: float = 0.3):
	###Credit to Genomeia (I borrowed the physics linking between cells from Genomeia) ^_^
	var index = 0
	for neighbor in adhesion:
		if !is_instance_valid(neighbor):
			adhesion.remove_at(index)
			return
		if get_instance_id() < neighbor.get_instance_id():
			var r = position - neighbor.position
			var distance = r.length()
			if distance == 0:
				return
			if distance > Game.max_adhesion_length: #if too long then break it
				adhesion.erase(neighbor)
				neighbor.adhesion.erase(self)
				return
			var dir = r / distance  # unit vector along the link

			#hookes law
			var stiffness = (adhesion_stiffness + neighbor.adhesion_stiffness) / 2.0
			var spring_force = stiffness * (distance - rest_length)

			#damp
			var relative_velocity = velocity - neighbor.velocity
			var damp_force = damping * relative_velocity.dot(dir)

			var force = (spring_force + damp_force) * dir

			velocity -= force
			neighbor.velocity += force
		index += 1
#Make adhesion mutual or symmetric so there's no weirdness
func make_adhesion_mutual():
	for neighbor in adhesion:
		if !neighbor.adhesion.has(self):
			neighbor.adhesion.append(self)

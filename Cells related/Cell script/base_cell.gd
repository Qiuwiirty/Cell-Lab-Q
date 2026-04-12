extends Area2D
class_name BaseCell
#TODO: IMPROVE THE ADHESION
const SPLIT_AUDIO = preload("uid://c2ncgpkfynhkk")
const FOOD = preload("uid://bcp4xdxc828fp")
@onready var mode: CellMode = get_mode(dna) #mode like M0, M1, M2... It store essential thingies like color and etc..
var colliding: Array[Node2D]

var radius = 15.0
@export var mass = 2.88
@export var velocity = Vector2.ZERO
@export var energy_loss_coefficient = 1 #Related to metabolism
@export var adhesion: Array[BaseCell]
@export var nitrogen_reserve := 100.
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
#Current color is the color the cell is actually in. For example if cell get injected cell booster, it might turn pink but it only is current color. Quickly it will reverted to its original color
var current_color = Color.WHITE #it should immediately set on _ready

var accumulator := 0.0
const FIXED_STEP := 1.0 / 60.0

@export var dna: DNA
@export var current_mode: int = 0 #start from 0.

var is_debugged = false

#This a setting contain configuration
var conf := []
func _ready() -> void:
	conf = Game.get_global_conf()
	Game.cell_count += 1
	if !dna:
		#No dna, means we set it so there won't be any error
		#We set it to the M0 
		dna = DNA.new()
		mode = get_mode(dna)
		mode.cell_type = Game.get_cell_type(self)
	if is_debugged:
		Game.UI.get_node("debug_cell").assign_cell(self)
	#current_color = mode.color
	$render_quad.material = $render_quad.material.duplicate()
	$render_quad.mesh = $render_quad.mesh.duplicate()
	#$render_quad.material.set_shader_parameter("u_use_decoration", 0.0)
	#$render_quad.material.set_shader_parameter("decoration", load("uid://dpuiru35vknq5"))
	set_physics_process(false if Game.temperature == Game.SubstrateTemperature.FREEZE else true)
	$collision.shape = $collision.shape.duplicate()
	make_adhesion_mutual() #Fix adhesion that isn't symmterical 
	correct_appearance(1 / 60.) #Without this, you can see the default state of cell flash for a second when it's spawn. This func solve it
	dna.fix_dna()
func _process(delta: float) -> void:
	handle_drag()
	if Game.temperature == Game.SubstrateTemperature.FREEZE:
		correct_appearance(delta, false)
		create_voronoi_effect()
		return
		
	accumulator += delta * Game.timescale_modifier()
	
	while accumulator >= FIXED_STEP:
		simulate_step(FIXED_STEP)
		accumulator -= FIXED_STEP

	update_voronoi_effect()
func simulate_step(delta: float) -> void:
	age += delta
	update_cell_state(delta)
	apply_collision_forces(delta)
	apply_motion(delta)
	apply_adhesion_force()
	compute_flows()
	apply_flows()
	nitrogen_reserve = min(nitrogen_reserve + sqrt(conf[Game.SubsConf.NITRATES]) * delta, 100)
	if mode:
		if mass > mode.split_mass and nitrogen_reserve > 20 and Game.cell_count < Game.maximum_cell_count and age > 0.5:
			split()
			age = 0
	#check if cell should go bye bye
	if mass < 0.90:
		die()
func _unhandled_input(event):
	match get_parent().tool_mode:
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
				die() #Do not create food when injected cell removal
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
					elif get_parent().bind_adhesion_cell2 == null and get_parent().bind_adhesion_cell1 != self:
						get_parent().bind_adhesion_cell2 = self
						$selected_circle.color = Color.CYAN
						$selected_circle.show()
						Game.infonotice.show()
						# [i] is BBcode
						Game.infonotice.text = "[i] Press enter to bind/unbind adhesion"
		Game.ToolSelector.DEBUG_CELL:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and mouse_over and event.is_pressed():
				var debug_cell = Game.UI.get_node_or_null("debug_cell")
				if debug_cell:
					debug_cell.open()
					if debug_cell.cell != self and debug_cell.cell:
						debug_cell.cell.to_select(false, false)
					debug_cell.assign_cell(self)
					$select_cell.play()
					$selected_circle.color = Color.CHARTREUSE
					$selected_circle.show()
					is_debugged = true
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
	for cell in colliding:
		if !is_instance_valid(cell) or cell is not BaseCell:
			continue
		var midpoint = get_midpoint_intersection(cell.global_position, cell.radius)
		if midpoint == Vector2.ZERO:
			continue
		var uv = (midpoint + $render_quad.mesh.size * 0.5) / $render_quad.mesh.size
		uv.y = 1.0 - uv.y 
		positions.append(uv)
		var angle_to = get_angle_to(cell.global_position) 
		rot_dirs.append(Vector2(cos(angle_to), -sin(angle_to)))
		
	$render_quad.material.set_shader_parameter("centers", positions)
	$render_quad.material.set_shader_parameter("cell_count", colliding.size())
	$render_quad.material.set_shader_parameter("rot_dirs", rot_dirs)
	$render_quad.material.set_shader_parameter("screen_size", get_viewport_rect().size)
func colors_are_close(a: Color, b: Color, tolerance := 0.001) -> bool:
	return abs(a.r - b.r) < tolerance \
		and abs(a.g - b.g) < tolerance \
		and abs(a.b - b.b) < tolerance \
		and abs(a.a - b.a) < tolerance
#region Cell stuff
#Manage cell mass and clamp the mass. This also essential to decide whether cell should die
func correct_appearance(delta, modify_color_radius = true):
	if modify_color_radius:
		radius = lerp(radius, 15. * sqrt(mass / 3.6), 0.1) #Not linear 
	$collision.shape.radius = radius
	if modify_color_radius:
		#I am not using current_color != color cuz there will be always digits that are different. Instead I use tolerance (0.001)
		if !colors_are_close(current_color, mode.color):
			current_color = lerp(current_color, mode.color, 3.5 * delta)
		else: #Snap it
			current_color = mode.color
	$render_quad.material.set_shader_parameter("u_color", current_color)
	$render_quad.material.set_shader_parameter("u_size_mult", radius / 15.0)
func metabolism(delta, modifier := 1.0):
	if mode.disable_metabolism:
		return
	var alpha = 0.021614
	var beta = 0.161532
	var metabolic = -energy_loss_coefficient \
		* (1.0778 - conf[Game.SubsConf.SALINITY]) \
		* (alpha * sqrt(mass) + beta)

	#apply metabolism!!
	mass += metabolic * delta * modifier

	#clamp so the mass cell won't go over 3.6
	mass = minf(3.60, mass)

func die(create_food := true) -> void:
	if create_food:
		var new_food: Food = FOOD.instantiate()
		new_food.global_position = global_position
		new_food.nutrition = mass
		get_parent().add_child(new_food)
	Game.cell_count -= 1
	queue_free()

func play_split_sound():
	var sfx := AudioStreamPlayer2D.new()
	sfx.stream = SPLIT_AUDIO
	get_parent().add_child(sfx)
	sfx.play()
	sfx.finished.connect(sfx.queue_free)

#endregion
#region Node signal
#This is for voronoi purposes
func _cell_entered(area: Area2D) -> void:
	is_colliding = true
	colliding.append(area)
func _cell_exited(area: Area2D) -> void:
	colliding.erase(area)
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
func apply_motion(delta):
	velocity *= pow(0.9, delta * 60.0)
	global_position += velocity * delta
func apply_collision_forces(delta):
	if Game.use_plate_border: #Collision with plate's border 
		if global_position.length() > (Game.plate_diameter / 2) - radius - Game.plate_thickness:
			global_position = global_position.normalized() * ((Game.plate_diameter / 2) - radius - Game.plate_thickness)
	for other in colliding:
		if other is BaseCell:
			if !adhesion.has(other.get_parent() as BaseCell):
				var dir = global_position - other.global_position
				var dist = dir.length()

				if dist < other.radius - radius: #dies if it's on another cell
					die()
					continue
				var overlap = radius * 2 - dist
				if overlap <= 0:
					continue

				var normal = dir / dist
				velocity += normal * overlap * delta * 20
		elif other is CircleObstacle:
			var dir = global_position - other.global_position
			var dist = dir.length()
			if dist == 0:
				global_position += Vector2(radius, 0)
				continue
			var min_dist = radius + (other.current_diameter / 2)
			if dist < min_dist:
				global_position += (dir / dist) * (min_dist - dist)
		elif other is RectObstacle:
			# Find closest point on rect to cell center
			var local_pos = other.to_local(global_position)
			var half = other.current_size / 2.0
			var closest = Vector2(
				clamp(local_pos.x, -half.x, half.x),
				clamp(local_pos.y, -half.y, half.y)
			)
			var diff = local_pos - closest
			var dist = diff.length()
			if dist == 0:
				# Cell center is inside the rect — push out on shortest axis
				var dx = half.x - abs(local_pos.x)
				var dy = half.y - abs(local_pos.y)
				if dx < dy:
					closest = Vector2(half.x * sign(local_pos.x), local_pos.y)
				else:
					closest = Vector2(local_pos.x, half.y * sign(local_pos.y))
				diff = local_pos - closest
				dist = diff.length()
				if dist == 0:
					global_position += other.to_global(Vector2(radius, 0))
					continue
			if dist < radius:
				var push = (diff / dist) * (radius - dist)
				global_position += other.to_global(closest + diff + push) - other.to_global(closest + diff)
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
		velocity = ((target - global_position) * drag_speed) * Game.timescale_modifier()
	else:
		global_position = get_global_mouse_position() + drag_offset
func update_voronoi_effect():
	if not (is_colliding and visible_on_screen and Game.use_voronoi):
		return
	if colliding.is_empty():
		$render_quad.material.set_shader_parameter("cell_count", 0)
		is_colliding = false
	else:
		create_voronoi_effect()
#endregion
func to_select(b: bool, play_sound := true) -> void:
	$selected_circle.color = Color("ffa600")
	if b:
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
#compute and apply flows
func compute_flows() -> void:
	var index = 0
	for neighbor in adhesion:
		if !is_instance_valid(neighbor):
			##For some reason, using erase cause an error. So I use remove_at instead
			adhesion.remove_at(index)
			continue
		if neighbor.mode == null:
			continue
		#avoid double calculation: only lower ID cell do the calculations, higher ID skips it
		if get_instance_id() < neighbor.get_instance_id():
			
			var pressure_self = mass / mode.nutrient_priority
			var pressure_neighbor = neighbor.mass / neighbor.mode.nutrient_priority
			
			var flow = mode.flow_rate * (pressure_neighbor - pressure_self)
			
			#clamp
			flow = clamp(flow, -neighbor.mass, mass)
			
			# store instead of applying immediately
			delta_mass += flow
			neighbor.delta_mass -= flow
		index += 1

func apply_flows() -> void:
	mass += delta_mass
	delta_mass = 0.0

func apply_adhesion_force(damping: float = 0.3):
	###Credit to Genomeia (I borrowed the physics linking between cells from Genomeia) ^_^
	#Note that collision physics disabled between adhesion cells to prevent cells mving infinitely
	var index = 0
	for neighbor in adhesion:
		if !is_instance_valid(neighbor) or neighbor == self:
			adhesion.remove_at(index)
			continue
		if neighbor.mode == null:
			index += 1
			continue
		var rest_length = (radius + neighbor.radius) * 0.6667 #if cell A's radius 15 and B 15, then rest length 20 would look fine. basically this is an adjusted version
		var r = position - neighbor.position
		var distance = r.length()
		if distance == 0:
			index += 1
			continue
		if distance > conf[Game.SubsConf.MAX_ADHESION_LENGTH]: #if too long then break it
			adhesion.erase(neighbor)
			neighbor.adhesion.erase(self)
			continue
		var dir = r / distance  # unit vector along the link
		#hookes law
		var stiffness = (mode.adhesion_stiffness + neighbor.mode.adhesion_stiffness) / 2.0
		var spring_force = stiffness * (distance - rest_length)

		#damp
		var relative_velocity = velocity - neighbor.velocity
		var damp_force = damping * relative_velocity.dot(dir)

		var force = (spring_force + damp_force) * dir

		velocity -= force
		neighbor.velocity += force
		
		#rotational correction
		#cross product (2D scalar) tells us how far off-axis the neighbor is
		var to_neighbor = -dir  #direction FROM self TO neighbor
		var facing = Vector2.RIGHT.rotated(rotation)
		var cross = facing.cross(to_neighbor)  #positive = neighbor is to our left
		
		var rot_stiffness = stiffness * 0.002  #scale down, rotation is sensitive
		rotation += cross * rot_stiffness
		neighbor.rotation -= cross * rot_stiffness  #neighbor rotates opposite
		index += 1
#Make adhesion mutual or symmetric so there's no weirdness
func make_adhesion_mutual():
	for neighbor in adhesion:
		if !neighbor.adhesion.has(self):
			neighbor.adhesion.append(self)
#region DNA
#this is supposed use for virocytes
func get_mode(new_dna) -> CellMode:
	if new_dna:
		return new_dna.modes[current_mode]
	return null
func inject_DNA(new_dna) -> void:
	var cell_mode := get_mode(new_dna)
	if !cell_mode:
		return
	var correct_script := Game.get_script_for_type(cell_mode.cell_type)
	
	if get_script() != correct_script:
		var new_cell = Game.get_instance_cell(cell_mode.cell_type).instantiate()
		new_cell.position = position
		new_cell.velocity = velocity
		new_cell.dna = new_dna
		new_cell.split_mass = cell_mode.split_mass
		new_cell.split_ratio = cell_mode.split_ratio
		new_cell.color = cell_mode.color
		new_cell.nutrient_priority = cell_mode.nutrient_priority
		new_cell.child1 = cell_mode.child1
		new_cell.child2 = cell_mode.child2
		new_cell.adhesion_stiffness = cell_mode.adhesion_stiffness
		get_parent().add_child.call_deferred(new_cell)
		die()
		return
	
	#Same type, just update properties
	mode.split_mass = cell_mode.split_mass
	mode.split_ratio = cell_mode.split_ratio
	mode.color = cell_mode.color
	mode.nutrient_priority = cell_mode.nutrient_priority
	mode.child1 = cell_mode.child1
	mode.child2 = cell_mode.child2
	mode.adhesion_stiffness = cell_mode.adhesion_stiffness

func turn_into_another_cell_type(type: Game.CellType) -> void:
	var new_cell = Game.get_instance_cell(type).instantiate()
	new_cell.mass = mass
	new_cell.radius = radius
	new_cell.position = position
	new_cell.velocity = velocity
	new_cell.dna = dna
	new_cell.current_color = current_color
	get_parent().add_child.call_deferred(new_cell)
	if Game.UI.get_node_or_null("debug_cell") and is_debugged:
		new_cell.is_debugged = is_debugged
		new_cell.get_node("selected_circle").color = Color.CHARTREUSE
		new_cell.get_node("selected_circle").show()
	die()

func split() -> void:
	if !mode:
		print("Mode does not exist. Can't split")
		return
	var split_dir := Vector2.RIGHT.rotated(rotation + deg_to_rad(mode.split_angle))
	# child 1
	var child1 = Game.get_instance_cell(dna.get_mode(mode.child1).cell_type).instantiate()
	child1.position = position - split_dir
	child1.rotation = rotation + mode.child1_angle
	#The velocity is randomized a bit, so there's no issue where cell split and become cramped because it's on 1D line
	child1.velocity = velocity - split_dir * 100 + Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5)) 
	child1.dna = dna
	child1.current_mode = dna.get_mode(mode.child1).id
	child1.mass = mass * mode.split_ratio
	child1.nitrogen_reserve = nitrogen_reserve / 2.
	child1.radius = radius
	child1.current_color = current_color
	#child1.mode.set_up_custom_properties()
	# child 2
	var child2 = Game.get_instance_cell(dna.get_mode(mode.child2).cell_type).instantiate()
	child2.position = position + split_dir
	child2.rotation = rotation + mode.child2_angle
	child2.velocity = velocity + split_dir * 100 + Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
	child2.dna = dna
	child2.current_mode = dna.get_mode(mode.child2).id
	child2.mass = mass * (1.0 - mode.split_ratio)
	child2.nitrogen_reserve = nitrogen_reserve / 2.
	child2.radius = radius
	child2.current_color = current_color
	#child2.mode.set_up_custom_properties()
	if mode.make_adhesion:
		child1.adhesion.append(child2)
		child2.adhesion.append(child1)

	for cell in adhesion:
		if not is_instance_valid(cell):
			continue
		cell.adhesion.erase(self)
		
		var to_neighbor = (cell.position - position).normalized()
		var dot = split_dir.dot(to_neighbor)
		
		if mode.child1_kept_adhesion and dot < 0:
			if not child1.adhesion.has(cell):
				child1.adhesion.append(cell)
			if not cell.adhesion.has(child1):
				cell.adhesion.append(child1)
		elif mode.child2_kept_adhesion and dot > 0:
			if not child2.adhesion.has(cell):
				child2.adhesion.append(cell)
			if not cell.adhesion.has(child2):
				cell.adhesion.append(child2)
	get_parent().add_child.call_deferred(child1)
	get_parent().add_child.call_deferred(child2)
	die()
	#for cell in adhesion:
		#if not is_instance_valid(cell):
			#continue
		#cell.adhesion.erase(self)
		#if mode.child2_kept_adhesion:
			#child2.adhesion.append(cell)
			#cell.adhesion.append(child2)
		#if mode.child1_kept_adhesion:
			#child1.adhesion.append(cell)
			#cell.adhesion.append(child1)

extends BaseCell
class_name Lipocyte
enum{
	MAX_LIPIDS
}
@export var lipids := 13.68 #ng. Lipids max is 18.0 but can be modified with editing custom property of the mode
var delta_lipids = 0.0
func _ready() -> void:
	super()
	energy_loss_coefficient = 0.05
	$lipids.material = $lipids.material.duplicate()
func _unhandled_input(event):
	super(event)
	if !get_parent() is Plate:
		return
	match get_parent().tool_mode:
		Game.ToolSelector.CELL_BOOST:
			if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and mouse_over and event.is_pressed():
				lipids = mode.custprop[MAX_LIPIDS]
func correct_appearance(delta, modify_color_radius = true):
	super(delta, modify_color_radius)
	
	#use curve
	var lipid_ratio = lipids / mode.custprop[MAX_LIPIDS]
	var lipid_radius = (0.25 + lipid_ratio * 0.20) * radius / 15
	$lipids.material.set_shader_parameter("radius", lipid_radius)
#Override the metabolism to fit lipocyte
func metabolism(delta, modifier := 1.0):
	if mass < 3.6:
		var mass_deficit = 3.6 - mass
		var lipids_to_use = min(mass_deficit, lipids)  #don't use more lipids than available
		mass += lipids_to_use
		lipids -= lipids_to_use
	if mode.disable_metabolism:
		return
	var alpha = 0.021614
	var beta = 0.161532
	var metabolic = -energy_loss_coefficient \
		* (1.0778 - conf[Game.SubsConf.SALINITY]) \
		* (alpha * sqrt(mass) + beta)
	
	#apply metabolism!!
	if lipids > 0:
		lipids += metabolic * delta * modifier
	else:
		mass += metabolic * delta * modifier
	lipids = minf(mode.custprop[MAX_LIPIDS], lipids)
	mass = minf(3.60, mass)

func die(create_food := true) -> void:
	if create_food:
		var new_food: Food = FOOD.instantiate()
		new_food.global_position = global_position
		new_food.nutrition = mass
		new_food.coating = 10. #Coat it
		get_parent().add_child(new_food)
	Game.cell_count -= 1
	queue_free()
func compute_flows() -> void:
	var index = 0
	for neighbor in adhesion:
		if !is_instance_valid(neighbor):
			adhesion.remove_at(index)
			continue
		if neighbor.mode == null:
			continue
		
		# Only lower ID cell does the calculations
		if get_instance_id() < neighbor.get_instance_id():
			# Lipocyte's total storage = mass + lipids
			var total_self = mass + lipids
			var pressure_self = total_self / mode.nutrient_priority
			
			# Neighbor's total storage (lipids if Lipocyte, else just mass)
			var total_neighbor = neighbor.mass
			if neighbor is Lipocyte:
				total_neighbor += neighbor.lipids
			var pressure_neighbor = total_neighbor / neighbor.mode.nutrient_priority
			
			var flow = mode.flow_rate * (pressure_neighbor - pressure_self)
			
			# Now determine what actually flows
			if flow > 0:  # Receiving from neighbor
				flow = min(flow, total_neighbor)
				
				if neighbor is Lipocyte:
					# Neighbor gives from lipids first, then mass
					var neighbor_lipid_give = min(flow, neighbor.lipids)
					var neighbor_mass_give = flow - neighbor_lipid_give
					
					neighbor.delta_lipids -= neighbor_lipid_give
					neighbor.delta_mass -= neighbor_mass_give
					
					# We receive into lipids first, then mass
					var lipid_receive = min(flow, mode.custprop[MAX_LIPIDS] - lipids)
					delta_lipids += lipid_receive
					delta_mass += (flow - lipid_receive)
				else:
					# Non-Lipocyte neighbor gives mass only
					neighbor.delta_mass -= flow
					
					# We receive (lipids first if we can store them)
					var lipid_receive = min(flow, mode.custprop[MAX_LIPIDS] - lipids)
					delta_lipids += lipid_receive
					delta_mass += (flow - lipid_receive)
					
			else:  # Giving to neighbor (flow < 0)
				flow = -flow  # Make positive for easier logic
				flow = min(flow, total_self)
				
				# Give from lipids first, then mass
				var lipid_give = min(flow, lipids)
				var mass_give = flow - lipid_give
				delta_lipids -= lipid_give
				delta_mass -= mass_give
				
				# Neighbor receives
				if neighbor is Lipocyte:
					var neighbor_lipid_receive = min(flow, neighbor.mode.custprop[MAX_LIPIDS] - neighbor.lipids)
					neighbor.delta_lipids += neighbor_lipid_receive
					neighbor.delta_mass += (flow - neighbor_lipid_receive)
				else:
					# Non-Lipocyte can only receive mass portion
					neighbor.delta_mass += mass_give
					# lipid_give gets lost/wasted since neighbor can't store it
		
		index += 1
func apply_flows() -> void:
	mass += delta_mass
	delta_mass = 0.0
	
	lipids += delta_lipids
	lipids = clampf(lipids, 0.0, mode.custprop[MAX_LIPIDS])
	delta_lipids = 0.0
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
	var lipids_for_child1 = lipids * mode.split_ratio
	if child1 is Lipocyte:
		child1.lipids = lipids_for_child1
	else:
		var mass_capacity = 3.6 - child1.mass
		var lipids_converted = min(lipids_for_child1, mass_capacity)
		child1.mass += lipids_converted
		#remaining lipids are wasted which is expected for non-lipocyte
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
	var lipids_for_child2 = lipids * (1.0 - mode.split_ratio)
	if child2 is Lipocyte:
		child2.lipids = lipids_for_child2
	else:
		var mass_capacity = 3.6 - child2.mass
		var lipids_converted = min(lipids_for_child2, mass_capacity)
		child2.mass += lipids_converted
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
	die(false) #do not create food upon death

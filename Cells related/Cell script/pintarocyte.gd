extends Phagocyte
class_name Pintarocyte
var cells_sense : Array[BaseCell]
var foods_sense : Array[Food]
func simulate_step(delta: float) -> void:
	super(delta)
	response_to_senses()
func response_to_senses() -> void:
	var i = 0
	for cell in cells_sense:
		if is_instance_valid(cell):
			if cell is Devorocyte or cell is Glueocyte:
				var direction = (cell.global_position - global_position).normalized()
				launch_food(direction)
		else:
			cells_sense.remove_at(i)
		i += 1
func launch_food(dir: Vector2) -> void:
	#It will launch a coated food, so it can move forward. It depends on nitratres which impact its effictiveness
	if nitrogen_reserve > 70.:
		var mod = nitrogen_reserve / 100
		var new_food = FOOD.instantiate()
		new_food.nutrition = mass * mod * 2
		new_food.global_position = global_position
		new_food.coating = 5 * mod
		var velocity_diff = dir * (mass * 0.9) * mod
		new_food.velocity += velocity_diff * 50
		velocity -= velocity_diff * 50
		mass *= 0.9 * mod
		nitrogen_reserve -= 50 * mod #Itll cost the cell nitrates and mass
		get_parent().add_child(new_food)
func _sense_area_exited(area: Area2D) -> void:
	if area is BaseCell:
		cells_sense.erase(area)
	elif area is Food:
		foods_sense.erase(area)
func _sense_area_entered(area: Area2D) -> void:
	if area is BaseCell:
		cells_sense.append(area)
	if area is Food:
		foods_sense.append(area)

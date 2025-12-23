extends CharacterBody2D
#Get all cells that are currently on the plate
func get_all_cells() -> Array[CharacterBody2D]:
	var cells: Array[CharacterBody2D] = []
	for cell in get_parent().get_children():
		if cell is Node2D and cell != self:
			if cell.is_in_group("Cells"):
				cells.append(cell)
	return cells
#Expect the var list to be fully full of cells
func get_positions_from_cells(list: Array[CharacterBody2D]) -> PackedVector2Array:
	var positions := PackedVector2Array()
	for cell: CharacterBody2D in list:
		positions.append(cell.position)
	return positions
func _physics_process(delta: float) -> void:
	print(get_positions_from_cells(get_all_cells())) #Print normally showing other cells
	#For test only since all are still colliding
	$render.material.set_shader_parameter("aleins", get_positions_from_cells(get_all_cells()))

extends ColorRect

func get_all_cells() -> Array[CharacterBody2D]:
	var cells: Array[CharacterBody2D] = []
	for cell in get_parent().get_parent().get_children():
		if cell is Node2D and cell != self:
			if cell.is_in_group("Cells"):
				cells.append(cell)
	return cells
#Expect the var list to be fully full of cells
func get_screen_positions_from_cells(list: Array[CharacterBody2D]) -> PackedVector2Array:
	var positions := PackedVector2Array()
	for cell: CharacterBody2D in list:
		positions.append(get_viewport().get_canvas_transform() * cell.position)
	return positions
func _physics_process(_delta: float) -> void:
	material.set_shader_parameter("u_cells", get_screen_positions_from_cells(get_all_cells()))
	material.set_shader_parameter("u_colors", PackedColorArray([Color.WHITE, Color.RED, Color.GREEN, Color.AQUA]))
	material.set_shader_parameter("u_radii",PackedFloat32Array([15.0, 15.0, 30.0, 30.0]))

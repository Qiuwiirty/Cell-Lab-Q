extends Node
var pools: Dictionary = {}  # CellType -> Array[BaseCell]

func return_cell(cell: BaseCell, type: Game.CellType) -> void:
	if not pools.has(type):
		pools[type] = []
	cell.hide()
	if cell.get_parent() != null:
		cell.get_parent().remove_child(cell)
	cell.set_process(false)
	pools[type].append(cell)

func get_cell(type: Game.CellType) -> BaseCell:
	if pools.has(type) and not pools[type].is_empty():
		var cell: BaseCell = pools[type].pop_back()
		cell.set_process(true)
		return cell
	# pool empty, instantiate fresh
	var new_cell = Game.get_instance_cell(type).instantiate()
	new_cell.set_process(true)
	return new_cell

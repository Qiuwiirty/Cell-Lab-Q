class_name DNA
extends Resource
# Total mode can be adjusted
@export var modes: Array[CellMode] = []
func _init() -> void:
	modes.resize(Game.max_modes_count)
	for i in Game.max_modes_count:
		var cell = CellMode.new()
		cell.index_mode = i
		modes[i] = cell

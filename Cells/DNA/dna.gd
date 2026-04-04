class_name DNA
extends Resource
# Total mode can be adjusted
const mode_count = 40
@export var modes: Array[CellMode] = []
func _init() -> void:
	modes.resize(mode_count)
	for i in mode_count:
		modes[i] = CellMode.new()

class_name DNA
extends Resource
# Total mode can be adjusted
@export var modes: Array[CellMode] = []
func _init() -> void:
	modes.resize(Game.max_modes_count)
	for i in Game.max_modes_count:
		var mode = CellMode.new()
		mode.id = i
		modes[i] = mode
func fix_dna() -> void: #resize the DNA to correct size, and make the index_mode correctly
	modes.resize(Game.max_modes_count)
	for i in Game.max_modes_count:
		var mode = modes[i]
		if modes[i] == null:
			mode = CellMode.new()
			modes[i] = mode
		mode.id = i
func get_mode(index: int) -> CellMode:
	if index in range(modes.size()):
		return modes[index]
	print("Error, no cell mode found at index: ", index)
	return null

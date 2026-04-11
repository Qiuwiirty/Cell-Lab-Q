extends Node2D
#This function for simply spawning the cell according to the DNA and what the mode are
#This DOES NOT spawn mutiple cells, just one
@export var dna: DNA
@export var mode := 0
func _ready() -> void:
	if !dna:
		dna = DNA.new()
	mode = clamp(mode, 0, Game.max_modes_count)
	set_properties_DNA()
func set_properties_DNA() -> void:
	var cell_mode := dna.modes[mode]
	var new_cell = Game.get_instance_cell(cell_mode.cell_type).instantiate()
	new_cell.position = position
	new_cell.dna = dna
	new_cell.current_mode = mode
	get_parent().add_child.call_deferred(new_cell)
	queue_free()

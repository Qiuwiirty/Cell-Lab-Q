class_name CellMode
extends Resource
#Not all cell properties is here because some of it isn't necessary (Like energy_loss_coefficient, can be easily defined by looking at the cell type)
@export var cell_type: int = Game.BASE_CELL
@export var mass := 2.88
@export var color: Color
@export var nutrient_priority := 1.0
@export var children1: CellMode #refer to another cell mode
@export var children2: CellMode
@export var adhesion_stiffness := 5.0
func _init() -> void:
	color = Color(randf(), randf(), randf())

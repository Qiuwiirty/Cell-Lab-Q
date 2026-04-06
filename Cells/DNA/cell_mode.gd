class_name CellMode
extends Resource
#Not all cell properties is here because some of it isn't necessary (Like energy_loss_coefficient, can be easily defined by looking at the cell type)
@export var cell_type: int = Game.CellType.BASE_CELL
@export var split_mass := 2.88
@export var split_ratio := 0.5
@export var split_angle := 0 #degrees
@export var color: Color
@export var nutrient_priority := 1.0
@export var child1: CellMode = self #refer to another cell mode (by default it referring to itself)
@export var child2: CellMode = self
@export var child1_kept_adhesion := false #For now, if true, make all the split cell try to make adhesion with the parent's cell adhesion
@export var child2_kept_adhesion := false
@export var make_adhesion := false
@export var adhesion_stiffness := 5.0
@export var index_mode: int #which mode it is, like 0, 1, ...
@export var disable_metabolism := false
func _init() -> void:
	color = Color(randf(), randf(), randf())

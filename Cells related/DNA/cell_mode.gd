class_name CellMode
extends Resource
#Not all cell properties is here because some of it isn't necessary (Like energy_loss_coefficient, can be easily defined by looking at the cell type)
@export var cell_type: Game.CellType = Game.CellType.BASE_CELL
@export var split_mass := 8
@export var split_ratio := 0.5
@export var split_angle := 0 #degrees
@export var color: Color
@export var nutrient_priority := 1.0
@export var child1: int = 0 #refer to another cell mode (by default it referring to itself)
@export var child2: int = 0
@export var child1_kept_adhesion := false #For now, if true, make all the split cell try to make adhesion with the parent's cell adhesion
@export var child2_kept_adhesion := false
@export var child1_angle := 0 #degrees, again
@export var child2_angle := 0


@export var make_adhesion := false
@export var adhesion_stiffness := 5.0
@export var id: int #which mode it is, like 0, 1, ...
@export var disable_metabolism := false
@export var custprop : Array #Custom properties Contain specific settings like flagellocyte's swim force etc..
#Use array instead of dictionary so it will be faster ^_^

#how fast nutrients can flow through a connection
#you could make flow_rate different for each cell, but it is best to make same for all cells rn
@export var flow_rate = 0.01
func _init() -> void:
	if !id:
		child1 = id
		child2 = id
	color = Color(randf(), randf(), randf())
func set_up_custom_properties():
	match cell_type:
		Game.CellType.LUMINOCYTE:
			custprop.resize(2)
			if custprop[Luminocyte.LUM_SCALE] == null:
				custprop[Luminocyte.LUM_SCALE] = 1.0
			if custprop[Luminocyte.LUM_INTENSITY] == null:
				custprop[Luminocyte.LUM_INTENSITY] = 1.0
		Game.CellType.FLAGELLOCYTE:
			custprop.resize(1)
			if custprop[Flagellocyte.SWIM_FORCE] == null:
				custprop[Flagellocyte.SWIM_FORCE] = 50
		Game.CellType.DEVOROCYTE:
			custprop.resize(1)
			if custprop[Devorocyte.MASS_ABSORPTION_RATE] == null:
				custprop[Devorocyte.MASS_ABSORPTION_RATE] = 7.3
		Game.CellType.LIPOCYTE:
			custprop.resize(1)
			if custprop[Lipocyte.MAX_LIPIDS] == null:
				custprop[Lipocyte.MAX_LIPIDS] = 18.

class_name CellMode
extends Resource
#Not all cell properties is here because some of it isn't necessary (Like energy_loss_coefficient, can be easily defined by looking at the cell type)
@export var cell_type: Game.CellType = Game.CellType.BASE_CELL
@export var split_mass := 2.55
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
@export var custprop : Array[GenomeParam] #Custom properties Contain specific settings like flagellocyte's swim force etc.. GenomParam is a value where you can do some programming signal
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
			if not custprop[Luminocyte.Props.LUM_SCALE] is GenomeParam:
				var gp := GenomeParam.new()
				gp.fixed_value = 1.0
				custprop[Luminocyte.Props.LUM_SCALE] = gp
			if not custprop[Luminocyte.Props.LUM_INTENSITY] is GenomeParam:
				var gp := GenomeParam.new()
				gp.fixed_value = 1.0
				custprop[Luminocyte.Props.LUM_INTENSITY] = gp
		Game.CellType.FLAGELLOCYTE:
			custprop.resize(1)
			if not custprop[Flagellocyte.Props.SWIM_FORCE] is GenomeParam:
				var gp := GenomeParam.new()
				gp.fixed_value = 50.0
				custprop[Flagellocyte.Props.SWIM_FORCE] = gp
		Game.CellType.DEVOROCYTE:
			custprop.resize(1)
			if not custprop[Devorocyte.Props.MASS_ABSORPTION_RATE] is GenomeParam:
				var gp := GenomeParam.new()
				gp.fixed_value = 7.3
				custprop[Devorocyte.Props.MASS_ABSORPTION_RATE] = gp
		Game.CellType.LIPOCYTE:
			custprop.resize(1)
			if not custprop[Lipocyte.Props.MAX_LIPIDS] is GenomeParam:
				var gp := GenomeParam.new()
				gp.fixed_value = 18.0
				custprop[Lipocyte.Props.MAX_LIPIDS] = gp
		Game.CellType.BUOYOCYTE:
			custprop.resize(1)
			if not custprop[Buoyocyte.Props.DENSITY] is GenomeParam:
				var gp := GenomeParam.new()
				gp.fixed_value = 300.0
				custprop[Buoyocyte.Props.DENSITY] = gp
		Game.CellType.SENSE_CELL, Game.CellType.MONOCYTE, Game.CellType.STEREOCYTE:
			custprop.resize(7)
			if not custprop[SenseCell.Props.SENSE_TYPE] is GenomeParam:
				var gp := GenomeParam.new()
				gp.fixed_value = SenseCell.SenseType.CELL
				gp.force_fixed_value = true
				custprop[SenseCell.Props.SENSE_TYPE] = gp
			if not custprop[SenseCell.Props.OUTPUT_CHANNEL] is GenomeParam:
				var gp := GenomeParam.new()
				gp.fixed_value = 0
				custprop[SenseCell.Props.OUTPUT_CHANNEL] = gp
			if not custprop[SenseCell.Props.OUTPUT] is GenomeParam:
				var gp := GenomeParam.new()
				gp.fixed_value = 60.0
				custprop[SenseCell.Props.OUTPUT] = gp
			if not custprop[SenseCell.Props.SENSE_RED] is GenomeParam:
				var gp := GenomeParam.new()
				gp.fixed_value = 1.0
				custprop[SenseCell.Props.SENSE_RED] = gp
			if not custprop[SenseCell.Props.SENSE_GREEN] is GenomeParam:
				var gp := GenomeParam.new()
				gp.fixed_value = 0.0
				custprop[SenseCell.Props.SENSE_GREEN] = gp
			if not custprop[SenseCell.Props.SENSE_BLUE] is GenomeParam:
				var gp := GenomeParam.new()
				gp.fixed_value = 0.0
				custprop[SenseCell.Props.SENSE_BLUE] = gp
			if not custprop[SenseCell.Props.COLOR_THRESHOLD] is GenomeParam:
				var gp := GenomeParam.new()
				gp.fixed_value = 0.1
				custprop[SenseCell.Props.COLOR_THRESHOLD] = gp
		_:
			custprop.clear()

extends Node
enum ToolSelector
{
	CELL_SYNTHESIZER, #Fancy name, basically adding cell
	OPTICAL_TWEEZERS, #Fancy name, basically cell mover tool
	CELL_BOOST,
	CELL_REMOVAL,
	CELL_DIAGNOSTICS,
	BIND_ADHESION, #Make adhesion (links) between cells
	DEBUG_CELL
}
enum SubstrateTemperature
{
	FREEZE,
	SLOW_OBSERVE,
	OBSERVE,
	INCUBATE,
	CUSTOM
}
enum CellType
{
	BASE_CELL, #The most basic cell
	PHOTOCYTE,
	LUMINOCYTE
}
signal UI_ready
const max_modes_count = 40
var UI = null #This must be immediately set so system can quickly access UI
###Containing current plate configuration and managing stuff
var maximum_cell_count = 100
var cell_count = 0
var brightness_mult = 1.0 #ONLY USE ON NON-MATH LIGHTNING BTW!!
var salinity = 0.25
var temperature = Game.SubstrateTemperature.OBSERVE
var use_voronoi = true
var math_lighting = Vector4(5.58, 1.025, 2.375, 0.14)
var use_math_lightning = true
var custom_temperature = 1.0
var max_adhesion_length = 40
var nitrates = 100.0 #0.0-100.0
var infonotice
##There are two options:
#True: this means the game use math and shader to calculate and create light which could be faster and can quickly change
#False: use image instead, which can create many unique stuff and probably more interesting plate
func _process(_delta: float) -> void:
	pass
func sterilize():
	get_tree().call_group("cells", "queue_free")
	get_tree().call_group("food", "queue_free")
#if you want to make it permanent, you do not need this function
func show_info_notice_timed(text: String, duration: float):
	infonotice.show()
	infonotice.text = text
	await get_tree().create_timer(duration).timeout
	infonotice.hide()
func _ready() -> void:
	Engine.time_scale = 1
	await UI_ready
	infonotice = UI.get_node("infonotice")
func get_script_for_type(type: CellType) -> GDScript:
	match type:
		CellType.BASE_CELL: return BaseCell
		CellType.PHOTOCYTE: return Photocyte
		CellType.LUMINOCYTE: return Luminocyte
		_: return BaseCell
func get_cell_type(cell: BaseCell):
	if cell is Photocyte:
		return CellType.PHOTOCYTE
	elif cell is Luminocyte:
		return CellType.LUMINOCYTE
	return CellType.BASE_CELL
func get_instance_cell(cell_type: CellType):
	match cell_type:
		Game.CellType.BASE_CELL:
			return load("uid://cymj82ljpiu70")
		Game.CellType.PHOTOCYTE:
			return load("uid://sy8jnyx6hyux")
		Game.CellType.LUMINOCYTE:
			return load("uid://b7wyhxq3hyig5")
		_:
			print("Unknown cell type")
			return load("uid://cymj82ljpiu70") #Load Base cell

extends Node
enum ToolSelector
{
	CELL_SYNTHESIZER, #Fancy name, basically adding cell
	OPTICAL_TWEEZERS, #Fancy name, basically cell mover tool
	CELL_BOOST,
	CELL_REMOVAL,
	CELL_DIAGNOSTICS,
	BIND_ADHESION #Make adhesion (links) between cells
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
	PHAGOCYTE
}
signal UI_ready
var UI = null #This must be immediately set so system can quickly access UI
###Containing current plate configuration and managing stuff
var brightness_mult = 1.0 #ONLY USE ON NON-MATH LIGHTNING BTW!!
var salinity = 0.25
var temperature = Game.SubstrateTemperature.OBSERVE
var use_voronoi = true
var math_lighting = Vector4(5.58, 1.025, 2.375, 0.14)
var use_math_lightning = true
var custom_temperature = 1.0
var max_adhesion_length = 40
var infonotice
##There are two options:
#True: this means the game use math and shader to calculate and create light which could be faster and can quickly change
#False: use image instead, which can create many unique stuff and probably more interesting plate
func _process(_delta: float) -> void:
	var cells = get_tree().get_nodes_in_group("cells")
	for cell in cells:
			cell.compute_flows()
	for cell in cells:
			cell.apply_flows()
	for cell in cells:
		cell.apply_adhesion_force()
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

extends Node
enum ToolSelector
{
	CELL_SYNTHESIZER, #Fancy name, basically adding cell
	OPTICAL_TWEEZERS, #Fancy name, basically cell mover tool
	CELL_BOOST,
	CELL_REMOVAL,
	CELL_DIAGNOSTICS
}
enum SubstrateTemperature
{
	FREEZE,
	SLOW_OBSERVE,
	OBSERVE,
	INCUBATE
}
var UI = null #This must be immediately set so system can quickly access UI
###Containing current plate configuration and managing stuff
var brightness_mult = 1.0 #ONLY USE ON NON-MATH LIGHTNING BTW!!
var salinity = 0.25
var temperature = Game.SubstrateTemperature.OBSERVE
var use_voronoi = true
var math_lighting = Vector4(5.58, 1.025, 2.375, 0.14)
var use_math_lightning = true
var adhesion_links
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

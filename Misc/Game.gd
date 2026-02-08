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
###Containing current plate configuration and managing stuff
var brightness_mult = 1.0
var salinity = 0.25
var temperature = Game.SubstrateTemperature.OBSERVE
var use_voronoi = true
func _process(_delta: float) -> void:
	await get_tree().create_timer(1).timeout
	if Engine.get_frames_drawn() < 1:
		print("FPS is dangerously low. Quitting the game")
		get_tree().quit()

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

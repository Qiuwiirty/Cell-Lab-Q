extends Node
#NOTICE: when adding new properties, remember to always edit SubsConf!
enum ToolSelector
{
	CELL_SYNTHESIZER, #Fancy name, basically adding cell
	OPTICAL_TWEEZERS, #Fancy name, basically cell mover tool
	CELL_BOOST,
	CELL_REMOVAL,
	CELL_DIAGNOSTICS,
	BIND_ADHESION, #Make adhesion (links) between cells
	DEBUG_CELL,
	ZONE_EDITOR,
	OBSTACLE_EDITOR
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
	LUMINOCYTE,
	PHAGOCYTE,
	FLAGELLOCYTE,
	DEVOROCYTE,
	LIPOCYTE,
	GLUEOCYTE
}
signal UI_ready
const max_modes_count := 40
var UI = null #This must be immediately set so system can quickly access UI
var plate: Plate
###Containing current plate configuration and managing stuff
var maximum_cell_count := 100
var cell_count := 0
var brightness_mult := 1.0 #ONLY USE ON NON-MATH LIGHTNING BTW!!
var salinity := 0.25
var temperature := Game.SubstrateTemperature.OBSERVE
var use_voronoi := true
var math_lighting := Vector4(5.58, 1.025, 2.375, 0.14)
var use_math_lightning := true
var nonmath_use_only_alpha := false #Use alpha or not for brightness of non-mathematical lighting (If false, it still use alpha, just that r, g, & b would also be used)
var custom_temperature := 1.0
var max_adhesion_length := 40.
var nitrates := 100.0 #0.0-100.0
var plate_age := 0.0 #h
var light_feed_cost_luminocyte := false #Basically, if true, feeding on photocytes will cost mass for the Luminocyte
var infonotice

#Plate border settings
var use_plate_border := false
var plate_diameter := 1000.
var plate_color := Color(1.0, 1.0, 1.0)
var plate_thickness := 20.
#Nutrients settings
var food_spawn_shape := Food.SpawnShape.CIRCLE
var rect_spawn_size := Vector2(1000, 1000)
var radii_spawn_size := 500.0
var nutrient_rate := 5. #0.0 - 15
var nutrient_chunk_size := 1.2 #0.0 - 1.2
var show_food_spawn_marker := true

##There are two options:
#True: this means the game use math and shader to calculate and create light which could be faster and can quickly change
#False: use image instead, which can create many unique stuff and probably more interesting plate

#These used for getting and reading image brightness for non-mathematical lighting photosynthesis
var width
var height
var format

var data: PackedByteArray
var current_path = "res://platecolor.png"
var image_scale = Vector2(1.0, 1.0)
func _process(delta: float) -> void:
	if temperature == SubstrateTemperature.FREEZE:
		return
	plate_age += delta * timescale_modifier()
func sterilize() -> void:
	get_tree().call_group("cells", "die")
	get_tree().call_group("food", "queue_free")
	plate_age = 0
#if you want to make it permanent, you do not need this function
func show_info_notice_timed(text: String, duration: float) -> void:
	infonotice.show()
	infonotice.text = text
	await get_tree().create_timer(duration).timeout
	infonotice.hide()
func _ready() -> void:
	load_file(current_path)
	await UI_ready
	plate = UI.get_parent()
	infonotice = UI.get_node("infonotice")
func get_script_for_type(type: CellType) -> GDScript:
	match type:
		CellType.BASE_CELL: return BaseCell
		CellType.PHOTOCYTE: return Photocyte
		CellType.LUMINOCYTE: return Luminocyte
		CellType.PHAGOCYTE: return Phagocyte
		CellType.FLAGELLOCYTE: return Flagellocyte
		CellType.DEVOROCYTE: return Devorocyte
		CellType.LIPOCYTE: return Lipocyte
		CellType.GLUEOCYTE: return Glueocyte
		_: return BaseCell
func get_cell_type(cell: BaseCell) -> CellType:
	if cell is Photocyte:
		return CellType.PHOTOCYTE
	elif cell is Luminocyte:
		return CellType.LUMINOCYTE
	elif cell is Phagocyte:
		return CellType.PHAGOCYTE
	elif cell is Flagellocyte:
		return CellType.FLAGELLOCYTE
	elif cell is Devorocyte:
		return CellType.DEVOROCYTE
	elif cell is Lipocyte:
		return CellType.LIPOCYTE
	elif cell is Glueocyte:
		return CellType.GLUEOCYTE
	return CellType.BASE_CELL
	#This doesn't work..
	#match cell:
		#Photocyte:
			#return CellType.PHOTOCYTE
		#Luminocyte:
			#return CellType.LUMINOCYTE
		#Phagocyte:
			#return CellType.PHAGOCYTE
		#Flagellocyte:
			#return CellType.FLAGELLOCYTE
		#Devorocyte:
			#return CellType.DEVOROCYTE
		#Lipocyte:
			#return CellType.LIPOCYTE
		#Glueocyte:
			#return CellType.GLUEOCYTE
		#_:
			#return CellType.BASE_CELL
func get_instance_cell(cell_type: CellType):
	match cell_type:
		CellType.BASE_CELL:
			return load("uid://cymj82ljpiu70")
		CellType.PHOTOCYTE:
			return load("uid://sy8jnyx6hyux")
		CellType.LUMINOCYTE:
			return load("uid://b7wyhxq3hyig5")
		CellType.PHAGOCYTE:
			return load("uid://byt4u4bomwhbk")
		CellType.FLAGELLOCYTE:
			return load("uid://df45adrwx1bsm")
		CellType.DEVOROCYTE:
			return load("uid://dwjpg3vw0amtl")
		CellType.LIPOCYTE:
			return load("uid://jo0e0p6p8q8l")
		CellType.GLUEOCYTE:
			return load("uid://d3x0cbqjr0c6n")
		_:
			print("Unknown cell type")
			return load("uid://cymj82ljpiu70") #Load Base cell
func timescale_modifier() -> float:
	match Game.temperature:
		Game.SubstrateTemperature.SLOW_OBSERVE:
			return 0.1
		Game.SubstrateTemperature.OBSERVE:
			return 1
		Game.SubstrateTemperature.INCUBATE:
			return 3
		Game.SubstrateTemperature.CUSTOM:
			return Game.custom_temperature
		Game.SubstrateTemperature.FREEZE:
			return 0
		_:
			print('No valid game.temperature')
			return 1
func load_file(path: String) -> void: #Load file for non-mathematical lighting photosynthesisif FileAccess.file_exists(path):
	if FileAccess.file_exists(path):
		var img := Image.new()
		var err := img.load(path)  #Image.load() handles OS paths, normal load doesn't work
		if err != OK:
			show_info_notice_timed("Failed to load image: " + path, 3)
			print("Failed to load image: " + path)
			return
		img.convert(Image.FORMAT_RGBA8)
		# Apply scale before storing
		var scaled_w := int(img.get_width() * image_scale.x)
		var scaled_h := int(img.get_height() * image_scale.y)
		img.resize(scaled_w, scaled_h, Image.INTERPOLATE_BILINEAR)
		width = img.get_width()
		height = img.get_height()
		data = img.get_data()
	else:
		show_info_notice_timed("Cannot load path: " + path, 3)
		print("Cannot load path: " + path)
enum SubsConf #Substrate configuration (it's shorted so i don't need to type much lol)
{
	SALINITY,
	NITRATES,
	MAX_ADHESION_LENGTH,
	BRIGHTNESS_MULT,
	LIGHT_FEED_COST_LUMINOCYTE
}
func get_global_conf() -> Array:
	var conf := []
	###WARNING: NEED CHANGE THIS NUMBER EVERYTIME NEW CONFIGURATION CAME UP
	conf.resize(5)
	conf[SubsConf.SALINITY] = salinity
	conf[SubsConf.NITRATES] = nitrates
	conf[SubsConf.MAX_ADHESION_LENGTH] = max_adhesion_length
	conf[SubsConf.BRIGHTNESS_MULT] = brightness_mult
	conf[SubsConf.LIGHT_FEED_COST_LUMINOCYTE] = light_feed_cost_luminocyte
	return conf

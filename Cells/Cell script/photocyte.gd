extends BaseCell
class_name Photocyte

#These used for getting and reading image brightness to perform photosynthesis
var width
var height
var format

var data: PackedByteArray

func _ready():
	var img: Image = preload("res://platecolor.png").get_image()
	img.convert(Image.FORMAT_RGBA8)
	width = img.get_width()
	height = img.get_height()
	data = img.get_data()
	$render_quad.material = $render_quad.material.duplicate()
	$render_quad.material.set_shader_parameter("u_use_decoration", 1.0)
	$render_quad.material.set_shader_parameter("decoration", load("uid://dpuiru35vknq5"))
	super()
	energy_loss_coefficient = 2
func _process(delta: float) -> void:
	super(delta)
	if Game.temperature == Game.SubstrateTemperature.FREEZE:
		return
	#Photosynthesis
	#Delta must be mutlipied with timescale_modifier because the super(delta) does not carry any modification to delta and need to perform again to be consistent
	#Else, photocyte may rapidly dying or immortal if not using time scale modifier
	mass = min(mass + (get_brightness() * (delta * timescale_modifier()) * (1.0 if Game.use_math_lightning else Game.brightness_mult)), 3.6)
func get_brightness() -> float:
	if not Game.use_math_lightning:
		var local_pos: Vector2 = $"../Platecolor".to_local(global_position)

		var pixel_x := int(local_pos.x + width * 0.5)
		var pixel_y := int(local_pos.y + height * 0.5)
		#check if pixel are out of bounds
		if (pixel_x >= width or pixel_x < 0) or (pixel_y >= height or pixel_y < 0):
			return 0.0
		var colorpx := get_pixel_rgb8(pixel_x, pixel_y)
		#based on transparency
		#return colorpx.a
		var brightness = (0.299 * colorpx.r + 0.587 * colorpx.g + 0.114 * colorpx.b) * colorpx.a
		return brightness
	else:
		var colorpx = shader_color(global_to_shader_p(global_position), Game.math_lighting)
		var brightness = 0.299 * colorpx.r + 0.587 * colorpx.g + 0.114 * colorpx.b
		return brightness
func get_pixel_rgb8(
		x: int,
		y: int,
	) -> Color:
	var idx = (y * width + x) * 4
	return Color(
		data[idx]     / 255.0,
		data[idx + 1] / 255.0,
		data[idx + 2] / 255.0,
		data[idx + 3] / 255.0
	)
	
func global_to_shader_p(gpos: Vector2) -> Vector2:
	var local =$"../quad".to_local(gpos)
	var uv = (local + Vector2(1000, 1000)/2) / Vector2(1000, 1000)
	return uv
func shader_color(uv: Vector2, dir: Vector4) -> Color:
	var p = uv * 2.0 - Vector2.ONE
	
	var ds = p.dot(p)
	
	if ds > 1.02:
		return Color(0,0,0,0)
		
	if ds > 0.999:
		return Color(0,0,0,0)
	
	ds = 1.0 + (1.0 - dir.z) * (1.0 - ds) / dir.z
	
	var py = dir.x * p.x + dir.y * p.y
	
	var l = dir.w * max((py * (1.0 - dir.z) + dir.z) / (ds * ds), 0.0)
	
	return Color(l*0.5, l*0.35, l*0.25, 1.0)

extends BaseCell
class_name Photocyte

func _ready():
	$render_quad.material = $render_quad.material.duplicate()
	$render_quad.material.set_shader_parameter("u_use_decoration", 1.0)
	$render_quad.material.set_shader_parameter("decoration", load("uid://dpuiru35vknq5"))
	super()
	energy_loss_coefficient = 2
func _process(delta: float) -> void:
	super(delta)
func simulate_step(delta: float) -> void:
	super(delta)
	mass = min(mass + (get_brightness() * delta * (1.0 if Game.use_math_lightning else conf[Game.SubsConf.BRIGHTNESS_MULT])), 3.6)
func get_brightness() -> float:
	if not Game.use_math_lightning:
		var local_pos: Vector2 = $"../Platecolor".to_local(global_position)
		var pixel_x := int(round(local_pos.x + Game.width * 0.5))
		var pixel_y := int(round(local_pos.y + Game.height * 0.5))
		if pixel_x >= Game.width or pixel_x < 0 or pixel_y >= Game.height or pixel_y < 0:
			return 0.0
		var colorpx := get_pixel_rgb8(pixel_x, pixel_y)
		if Game.nonmath_use_only_alpha:
			return colorpx.a
		return (0.299 * colorpx.r + 0.587 * colorpx.g + 0.114 * colorpx.b) * colorpx.a
	else:
		var colorpx = shader_color(global_to_shader_p(global_position), Game.math_lighting)
		return 0.299 * colorpx.r + 0.587 * colorpx.g + 0.114 * colorpx.b
func get_pixel_rgb8(
		x: int,
		y: int,
	) -> Color:
	var idx = (y * Game.width + x) * 4
	return Color(
		Game.data[idx]     / 255.0,
		Game.data[idx + 1] / 255.0,
		Game.data[idx + 2] / 255.0,
		Game.data[idx + 3] / 255.0
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

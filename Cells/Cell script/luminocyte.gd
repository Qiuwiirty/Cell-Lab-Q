extends BaseCell
class_name Luminocyte
#lum is luminosity
@export var lum_scale = 1.0 #1.0 is the supposed maximum for size and intensity (but then there's no enforcing)
@export var lum_intensity = 1.0 
var photocytes_in_light: Array[Photocyte] = []
func _ready() -> void:
	super()
	energy_loss_coefficient = 2.5
func simulate_step(delta: float) -> void:
	super(delta)
	$photocyte_detector/collision.scale = Vector2(lum_scale, lum_scale)
	$light.scale = Vector2(lum_scale, lum_scale)
	var warm := Color(1.0, 0.8, 0.5)  #warm glow fallback
	var t = current_color.v  #HSV value, 0.0 = black, 1.0 = bright
	var light_color = current_color.lerp(warm, 1.0 - t)
	$light.material.set_shader_parameter("u_color", light_color)
	$light.material.set_shader_parameter("intensity", lum_intensity)
	var i = 0
	for photocyte in photocytes_in_light:
		if !is_instance_valid(photocyte):
			photocytes_in_light.remove_at(i)
			continue
		var distance_mod = (128 * lum_scale) / global_position.distance_to(photocyte.global_position)
		var result = distance_mod * delta * lum_intensity / 5 
		photocyte.mass = min(photocyte.mass + result, 3.6)
		if Game.light_feed_cost_luminocyte and not mode.disable_metabolism:
			mass -= result
		i += 1
		
func metabolism(delta, modifier := 1.0):
	super(delta, modifier + (lum_intensity + lum_scale) / 2.0)
	
func _on_photocyte_detector_area_entered(body: Node2D) -> void:
	if body is Photocyte:
		if global_position.distance_to(body.global_position) <= 128:
			photocytes_in_light.append(body)

func _on_photocyte_detector_area_exited(body: Node2D) -> void:
	if body is Photocyte and is_instance_valid(body):
		if photocytes_in_light.has(body):
			photocytes_in_light.erase(body)

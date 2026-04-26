extends BaseCell
class_name Nitrocyte
func _ready() -> void:
	super()
	$renders/fractal.material = $renders/fractal.material.duplicate()
func simulate_step(delta: float) -> void:
	super(delta)
	#constantly add nitrogen reserve
	nitrogen_reserve = min(nitrogen_reserve + 10.0 * delta, 100)
func correct_appearance(delta, modify_color_radius = true) -> void:
	super(delta, modify_color_radius)
	$renders/fractal.material.set_shader_parameter("color", current_color * 0.5)
	$renders/fractal.scale = Vector2(radius / 15., radius / 15.)

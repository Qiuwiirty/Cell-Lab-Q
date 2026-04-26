extends SenseCell
class_name Monocyte #THIS IS SAME AS SENSEOCYTE, but I think monocyte is a better name
func _ready() -> void:
	super()
	$renders/mono.material = $renders/mono.material.duplicate()
func simulate_step(delta: float) -> void:
	super(delta)

func correct_appearance(delta, modify_color_radius = true):
	super(delta, modify_color_radius)
	$renders/mono.material.set_shader_parameter("cell_color", current_color * 0.5)
	$renders/mono.material.set_shader_parameter("cell_radius", (radius / 15) * 0.77)

func _on_detector_area_entered(area: Area2D) -> void:
	if area is BaseCell:
		cells_in_area.append(area)
	if area is Food:
		foods_in_area.append(area)

func _on_detector_area_exited(area: Area2D) -> void:
	if area is BaseCell:
		cells_in_area.erase(area)
	if area is Food:
		foods_in_area.erase(area)

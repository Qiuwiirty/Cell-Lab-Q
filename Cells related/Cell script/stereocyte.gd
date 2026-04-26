extends SenseCell
class_name Stereocyte
func _ready() -> void:
	super()
	$renders/stereo.material = $renders/stereo.material.duplicate()
func correct_appearance(delta, modify_color_radius = true):
	super(delta, modify_color_radius)
	$renders/stereo.material.set_shader_parameter("cell_color", current_color * 0.5)
	$renders/stereo.material.set_shader_parameter("cell_radius", (radius / 15) * 0.707)
func simulate_step(delta: float) -> void:
	super(delta)
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

func sense_cell(cell: BaseCell) -> float:
	if not color_matches(cell):
		return 0.0
	var to_target := cell.global_position - global_position
	var r := to_target.length()
	var right := Vector2.UP.rotated(rotation)
	var side := to_target.normalized().dot(right)
	return gprop(Props.OUTPUT) * bessel_k0(r / R0) * side

func sense_food(food: Food) -> float:
	var to_target := food.global_position - global_position
	var r := to_target.length()
	var m : float = food.nutrition 
	
	var right := Vector2.UP.rotated(rotation)
	var side := to_target.normalized().dot(right)
	return gprop(Props.OUTPUT)  * m * C * bessel_k0(r / R0) * side

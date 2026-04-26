extends Area2D
class_name SimpleCell

## A stripped-down environment cell. No DNA, no adhesion, no splitting.
## Has physics (velocity/drag/collision) and metabolism, dies → spawns food.

const FOOD = preload("uid://bcp4xdxc828fp")

var radius := 15.0
var mass := 2.88
var velocity := Vector2.ZERO
var angular_velocity := 0.0
var energy_loss_coefficient := 1.0

var current_color := Color.WHITE
var visible_on_screen := false

var colliding: Array[Node2D]

var accumulator := 0.0
const FIXED_STEP := 1.0 / 60.0

var conf := []

var protected_devorocyte = false 
var protected_injury = false

func _ready() -> void:
	conf = Game.get_global_conf()
	$render_quad.material = $render_quad.material.duplicate()
	$render_quad.mesh   = $render_quad.mesh.duplicate()
	$collision.shape    = $collision.shape.duplicate()
	correct_appearance(1.0 / 60.0)

func _process(delta: float) -> void:
	create_voronoi_effect()
	if Game.temperature == Game.SubstrateTemperature.FREEZE:
		return

	accumulator += delta * Game.timescale_modifier()
	while accumulator >= FIXED_STEP:
		simulate_step(FIXED_STEP)
		accumulator -= FIXED_STEP

func simulate_step(delta: float) -> void:
	metabolism(delta)
	apply_collision_forces(delta)
	apply_motion(delta)
	correct_appearance(delta)

	if mass < 0.90:
		die()

func correct_appearance(_delta: float) -> void:
	radius = lerp(radius, 15.0 * sqrt(mass / 3.6), 0.1)
	$collision.shape.radius = radius
	$render_quad.material.set_shader_parameter("u_color",     current_color)
	$render_quad.material.set_shader_parameter("u_size_mult", radius / 15.0)

#region Physics

func apply_motion(delta: float) -> void:
	velocity         *= pow(0.9, delta * 60.0)
	global_position  += velocity * delta
	angular_velocity *= pow(0.9, delta * 60.0)
	rotation         += angular_velocity * delta

func apply_collision_forces(delta: float) -> void:
	if Game.use_plate_border:
		var limit := (Game.plate_diameter / 2.0) - radius - Game.plate_thickness
		if global_position.length() > limit:
			global_position = global_position.normalized() * limit

	for other in colliding:
		if other is BaseCell or other is SimpleCell:
			var dir  := global_position - other.global_position
			var dist := dir.length()
			if dist < other.radius - radius:
				die()
				return
			var overlap := radius * 2.0 - dist
			if overlap <= 0.0:
				continue
			velocity += (dir / dist) * overlap * delta * 20.0

		elif other is CircleObstacle:
			var dir      := global_position - other.global_position
			var dist     := dir.length()
			if dist == 0.0:
				global_position += Vector2(radius, 0.0)
				continue
			var min_dist = radius + (other.current_diameter / 2.0)
			if dist < min_dist:
				global_position += (dir / dist) * (min_dist - dist)

		elif other is RectObstacle:
			var local_pos := other.to_local(global_position)
			var half      = other.current_size / 2.0
			var closest   = Vector2(
				clamp(local_pos.x, -half.x, half.x),
				clamp(local_pos.y, -half.y, half.y)
			)
			var diff = local_pos - closest
			var dist := diff.length()
			if dist == 0.0:
				var dx = half.x - abs(local_pos.x)
				var dy = half.y - abs(local_pos.y)
				closest = dx < dy \
					if Vector2(half.x * sign(local_pos.x), local_pos.y) \
					else Vector2(local_pos.x, half.y * sign(local_pos.y))
				diff = local_pos - closest
				dist = diff.length()
				if dist == 0.0:
					global_position += other.to_global(Vector2(radius, 0.0))
					continue
			if dist < radius:
				var push = (diff / dist) * (radius - dist)
				global_position += other.to_global(closest + diff + push) \
								 - other.to_global(closest + diff)
#endregion

#region -Metabolism and death-
func metabolism(delta: float) -> void:
	mass -= energy_loss_coefficient * (1.0778 - conf[Game.SubsConf.SALINITY]) * 0.05 * delta

func die() -> void:
	var food := FOOD.instantiate()
	food.global_position = global_position
	food.nutrition       = mass
	get_parent().add_child(food)
	queue_free()
#endregion

#region -Collision signal-

func _cell_entered(area: Area2D) -> void:
	colliding.append(area)

func _cell_exited(area: Area2D) -> void:
	colliding.erase(area)

#endregion

#region -Screen notifier-

func _screen_entered_notifier() -> void:
	visible_on_screen = true
	$render_quad.show()

func _screen_exited_notifier() -> void:
	visible_on_screen = false
	$render_quad.hide()

#endregion

#region -Voronoi effect-
func get_midpoint_intersection(c2: Vector2, r2: float) -> Vector2:
	var d := global_position.distance_to(c2)
	# No intersection or degenerate case
	if d == 0.0 or d > radius + r2 or d < abs(radius - r2):
		return Vector2.ZERO # or null / error handling

	var a = (radius * radius - r2 * r2 + d * d) / (2.0 * d)
	var direction := (c2 - global_position).normalized()
	return to_local(global_position + direction * a)

func create_voronoi_effect() -> void:
	var positions := PackedVector2Array()
	var rot_dirs := PackedVector2Array()
	for cell in colliding:
		if !is_instance_valid(cell) or !cell.is_in_group("cells"):
			continue
		var midpoint = get_midpoint_intersection(cell.global_position, cell.radius)
		if midpoint == Vector2.ZERO:
			continue
		var uv = (midpoint + $render_quad.mesh.size * 0.5) / $render_quad.mesh.size
		uv.y = 1.0 - uv.y 
		positions.append(uv)
		var angle_to = get_angle_to(cell.global_position) 
		rot_dirs.append(Vector2(cos(angle_to), -sin(angle_to)))
	$render_quad.material.set_shader_parameter("centers", positions)
	$render_quad.material.set_shader_parameter("cell_count", colliding.size())
	$render_quad.material.set_shader_parameter("rot_dirs", rot_dirs)
	$render_quad.material.set_shader_parameter("screen_size", get_viewport_rect().size)
#endregion

func update_protected() -> void:
	protected_devorocyte = false
	protected_injury = false

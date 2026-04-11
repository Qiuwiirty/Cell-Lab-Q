extends Node2D
class_name Plate

var mode = Game.ToolSelector.CELL_SYNTHESIZER
const PHOTOCYTE = preload("uid://sy8jnyx6hyux") #I do not get why using preload and const cause an error in testplate if there basecell. 
const FOOD = preload("uid://bcp4xdxc828fp")
const ZONE = preload("uid://cddbgwbo87uoa")

var selected_cell: BaseCell = null
var locked_to_selected = false

var bind_adhesion_cell1: BaseCell = null
var bind_adhesion_cell2: BaseCell = null

var accumulator := 0.0
const FIXED_STEP := 1.0 / 60.0
func _unhandled_input(event: InputEvent) -> void:
	#ui_cancel is esc
	if event.is_action_pressed("ui_cancel"):
		discard_any_selection()
		Game.infonotice.hide()
	if event.is_action_pressed("ui_accept"):
		if bind_adhesion_cell1 and bind_adhesion_cell2:
			handle_adhesion_bind()
	if event is InputEventMouseButton:
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and event.pressed:
			match mode:
				Game.ToolSelector.CELL_SYNTHESIZER:
					var new_cell = PHOTOCYTE.instantiate()
					#Add by Vector2(randf(), randf()) to avoid weird physics issue
					new_cell.global_position = get_global_mouse_position() + Vector2(randf(), randf())
					add_child(new_cell)
					$PlaceCell.play()
				Game.ToolSelector.OPTICAL_TWEEZERS:
					pass
				Game.ToolSelector.CELL_BOOST:
					var new_food = FOOD.instantiate()
					new_food.global_position = get_global_mouse_position() + Vector2(randf(), randf())
					add_child(new_food)
					$PlaceCell.play()
				Game.ToolSelector.CELL_REMOVAL:
					$Invalid.play()
				Game.ToolSelector.CELL_DIAGNOSTICS:
					if selected_cell:
						selected_cell.to_select(false)
						selected_cell = null
						locked_to_selected = false
					else:
						$Invalid.play()
				Game.ToolSelector.ZONE_EDITOR:
					var new_zone = ZONE.instantiate()
					new_zone.global_position = get_global_mouse_position()
					new_zone.modulate = Color(randf(), randf(), randf(), 0.3906)
					add_child(new_zone)
func _process(delta: float) -> void:
	if Game.temperature == Game.SubstrateTemperature.FREEZE:
		return
	accumulator += delta * Game.timescale_modifier()
	while accumulator >= FIXED_STEP:
		if randf() < get_nutrient_spawn_chance() * FIXED_STEP:
			spawn_food()
		accumulator -= FIXED_STEP
	if selected_cell:
		if Game.UI:
			Game.UI.set_diagnostics(selected_cell.diagnostics())
		if locked_to_selected:
			$Camera2D.global_position = selected_cell.global_position
	else:
		if Game.UI:
			#false make it not show any diagnostics
			Game.UI.set_diagnostics("false")
	if Game.use_math_lightning:
		$quad.material.set_shader_parameter("dir", Game.math_lighting)
func _ready() -> void:
	correct_brightness_plate()
func correct_brightness_plate():
	$Platecolor.material.set_shader_parameter("brightness", Game.brightness_mult)
func change_tool(into: Game.ToolSelector):
	mode = into
	if mode != Game.ToolSelector.CELL_DIAGNOSTICS or mode != Game.ToolSelector.BIND_ADHESION:
		discard_any_selection()
		Game.UI.get_node("debug_cell").close()
	if mode == Game.ToolSelector.ZONE_EDITOR:
		Game.show_info_notice_timed("Click anywhere to create/edit a ZONE", 5)
func discard_any_selection():
	discard_old_selected_cell()
	if bind_adhesion_cell1:
		bind_adhesion_cell1.discard_bind_selection()
		bind_adhesion_cell1 = null
		if bind_adhesion_cell2:
			bind_adhesion_cell2.discard_bind_selection()
			bind_adhesion_cell2 = null
#Move toward selected cell smoothly
func tween_to_selected_cell_position() -> void:
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)\
	.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property($Camera2D, "global_position", selected_cell.global_position, 0.5)
	tween.tween_callback(func(): locked_to_selected = true)
#Remove selected cell
func discard_old_selected_cell() -> void:
	if selected_cell:
		#Second argument (play sound) is false because this function is often used when switching diagnostics. And switching diagnostics does not have the deselect so it is removed
		selected_cell.to_select(false, false)
		locked_to_selected = false
		selected_cell = null
func handle_adhesion_bind():
	#This assume if the cell's adhesion are symmetrical/mutual (IF NOT CAN CAUSE ISSUE)
	if not bind_adhesion_cell1.adhesion.has(bind_adhesion_cell2):
		if bind_adhesion_cell1.global_position.distance_to(bind_adhesion_cell2.global_position) < Game.max_adhesion_length:
			bind_adhesion_cell1.adhesion.append(bind_adhesion_cell2)
			bind_adhesion_cell2.adhesion.append(bind_adhesion_cell1)
			Game.infonotice.hide()
		else:
			Game.show_info_notice_timed("[color=red] [i] The distance between cells is too far for adhesion", 3)
	else:
		bind_adhesion_cell1.adhesion.erase(bind_adhesion_cell2)
		bind_adhesion_cell2.adhesion.erase(bind_adhesion_cell1)
		Game.infonotice.hide()
	discard_any_selection()

func change_mathematical_lighting() -> void:
	if Game.use_math_lightning:
		$Platecolor.hide()
		$quad.show()
	else: #not using mathematical lighting
		$Platecolor.show()
		$quad.hide()
		var img := Image.new()
		img.load(Game.current_path)
		$Platecolor.texture = ImageTexture.create_from_image(img)
		$Platecolor.scale = Game.image_scale

func change_nonmath_plate_scale() -> void:
	$Platecolor.scale = Game.image_scale

func spawn_food() -> void:
	var new_food: Food = FOOD.instantiate()
	match Game.food_spawn_shape:
		Food.SpawnShape.RECTANGLE:
			new_food.global_position = Vector2(
				randf_range(-Game.rect_spawn_size.x, Game.rect_spawn_size.x),
				randf_range(-Game.rect_spawn_size.y, Game.rect_spawn_size.y)
			) / 2
		Food.SpawnShape.CIRCLE:
			var angle = randf() * TAU
			var radius = sqrt(randf()) * Game.radii_spawn_size
			new_food.global_position = Vector2(cos(angle), sin(angle)) * radius
	new_food.nutrition = Game.nutrient_chunk_size * 8.3333
	add_child(new_food)

func get_nutrient_spawn_chance():
	var A
	if Game.use_math_lightning: #It must be circle 
		var area =  PI * pow($quad.mesh.size.x / 2, 2)
		A = area / PI
	else: #It assume it must be a rectangle
		A = (Game.width * Game.height) / PI
	return A * (Game.nutrient_rate / 100) / 0.02

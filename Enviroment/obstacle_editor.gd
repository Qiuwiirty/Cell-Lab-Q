extends PanelContainer
class_name ObstacleEditor
var obstacle: Area2D
const ANIM_DURATION = 0.1

var _dragging := false
var _drag_offset := Vector2.ZERO

enum {
	CIRCLE,
	RECTANGLE
}
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
			_drag_offset = get_global_mouse_position() - global_position
	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset

func _process(delta: float) -> void:
	if obstacle is RectObstacle:
		var direction = Input.get_vector("ui_left", "ui_right", "ui_down", "ui_up")
		obstacle.set_size((obstacle.current_size + direction * delta * 100).max(Vector2(0.0, 0.0)))
		$VBoxContainer/ScrollContainer/VBoxContainer/Size/x.value = obstacle.current_size.x
		$VBoxContainer/ScrollContainer/VBoxContainer/Size/y.value = obstacle.current_size.y
	elif obstacle is CircleObstacle:
		if Input.is_action_pressed("ui_up"):
			obstacle.set_diameter(obstacle.current_diameter + 100 * delta)
			$VBoxContainer/ScrollContainer/VBoxContainer/Radius/diameter.value = obstacle.current_diameter
		elif Input.is_action_pressed("ui_down"):
			obstacle.set_diameter(min(obstacle.current_diameter - 100 * delta), 0.0)
			$VBoxContainer/ScrollContainer/VBoxContainer/Radius/diameter.value = obstacle.current_diameter
func open():
	show()
	scale = Vector2(0.8, 0.8)
	modulate.a = 0.0
	
	var tween = create_tween().set_parallel(true)
	#set_trans and set_ease are added to make it more smooth
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "scale", Vector2.ONE, ANIM_DURATION)
	tween.tween_property(self, "modulate:a", 1.0, ANIM_DURATION)
func close():
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	
	tween.tween_property(self, "scale", Vector2(0.8, 0.8), ANIM_DURATION)
	tween.tween_property(self, "modulate:a", 0.0, ANIM_DURATION)
	tween.set_parallel(false)
	tween.tween_callback(hide)
func assign_obstacle(new_obstacle: Area2D) -> void:
	if new_obstacle is CircleObstacle:
		$VBoxContainer/ScrollContainer/VBoxContainer/Size.hide()
		$VBoxContainer/ScrollContainer/VBoxContainer/Radius.show()
		$VBoxContainer/ScrollContainer/VBoxContainer/Radius/diameter.value = new_obstacle.current_diameter
	elif new_obstacle is RectObstacle: #Why use elif? to make sure and also Godot editor would know :)
		$VBoxContainer/ScrollContainer/VBoxContainer/Size.show()
		$VBoxContainer/ScrollContainer/VBoxContainer/Radius.hide()
		$VBoxContainer/ScrollContainer/VBoxContainer/Size/x.value = new_obstacle.current_size.x
		$VBoxContainer/ScrollContainer/VBoxContainer/Size/y.value = new_obstacle.current_size.y
	else:
		print("Obstacle is not CircleObstacle/RectObstacle and therefore invalid.")
		return
	$VBoxContainer/ScrollContainer/VBoxContainer/color_of_zone/ColorPickerButton.color = new_obstacle.modulate
	obstacle = new_obstacle

func _on_color_changed(color: Color) -> void:
	if obstacle:
		obstacle.modulate = color

func _on_shape_selected(index: int) -> void:
	match index:
		CIRCLE:
			pass
		RECTANGLE:
			pass


func _on_x_changed(value: float) -> void:
	if obstacle is RectObstacle:
		obstacle.set_size(Vector2(value, obstacle.current_size.y))

func _on_y_changed(value: float) -> void:
	if obstacle is RectObstacle:
		obstacle.set_size(Vector2(obstacle.current_size.x, value))

func _on_diameter_changed(value: float) -> void:
	if obstacle is CircleObstacle:
		obstacle.set_diameter(value)

func _on_delete_button_up() -> void:
	obstacle.queue_free()
	obstacle = null
	close()

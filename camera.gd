extends Camera2D

var dragging := false
var last_mouse_pos := Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	# Zooming
	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom *= 1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom /= 1.1

	# Start / stop dragging (middle mouse or right mouse recommended)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			dragging = event.pressed
			last_mouse_pos = event.position

	# Drag movement
	if event is InputEventMouseMotion and dragging:
		var delta = event.position - last_mouse_pos
		global_position -= (delta / zoom)
		last_mouse_pos = event.position

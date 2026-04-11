extends PanelContainer

###NOTE: THIS NODE AND SCRIPT IS INTENDED USING INSIDE 'ui'. MAY BREAK IF PLACED INCORRECTLY
@onready var plate = get_parent().get_parent()
###Animation used is easing scale ( I think that's the name? :P )
const ANIM_DURATION = 0.1

var _dragging := false
var _drag_offset := Vector2.ZERO

@onready var yes: Button = $VBoxContainer/HBoxContainer/yes
@onready var no: Button = $VBoxContainer/HBoxContainer/no
@onready var information: Label = $VBoxContainer/Label
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


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_dragging = event.pressed
			_drag_offset = get_global_mouse_position() - global_position

	elif event is InputEventMouseMotion and _dragging:
		global_position = get_global_mouse_position() - _drag_offset

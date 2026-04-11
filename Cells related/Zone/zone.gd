extends Area2D
class_name Zone
#Configurations coming from game, and can be adjusted
@export var salinity := 0.5
@export var nitrates := 100.0
@export var max_adhesion_length := 40.0
@export var brightness_mult := 1.0
@export var light_feed_cost_luminocyte := false

var mouse_over = false
var cells_inside: Array[BaseCell] = []
func _unhandled_input(event: InputEvent) -> void:
	if Game.plate.tool_mode == Game.ToolSelector.ZONE_EDITOR:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and mouse_over and event.is_pressed():
			var zone_editor = Game.UI.get_node_or_null("zone_editor")
			if zone_editor:
				zone_editor.assign_zone(self)
				zone_editor.open()
				get_viewport().set_input_as_handled()
			else:
				print("ZONE EDITOR DOES NOT EXIST")
func _on_area_entered(area: Area2D) -> void:
	if area is BaseCell:
		inject_conf(area)
		cells_inside.append(area)
func _on_area_exited(area: Area2D) -> void:
	if area is BaseCell:
		area.conf = Game.get_global_conf()
func inject_conf(cell:BaseCell) -> void:
	var conf := []
	conf.resize(5)
	conf[Game.SubsConf.SALINITY] = salinity
	conf[Game.SubsConf.NITRATES] = nitrates
	conf[Game.SubsConf.MAX_ADHESION_LENGTH] = max_adhesion_length
	conf[Game.SubsConf.LIGHT_FEED_COST_LUMINOCYTE] = light_feed_cost_luminocyte
	cell.conf = conf
func update_conf():
	if not cells_inside.is_empty():
		var i = 0
		for cell in cells_inside:
			if not is_instance_valid(cell):
				cells_inside.remove_at(i)
				i += 1
				continue
			inject_conf(cell)
			i += 1
func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false

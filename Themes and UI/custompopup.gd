extends PanelContainer
#Whoopsies daisy, this does not have a script yet!
#I plan on making it possible to create a custom popup menu using script only or via inspector easily without manually having to edit (maybe)
#But for now, just copy paste this node and modify it.

###Animation used is easing scale ( I think that's the name? :P )
func open():
	show()
	scale = Vector2(0.0, 0.0)
	modulate.a = 0.0
	
	var tween = create_tween().set_parallel(true)
	#set_trans and set_ease are added to make it more smooth
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "scale", Vector2.ONE, 0.3)

	tween.tween_property(self, "modulate:a", 1.0, 0.3)

func close():
	var tween = create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_IN)
	
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.set_parallel(false)
	tween.tween_callback(hide)

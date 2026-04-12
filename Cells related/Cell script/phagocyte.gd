extends BaseCell
class_name Phagocyte

func simulate_step(delta: float) -> void:
	super(delta)
	if mass < 3.6:
		for food in colliding:
			if food is Food:
				if food.coating <= 0 and food.nutrition > 0.0:
					var consumption_rate = 1.0 * delta
					food.nutrition -= consumption_rate * 2
					mass += consumption_rate

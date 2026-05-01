extends SignalProducerCell
class_name Neurocyte
enum Props {
	OUTPUT_CHANNELS,
	PATHWAYS
}

func _ready() -> void:
	super()
	energy_loss_coefficient = 0.2
	create_oscillation(3.25, 0, 0, 1)
# THIS IS BORROWED FROM THE CELL LAB'S SOURCE CODE
# (i dont really understand most of it t-t)
func simulate_period(connections: int, osc_weight: float, sustain_weight: float) -> float:
	var neighbors_a = PackedFloat32Array()
	var neighbors_b = PackedFloat32Array()
	neighbors_a.resize(connections)
	neighbors_b.resize(connections)
	neighbors_a.fill(0.0)
	neighbors_b.fill(0.0)
	
	var s_a = 1.0
	var s_b = 0.0
	
	const DT = 0.005
	const MAX_STEPS = 80000
	const DECAY = 5.0
	const FLOW = 5.0
	
	var zero_crossings = 0
	var period_start = 0.0
	var period = 0.0
	var step = 1
	
	while step < MAX_STEPS:

		var w_a = clampf(osc_weight * s_b, -20.0, 20.0) \
				+ clampf(sustain_weight * s_a, -20.0, 20.0)
		var w_b = clampf(-osc_weight * s_a, -20.0, 20.0) \
				+ clampf(sustain_weight * s_b, -20.0, 20.0)
		
		var new_a = s_a + ((-DECAY * s_a) + w_a) * DT
		var new_b = s_b + ((-DECAY * s_b) + w_b) * DT
		
		for i in connections:
			new_a -= FLOW * (s_a - neighbors_a[i]) * DT
			new_b -= FLOW * (s_b - neighbors_b[i]) * DT
			neighbors_a[i] += (FLOW * (s_a - neighbors_a[i]) - DECAY * neighbors_a[i]) * DT
			neighbors_b[i] += (FLOW * (s_b - neighbors_b[i]) - DECAY * neighbors_b[i]) * DT
		
		if new_b * s_b < 0.0:
			zero_crossings += 1
			if zero_crossings == 6:
				period_start = step * DT
			if zero_crossings == 14:
				period = ((step * DT) - period_start) / 4.0
				break
		
		s_a = clampf(new_a, -1.0, 1.0)
		s_b = clampf(new_b, -1.0, 1.0)
		step += 1
	
	return period
func find_weight_for_period(target_period: float, connections: int) -> float:
	var sustain_weight = 7.5 + connections * 4.0
	
	var lo = 0.0
	var hi = 8.0
	var mid = (lo + hi) * 0.5
	
	for i in 25:
		var measured = simulate_period(connections, mid, sustain_weight)
		if measured - target_period < 0.0:
			lo = mid
		else:
			hi = mid
		mid = (lo + hi) * 0.5
	
	return mid

func create_oscillation(period: float, connections: int, ch_a: int, ch_b: int) -> void:
	var pathways = gprop(Props.PATHWAYS)
	var channels = gprop(Props.OUTPUT_CHANNELS)
	
	var osc_weight = find_weight_for_period(period, connections)
	var sustain_weight = 7.5 + connections * 4.0  # f5 in Cell Lab
	
	pathways[0].mode = GenomeParam.Mode.USE_STATE
	pathways[0].input_signal = ch_b
	pathways[0].a = osc_weight
	pathways[0].formula = GenomeParam.Formula.LINEAR
	channels[0] = ch_a
	
	pathways[1].mode = GenomeParam.Mode.USE_STATE
	pathways[1].input_signal = ch_a
	pathways[1].a = -osc_weight  # negative = oscillation
	pathways[1].formula = GenomeParam.Formula.LINEAR
	channels[1] = ch_b
	
	
	pathways[2].mode = GenomeParam.Mode.USE_STATE
	pathways[2].input_signal = ch_a
	pathways[2].a = sustain_weight
	pathways[2].formula = GenomeParam.Formula.LINEAR
	channels[2] = ch_a
	
	pathways[3].mode = GenomeParam.Mode.USE_STATE
	pathways[3].input_signal = ch_b
	pathways[3].a = sustain_weight
	pathways[3].formula = GenomeParam.Formula.LINEAR
	channels[3] = ch_b
func _compute_W() -> Array:
	var channels = gprop(Props.OUTPUT_CHANNELS)
	var pathways = gprop(Props.PATHWAYS)
	var W = [0.0, 0.0, 0.0, 0.0]
	for i in pathways.size():
		var raw = clampf(pathways[i].get_value(self), -20.0, 20.0)
		W[channels[i]] += raw
	return W

func dissipate_signals() -> void:
	var W = _compute_W()
	
	for i in 4:
		signals_production[i] = W[i]
	
	for i in signals.size():
		signals[i] += (W[i] - 5.0 * signals[i]) * FIXED_STEP
		signals[i] = clamp(signals[i], -SIGNAL_MAX, SIGNAL_MAX)

func simulate_step(delta: float) -> void:
	super(delta)  

extends Node2D

var counter = 0

func _ready() -> void:
		$AnimatedSprite2D.play("flicker")

func _physics_process(_delta):
	pulsate()
	
func pulsate() -> void:
	$PointLight2D.energy = pulsating_energy_value(counter)
	counter += 0.1
	
func pulsating_energy_value(x : float) -> float:
	#creates random flicker
	var flicker = (randi() % 3) * 0.1
	#creates sinus-shaped pulse
	var pulse =  0.5 * abs(sin(0.4 * x)) + 0.7
	var result = max(pulse + flicker, 0.3)
	return result 

	
	

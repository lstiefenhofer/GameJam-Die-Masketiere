extends Node2D

var counter = 0

func _ready() -> void:
		$AnimatedSprite2D.play("flicker")

func _physics_process(delta):
	pulsate()
	
	 
func pulsate() -> void:
	$PointLight2D.energy = my_sinus(counter)
	counter += 0.1
	
func my_sinus(x : float) -> float:
	return  0.5 * sin(x) + 0.5
	
	

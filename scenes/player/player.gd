extends CharacterBody2D

class_name Player

@export var speed: float = 20

func _physics_process(_delta: float) -> void:
	var input_vector = Input.get_vector("left", "right", "up", "down")
	velocity = input_vector * speed
	move_and_slide()

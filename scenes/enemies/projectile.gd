extends Area2D


@export var damage : int = 1
@export var speed : float = 150.0

var instigator : Node

var current_lifetime : float = 0.0
var maximum_lifetime : float = 5.0

func _process(delta: float) -> void:
	current_lifetime += delta
	
	if current_lifetime > maximum_lifetime:
		queue_free()	


func _physics_process(delta: float) -> void:
	move_local_x(delta * speed)
	

func _on_body_entered(body: Node2D) -> void:
	if instigator:
		if body == instigator:
			return
	
	if body.has_method("take_damage"):
		body.take_damage(instigator, damage)
		queue_free()

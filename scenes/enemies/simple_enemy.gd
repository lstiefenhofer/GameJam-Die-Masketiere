extends CharacterBody2D

@export var speed: float = 50

var target: Player
var is_player_detected: bool = false

func _physics_process(_delta: float) -> void:
	if is_player_detected:
		var direction_to_player = (target.position - position).normalized()
		velocity = direction_to_player * speed
		move_and_slide()


func _on_detection_area_body_entered(_body: Node2D) -> void:
	is_player_detected = true


func _on_detection_area_body_exited(_body: Node2D) -> void:
	is_player_detected = false

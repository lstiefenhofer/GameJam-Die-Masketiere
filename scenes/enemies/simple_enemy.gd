extends CharacterBody2D

@export var speed: float = 50
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var target: Player
var is_player_detected: bool = false

func _physics_process(_delta: float) -> void:
	if is_player_detected:
		var next_target = navigation_agent.get_next_path_position()
		var direction_to_player = (next_target - position).normalized()
		velocity = direction_to_player * speed
		move_and_slide()


func _on_detection_area_body_entered(_body: Node2D) -> void:
	is_player_detected = true


func _on_detection_area_body_exited(_body: Node2D) -> void:
	is_player_detected = false


func _on_pathfinding_timer_timeout() -> void:
	navigation_agent.target_position = target.position


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	pass # Replace with function body.

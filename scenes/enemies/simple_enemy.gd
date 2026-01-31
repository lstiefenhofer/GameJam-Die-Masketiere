extends CharacterBody2D

@export var speed: float = 50
@export var health: float = 3:
	set(value):
		health = value
		if health < 0:
			die()
@export var damage: float = 1

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var enemy_placeholder: Sprite2D = $EnemyPlaceholder
@onready var sprite_flash: SpriteFlash = $EnemyPlaceholder
@onready var attack_timer: Timer = $AttackTimer
@onready var attack_sprite: Sprite2D = $AttackSprite

var target: Player
var is_player_detected: bool = false
var is_player_in_attack_range: bool = false

func _physics_process(_delta: float) -> void:
	if is_player_detected:
		var next_target = navigation_agent.get_next_path_position()
		var direction_to_player = (next_target - position).normalized()
		var velocity_to_next_target = direction_to_player * speed
		if navigation_agent.avoidance_enabled:
			# Set the velocity on the navigation agent and then get the safe velocity after avoidance in _on_navigation_agent_2d_velocity_computed.
			navigation_agent.set_velocity(velocity_to_next_target)
		else:
			velocity = velocity_to_next_target
		enemy_placeholder.flip_h = velocity.x < 0
		if not is_player_in_attack_range:
			move_and_slide()


func _on_detection_area_body_entered(_body: Node2D) -> void:
	is_player_detected = true


func _on_detection_area_body_exited(_body: Node2D) -> void:
	is_player_detected = false


func _on_pathfinding_timer_timeout() -> void:
	navigation_agent.target_position = target.position


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	

func take_damage(damage: float) -> void:
	health -= damage
	sprite_flash.flash(0.1, 0.2)


func die() -> void:
	queue_free()


func _process(_delta: float) -> void:
	# Attack sprite to hint where the enemy is attacking.
	if is_player_in_attack_range:
		var progress = 1.0 - attack_timer.time_left / attack_timer.wait_time
		attack_sprite.modulate.a = progress * 0.5


func _on_attack_area_body_entered(_body: Node2D) -> void:
	is_player_in_attack_range = true
	attack_timer.start()


func _on_attack_area_body_exited(_body: Node2D) -> void:
	is_player_in_attack_range = false
	attack_timer.stop()
	attack_sprite.modulate.a = 0


func _on_attack_timer_timeout() -> void:
	if is_player_in_attack_range:
		target.take_damage(damage)

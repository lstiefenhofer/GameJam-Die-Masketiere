extends CharacterBody2D

@export var speed: float = 50
@export var health: float = 3:
	set(value):
		health = value
		if health <= 0:
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

var _default_max_speed = 100;

var can_move = true # For movement controls in child scripts.
var _is_in_override_navigation = false
var _is_attacking = false

signal target_reached()

func _ready() -> void:
	target = Player.player
	
	navigation_agent.navigation_finished.connect(Callable(self, "move_to_finished"))
	_default_max_speed = navigation_agent.max_speed


func get_target() -> Player:
	return Player.player


func _process(delta: float) -> void:
	choose_attack()


func choose_attack():
	if _is_in_override_navigation:
		return
		
	if _is_attacking:
		return
		
	if start_attack():
		_is_attacking = true
		

func _physics_process(_delta: float) -> void:
	if is_player_detected and can_move:
		var next_target = navigation_agent.get_next_path_position()
		var direction_to_player = (next_target - position).normalized()
		var velocity_to_next_target = direction_to_player * speed
		if navigation_agent.avoidance_enabled:
			# Set the velocity on the navigation agent and then get the safe velocity after avoidance in _on_navigation_agent_2d_velocity_computed.
			navigation_agent.set_velocity(velocity_to_next_target)
		else:
			velocity = velocity_to_next_target
		enemy_placeholder.flip_h = velocity.x < 0
		
		move_and_slide()


func _on_detection_area_body_entered(_body: Node2D) -> void:
	is_player_detected = true


func _on_detection_area_body_exited(_body: Node2D) -> void:
	is_player_detected = false


func _on_pathfinding_timer_timeout() -> void:
	if is_instance_valid(get_target()) and !_is_in_override_navigation:
		navigation_agent.target_position = get_target().position


func set_movement_speed_multiplier(in_multiplier : float):
	navigation_agent.set_max_speed(_default_max_speed*in_multiplier)


# Call in child scripts
func move_to(new_position : Vector2):
	can_move = true
	_is_in_override_navigation = true
	navigation_agent.target_position = new_position
	if !navigation_agent.is_target_reachable():
		printerr("Target not reachable")
		_is_in_override_navigation = false


func move_to_finished():
	if(!_is_in_override_navigation):
		return
		
	_is_in_override_navigation = false


func stop_movement_override():	
	_is_in_override_navigation = false


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	

func take_damage(incoming_damage: float) -> void:
	health -= incoming_damage
	sprite_flash.flash(0.1, 0.2)


func die() -> void:
	queue_free()


# Implement in child
func start_attack() -> bool:
	if is_player_in_attack_range:
		default_attack()
		return true
		
	return false
	

func default_attack():
	can_move = false
	
	attack_timer.start()

	while(attack_timer.time_left > 0.1):
		# Attack sprite to hint where the enemy is attacking.
		var progress = 1.0 - attack_timer.time_left / attack_timer.wait_time
		attack_sprite.modulate.a = progress * 0.5
		await get_tree().process_frame
	
	attack_sprite.modulate.a = 0.0
	can_move = true
	hit_player_in_range()
	await get_tree().create_timer(2.0).timeout
	finish_attack()


func finish_attack():
	_is_attacking = false
	can_move = true
	attack_sprite.modulate.a = 0.0


func _on_attack_area_body_entered(_body: Node2D) -> void:
	is_player_in_attack_range = true


func _on_attack_area_body_exited(_body: Node2D) -> void:
	is_player_in_attack_range = false


func hit_player_in_range() -> void:
	if is_player_in_attack_range and is_instance_valid(get_target()):
		get_target().take_damage(damage)

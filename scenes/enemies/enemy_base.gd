extends CharacterBody2D
class_name EnemyBase

@export var speed: float = 50
@export var attack_cooldown_min: float = 0.5
@export var attack_cooldown_max: float = 1.5
@export var forget_radius: float = 200.0
@export var invert_flip: bool = false
@export var min_nav_target_distance: float = 0.0
var _default_max_speed = 100
var _default_speed = 50
@export var health: float = 3:
	set(value):
		health = value
		if health <= 0:
			_die()
@export var damage: float = 1


@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var enemy_placeholder: Sprite2D = $EnemyPlaceholder
@onready var enemy_spritesheet: AnimatedSpriteFlash = $EnemySpritesheet
@onready var sprite_flash: SpriteFlash = $EnemyPlaceholder
@onready var animated_sprite_flash: AnimatedSpriteFlash = $EnemySpritesheet
@onready var attack_sprite: Sprite2D = $AttackSprite
@onready var nearby_shape: CollisionShape2D = $DetectionArea/CollisionShape2D

var target: Node2D
var is_player_in_attack_range: bool = false

var can_move = true # For movement controls in child scripts.
var _is_in_override_navigation = false
var _is_attacking = false
var _current_pushback_intensity = 0.0
var _current_pushback_velocity = Vector2.ZERO
var _time_spend_on_current_navigation = 0.0
var _max_time_spending_in_navigation = 5.0
var _first_overlap_check = true # Check on spawn, if player is nearby

var active_timers : Array[Timer]

signal target_reached()

func _ready() -> void:
	#target = Player.player
	
	navigation_agent.navigation_finished.connect(Callable(self, "_move_to_finished"))
	_default_max_speed = navigation_agent.max_speed
	_default_speed = speed


func create_local_timer(duration) -> Timer:
	if !is_inside_tree():
		return null
	
	var timer = Timer.new()
	add_child(timer)
	timer.start(duration)
	active_timers.append(timer)
	return timer


func get_target() -> Node2D:
	return target
	#return Player.player


func _process(delta: float) -> void:
	choose_attack()
	
	if _current_pushback_intensity >= 0:
		_current_pushback_intensity -= 0.5 * delta
	else:
		_current_pushback_intensity = 0
	
	# Unassign target when it gets too far away
	if target and target.global_position.distance_squared_to(global_position) > forget_radius * forget_radius:
		target = null
		
	if _is_in_override_navigation:
		_time_spend_on_current_navigation += delta
		if _time_spend_on_current_navigation > _max_time_spending_in_navigation:
			stop_movement_override()
			
	if enemy_spritesheet.sprite_frames and enemy_spritesheet.animation != "Attack":
		if velocity.length_squared() > 1 and enemy_spritesheet.animation != "Walk":
			enemy_spritesheet.play("Walk")
		elif velocity.length_squared() == 0 and enemy_spritesheet.animation != "Idle":
			enemy_spritesheet.play("Idle")


func choose_attack():
	if !get_target():
		return
	
	if _is_in_override_navigation:
		return
		
	if _is_attacking:
		return
		
	if start_attack():
		_is_attacking = true
		

func _physics_process(_delta: float) -> void:
	if get_target() and can_move:
		var next_target = navigation_agent.get_next_path_position()
		var direction_to_player = (next_target - global_position).normalized()
		var velocity_to_next_target = direction_to_player * speed
		if navigation_agent.avoidance_enabled:
			# Set the velocity on the navigation agent and then get the safe velocity after avoidance in _on_navigation_agent_2d_velocity_computed.
			navigation_agent.set_velocity(velocity_to_next_target)
		else:
			velocity = velocity_to_next_target
			
		if enemy_placeholder:
			enemy_placeholder.flip_h = velocity.x > 0 if invert_flip else velocity.x < 0
		if enemy_spritesheet:
			enemy_spritesheet.flip_h = velocity.x > 0 if invert_flip else velocity.x < 0
		
		velocity += _current_pushback_intensity * _current_pushback_velocity
		move_and_slide()
		
	elif _current_pushback_intensity == 0:
		velocity = Vector2.ZERO
		
	elif _current_pushback_intensity > 0:
		velocity = _current_pushback_intensity * _current_pushback_velocity
		move_and_slide()
		
	#print("Intensity %d, Velocity %v" % [_current_pushback_intensity, _current_pushback_velocity])

	# Only check once if there is a player already inside our physics shape
	if !target and _first_overlap_check:
		var params = PhysicsShapeQueryParameters2D.new()
		params.shape_rid = nearby_shape.shape.get_rid()
		var space_state = get_world_2d().direct_space_state
		var intersections : Array[Dictionary] = space_state.intersect_shape(params, 6)
		for intersection in intersections:
			var collider = intersection["collider"]
			if collider and collider is Player:
				target = collider
				break
		_first_overlap_check = false


func set_sprite_direction(look_at_location : Vector2):
	if enemy_placeholder:
		enemy_placeholder.flip_h = look_at_location.x < global_position.x
	if enemy_spritesheet:
		enemy_spritesheet.flip_h = look_at_location.x < global_position.x


func _on_pathfinding_timer_timeout() -> void:
	if is_instance_valid(get_target()) and !_is_in_override_navigation:
		var direction = (get_target().global_position - global_position).limit_length(min_nav_target_distance)
		navigation_agent.target_position = get_target().global_position - direction


func set_movement_speed_multiplier(in_multiplier : float):
	speed = _default_speed * in_multiplier


# Call in child scripts
func move_to(new_position : Vector2) -> bool:
	can_move = true
	_time_spend_on_current_navigation = 0.0
	_is_in_override_navigation = true
	navigation_agent.target_position = new_position
	if !navigation_agent.is_target_reachable():
		printerr("Target not reachable")
		_is_in_override_navigation = false
		navigation_agent.target_position = global_position # Just reset to itself
		return false
		
	return true


func _move_to_finished():
	if(!_is_in_override_navigation):
		return
		
	_is_in_override_navigation = false
	target_reached.emit()


func stop_movement_override():	
	_is_in_override_navigation = false


func _on_navigation_agent_2d_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	

func take_damage(instigator : CharacterBody2D, incoming_damage: float, pushback_velocity : Vector2 = Vector2.ZERO) -> void:
	health -= incoming_damage
	sprite_flash.flash(0.1, 0.2)
	animated_sprite_flash.flash(0.1, 0.2)
	if pushback_velocity.length_squared() > 0:
		_current_pushback_intensity = 1.0
		_current_pushback_velocity = pushback_velocity
		interrupt_attack()
		
	target = instigator # Always attack the instigator 
	# (This is planned to be used when enemies attack other enemies. 
	# Or when the player attacks an enemy that was attacking an enemy. It will then attack the player again.


func get_target_direction() -> Vector2:
	if !get_target():
		return Vector2(1.0, 0.0)
		
	var direction = (get_target().global_position - global_position).normalized()
	return direction


func get_position_in_arc_before_target(position_arc_degrees = 90.0, position_arc_distance = 80.0):
	if !get_target():
		return Vector2.UP
	
	var arc_degrees_rad = deg_to_rad(position_arc_degrees)
	return get_target().global_position + (-get_target_direction()).rotated(randf_range(-arc_degrees_rad, arc_degrees_rad)) * position_arc_distance


# Implement in child
func start_attack() -> bool:
	if is_player_in_attack_range:
		if randi_range(0, 1) == 1:
			charge_attack(damage)
		else:
			default_attack(damage)
		return true
		
	return false
	

func default_attack(in_damage : int):
	can_move = false
	
	var timer_duration = 1.0
	var timer = create_local_timer(timer_duration)
	if !timer:
		finish_attack()
		return

	while(timer and timer.time_left > 0.1):
		if(!get_target()):
			finish_attack()
			break
		
		# Attack sprite to hint where the enemy is attacking.
		var progress = 1.0 - timer.time_left / timer_duration
		attack_sprite.modulate.a = progress * 0.5
		# We need to cancel the loop if we are not inside the tree, else we have an infinite loop.
		if is_inside_tree(): 
			await get_tree().process_frame
		else:
			return
	
	attack_sprite.modulate.a = 0.0
	can_move = true
	hit_player_in_range(in_damage)
	finish_attack()


func charge_attack(in_damage : int, charge_audio_player : AudioStreamPlayer2D = null, position_arc_degrees = 90.0, position_arc_distance = 80.0, charge_speed_multiplier = 3.0):
	if(!get_target()):
		finish_attack()
		return
	
	# Move to random location on a half circle between player and enemy which is 80 pixels away from player
	if !move_to(get_position_in_arc_before_target(position_arc_degrees, position_arc_distance)):
		interrupt_attack() # Not reachable
		return
	
	await target_reached
	can_move = false
	var timer = create_local_timer(0.5)
	if timer:
		await timer.timeout # Cooldown before charge
	
	if(!get_target()):
		interrupt_attack()
		return
	
	set_sprite_direction(get_target().global_position) # Just flip sprites towards player
	
	set_movement_speed_multiplier(charge_speed_multiplier)
	if !move_to(get_target().global_position + get_target_direction() * 30.0):
		interrupt_attack() # Not reachable
		return
	
	if charge_audio_player:
		charge_audio_player.play()
	
	while(_is_in_override_navigation):
		if(!get_target()):
			interrupt_attack()
			break
			
		if hit_player_in_range(in_damage):
			stop_movement_override()
			break
		# We need to cancel the loop if we are not inside the tree, else we have an infinite loop.
		if is_inside_tree(): 
			await get_tree().process_frame
		else:
			return
	
	can_move = false
	finish_attack()


func finish_attack():
	can_move = true
	attack_sprite.modulate.a = 0.0
	set_movement_speed_multiplier(1.0)
	
	# Cooldown for next attack
	var timer = create_local_timer(randf_range(attack_cooldown_min, attack_cooldown_max))
	if timer:
		await timer.timeout 
	
	_is_attacking = false
	_clear_timers()


func interrupt_attack():
	if !_is_attacking:
		return
		
	_reset_attack_state()
	_clear_timers()
	
	var timer = create_local_timer(0.2)
	if timer:
		await timer.timeout 
		
	_is_attacking = false


func _reset_attack_state():
	can_move = true
	attack_sprite.modulate.a = 0.0
	_is_in_override_navigation = false
	set_movement_speed_multiplier(1.0)


func _clear_timers():
	for timer in active_timers:
		if timer:
			timer.stop()
			timer.queue_free()
			
	active_timers.clear()


func _on_detection_area_body_entered(_body: Node2D) -> void:
	on_target_assignment(_body)


func on_target_assignment(_body: Node2D) -> void:
	if _body is Player and !target:
		#is_player_detected = true
		target = _body


func _on_detection_area_body_exited(_body: Node2D) -> void:
	pass # Use forget range in process function
	#is_player_detected = false


func _on_attack_area_body_entered(_body: Node2D) -> void:
	is_player_in_attack_range = true


func _on_attack_area_body_exited(_body: Node2D) -> void:
	is_player_in_attack_range = false


func hit_player_in_range(in_damage : int) -> bool:
	if is_player_in_attack_range and is_instance_valid(get_target()):
		get_target().take_damage(self, in_damage)
		return true
		
	return false
	

func _die() -> void:
	_clear_timers()
	queue_free()

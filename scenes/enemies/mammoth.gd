extends EnemyBase

@export var trumpet : AudioStreamPlayer2D
@export var stomp : AudioStreamPlayer2D

@export var charge_damage : int
@export var stomp_damage : int
@export var stomp_radius : float = 200.0

func _process(delta: float) -> void:
	super._process(delta)
	



func start_attack() -> bool:
	if is_player_in_attack_range:
		var attack_number = 1 #randi_range(0, 2)
		if attack_number == 0:
			charge_attack(charge_damage)
		elif attack_number == 1:
			stomp_attack(stomp_damage)
		elif attack_number == 2:
			default_attack(damage)
			
		return true
	return false

func stomp_attack(in_damage : int):
	if(!move_to(get_position_in_arc_before_target(45.0, 50.0))):
		interrupt_attack()
		return
		
	await target_reached
	
	if(!get_target()):
		interrupt_attack()
	
	enemy_spritesheet.play("Attack")
	can_move = false
	trumpet.play()
	var timer = create_local_timer(0.5)
	await timer.timeout
	
	# Do not need to check for target since we are applying AOE
	
	var overlap_check = OverlapCheck.create_physics_overlap(self, global_position, stomp_radius, 6)
	assert(overlap_check)
	overlap_check.on_colliders_collected.connect(Callable(self, "stomp_area_damage"))


func stomp_area_damage(intersections : Array[Dictionary]):
	for intersection in intersections:
		var collider = intersection["collider"]
		if collider:
			if collider.has_method("take_damage") and collider != self:
				if collider is not Player:
					var pushback_direction = (collider.global_position - global_position).normalized() * 50.0
					collider.take_damage(self, stomp_damage, pushback_direction)
				else:
					collider.take_damage(self, stomp_damage)
					
	finish_attack()
	enemy_spritesheet.play("Walk")
	
	
	
	
	
	
	
	

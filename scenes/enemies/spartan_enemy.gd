extends EnemyBase

@export var spear_scene : PackedScene 

func start_attack() -> bool:
	#if is_player_in_attack_range:
	var attack_number = randi_range(0, 1) 
	if attack_number == 0:
		spear_throw(damage)
	elif attack_number == 1:
		default_attack(damage)
	return true
		

	
func spear_throw(in_damage : int):
	debug_log("Started spear attack")
	current_attack_name = "Spear attack"
	_is_attacking = true
	if !move_to(get_position_in_arc_before_target(25.0, 70.0)):
		interrupt_attack()
		return
	
	await target_reached
	if(!get_target()):
		interrupt_attack()
		return
	
	debug_log("Proceed")
	can_move = false	
	enemy_spritesheet.play("Attack")
	var new_spear : Node2D = spear_scene.instantiate()
	new_spear.global_position = global_position + Vector2.UP * 22.0
	new_spear.look_at(get_target().global_position)
	new_spear.instigator = self
	get_tree().root.add_child(new_spear)
	finish_attack()


func _on_enemy_spritesheet_animation_finished() -> void:
	if enemy_spritesheet.animation == "Attack":
		enemy_spritesheet.play("Idle")

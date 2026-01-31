extends CharacterBody2D

class_name Player

@export var speed: float = 20
@export var damage: float = 1

@export var legs: AnimatedSprite2D
@export var body: AnimatedSprite2D


@onready var attack_area: Area2D = $AttackArea
@onready var invincibility_timer: Timer = $InvincibilityTimer

@export var audio_player: AudioStreamPlayer2D
var is_attacking: bool = false
var is_dead: bool = false

func _process(_delta: float) -> void:
	if is_dead:
		return
	if velocity.length_squared() > 10.0 and legs.get_animation() != "Walk":
		legs.play("Walk")
	elif velocity.length_squared() < 1.0 and legs.get_animation() != "Idle":
		legs.play("Idle")
	
	if abs(velocity.x) > 0:
		legs.flip_h = velocity.x < 0
		body.flip_h = velocity.x < 0
		attack_area.scale.x = -1 if velocity.x < 0 else 1
	

func _unhandled_input(event: InputEvent) -> void:
	if is_dead:
		return
	if event.is_action_pressed("Attack") and !is_attacking:
		is_attacking = true
		trigger_attack()


func trigger_attack():
	body.play("Attack")
	await get_tree().create_timer(0.2).timeout
	
	# Activate attack area to trigger damage on all enemies that are inside.
	# @see _on_attack_area_body_entered
	attack_area.monitoring = true
	
	await get_tree().create_timer(0.2).timeout
	attack_area.monitoring = false
	is_attacking = false


func _on_player_body_animation_finished() -> void:
	body.play("Idle")


func _physics_process(_delta: float) -> void:
	var input_vector = Input.get_vector("left", "right", "up", "down")
	velocity = input_vector * speed
	move_and_slide()
	
	if velocity.length() > 0:
		if not audio_player.playing:
			audio_player.play(0.0)
	else:
		audio_player.stop()



func _on_attack_area_body_entered(physics_body: Node2D) -> void:
	if "take_damage" in physics_body:
		physics_body.take_damage(damage)
		

func take_damage(incoming_damage: float) -> void:
	if not invincibility_timer.time_left:
		Globals.player_health -= incoming_damage
		if Globals.player_health <= 0:
			die()
		# Legs use same material as body, so we only need to set the shader parameters to flash on one.
		body.flash(0.1, 0.2)
		invincibility_timer.start()
		

func die() -> void:
	is_dead = true
	# TODO Probably just show a dead sprite instead and disable all interactability.
	queue_free()

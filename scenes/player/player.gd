extends CharacterBody2D

class_name Player
static var player : Player

@export var speed: float = 10
@export var damage: float = 1
@export var pushback_force: float = 150.0

@export var legs: AnimatedSprite2D
@export var body: AnimatedSprite2D
@export var attack_effect: Sprite2D

@export var death_scene : PackedScene
@export var footstep_sound_player : AudioStreamPlayer2D

## The scale for the point light for the amount of masks collected in the antique.
@export var point_light_scale_per_mask_count: Array[float]

@onready var attack_area: Area2D = $AttackArea
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var point_light: PointLight2D = $PointLight2D

var is_attacking: bool = false
var is_dead: bool = false
# Damage multiplier is set by mask effects.
var damage_multiplier: float = 1


func _init() -> void:
	player = self


func _ready() -> void:
	attack_effect.visible = false
	Globals.recalculate_mask_effects.connect(_on_recalculate_mask_effects)
	_on_recalculate_mask_effects()

func _process(_delta: float) -> void:
	if is_dead:
		return
	if velocity.length_squared() > 10.0 and legs.get_animation() != "Walk":
		legs.play("Walk")
	elif velocity.length_squared() < 1.0 and legs.get_animation() != "Idle":
		legs.play("Idle")
	
	if abs(velocity.x) > 2:
		legs.flip_h = velocity.x < 0
		body.flip_h = velocity.x < 0
		attack_effect.flip_h = velocity.x < 0
		attack_area.scale.x = -1 if velocity.x < 0 else 1
	

func _unhandled_input(event: InputEvent) -> void:
	if is_dead:
		return
	if event.is_action_pressed("Attack") and !is_attacking:
		is_attacking = true
		trigger_attack()


func trigger_attack():
	body.stop()
	body.play("Attack")
	Globals.emit_signal("attack_signal", 0.4)
	await get_tree().create_timer(0.2).timeout
	
	# Activate attack area to trigger damage on all enemies that are inside.
	# @see _on_attack_area_body_entered
	attack_area.monitoring = true
	
	await get_tree().create_timer(0.2).timeout
	attack_area.monitoring = false
	is_attacking = false
	attack_effect.visible = false


func _on_player_body_animation_finished() -> void:
	body.play("Idle")


func _physics_process(_delta: float) -> void:
	var input_vector = Input.get_vector("left", "right", "up", "down")
	velocity = input_vector * speed
	move_and_slide()


func _on_attack_area_body_entered(physics_body: Node2D) -> void:
	if "take_damage" in physics_body:
		var pushback_velocity = (physics_body.global_position - global_position).normalized() * pushback_force
		physics_body.take_damage(self, damage * damage_multiplier, pushback_velocity)
		attack_effect.visible = true
		

func take_damage(instigator : CharacterBody2D, incoming_damage: float) -> void:
	if not invincibility_timer.time_left:
		Globals.player_health -= incoming_damage
		if Globals.player_health <= 0:
			die()
		else:
			body.play("Hit")
		# Legs use same material as body, so we only need to set the shader parameters to flash on one.
		body.flash(0.1, 0.2)
		invincibility_timer.start()
		

func die() -> void:
	is_dead = true
	var death = death_scene.instantiate()
	get_tree().root.add_child(death)
	for node in death.get_children():
		if node is AnimatedSprite2D:
			node.flip_h = body.flip_h
		elif node is Camera2D:
			node.make_current()
			
	death.position = position
	queue_free()


# Apply the current mask effects to the player.
func _on_recalculate_mask_effects() -> void:
	# The second stone age mask gives more damage.
	damage_multiplier = 1.5 if Globals.mask_count[Globals.LevelId.StoneAge] >= 2 else 1.0
	var current_scale = point_light_scale_per_mask_count[Globals.mask_count[Globals.LevelId.Antique]]
	if current_scale != point_light.texture_scale:
		var tween = create_tween()
		tween.tween_property(point_light, "texture_scale", current_scale, 0.6).set_trans(Tween.TRANS_BACK)

var skip_frame = true
func _on_player_legs_frame_changed() -> void:
	if legs.animation != "Walk":
		return
	skip_frame = !skip_frame
	if !skip_frame:
		footstep_sound_player.stop()
		footstep_sound_player.play()

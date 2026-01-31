extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var attack_count_down: ProgressBar = $AttackCountDown
const Player = preload("uid://bi3md3unr3sa8")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = get_node("res://scenes/player/player.gd")
	Globals.attack_signal.connect(_on_attack_signal)
	attack_count_down.hide()
	update_health()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_health()

func update_health() -> void:
	health_bar.value = Globals.player_health

func _on_attack_signal(duration: float):
	attack_count_down.show()
	attack_count_down.min_value = 0.0
	attack_count_down.max_value = duration
	attack_count_down.value = duration

	var time_left := duration

	while time_left > 0.0:
		await get_tree().process_frame
		var delta := get_process_delta_time()
		time_left -= delta
		attack_count_down.value = time_left
	attack_count_down.hide()

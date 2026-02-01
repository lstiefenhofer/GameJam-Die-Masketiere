extends Control

@onready var health_bar: ProgressBar = $HealthBar
@onready var attack_count_down: ProgressBar = $AttackCountDown
@onready var pause_menu: Panel = $PauseMenu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	show() # Make sure GUI is visible at game time
	Globals.attack_signal.connect(_on_attack_signal)
	Globals.setup_hover(get_tree().get_root())
	attack_count_down.hide()
	pause_menu.hide()
	update_health()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	update_health()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"): 
		get_tree().paused = !get_tree().paused
		if get_tree().paused:
			pause_menu.show()
		else:
			pause_menu.hide()
		

func update_health() -> void:
	health_bar.value = Globals.player_health

func _on_attack_signal(duration: float) -> void:
	attack_count_down.show()
	attack_count_down.min_value = 0.0
	attack_count_down.max_value = duration
	attack_count_down.value = duration

	var time_left := duration

	while time_left > 0.0:
		await get_tree().process_frame

		if get_tree().paused:
			continue  # do not advance time while paused

		var delta := get_process_delta_time()
		time_left -= delta
		attack_count_down.value = time_left

	attack_count_down.hide()


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_main_menu_pressed() -> void:
	Globals.goto_main_menu()

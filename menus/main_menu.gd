extends Control

@onready var main_menu: VBoxContainer = $VBoxContainer/MarginBox/MainMenu
@onready var settings_menu: VBoxContainer = $VBoxContainer/MarginBox/SettingsMenu


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	settings_menu.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/bitowl/levels/test_level.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_settings_pressed() -> void:
	main_menu.visible = false
	settings_menu.visible = true


func _on_settings_back_pressed() -> void:
	settings_menu.visible = false
	main_menu.visible = true

func set_volume_on_audio_bus(bus: String, value: float) -> void:
	var id = AudioServer.get_bus_index(bus)
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(id, db)

func _on_volume_master_value_changed(value: float) -> void:
	set_volume_on_audio_bus("Master", value)


func _on_volume_effects_value_changed(value: float) -> void:
	set_volume_on_audio_bus("SFX", value)


func _on_volume_background_value_changed(value: float) -> void:
	set_volume_on_audio_bus("Background", value)


func _on_fullscreen_toggle_toggled(toggled_on: bool) -> void:
	match toggled_on:
		true:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		false:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

extends Control

@onready var main_menu: VBoxContainer = $VBoxContainer/MarginBox/MainMenu
@onready var settings_menu: VBoxContainer = $VBoxContainer/MarginBox/SettingsMenu

@onready var volume_master: HSlider = $VBoxContainer/MarginBox/SettingsMenu/HBoxContainer/Sound/VBoxContainer/VolumeMaster
@onready var volume_effects: HSlider = $VBoxContainer/MarginBox/SettingsMenu/HBoxContainer/Sound/VBoxContainer/VolumeEffects
@onready var volume_background: HSlider = $VBoxContainer/MarginBox/SettingsMenu/HBoxContainer/Sound/VBoxContainer/VolumeBackground
@onready var fullscreen_toggle: CheckButton = $VBoxContainer/MarginBox/SettingsMenu/HBoxContainer/Graphics/VBoxContainer/FullscreenToggle

var config := ConfigFile.new()
const SETTINGS_PATH = "user://settings.cfg"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Globals.setup_hover(get_tree().get_root())
	settings_menu.visible = false

	if config.load(SETTINGS_PATH) == OK:
		var master = config.get_value("audio", "master", 1.0)
		var effects = config.get_value("audio", "effects", 1.0)
		var background = config.get_value("audio", "background", 1.0)
		var fullscreen = config.get_value("video", "fullscreen", false)
		
		volume_master.value = master
		volume_effects.value = effects
		volume_background.value = background

		set_volume_on_audio_bus("Master", master)
		set_volume_on_audio_bus("SFX", effects)
		set_volume_on_audio_bus("Background", background)

		fullscreen_toggle.button_pressed = fullscreen
		if fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/levels/stoneage.tscn")


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
	config.set_value("audio", "master", value )
	config.save(SETTINGS_PATH)


func _on_volume_effects_value_changed(value: float) -> void:
	set_volume_on_audio_bus("SFX", value)
	config.set_value("audio", "effects", value )
	config.save(SETTINGS_PATH)


func _on_volume_background_value_changed(value: float) -> void:
	set_volume_on_audio_bus("Background", value)
	config.set_value("audio", "background", value )
	config.save(SETTINGS_PATH)


func _on_fullscreen_toggle_toggled(toggled_on: bool) -> void:
	match toggled_on:
		true:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		false:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	config.set_value("video", "fullscreen", toggled_on)
	config.save(SETTINGS_PATH)

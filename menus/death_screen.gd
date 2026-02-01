extends Control

var coming_from_level = Globals.LevelId.StoneAge
@onready var death_screen_panel: Panel = $DeathScreenPanel
@onready var menu: VBoxContainer = $DeathScreenPanel/Menu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var time = 3.0
	show() 
	menu.hide()
	fade_to_black(death_screen_panel, time)
	await get_tree().create_timer(time).timeout
	menu.show()
	
	var level_names = ["Level", "AntiqueLevel", "StoneAgeLevel", "StoneageLevel"]
	for node in get_tree().get_root().get_children():
		if node.name in level_names:
			node.queue_free()
			coming_from_level = node.level_id


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_respawn_pressed() -> void:
	Globals.reset_player()
	var level = Globals.LevelLookup[coming_from_level]
	get_tree().change_scene_to_file(level)
 
func _on_main_menu_pressed() -> void:
	Globals.goto_main_menu()

func _on_quit_pressed() -> void:
	get_tree().quit()
	
func fade_to_black(panel: Panel, duration) -> void:
	var style := panel.get_theme_stylebox("panel").duplicate() as StyleBoxFlat
	panel.add_theme_stylebox_override("panel", style)

	var tween := create_tween()
	tween.tween_property(
		style,
		"bg_color",
		Color.BLACK,
		duration
	)

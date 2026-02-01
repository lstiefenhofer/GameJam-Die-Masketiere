extends Node

const INITIAL_PLAYER_HEALTH: float = 10.0
var player_health: float = INITIAL_PLAYER_HEALTH

@warning_ignore("unused_signal") 
signal attack_signal(duration: float)

enum LevelId {
	StoneAge,
	Antique,
	StoneAgeCopy,
	None,
}
var level_names = ["Level", "AntiqueLevel", "StoneAgeLevel", "StoneageLevel"]
var LevelLookup: Dictionary[LevelId, String] = {
	LevelId.Antique: "res://scenes/levels/antique.tscn",
	LevelId.StoneAge: "res://scenes/levels/stoneage.tscn",
	LevelId.StoneAgeCopy: "res://scenes/bitowl/levels/my_stoneage_copy.tscn",
}

# Mask count in each level.
var mask_count: Array[int] = [0, 0, 0]

var collected_masks : Array[MaskInfo]

@warning_ignore("unused_signal") 
signal mask_collected(mask_count: int, mask_info: MaskInfo)
	
# Everybody that calculates mask effects should check again if they are active.
@warning_ignore("unused_signal") 
signal recalculate_mask_effects()

const MAIN_MENU = preload("uid://ditt1j1ooojdu")

@onready var cursor_normal = preload("res://assets/nes.css/cursor.png")
@onready var cursor_hover = preload("res://assets/nes.css/cursor-click.png")
@onready var cursor_normal_2x = preload("res://assets/nes.css/cursor_2x.png")
@onready var cursor_hover_2x = preload("res://assets/nes.css/cursor-click_2x.png")

var cursor_2x = false

func _ready():
	Input.set_custom_mouse_cursor(cursor_normal)

func quit():
	SaveStuffToDisk.save_last_level(SaveStuffToDisk.last_level)
	get_tree().quit()

func reset_player() -> void:
	var nodes_to_remove = ["Player", "PlayerDead"]
	for node in get_tree().get_root().get_children():
		if node.name in nodes_to_remove:
			node.queue_free()
			
	player_health = INITIAL_PLAYER_HEALTH
	get_tree().paused = false

func get_current_level() -> LevelId:
	var ret = SaveStuffToDisk.last_level
	for node in get_tree().get_root().get_children():
		if node.name in level_names:
			node.queue_free()
			ret = node.level_id
	return ret

func goto_main_menu() -> void:
	SaveStuffToDisk.save_last_level(get_current_level())
	reset_player()
	get_tree().change_scene_to_packed(MAIN_MENU)


func setup_hover(node: Node):
	# Target common interactable controls
	if node is Button or node is TextureButton or node is CheckBox or node is OptionButton or node is HSlider:
		node.connect("mouse_entered", Callable(self, "_on_hover").bind(node))
		node.connect("mouse_exited", Callable(self, "_on_exit").bind(node))
	# Recursively process children
	for child in node.get_children():
		if child is Node:
			setup_hover(child)

func _on_hover(control: Control):
	if control is BaseButton:
		if control.disabled:
			return
	if cursor_2x:
		Input.set_custom_mouse_cursor(cursor_hover_2x)
	else:
		Input.set_custom_mouse_cursor(cursor_hover)

func _on_exit(_control: Control):
	if cursor_2x:
		Input.set_custom_mouse_cursor(cursor_normal_2x)
	else:
		Input.set_custom_mouse_cursor(cursor_normal)

func set_in_interactable_range(is_in_range: bool) -> void:
	if is_in_range:
		_on_hover(null)
	else:
		_on_exit(null)

extends Level

@onready var antique_exit: Area2D = $Objects/AntiqueExit

var is_exit_open: bool = false

func _ready() -> void:
	super()
	Globals.recalculate_mask_effects.connect(_on_recalculate_mask_effects)

# Open the exit when all three masks are collected.
func _on_recalculate_mask_effects() -> void:
	if Globals.mask_count[level_id] >= 3:
		is_exit_open = true
		antique_exit.open_door()


func _on_antique_exit_door_entered() -> void:
	if is_exit_open:
		transition_to_scene("res://menus/end_screen.tscn")

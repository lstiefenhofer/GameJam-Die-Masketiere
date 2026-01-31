extends Level

@onready var exit_door: StaticBody2D = $ExitDoor

func _ready() -> void:
	super()
	Globals.recalculate_mask_effects.connect(_on_recalculate_mask_effects)

func _on_exit_doot_player_entered_door() -> void:
	transition_to_level("res://scenes/levels/antique.tscn")

func _on_recalculate_mask_effects() -> void:
	if Globals.mask_count[level_id] >= 2:
		exit_door.state = Door.State.EXIT

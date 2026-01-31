extends Node2D

@onready var player: Player = $Player
@onready var enemies: Node2D = $Enemies

func _ready() -> void:
	# Inform all enemies where the player is.
	for enemy in enemies.get_children():
		if "target" in enemy:
			enemy.target = player

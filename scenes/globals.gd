extends Node

var player_health: float = 10
signal attack_signal(duration: float)

enum LevelId {
	Stoneage,
	Antique
}

# Mask count in each level.
var mask_count: Array[int] = [0, 0]

signal mask_collected(mask_count: int)
	

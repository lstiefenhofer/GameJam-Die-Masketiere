extends Node

var player_health: float = 10
@warning_ignore("unused_signal") 
signal attack_signal(duration: float)

enum LevelId {
	StoneAge,
	Antique
}

# Mask count in each level.
var mask_count: Array[int] = [0, 0]

@warning_ignore("unused_signal") 
signal mask_collected(mask_count: int)
	
# Everybody that calculates mask effects should check again if they are active.
@warning_ignore("unused_signal") 
signal recalculate_mask_effects()

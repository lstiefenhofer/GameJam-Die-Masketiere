extends Collectible

func collected_by_player(_player: Player) -> void:
	print("Money ++")
	queue_free()

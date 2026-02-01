extends Control

var coming_from_level = Globals.LevelId.StoneAge

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#self.hide()
	await get_tree().create_timer(3.0).timeout
	#self.show()
	# Remove 
	var level_names = ["Level", "AntiqueLevel", "StoneAgeLevel", "StoneageLevel"]
	for node in get_tree().get_root().get_children():
		if node.name in level_names:
			node.queue_free()
			coming_from_level = node.level_id
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_respawn_pressed() -> void:
	var nodes_to_remove = ["Player", "PlayerDead"]
	for node in get_tree().get_root().get_children():
		if node.name in nodes_to_remove:
			node.queue_free()
	Globals.reset_player()
	var level = Globals.LevelLookup[coming_from_level]
	get_tree().change_scene_to_file(level)
 

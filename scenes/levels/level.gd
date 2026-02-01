extends Node2D

class_name Level

@onready var player: Player = $Player
@onready var enemies: Node2D = $Enemies
@onready var enemy_spawn_points: Node2D = $EnemySpawnPoints
@onready var enemy_spawn_timer: Timer = $EnemySpawnTimer

@export var level_id: Globals.LevelId
@export var enemy_scenes: Array[PackedScene]
## If true spawns wave 0 for the first collected mask, wave 1 for the second. 
## If false spawns wave 0 for the mask with id 0 and wave 1 for the mask with id 1.
@export var spawn_waves_by_mask_count: bool = false
@export var enemy_waves: Array[Node2D]
## Additional enemy waves that can be spawned by their name.
@export var additional_enemy_waves: Array[Node2D]
var additional_waves: Dictionary[String, Node2D] = {}

func _ready() -> void:
	# Inform all enemies where the player is.
	for enemy in enemies.get_children():
		if "target" in enemy:
			enemy.target = player
	
	TransitionOverlay.fade_out(1.0)
			
	Globals.mask_collected.connect(_on_mask_collected)
	
	# Remove the wave nodes as they are only spawned later.
	for wave in enemy_waves:
		if wave:
			enemies.remove_child(wave)
	for wave in additional_enemy_waves:
		if wave:
			enemies.remove_child(wave)
		additional_waves[wave.name] = wave
			
func _on_enemy_spawn_timer_timeout() -> void:
	if enemy_spawn_points.get_children().is_empty():
		push_warning("There are no enemy spawn points defined in this level!")
		enemy_spawn_timer.stop()
		return
	if enemy_scenes.is_empty():
		push_error("There are no enemy scenes defined for this level!")
		enemy_spawn_timer.stop()
		return
	var enemy_scene = enemy_scenes.pick_random()
	if not enemy_scene:
		return
	var enemy = enemy_scene.instantiate()

	var spawn_point = enemy_spawn_points.get_children().pick_random()
	if not spawn_point:
		return
	# TODO Only spawn if there is no enemy near this spawn point.
	# TODO Only spawn if the player is not at this spawn point.
		
	enemy.position = spawn_point.position
	enemies.add_child(enemy)


func _on_mask_collected(mask_id: int, mask_info:MaskInfo) -> void:
	print("Mask "+ str(mask_id) + " collected.")
	
	if mask_info == null:
		printerr("Interactable %s doesn't have a mask_info resource assigned yet. You can find them scenes/collectibles/MaskInfos" % [name])
	
	if Globals.collected_masks.has(mask_info):
		printerr("Interactable %s already contains this mask_info. Try to assign another one. You can find them scenes/collectibles/MaskInfos" % [name])
	
	Globals.collected_masks.append(mask_info)
	Globals.mask_count[level_id] += 1
	Globals.recalculate_mask_effects.emit()

	# Spawn a wave of enemies.
	var wave_id = Globals.mask_count[level_id] if spawn_waves_by_mask_count else mask_id
	
	if wave_id < enemy_waves.size():
		var wave = enemy_waves[wave_id]
		if wave:
			for enemy in wave.get_children():
				wave.remove_child(enemy)
				enemies.add_child(enemy)
	
	# Start regularly spawning enemies.
	enemy_spawn_timer.start()


func transition_to_level(level: Globals.LevelId) -> void:
	call_deferred("_transition_to_level", Globals.LevelLookup[level])
	

func _transition_to_level(level: String) -> void:
	get_tree().paused = true
	await TransitionOverlay.fade_to_black(1.0)
	get_tree().paused = false
	get_tree().change_scene_to_file(level)


func spawn_additional_enemy_wave(wave_name: String) -> void:
	if not wave_name in additional_waves:
		push_error("No additional wave with name '" + wave_name + '" defined.')
		return
	var wave = additional_waves[wave_name]
	if wave:
		for enemy in wave.get_children():
			wave.remove_child(enemy)
			enemies.add_child(enemy)

extends Node

var storage := ConfigFile.new()
const STORAGE_PATH = "user://storage.cfg"
 
var last_level: Globals.LevelId = Globals.LevelId.None

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if storage.load(STORAGE_PATH) == OK:
		last_level = storage.get_value("GameState", "LastLevel", Globals.LevelId.None)

func save_last_level(level: Globals.LevelId) -> void:
	last_level = level
	storage.set_value("GameState", "LastLevel", last_level)
	storage.save(STORAGE_PATH)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

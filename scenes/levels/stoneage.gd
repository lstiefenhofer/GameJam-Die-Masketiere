extends Level
@export var closed_door_one: Door
@export var closed_door_two: Door
@export var fake_pedestral: StaticBody2D
@export var fake_pedestral_2: StaticBody2D
@export var fake_pedestral_3: StaticBody2D
@export var fake_pedestral_4: StaticBody2D




func _on_button_pressed_open_door() -> void:
	closed_door_one.state = Door.State.OPEN
	spawn_additional_enemy_wave("ButtonOneMonsterWave")



func _on_button_pressed_open_second_door() -> void:
	closed_door_two.state = Door.State.OPEN
	spawn_additional_enemy_wave("ButtonTwoMonsterWave")
	fake_pedestral.queue_free()
	fake_pedestral_2.queue_free()
	fake_pedestral_3.queue_free()
	fake_pedestral_4.queue_free()

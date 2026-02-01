extends Area2D

signal door_entered()
@export var sprite_2d: Sprite2D

func _on_body_entered(_body: Node2D) -> void:
	door_entered.emit()

func open_door() -> void:
	sprite_2d.hide()

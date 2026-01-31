@tool

extends Node2D

signal player_entered_door()

enum State {
	EXIT,
	CLOSED,
	OPEN,
}

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var closed_door_collision: CollisionShape2D = $ClosedDoorCollision

@export var state: State:
	set(value):
		state = value
		setup_door()
		
func _ready() -> void:
	setup_door()
	
func setup_door() -> void:
	if sprite_2d:
		sprite_2d.frame = state
	if closed_door_collision:
		closed_door_collision.disabled = state != State.CLOSED



func _on_enter_door_area_body_entered(_body: Node2D) -> void:
	player_entered_door.emit()

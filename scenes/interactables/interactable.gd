extends StaticBody2D

class_name Interactable

@onready var interact_hint: PanelContainer = $InteractHint

var is_player_in_range: bool = false:
	set(value):
		is_player_in_range = value
		# TODO this breaks if we are in the range of two interactables
		if is_interactable:
			Globals.set_in_interactable_range(value)
@export var is_interactable: bool = true

func _process(_delta: float) -> void:
	if is_interactable and is_player_in_range and Input.is_action_just_pressed("Attack"):
		interact()

func _on_interaction_area_body_entered(_body: Node2D) -> void:
	is_player_in_range = true
	if is_interactable:
		interact_hint.show()

func _on_interaction_area_body_exited(_body: Node2D) -> void:
	is_player_in_range = false
	interact_hint.hide()

func interact() -> void:
	is_player_in_range = false
	is_interactable = false
	interact_hint.hide()

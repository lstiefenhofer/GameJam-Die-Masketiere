extends StaticBody2D

class_name Interactable

@onready var interact_hint: PanelContainer = $InteractHint

@export var is_interactable: bool = true
var is_player_in_range: bool = false
var is_current_interactable: bool = false

func _process(_delta: float) -> void:
	if is_interactable and is_current_interactable and Input.is_action_just_pressed("Attack"):
		interact()

func _on_interaction_area_body_entered(player: Player) -> void:
	if is_interactable:
		player.register_interactable(self)
	is_player_in_range = true

func _on_interaction_area_body_exited(player: Player) -> void:
	if is_interactable:
		player.deregister_interactable(self)
	is_player_in_range = false
	
func interact() -> void:
	is_player_in_range = false
	is_interactable = false
	Player.player.deregister_interactable(self)

	
func show_interaction_hint() -> void:
	interact_hint.show()
	is_current_interactable = true
	
func hide_interaction_hint() -> void:
	interact_hint.hide()
	is_current_interactable = false

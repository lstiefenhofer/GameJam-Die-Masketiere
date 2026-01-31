extends EnemyBase

@onready var mammoth = $EnemySpritesheet


func default_attack():
	mammoth.play("run")
	charge_attack()
	mammoth.stop()

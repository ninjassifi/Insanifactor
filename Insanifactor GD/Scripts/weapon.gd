extends Node2D

@export var attack_component : AttackComponent

func _physics_process(delta):
	if(Input.is_action_pressed("attack")):
		attack_component.attack()

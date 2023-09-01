extends Area2D

class_name HurtComponent

@export var health_component : HealthComponent

func damage(damage : float):
	# If health component exists, damage the heath component
	if health_component:
		health_component.damage(damage)

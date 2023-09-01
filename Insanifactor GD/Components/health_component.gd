extends Node

class_name HealthComponent

signal damaged

@export var max_health : float = 10.0;
var health;

func _ready():
	health = max_health


# Does damage and things to this health
func damage(damage : float) -> void:
	damaged.emit()
	
	health = health - damage
	# If health is less than 0, than rid this node
	if(health <= 0):
		die()


func die() -> void:
	get_parent().queue_free()

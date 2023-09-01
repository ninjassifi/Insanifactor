extends Node

class_name HealthBarComponent

@export var health_component : HealthComponent

@onready var bar : ProgressBar = $ProgressBar

func _ready():
	bar.min_value = 0.0
	bar.max_value = health_component.max_health


# When the health component damaged signal is sent:
func damaged():
	bar.value = health_component.health

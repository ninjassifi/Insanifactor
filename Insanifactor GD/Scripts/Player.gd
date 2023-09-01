extends CharacterBody2D


@export var speed : float = 300.0

func _physics_process(delta):
	velocity = Vector2.ZERO; # The player's movement vector.
	var direction = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
		
	velocity = direction.normalized() * speed; # This turns it so that your velocity isn't faster when pressing w and d at the same time
	velocity = velocity * delta; # velocity per second, not per frame
	move_and_collide(velocity);

func damage(damage : float):
	var health_component : HealthComponent = $HealthComponent
	health_component.damage(damage)

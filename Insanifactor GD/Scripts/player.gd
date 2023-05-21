extends RigidBody2D

@export var speed = 400;
var velocity;

func _process(delta):
	pass
func _physics_process(delta):
	velocity = Vector2.ZERO; # The player's movement vector.
	if Input.is_action_pressed("moveRight"):
		velocity.x += 1;
	if Input.is_action_pressed("moveLeft"):
		velocity.x -= 1;
	if Input.is_action_pressed("moveDown"):
		velocity.y += 1;
	if Input.is_action_pressed("moveUp"):
		velocity.y -= 1;
		
	velocity = velocity.normalized() * speed; # This turns it so that your velocity isn't faster when pressing w and d at the same time
	velocity = velocity * delta; # velocity per second, not per frame
	move_and_collide(velocity);

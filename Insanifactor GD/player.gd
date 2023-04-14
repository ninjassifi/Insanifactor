extends RigidBody2D

@export var speed = 400;
var screen_size;

func _ready():
	screen_size = get_viewport_rect().size

func _process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("moveRight"):
		velocity.x += 1
	if Input.is_action_pressed("moveLeft"):
		velocity.x -= 1
	if Input.is_action_pressed("moveDown"):
		velocity.y += 1
	if Input.is_action_pressed("moveUp"):
		velocity.y -= 1
		
	velocity = velocity.normalized() * speed; # This turns it so that your velocity isn't faster when pressing w and d at the same time
	
	position += velocity * delta; # Make it so that you move the same speed even if your computer is slow

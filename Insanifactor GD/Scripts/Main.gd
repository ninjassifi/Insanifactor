extends Node2D

# Chunk radius
var chunkRadius = 2;

# Get player coords to generate chunks
@onready var player = get_node("/root/Main/Player");

@onready var camera = get_node("/root/Main/Player/Camera");

@onready var terrain = get_node("/root/Main/Terrain");
func _physics_process(delta):
	
	# Generate in a radius of player offset by player width and height
	var playerWidth = 32;
	var playerHeight = 32;
	
	terrain.setChunkRadius(chunkRadius);
	
	var playerPos = terrain.getPositionToTile(player.position + Vector2(playerWidth / 2, playerHeight / 2));
	
	print(playerPos);
	# Generate chunks at player
	terrain.generatePlayer(playerPos);


func onChunkRadiusChanged(tempChunkRadius):
	chunkRadius = tempChunkRadius;

extends Node2D

# Chunk radius
var chunkRadius = 4;

# Spawn area for clearing obsticles (it's the radius so to say, but still a square area)
var spawnAreaSize = Vector2i(5, 5);

# Get player coords to generate chunks
@onready var player = get_node("/root/Main/Player");

@onready var camera = get_node("/root/Main/Player/Camera");

@onready var terrain = get_node("/root/Main/Terrain");

func _ready():
	# Gen terrain so we can clear it
	generatePlayer(player);
	
	# Make the boundries, and clear the area of spawn
	var topLeft = terrain.getPositionToTile(player.position) - spawnAreaSize;
	var bottomRight = terrain.getPositionToTile(player.position) + spawnAreaSize;
	terrain.fillArea(topLeft, bottomRight, terrain.TileExact.CLEAR_FLOOR);

func _physics_process(delta):
	generatePlayer(player);
	

func generatePlayer(player):
	# Generate in a radius of player offset by player width and height
	var playerWidth = 32;
	var playerHeight = 32;
	
	terrain.setChunkRadius(chunkRadius);
	
	#  Vector2(terrain.chunkSizeX * 32 / 2, terrain.chunkSizeY * 32 / 2) means add (2, 1) tiles to the player pos
	var playerPos = terrain.getPositionToTile(player.position + Vector2(playerWidth / 2, playerHeight / 2) + Vector2(terrain.chunkSizeX * 32 + 32, terrain.chunkSizeY * 32 / 2));
	
	
	
	print(playerPos);
	# Generate chunks at player
	terrain.generatePlayer(playerPos);

func onChunkRadiusChanged(tempChunkRadius):
	chunkRadius = tempChunkRadius;

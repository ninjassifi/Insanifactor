extends TileMap


# Tile stuff

# Types of tile
enum TileType{
	WALL,
	WATER,
	AIR
}
enum TileExact{
	AIR,
	CLEAR_FLOOR,
	WATER_SHALLOW,
	WATER_MEDIUM,
	WATER_DEEP,
	WALL_ALONE,
	WALL_LEFT,
	WALL_RIGHT,
	WALL_TOP,
	WALL_DOWN,
	WALL_TOP_LEFT,
	WALL_TOP_RIGHT,
	WALL_BOTTOM_LEFT,
	WALL_BOTTOM_RIGHT
}

var tileType = {};
var tileExact = {};

# Size of chunks (in tiles)
var chunkSizeX = 2;
var chunkSizeY = 2;

# Radius for chunks (in tiles)
var chunkRadius = 5;

var generatedChunks = {};

# Biomes

enum BiomeType{
	
}

var biomeType = {};
# Perlin noise maps
var biome = FastNoiseLite.new();
var altitude = FastNoiseLite.new();

func _ready():
	# Randomize the noise
	biome.seed = randi();
	altitude.seed = randi();

func _process(delta):
	# Formula is (the maximum size of the screen / the tile size, for size in tiles / min chunk size, for the at least minimum of covering the screen)
	#chunkRadius = ceil(max(screenSize.x, screenSize.y) / tileSize / min(chunkSizeX, chunkSizeY));
	pass;

func generatePlayer(tilePos : Vector2i):
	generateRadius(chunkRadius, tilePos);
	# Divide tilepos by 2 because it is to fast for some reason
	setPhysicsRadius(chunkRadius * min(chunkSizeX, chunkSizeY) - 1, tilePos / 2);

func generateRadius(radius : int, tilePos : Vector2i):
	var chunkPos = convertToChunkpos(tilePos);
	
	# For every tile in a radius
	# (chunkRadius is (center - radius) + 1 to (center + radius) - 1)
	# (chunkRadius / chunkSize, for chunk size in tiles, then floor to get a whole number)
	for chunkX in range(chunkPos.x - radius + 1, chunkPos.x + radius):
		for chunkY in range(chunkPos.y - radius + 1, chunkPos.y + radius):
			# If it is not generated, run the generation script
			if (generatedChunks.get(Vector2i(chunkX, chunkY)) == null):
				generatedChunks[Vector2i(chunkX, chunkY)] = true;
				generateChunk(Vector2i(chunkX, chunkY));

func generateChunk(chunkPos : Vector2i):
	var tilePos = Vector2i.ZERO;

	# Get the actual tileposition but with steps of chunk position and offset so that the chunks generate when in the chunk area
	tilePos.x = chunkPos.x * chunkSizeX - chunkSizeX;
	tilePos.y = chunkPos.y * chunkSizeY - chunkSizeY;
	
	# Generate from 0 to chunkSize
	for x in range(chunkSizeX):
		for y in range(chunkSizeY):
			var alt = altitude.get_noise_2d(tilePos.x + x, tilePos.y + y);
			
			# If the altitude at a point is more than 1, set tile to wall 
			if(floor(alt + 1) > 0):
				# Set wall
				set_cell(0, Vector2i(tilePos.x + x, tilePos.y + y), 1, Vector2i(0, 1));
				# Add wall to tileType array
				tileType[Vector2i(tilePos.x + x, tilePos.y + y)] = TileType.WALL;
				tileExact[Vector2i(tilePos.x + x, tilePos.y + y)] = TileExact.WALL_ALONE;
			else:
				# Set floor
				set_cell(0, Vector2i(tilePos.x + x, tilePos.y + y), 1, Vector2i(0, 0));
				# If floor, it is air
				tileType[Vector2i(tilePos.x + x, tilePos.y + y)] = TileType.AIR;
				tileExact[Vector2i(tilePos.x + x, tilePos.y + y)] = TileExact.CLEAR_FLOOR;

func setPhysicsRadius(radius : int, tilePos : Vector2i):
	# For every tile in a radius
	# (physicsRadius is (center - radius) + 1 to (center + radius) - 1)
	# (chunkRadius / chunkSize, for chunk size in tiles, then floor to get a whole number)
	for tileX in range(tilePos.x - radius, tilePos.x + radius):
		for tileY in range(tilePos.y - radius, tilePos.y + radius):
			# If physics wall
			_setPhysicsWall(tilePos + Vector2i(tileX, tileY))

func _setPhysicsWall(tilePos : Vector2i):
	# If the current tile is not a wall, stop function
	if(tileType.get(tilePos) != TileType.WALL):
		return;
	# From -1 to 1, it's just that godot goes from -1 to 0 LIKE BRUH (so I have to do from -1 to 2)
	for tileY in range(-1, 2):
		for tileX in range(-1, 2):
			# Diagram:
			# S x x
			# x o x
			# x x E
			# S = start, o = origin, E = end
			
			var currentTileType = tileType.get(tilePos + Vector2i(tileX, tileY));
			var nonCollision = TileType.AIR;
			
			# If the tilepos is a floor tile, set the current tile to a physics wall (tile at tilePos) and end function
			if(currentTileType == nonCollision):
				set_cell(0, tilePos, 1, Vector2i(0, 2));
				return;

func convertToChunkpos(tilePosition : Vector2i):
	var chunkPos = Vector2(); 
	chunkPos.x = floor(tilePosition.x / chunkSizeX);
	chunkPos.y = floor(tilePosition.y / chunkSizeY);
	return chunkPos;

func setChunkRadius(tempChunkRadius : int):
	chunkRadius = tempChunkRadius;

func getPositionToTile(position : Vector2):
	# Divide the position by the scale of this object
	return local_to_map(position / scale);

extends TileMap

# Some info: Always setcell at layer 0, because that is the floor layer
# Current tilemap:
var globalTextureMapIndex = 1;

# Types of tile
enum TileType{
	WALL,
	WATER,
	AIR
};
enum TileExact{
	AIR,
	OLD_CLEAR_FLOOR,
	CLEAR_FLOOR,
	WATER_SHALLOW,
	WATER_MEDIUM,
	WATER_DEEP,
	OLD_WALL_ALONE,
	WALL_ALONE,
	WALL_ALONE_COLLIDE,
	WALL_MIDDLE,
	WALL_LEFT,
	WALL_RIGHT,
	WALL_TOP,
	WALL_BOTTOM,
	WALL_TOP_LEFT,
	WALL_TOP_RIGHT,
	WALL_BOTTOM_LEFT,
	WALL_BOTTOM_RIGHT
};

# Dictionaries for each tile about their type and exact type
var tileType = {};
var tileExact = {};

# Conversion table for turning tileExacts to tileTypes
var tileTypeTable = {
	TileExact.AIR :                TileType.AIR,
	TileExact.OLD_CLEAR_FLOOR :    TileType.AIR,
	TileExact.CLEAR_FLOOR :        TileType.AIR,
	TileExact.WATER_SHALLOW :      TileType.WATER,
	TileExact.WATER_MEDIUM :       TileType.WATER,
	TileExact.WATER_DEEP :         TileType.WATER,
	TileExact.OLD_WALL_ALONE :     TileType.WALL,
	TileExact.WALL_ALONE :         TileType.WALL,
	TileExact.WALL_ALONE_COLLIDE : TileType.WALL,
	TileExact.WALL_TOP_LEFT :      TileType.WALL,
	TileExact.WALL_TOP :           TileType.WALL,
	TileExact.WALL_TOP_RIGHT :     TileType.WALL,
	TileExact.WALL_LEFT :          TileType.WALL,
	TileExact.WALL_MIDDLE :        TileType.WALL,
	TileExact.WALL_RIGHT :         TileType.WALL,
	TileExact.WALL_BOTTOM_LEFT :   TileType.WALL,
	TileExact.WALL_BOTTOM :        TileType.WALL,
	TileExact.WALL_BOTTOM_RIGHT :  TileType.WALL,
};

# Tile textures in dictionary to easily and fastly recieve texture atlas coords
var tileTextures = {
	TileExact.AIR : Vector2i(0, -1),
	TileExact.CLEAR_FLOOR : Vector2i(0, 0),
	TileExact.WALL_ALONE : Vector2i(0, 1),
	TileExact.WALL_ALONE_COLLIDE : Vector2i(0, 2)
};

# Biomes
enum BiomeType{
	VOID,
	NORMAL,
	OLD
}

var biomeType = {};
var biomePercentage = {};

# Size of chunks (in tiles)
var chunkSizeX = 2;
var chunkSizeY = 2;

# Radius for chunks (in tiles)
var chunkRadius = 5;

var generatedChunks = {};

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
	# Divide tilepos by 2 because it is too fast for some reason
	setPhysicsRadius(chunkRadius * min(chunkSizeX, chunkSizeY) - 1, tilePos / 2);

func generateRadius(radius : int, tilePos : Vector2i):
	var chunkPos = convertToChunkpos(tilePos);
	
	# (Technically this generates in a square, but it's around the player)
	
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
	for tileX in range(chunkSizeX):
		for tileY in range(chunkSizeY):
			var alt = altitude.get_noise_2d(tilePos.x + tileX, tilePos.y + tileY);
			
			# bio is from 0 to 1, get_noise_2d goes from -0.5 to 0.5
			var bio = biome.get_noise_2d(tilePos.x + tileX, tilePos.y + tileY) + .5;
			# If biome variable is less than .9, than the biome will be normal
			if(bio < .6):
				biomeType[tilePos + Vector2i(tileX, tileY)] = BiomeType.NORMAL;
			elif(bio < .9):
				biomeType[tilePos + Vector2i(tileX, tileY)] = BiomeType.OLD;
			else:
				biomeType[tilePos + Vector2i(tileX, tileY)] = BiomeType.VOID;
			
			# Normal biome type
			if(biomeType[tilePos + Vector2i(tileX, tileY)] == BiomeType.NORMAL):
				# If the altitude at a point is more than 1, set tile to wall 
				if(floor(alt + 1) > 0):
					# Set wall
					setTile(Vector2i(tilePos + Vector2i(tileX, tileY)), TileExact.WALL_ALONE);
				else:
					# Set floor
					setTile(Vector2i(tilePos + Vector2i(tileX, tileY)), TileExact.CLEAR_FLOOR);
			
			# Void biome
			elif(biomeType[tilePos + Vector2i(tileX, tileY)] == BiomeType.VOID):
				setTile(Vector2i(tilePos + Vector2i(tileX, tileY)), TileExact.AIR);
			
			elif(biomeType[tilePos + Vector2i(tileX, tileY)] == BiomeType.OLD):
				# If the altitude at a point is more than 1, set tile to wall 
				if(floor(alt + 1) > 0):
					# Set wall
					setTile(Vector2i(tilePos + Vector2i(tileX, tileY)), TileExact.WALL_ALONE, 2);
				else:
					# Set floor
					setTile(Vector2i(tilePos + Vector2i(tileX, tileY)), TileExact.CLEAR_FLOOR, 2);

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

func getPositionToTile(position : Vector2):
	# Divide the position by the scale of this object
	return local_to_map(position / scale);

func setChunkRadius(tempChunkRadius : int):
	chunkRadius = tempChunkRadius;

func fillArea(tilePos1 : Vector2i, tilePos2 : Vector2i, TileExact):
	for tileX in range(tilePos1.x, tilePos2.x):
		for tileY in range(tilePos1.y, tilePos2.y):
			setTile(Vector2i(tileX, tileY), TileExact)

func setTile(tilePos : Vector2i, TileExact, textureMapIndex = globalTextureMapIndex):
	# TileExact != tileExact, tileExact = enum while TileExact in this function is a pointer to a specific enum inside tileExact.
	
	# Decifering this is, set cell at (tilePos) the sprite at (vec2i) of spritesheet (globalTextureMapIndex)
	set_cell(0, tilePos, textureMapIndex, tileTextures.get(TileExact));
	
	# Set the TileExact and TileType
	
	# At tilepos set tileExact to TileExact
	tileExact[tilePos] = TileExact;
	
	# At tilepos set the TileType to convertToTileType(TileExact)
	tileType[tilePos] = tileTypeTable.get(TileExact);

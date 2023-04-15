extends TileMap

# Tile stuff
@export var tileSize = 64;

# Size of map basically (in tiles)
const width = 128;
const height = 128;

# Size of chunks (in tiles)
const chunkSizeX = 16;
const chunkSizeY = 16;

# Weather or not to generate on the fly or generate all at once
const allAtOnce = true;

# Perlin noise maps
var biome = FastNoiseLite.new();
var altitude = FastNoiseLite.new();

func _ready():
	
	# Generate the floor, because I ain't doing it myself
	
	# From -64,-64 to 64, 64 (tile pos)
	var from = convertToTilepos(Vector2i(width / 2 - width, height / 2 - height));
	var to = convertToTilepos(Vector2i(width, height));
	
	#generateFloor(from, to);
	
	# Randomize the perlin noise
	
	biome.seed = randi();
	altitude.seed = randi();
	
	generateChunk(from, to);

func _process(delta):
	pass

func generateChunk(from, to):
	var tilePos = local_to_map(from);
	for y in range(to.y / tileSize):
		for x in range(to.x / tileSize):
			var alt = altitude.get_noise_2d(tilePos.x + x, tilePos.y + y);
			
			set_cell(0, Vector2i(tilePos.x + x, tilePos.y + y), 0, Vector2i(0, floor(alt + 1)));

func generateFloor(from, to):
	var tilePos = local_to_map(from);
	for y in range(to.y / tileSize):
		for x in range(to.x / tileSize):
			# Layer, Position, texture sheet, where on texture sheet
			set_cell(0 , Vector2i(tilePos.x + x, tilePos.y + y), 0 , Vector2i(0,0));

func convertToTilepos(position):
	position.x *= tileSize;
	position.y *= tileSize;
	return position;

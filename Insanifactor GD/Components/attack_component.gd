extends Area2D

class_name AttackComponent

# Ammount of damage that this weapon does
@export var attack_damage : float = 1.0
@export var attack_cooldown : float = 1.0

var can_attack : bool = false
var cooldownTimer := Timer.new()
var enemy

func _ready():
	add_child(cooldownTimer)
	initCooldownTimer()


func onAreaEntered(area):
	enemy = area
	can_attack = true
	#print("detected")


func onAreaExited(area):
	can_attack = false


func attack():
	# If cannot attack or cooldown is still not 0, return
	if(!can_attack):
		return
		
	if(cooldownTimer.time_left != 0):
		return
	
	if(enemy.has_method("damage")):
		enemy.damage(attack_damage)
		# Start it over so we don't do damage 20x per second
		resetCooldownTimer()


func initCooldownTimer():
	cooldownTimer.wait_time = attack_cooldown
	cooldownTimer.autostart = true
	cooldownTimer.one_shot = true
	cooldownTimer.start()


func resetCooldownTimer():
	cooldownTimer.wait_time = attack_cooldown
	cooldownTimer.start()

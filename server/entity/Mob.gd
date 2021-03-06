extends "res://server/entity/entity.gd"

onready var world = get_node("/root/World")
onready var players = get_node("/root/World/entities/players")

var nearby_players = {}

func _ready():
	set_max_attributes(100, 100, 100, 100, 100, 100)
	who = "mob"
	get_node("hitbox").set_shape(load("res://server/entity/entity_resources/mob_hitbox.tres"))
	set_collision_layer_bit(Base.MOB_COLLISION_LAYER, true) # 
	set_collision_layer_bit(0, true) # tiles
	set_collision_mask_bit(0, false) # reset 
	#set_collision_mask_bit(Base.MOB_COLLISION_LAYER, true) # mobs
	set_collision_mask_bit(Base.PLAYER_COLLISION_LAYER, true) # players
	set_collision_mask_bit(Base.PROJECTILE_COLLISION_LAYER, true) # projectiles
	#set mob position
	get_node("area").connect("body_entered", self, "_on_area_body_entered")
	get_node("area").connect("body_exited", self, "_on_area_body_exited")
	
	
func _on_area_body_entered(body):
	if body.is_class("TileMap"):
		velocity.y = -1.5*150
	elif body.who == "player":
		enemies_in_range[body] = true
	
		
func _on_area_body_exited(body):
	if body.is_class("TileMap"):
		return
	if body.who == "player":
		enemies_in_range.erase(body)
	
	
func _physics_process(delta):
	move()
	
	
func find_nearest_player():
	var minx = 300
	var near = null
	for p in players.get_children():
		var x = position.distance_to(p.position)
		if (x < minx):
			minx = x
			near = p
	return near


func move():
	state = "idle"
	var player = find_nearest_player()
	if (player != null):
		state = "walking"
		velocity.x = (2 * int(player.position.x > position.x) - 1)* speed
	else:
		velocity.x = 0
	attack()
	move_and_slide(velocity, Vector2(0,-1))
	rpc("remote_move", position, velocity, state)
	if !is_on_floor():
		velocity.y += GRAVITY
	
	
func attack():
	for player in enemies_in_range:
		state = "attacking"
		player.take_damage(damage)
	
	
remote func take_damage(x):
	health -= x
	rpc("set_health", health)
	if (health <= 0):
		rpc("playMobDeath")
		# 50/50 chance to spawn item
		var chance = randi()%2
		if chance == 0 || chance == 1:
			world.get_node("Spawning/ItemSpawner").spawn_item(position) # spawn a potion
		rpc("delete_me")
		queue_free()
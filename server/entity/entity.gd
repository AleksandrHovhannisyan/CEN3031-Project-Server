extends KinematicBody2D

var who = "none"

var GRAVITY = 12

var velocity = Vector2()
var health

var state = "idle"

func apply_gravity():
	velocity.y += GRAVITY

func _ready():
	var hitbox = CollisionShape2D.new()
	hitbox.set_name("hitbox")
	add_child(hitbox)
	pass
	
	
func check_position():
	if position.y > 650:
		position = Vector2(0,0)
		velocity.y = 0
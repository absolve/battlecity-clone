extends Area2D


var dir=Game.dir.UP
var power=Game.bulletPower.NORMAL
var speed=160
var own=Game.objType.PLAYER
var playerId=Game.playerId.p1
var vec=Vector2.ZERO

onready var sprite=$Sprite
onready var shape=$shape

func _ready():
	if dir==Game.dir.UP:
		sprite.flip_v=true
		vec=Vector2(0,-speed)
	elif dir==Game.dir.DOWN:
		vec=Vector2(0,speed)
	elif dir==Game.dir.LEFT:
		vec=Vector2(-speed,0)
		sprite.rotation_degrees=90
		shape.rotation_degrees=90
	elif dir==Game.dir.RIGHT:
		vec=Vector2(speed,0)
		sprite.rotation_degrees=-90
		shape.rotation_degrees=-90
		
func setPower(value):
	if value==Game.bulletPower.normal:
		speed=180
	elif value==Game.bulletPower.fast:
		speed=380
	elif value==Game.bulletPower.super:
		speed=380
	power=value


func _physics_process(delta):
	position+=vec*delta


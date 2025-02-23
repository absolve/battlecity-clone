extends Area2D

var objType=Game.objType.BULLET
var dir=Game.dir.UP
var power=Game.bulletPower.NORMAL
var speed=160
var own=Game.objType.PLAYER
var ownId=0
var playerId=Game.playerId.p1
var vec=Vector2.ZERO

const cellSize=16
var mapSize=Vector2(cellSize*26,cellSize*26)


var explode=preload("res://scene/explode.tscn")
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
	if value==Game.bulletPower.NORMAL:
		speed=180
	elif value==Game.bulletPower.FAST:
		speed=380
	elif value==Game.bulletPower.SUPER:
		speed=380
	power=value


func _physics_process(delta):
	position+=vec*delta
	if position.x<0||position.x>mapSize.x:
		addexplode()
	if position.y<0||position.y>mapSize.y:
		addexplode()
	

func addexplode():
	var temp = explode.instance()
	temp.position=position
	Game.map.addOther(temp)
	queue_free()

func _on_bullet_area_entered(area):
	if area.get_instance_id()==ownId:
		return	
	if own==Game.objType.ENEMY:
		if area.get('objType')==Game.objType.PLAYER:
			addexplode()
	elif own==Game.objType.PLAYER:
		if area.get('objType')==Game.objType.ENEMY:
			addexplode()		
	if area.get('objType')==Game.objType.BULLET||area.get('objType')==Game.objType.BASE:
		call_deferred('queue_free')	
	elif area.get('objType')==Game.objType.BRICK:
		if area.get('type')==Game.brickType.WALL||area.get('type')==Game.brickType.STONE:
			addexplode()

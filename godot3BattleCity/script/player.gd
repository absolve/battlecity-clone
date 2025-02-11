extends "res://script/tank.gd"

#玩家id 用来区分按键
var playerId=Game.playerId.p1
var bullet=preload("res://scene/bullet.tscn")
var maxBullet=1
var objType=Game.objType.PLAYER

func _ready():
	if dir==Game.dir.UP:
		radar.rotation_degrees=-90
	elif dir==Game.dir.DOWN:
		radar.rotation_degrees=90
	elif dir==Game.dir.LEFT:
		radar.rotation_degrees=180
	elif dir==Game.dir.RIGHT:
		radar.rotation_degrees=0

func _physics_process(delta):
	
	lastDir=dir
	if Input.is_action_pressed("p1_down"):
		vec=Vector2(0,speed)
		dir=Game.dir.DOWN
	elif Input.is_action_pressed("p1_up"):
		vec=Vector2(0,-speed)
		dir=Game.dir.UP
	elif Input.is_action_pressed("p1_left"):
		vec=Vector2(-speed,0)
		dir=Game.dir.LEFT
	elif Input.is_action_pressed("p1_right"):
		vec=Vector2(speed,0)
		dir=Game.dir.RIGHT
	else:
		vec=Vector2.ZERO	
		
	if lastDir!=dir:	#转向的需要修改位置
		turnDirection()
	
	if Input.is_action_pressed("p1_shoot"):
		fire()
	
	animation(dir,vec)		
	if !isStop:
		position+=vec*delta

	#调整一下位置
	if position.x<=tankSize/2:
		position.x=tankSize/2
	if position.x>=mapSize.x-tankSize/2:	
		position.x=mapSize.x-tankSize/2

	if position.y<=tankSize/2:
		position.y=tankSize/2
	if position.y>=mapSize.y-tankSize/2:	
		position.y=mapSize.y-tankSize/2



#改变方向的时候调整位置
func turnDirection():
	if dir==Game.dir.LEFT||dir==Game.dir.RIGHT:
		position.y=round((position.y)/16)*16
	else:
		position.x=round((position.x)/16)*16
	if dir==Game.dir.UP:
		radar.rotation_degrees=-90
	elif dir==Game.dir.DOWN:
		radar.rotation_degrees=90
	elif dir==Game.dir.LEFT:
		radar.rotation_degrees=180
	elif dir==Game.dir.RIGHT:
		radar.rotation_degrees=0

#发射子弹
func fire():
	if canShoot:
		canShoot=false
		shootTimer.start()
		var temp=bullet.instance()
		temp.position=position
		temp.dir=dir
		temp.playerId=playerId
		temp.own=Game.objType.PLAYER
		temp.setPower(bulletPower)
		temp.ownId=body.get_instance_id()
		bullets.append(temp)
		Game.map.addBullet(temp)
		get_instance_id()
	
func animation(dir,vec):
	if dir==Game.dir.UP:
		ani.flip_v=false
		ani.flip_h=false
		ani.rotation_degrees=0
	elif dir==Game.dir.DOWN:
		ani.flip_v=true
		ani.flip_h=false
		ani.rotation_degrees=0
	elif dir==Game.dir.LEFT:
		ani.flip_v=false
		ani.flip_h=true
		ani.rotation_degrees=-90
	elif dir==Game.dir.RIGHT:	
		ani.flip_v=false
		ani.flip_h=false
		ani.rotation_degrees=90

			
	if vec!=Vector2.ZERO:	
		ani.play("small_run")
	else:
		ani.play("small")	


func _on_radar_area_entered(area):
	if area==body: #排除自己
		return
	if area.get('objType')==Game.objType.BRICK:
		if area.get('type')!=Game.brickType.BUSH:
			isStop=true
	if area.get('objType')==Game.objType.BASE:
		isStop=true

func _on_radar_area_exited(area):
	if area==body:
		return 
	if area.get('objType')==Game.objType.BRICK:	
		isStop=false


extends "res://script/tank.gd"

var objType=Game.objType.ENEMY
var type=Game.enemyType.TYPEA
var targetPos=Vector2(12,24)*cellSize  #基地位置
var allDir=[Game.dir.LEFT,Game.dir.RIGHT,Game.dir.UP,Game.dir.DOWN]
var moveTime=0  #移动时间
var keepMoveTime=0 #保持移动的时间
var bullet=preload("res://scene/bullet.tscn")
var explode=preload("res://scene/explode.tscn")
var fireTime=0	#开火计时
var fireDelay=200 #延迟


func _ready():
	dir=Game.dir.DOWN
	
	if dir==Game.dir.UP:
		radar.rotation_degrees=-90
	elif dir==Game.dir.DOWN:
		radar.rotation_degrees=90
	elif dir==Game.dir.LEFT:
		radar.rotation_degrees=180
	elif dir==Game.dir.RIGHT:
		radar.rotation_degrees=0
	
	if type==Game.enemyType.TYPEA:
		armour=randi()%2
	elif type==Game.enemyType.TYPEB:
		armour=randi()%2
		speed=110
	elif type==Game.enemyType.TYPEC:
		armour=randi()%4
		bulletPower=Game.bulletPower.FAST
	elif type==Game.enemyType.TYPED:
		armour=randi()%4+1
		bulletPower=Game.bulletPower.FAST
		speed-=10
		
	keepMoveTime=randi()%300+60
	startInit()

func _physics_process(delta):
	if state==Game.tankstate.START:
		lastDir=dir
		
		if dir==Game.dir.DOWN:
			vec=Vector2(0,speed)
		elif dir==Game.dir.UP:
			vec=Vector2(0,-speed)
		elif dir==Game.dir.LEFT:
			vec=Vector2(-speed,0)
		elif dir==Game.dir.RIGHT:
			vec=Vector2(speed,0)
		
		moveTime+=1
		fireTime+=1
		if isStop:
			keepMoveTime-=15
			
		if moveTime>keepMoveTime: #改变方向
			moveTime=0
			keepMoveTime=randi()%300+60
			var p=randf() #随机概率值
			if type==Game.enemyType.TYPEA:
				if p>0.3:
					targetEagle(p)
				else:
					var temp=getNewDir(lastDir)
					dir	= temp[randi()%temp.size()]
			elif type==Game.enemyType.TYPEB||type==Game.enemyType.TYPEC:		
				if p>0.5:
					targetEagle(p)
				else:
					var temp=getNewDir(lastDir)
					dir	= temp[randi()%temp.size()]
			elif type==Game.enemyType.TYPED:
				if p>0.1:	
					targetEagle(p)
				else:
					var temp=getNewDir(lastDir)
					dir	= temp[randi()%temp.size()]	
					
		if fireTime>fireDelay:
			fireTime=0
			fireDelay=randi()%300+120
			fire()
				
		if lastDir!=dir:	#转向的需要修改位置
			turnDirection()
		animation(dir,vec)


		if !isStop:
			position+=vec*delta

		#调整一下位置
		if position.x<=tankSize/2:
			position.x=tankSize/2
			keepMoveTime-=10
		if position.x>=mapSize.x-tankSize/2:	
			position.x=mapSize.x-tankSize/2
			keepMoveTime-=10
		if position.y<=tankSize/2:
			position.y=tankSize/2
			keepMoveTime-=10
		if position.y>=mapSize.y-tankSize/2:	
			position.y=mapSize.y-tankSize/2
			keepMoveTime-=10
			
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

#向基地出发
func targetEagle(p):
	var dx=position.x-targetPos.x
	var dy=position.y-targetPos.y 
	if abs(dx)>abs(dy):
		if dx<0:
			dir=Game.dir.RIGHT
		else:
			dir=Game.dir.LEFT
	else:
		if dy<0:
			dir=Game.dir.DOWN
		else:
			dir=Game.dir.UP	
	if p>0.8:
		var temp=getNewDir(lastDir)
		dir	= temp[randi()%temp.size()]

#获取一个新方向	
func getNewDir(dir):
	var temp=[]
	for i in allDir:
		if i!=dir:
			temp.append(i)
	return temp

#开火
func fire():
	if canShoot:
		canShoot=false
		shootTimer.start()
		var temp=bullet.instance()
		temp.position=position
		temp.dir=dir
		temp.own=Game.objType.ENEMY
		temp.setPower(bulletPower)
		temp.ownId=get_instance_id()
#		bullets.append(temp)
		Game.map.addBullet(temp)

func addExplode(isBig=true):
	var temp=explode.instance()
	temp.big=isBig
	temp.position=position
	Game.map.addOther(temp)
			
#开始初始化
func startInit():
	bodyShape.disabled=true
	initTimer.start()
	ani.play('flash')

func animation(dir,vec):
	if dir==Game.dir.UP:
		ani.flip_v=true
		ani.flip_h=false
		ani.rotation_degrees=0
	elif dir==Game.dir.DOWN:
		ani.flip_v=false
		ani.flip_h=false
		ani.rotation_degrees=0
	elif dir==Game.dir.LEFT:
		ani.flip_v=false
		ani.flip_h=false
		ani.rotation_degrees=90		
	elif dir==Game.dir.RIGHT:	
		ani.flip_v=false
		ani.flip_h=true
		ani.rotation_degrees=-90
	
	if type==Game.enemyType.TYPEA:
		if vec!=Vector2.ZERO:	
			ani.play('typeA_run')
		else:
			ani.play("typeA")	


func _on_radar_area_entered(area):
	if area==self: #排除自己
		return
#	print(area.get('objType'))	
	if area.get('objType')==Game.objType.BRICK:
		if area.get('type')!=Game.brickType.BUSH&&area.get('type')!=Game.brickType.ICE:
			isStop=true
	elif area.get('objType') in [Game.objType.ENEMY,Game.objType.PLAYER,Game.objType.BASE]:
		isStop=true

func _on_radar_area_exited(area):
	if area==self:
		return 
	if area.get('objType')==Game.objType.BRICK:	
		isStop=false
	elif area.get('objType') in [Game.objType.ENEMY,Game.objType.PLAYER,Game.objType.BASE]:
		isStop=false
#	isStop=false

func _on_initTimer_timeout():
	state=Game.tankstate.START
	bodyShape.disabled=false


func _on_tank_area_entered(area):
	if area.get('objType')==Game.objType.BULLET:
		
		if area.get('own')==Game.objType.PLAYER:
			if armour>0:
				armour-=1
			else:	
				addExplode()
				bodyShape.disabled=false
				call_deferred('queue_free')	


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
var fireDelay=150 #延迟
var armourColor=['#52582f','#fff2d1','#ddab7b']
var armourColor1=['#1b3f5f','#d8f2b9','#7f963b']
var armourColor2=['#0d472f','#d9ffe7','#5ea77b']
var armourColor3=['#8f0077','#ffffff','#db2b00']
var hasItem=false #有物品
#var rayLength=16  #射线长度

@onready var hitSound=$hit
@onready var player=$player

func _ready():
	dir=Game.dir.DOWN
	collision_layer=2
	collision_mask=16
	if type==Game.enemyType.TYPEA:
		armour=randi()%2
	elif type==Game.enemyType.TYPEB:
		armour=randi()%2
		speed=100
	elif type==Game.enemyType.TYPEC:
		armour=randi()%4
		bulletPower=Game.bulletPower.FAST
	elif type==Game.enemyType.TYPED:
		armour=randi()%3+1
		bulletPower=Game.bulletPower.FAST
		speed-=10
	
	if randi()%10>=7:
		if armour<3:
			armour+=1
		hasItem=true
	#hasItem=true
	keepMoveTime=randi()%300+80
	startInit()
	
func _physics_process(delta):
	if state==Game.tankstate.START:
		lastDir=dir
		isStop=false
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
			fireDelay=randi()%140+100
			fire()
				
		if lastDir!=dir:	#转向的需要修改位置
			turnDirection()
		animation(dir,vec)


		var areas=[]
		if dir==Game.dir.LEFT:
			areas=leftArea.get_overlapping_areas()
		elif dir==Game.dir.RIGHT:
			areas=rightArea.get_overlapping_areas()
		elif dir==Game.dir.UP:
			areas=topArea.get_overlapping_areas()
		elif dir==Game.dir.DOWN:
			areas=bottomArea.get_overlapping_areas()
		
		
		for i in areas:
			if i == leftArea||i ==rightArea||i==topArea\
			||i==bottomArea||i==self:
				continue	
			if i.get('objType') in [Game.objType.BRICK,Game.objType.BASE]:
				var type=i.get('type')
				if type==Game.brickType.BUSH||type==Game.brickType.ICE:
					if type==Game.brickType.ICE:
						isOnIce=true
					continue
				isStop=true
			if i.get('objType') in [Game.objType.ENEMY,Game.objType.PLAYER]:
				if global_position.distance_to(i.global_position)<14:
					continue
				isStop=true
		
		if !isStop:
			position+=vec*delta	
		else:
			keepMoveTime-=25

		#调整一下位置
		if position.x<=tankSize/2:
			position.x=tankSize/2
			keepMoveTime-=20
		if position.x>=mapSize.x-tankSize/2:	
			position.x=mapSize.x-tankSize/2
			keepMoveTime-=20
		if position.y<=tankSize/2:
			position.y=tankSize/2
			keepMoveTime-=20
		if position.y>=mapSize.y-tankSize/2:	
			position.y=mapSize.y-tankSize/2
			keepMoveTime-=20

	
#改变方向的时候调整位置
func turnDirection():
	if dir==Game.dir.LEFT||dir==Game.dir.RIGHT:
		position.y=round((position.y)/16)*16
	else:
		position.x=round((position.x)/16)*16	
		
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
		var temp=bullet.instantiate()
		temp.position=position
		temp.dir=dir
		temp.own=Game.objType.ENEMY
		temp.setPower(bulletPower)
		temp.ownId=get_instance_id()
#		bullets.append(temp)
		Game.map.addBullet(temp)

func addExplosion(isBig=true):
	var temp=explode.instantiate()
	temp.big=isBig
	temp.position=position
	temp.playSound=true
	Game.map.addOther(temp)
	
#开始初始化
func startInit():
	monitorable=false
	monitoring=false
	initTimer.start()
	ani.play('flash')

#设置停止移动
func setFreeze(flag=true):
	if flag:
		isFreeze=flag
		state=Game.tankstate.FREEZE
		if ani.animation!='flash':
			ani.stop()
	else:
		isFreeze=false
		if initTimer.is_stopped():
			state=Game.tankstate.START

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
	elif type==Game.enemyType.TYPEB:
		if vec!=Vector2.ZERO:	
			ani.play('typeB_run')
		else:
			ani.play("typeB")	
	elif type==Game.enemyType.TYPEC:
		if vec!=Vector2.ZERO:	
			ani.play('typeC_run')
		else:
			ani.play("typeC")	
	elif type==Game.enemyType.TYPED:
		if vec!=Vector2.ZERO:	
			ani.play('typeD_run')
		else:
			ani.play("typeD")	

#设置颜色
func setColor():
	if armour>0:
		ani.material.set_shader_parameter('ischange',true)
		
	if hasItem:	
		if armour>0:
			ani.material.set_shader_parameter('newColor1',Color(armourColor3[0]))
			ani.material.set_shader_parameter('newColor2',Color(armourColor3[1]))
			ani.material.set_shader_parameter('newColor3',Color(armourColor3[2]))
			player.play("blink")
		else:
			if ani.material.get_shader_parameter('ischange'):
				ani.material.set_shader_parameter('ischange',false)		
			player.play("RESET")	
	else:	
		if armour>=3:
			ani.material.set_shader_parameter('newColor1',Color(armourColor2[0]))
			ani.material.set_shader_parameter('newColor2',Color(armourColor2[1]))
			ani.material.set_shader_parameter('newColor3',Color(armourColor2[2]))
		elif armour==2:	
			ani.material.set_shader_parameter('newColor1',Color(armourColor1[0]))
			ani.material.set_shader_parameter('newColor2',Color(armourColor1[1]))
			ani.material.set_shader_parameter('newColor3',Color(armourColor1[2]))
		elif armour==1:	
			ani.material.set_shader_parameter('newColor1',Color(armourColor[0]))
			ani.material.set_shader_parameter('newColor2',Color(armourColor[1]))
			ani.material.set_shader_parameter('newColor3',Color(armourColor[2]))
		else:
			if ani.material.get_shader_parameter('ischange'):
				ani.material.set_shader_parameter('ischange',false)	


#设置爆炸
func setExplosion():
	addExplosion()
	set_deferred('monitorable',false)
	set_deferred('monitoring',false)
	call_deferred('queue_free')	

func _on_init_timer_timeout():
	if !isFreeze:
		state=Game.tankstate.START
	else:
		animation(dir,Vector2.ZERO)	
	set_deferred('monitorable',true)
	set_deferred('monitoring',true)
	setColor()


func _on_area_entered(area):
	print(1)
	if isDestroy||area==null:
		return
	if area!=null&&area.get('objType')==Game.objType.BULLET:	
		if area.get('own')==Game.objType.PLAYER:
			if armour>0:
				armour-=1
				if hasItem: #添加物品
					Game.emit_signal("addBonus")
				setColor()	
				hitSound.play()
			else:
				isDestroy=true	
				state=Game.tankstate.DEAD
				addExplosion()
				visible=false
				set_deferred('monitorable',false)
				set_deferred('monitoring',false)
				Game.emit_signal("destroyEnemy",type,area.get('playerId'),position)
				call_deferred('queue_free')	

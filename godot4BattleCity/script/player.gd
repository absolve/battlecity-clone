extends "res://script/tank.gd"

#玩家id 用来区分按键
var playerId=Game.playerId.p1
var bullet=preload("res://scene/bullet.tscn")
var explode=preload("res://scene/explode.tscn")
var objType=Game.objType.PLAYER
var level=Game.level.MIN  #玩家坦克级别
var keymap={"up":0,"down":0,"left":0,"right":0,'shoot':0}
var greenColor=['#0d472f','#d9ffe7','#5ea77b']  #外表颜色

@onready var fireSound=$fire
@onready var hitSound=$hit
@onready var idleSound=$idle
@onready var walkSound=$walk
@onready var slideSound=$slide

func _ready():
	collision_layer=1
	collision_mask=16+8
	speed=80	
	startInit()
	if playerId==Game.playerId.p1:
		keymap["up"]="p1_up"
		keymap["down"]="p1_down"
		keymap["left"]="p1_left"
		keymap["right"]="p1_right"
		keymap["shoot"]="p1_shoot"
	elif playerId==Game.playerId.p2:
		keymap["up"]="p2_up"
		keymap["down"]="p2_down"
		keymap["left"]="p2_left"
		keymap["right"]="p2_right"
		keymap["shoot"]="p2_shoot"	
		ani.material.set_shader_parameter('ischange',true)

func _physics_process(delta):
	if state==Game.tankstate.START:
		lastDir=dir
		isStop=false
	
		if Input.is_action_pressed(keymap["down"]):
			if vec==Vector2.ZERO&&isOnIce: #之前的是停下来并且在冰上
				slideSound.play()
			vec=Vector2(0,speed)
			dir=Game.dir.DOWN
		elif Input.is_action_pressed(keymap["up"]):
			if vec==Vector2.ZERO&&isOnIce: #之前的是停下来并且在冰上
				slideSound.play()
			vec=Vector2(0,-speed)
			dir=Game.dir.UP
		elif Input.is_action_pressed(keymap["left"]):
			if vec==Vector2.ZERO&&isOnIce: #之前的是停下来并且在冰上
				slideSound.play()
			vec=Vector2(-speed,0)
			dir=Game.dir.LEFT
		elif Input.is_action_pressed(keymap["right"]):
			if vec==Vector2.ZERO&&isOnIce: #之前的是停下来并且在冰上
				slideSound.play()
			vec=Vector2(speed,0)
			dir=Game.dir.RIGHT
		else:
			vec=Vector2.ZERO	
			
		if lastDir!=dir:	#转向的需要修改位置
			turnDirection()
		
		if Input.is_action_pressed(keymap["shoot"]):
			fire()
		
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
		isOnIce=false	
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
				if type==Game.brickType.WATER&&hasShip:
					continue	
				isStop=true
			if i.get('objType') in [Game.objType.ENEMY,Game.objType.PLAYER]:
				if global_position.distance_to(i.global_position)<14:
					continue
				isStop=true
		
		if vec!=Vector2.ZERO:
			slideTime=20
			if !walkSound.playing:
				walkSound.play()
			if idleSound.playing:
				idleSound.stop()
		else:
			if walkSound.playing:
				walkSound.stop()
			if !idleSound.playing:
				idleSound.play()		
				
		if isOnIce&&slideTime>0&&vec==Vector2.ZERO: #冰块上继续滑行
			if dir==Game.dir.LEFT:
				vec=Vector2(-speed,0)
			elif dir==Game.dir.RIGHT:
				vec=Vector2(speed,0)
			elif dir==Game.dir.UP:
				vec=Vector2(0,-speed)
			elif dir==Game.dir.DOWN:
				vec=Vector2(0,speed)
			slideTime-=1
			
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




#开始初始化
func startInit():
	monitorable=false
	monitoring=false
	initTimer.start()
	ani.play('flash')

#改变方向的时候调整位置
func turnDirection():
	if dir==Game.dir.LEFT||dir==Game.dir.RIGHT:
		position.y=round((position.y)/16)*16
	else:
		position.x=round((position.x)/16)*16

#发射子弹
func fire():
	if canShoot:
		var del=[]
		for i in bullets: #清理无效对象
			if not is_instance_valid(i):
				del.append(i)
		for i in del:
			bullets.remove_at(bullets.find(i))	
		if bullets.size()>=bulletMax:
			return
		canShoot=false
		shootTimer.start()
		var temp=bullet.instantiate()
		temp.position=position
		temp.dir=dir
		temp.playerId=playerId
		temp.own=Game.objType.PLAYER
		temp.setPower(bulletPower)
		temp.ownId=get_instance_id()
		bullets.append(temp)
		Game.map.addBullet(temp)
		fireSound.play()
		
func addExplosion(isBig=true):
	var temp=explode.instantiate()
	temp.big=isBig
	temp.position=position
	temp.playSound=true
	temp.own=Game.objType.PLAYER
	Game.map.addOther(temp)		
		
#设置是否有船
func setShip(flag:bool):
	hasShip=flag
	ship.visible=flag
	if playerId==Game.playerId.p1:
		ship.play('0')
	elif playerId==Game.playerId.p2:
		ship.play('1')
		
#升级	
func upgrade():
	if level==Game.level.MIN:
		level=Game.level.MEDIUM
		bulletPower=Game.bulletPower.FAST
	elif level==Game.level.MEDIUM:
		level=Game.level.LARGE
		bulletPower=Game.bulletPower.FAST
		bulletMax=2
	elif level==Game.level.LARGE:
		level=Game.level.SUPER
		bulletPower=Game.bulletPower.SUPER
		bulletMax=2
		
#升级成肥坦克
func upgrade2Max():
	level=Game.level.SUPER
	bulletPower=Game.bulletPower.SUPER
	bulletMax=2
	armour=1
	
#设置停止移动
func setFreeze(flag=true):
	if flag:
		isFreeze=flag
		state=Game.tankstate.FREEZE
		if ani.animation!='flash':
			ani.stop()
			idleSound.stop()
			walkSound.stop()
	else:
		isFreeze=false
		if initTimer.is_stopped():
			state=Game.tankstate.START	

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
		if level==Game.level.MIN:
			ani.play("small_run")
		elif level==Game.level.MEDIUM:
			ani.play('medium_run')	
		elif level==Game.level.LARGE:
			ani.play('large_run')	
		elif level==Game.level.SUPER:
			ani.play('super_run')		
	else:
		if level==Game.level.MIN:
			ani.play("small")
		elif level==Game.level.MEDIUM:
			ani.play('medium')	
		elif level==Game.level.LARGE:
			ani.play('large')	
		elif level==Game.level.SUPER:
			ani.play('super')	
			
			


func _on_init_timer_timeout():
	if !isFreeze:
		state=Game.tankstate.START
	else:
		animation(dir,Vector2.ZERO)	
	setShip(hasShip)	
	set_deferred('monitorable',true)
	set_deferred('monitoring',true)
	startinvincible(3)


func _on_area_entered(area):
	if isDestroy||area==null:
		return
	if area!=null&&area.get('objType')==Game.objType.BULLET:
		if isInvincible:
			return
		if area.get('own')==Game.objType.ENEMY:
			if hasShip:
				setShip(false)
				return
			if armour>0:
				armour-=1
				if level==Game.level.SUPER:
					level=Game.level.LARGE
					bulletPower=Game.bulletPower.FAST
				hitSound.play()
			else:
				isDestroy=true
				state=Game.tankstate.DEAD
				set_deferred('monitorable',false)
				set_deferred('monitoring',false)
				Game.emit_signal("hitPlayer",playerId)
				visible=false
				addExplosion()
				call_deferred('queue_free')	
	if area!=null&&area.get('objType')==Game.objType.BONUS:
		Game.emit_signal("getBonus",area.get('type'),objType,playerId)
		area.call_deferred('queue_free')			

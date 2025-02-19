extends "res://script/tank.gd"

#玩家id 用来区分按键
var playerId=Game.playerId.p1
var bullet=preload("res://scene/bullet.tscn")
var explode=preload("res://scene/explode.tscn")
var maxBullet=1
var objType=Game.objType.PLAYER
var level=Game.level.MIN  #玩家坦克级别
var keymap={"up":0,"down":0,"left":0,"right":0,'shoot':0}
var greenColor=['#0d472f','#d9ffe7','#5ea77b']  #外表颜色
var rayLength=16  #射线长度

func _ready():
	collision_layer=1+8
	
	speed=120	
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
	

func _physics_process(delta):
	if state==Game.tankstate.START:
		lastDir=dir
		isStop=false
		if Input.is_action_pressed(keymap["down"]):
			vec=Vector2(0,speed)
			dir=Game.dir.DOWN
		elif Input.is_action_pressed(keymap["up"]):
			vec=Vector2(0,-speed)
			dir=Game.dir.UP
		elif Input.is_action_pressed(keymap["left"]):
			vec=Vector2(-speed,0)
			dir=Game.dir.LEFT
		elif Input.is_action_pressed(keymap["right"]):
			vec=Vector2(speed,0)
			dir=Game.dir.RIGHT
		else:
			vec=Vector2.ZERO	
			
		if lastDir!=dir:	#转向的需要修改位置
			turnDirection()
		
		if Input.is_action_pressed(keymap["shoot"]):
			fire()
		
		animation(dir,vec)		

		var space_state = get_world_2d().direct_space_state
		var rayDir=[]
		var dirIsStop=[false,false,false]
		if dir==Game.dir.LEFT:
			rayDir=[Vector2.LEFT,Vector2.LEFT.rotated(deg2rad(45))
			,Vector2.LEFT.rotated(deg2rad(-45))]
		elif dir==Game.dir.RIGHT:
			rayDir=[Vector2.RIGHT,Vector2.RIGHT.rotated(deg2rad(45))
			,Vector2.RIGHT.rotated(deg2rad(-45))]
		elif dir==Game.dir.UP:
			rayDir=[Vector2.UP,Vector2.UP.rotated(deg2rad(45))
			,Vector2.UP.rotated(deg2rad(-45))]
		elif dir==Game.dir.DOWN:
			rayDir=[Vector2.DOWN,Vector2.DOWN.rotated(deg2rad(45))
			,Vector2.DOWN.rotated(deg2rad(-45))]
		for i in range(rayDir.size()):
			var result=space_state.intersect_ray(global_position,
			global_position+rayDir[i]*rayLength
			,[self],1+2+4,false,true)
			if result:
				dirIsStop[i]=true
				if result.collider.get('objType')==Game.objType.BRICK:
					var type=result.collider.get('type')
					if type==Game.brickType.BUSH||type==Game.brickType.ICE:
						dirIsStop[i]=false
					if type==Game.brickType.WATER&& hasShip:
						dirIsStop[i]=false		
				if result.collider.get('objType') in [Game.objType.ENEMY,Game.objType.PLAYER]:
					if global_position.distance_to(result.collider.global_position)<14:
						dirIsStop[i]=false			
		if dirIsStop[0]||dirIsStop[1]||dirIsStop[2]:
			isStop=true	
		
					
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
#	position.y=round((position.y)/16)*16
#	position.x=round((position.x)/16)*16
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
			bullets.remove(bullets.find(i))	
		if bullets.size()>=maxBullet:
			return
		canShoot=false
		shootTimer.start()
		var temp=bullet.instance()
		temp.position=position
		temp.dir=dir
		temp.playerId=playerId
		temp.own=Game.objType.PLAYER
		temp.setPower(bulletPower)
		temp.ownId=get_instance_id()
		bullets.append(temp)
		Game.map.addBullet(temp)

func addExplosion(isBig=true):
	var temp=explode.instance()
	temp.big=isBig
	temp.position=position
	Game.map.addOther(temp)
		
#开始初始化
func startInit():
	bodyShape.call_deferred('set_disabled',true)
	initTimer.start()
	ani.play('flash')

#设置是否有船
func setShip(flag:bool):
	hasShip=flag
	ship.visible=flag

#升级	
func upgrade():
	if level==Game.level.MIN:
		level==Game.level.MEDIUM
		bulletPower=Game.bulletPower.FAST
	elif level==Game.level.MEDIUM:
		level==Game.level.SUPER
		bulletPower=Game.bulletPower.SUPER
		bulletMax=2

#升级成肥坦克
func upgrade2Max():
	level==Game.level.SUPER
	bulletPower=Game.bulletPower.SUPER
	bulletMax=2
	armour=1
	
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


#func _on_radar_area_entered(area):
#	if area==self: #排除自己
#		return
#	if area.get('objType')==Game.objType.BRICK:
#		if area.get('type')!=Game.brickType.BUSH&&area.get('type')!=Game.brickType.ICE:
#			isStop=true
#	if area.get('objType') in [Game.objType.ENEMY,Game.objType.PLAYER,Game.objType.BASE]:
#		isStop=true

#func _on_radar_area_exited(area):
#	if area==self:
#		return 
#	if area.get('objType')==Game.objType.BRICK:	
#		isStop=false
#	if area.get('objType') in [Game.objType.ENEMY,Game.objType.PLAYER,Game.objType.BASE]:
#		isStop=false



func _on_initTimer_timeout():
	state=Game.tankstate.START
	bodyShape.disabled=false
	startinvincible(3)


func _on_tank_area_entered(area):
	if area.get('objType')==Game.objType.BULLET:
		if isInvincible:
			return
		if area.get('own')==Game.objType.ENEMY:
			if hasShip:
				setShip(false)
				return
			if armour>0:
				armour-=1
				if level==Game.level.SUPER:
					level=Game.level.MEDIUM
					bulletPower=Game.bulletPower.FAST
			else:
				addExplosion()
				bodyShape.call_deferred('set_disabled',false)
				call_deferred('queue_free')	
				Game.emit_signal("hitPlayer",playerId)
	if area.get('objType')==Game.objType.BONUS:
		Game.emit_signal("getBonus",area.get('type'),objType,playerId)
		area.call_deferred('queue_free')


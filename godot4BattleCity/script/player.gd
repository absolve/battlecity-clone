extends "res://script/tank.gd"

#玩家id 用来区分按键
var playerId=Game.playerId.p1
var bullet=preload("res://scene/bullet.tscn")
var explode=preload("res://scene/explode.tscn")
var objType=Game.objType.PLAYER
var level=Game.level.MIN  #玩家坦克级别
var keymap={"up":0,"down":0,"left":0,"right":0,'shoot':0}
var greenColor=['#0d472f','#d9ffe7','#5ea77b']  #外表颜色



func _ready():
	collision_layer=1
	collision_mask=8
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
		#ani.material.set_shader_param('ischange',true)

func _physics_process(delta):
	
	pass

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
			#idleSound.stop()
			#walkSound.stop()
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

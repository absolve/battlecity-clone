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
var rayLength=16  #射线长度

func _ready():
	dir=Game.dir.DOWN
	collision_layer=2
	
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
	keepMoveTime=randi()%300+80
	
func _physics_process(delta):
	
	pass
	
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

func addExplosion(isBig=true):
	var temp=explode.instance()
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

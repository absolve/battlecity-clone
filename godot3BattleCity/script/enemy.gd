extends "res://script/tank.gd"

var objType=Game.objType.ENEMY
var type=Game.enemyType.TYPEA
var targetPos=Vector2(12,24)*cellSize  #基地位置
var allDir=[Game.dir.LEFT,Game.dir.RIGHT,Game.dir.UP,Game.dir.DOWN]

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
	
	startInit()

func _physics_process(delta):
	if state==Game.tankstate.START:
		lastDir=dir
		
		
		
		
		if lastDir!=dir:	#转向的需要修改位置
			turnDirection()
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


func _on_initTimer_timeout():
	state=Game.tankstate.START

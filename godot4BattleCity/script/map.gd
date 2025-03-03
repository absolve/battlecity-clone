extends Node2D

const cellSize=16	#每个格子的大小是16px
var mapSize=Vector2(cellSize*26,cellSize*26)
var enemyCount=20 # 敌人总数
var p1LiveNum=2
var p2LiveNUm=2
var player1 = [Vector2(8,25),Vector2(9,25),Vector2(8,24),Vector2(9,24)]
var player2 =[Vector2(16,25),Vector2(17,25),Vector2(16,24),Vector2(17,24)]
var enemyPos=[Vector2(0,0),Vector2(0,1),Vector2(1,0),Vector2(1,1),
	Vector2(24,0),Vector2(25,0),Vector2(24,1),Vector2(24,2),
	Vector2(12,0),Vector2(13,0),Vector2(12,1),Vector2(13,1)]
#敌人复活的位置	
var enemyRevivePos=[Vector2(0,0),Vector2(12,0),Vector2(24,0)]
#基地旁的方块
var baseBrickPos=[Vector2(11,25),Vector2(11,24),Vector2(11,23),
			Vector2(12,23),Vector2(13,23),Vector2(14,23),
			Vector2(14,25),Vector2(14,24)]
#基地
var basePlacePos=[Vector2(12,25),Vector2(13,25),Vector2(12,24),Vector2(13,24)]				
#基地位置
var basePos=Vector2(12,24)
#方块场景
var brick=preload("res://scene/brick.tscn")
var base=preload("res://scene/base.tscn")
var player=preload("res://scene/player.tscn")
var enemy=preload("res://scene/enemy.tscn")
var currentLevel  #当前场景文件内容
var enemyLogo=preload("res://scene/enemy_Logo.tscn")
var bonus=preload("res://scene/bonus.tscn")


@onready var brickNode=$child/brick
@onready var bulletsNode=$child/bullets
@onready var tanksNode=$child/tanks
@onready var otherNode=$child/other
@onready var enemyList=$gui/enemyList
@onready var levelName=$gui/vbox/name
@onready var p1Num=$gui/p1Num
@onready var p2Num=$gui/p2Num
@onready var p1Count=$gui/p1Num/hbox/Label
@onready var p2Count=$gui/p2Num/hbox/Label



#载入文件
func loadMap(filePath:String):
	var file = FileAccess.open(filePath, FileAccess.READ)
	if file:
		var json=JSON.new()
		#print(file.get_as_text())
		var currentLevel=json.parse_string(file.get_as_text())
		#print(currentLevel)
		file.close()
		for i in currentLevel['data']:
			if int(i['type']) in [0,1,2,3,4]:
				var temp=brick.instantiate()
				temp.position.x=int(i['x'])*cellSize+cellSize/2
				temp.position.y=int(i['y'])*cellSize+cellSize/2
				temp.type=int(i['type'])
#				temp.mapPos=Vector2(int(i['x']),int(i['y']))
				brickNode.add_child(temp)
		#删除玩家复活点和敌人复活点的砖块
		delPlayerPosBrick()
		delEnemyPosBrick()
		
#		delBasePlaceBrick()
		createBase()
	else:
		printerr('file not exists')	
	
	
	
#加载敌人数量
func loadEnemyCount():
	for i in enemyList.get_children():
		i.queue_free()
	for i in range(enemyCount):
		var temp=enemyLogo.instantiate()
		enemyList.add_child(temp)


#移除排在最后一个敌人图标
func removeEnemyLogo():
	var e=enemyList.get_children()	
	if e.size()>0:
		enemyList.remove_child(e.pop_back())
	
#删除玩家复活点方块	
func delPlayerPosBrick():
	for i in player1:
		var temp=getBrick(i.x,i.y)
		if temp:
			temp.queue_free()
	for i in player2:
		var temp=getBrick(i.x,i.y)
		if temp:
			temp.queue_free()

#改变砖块类型
func changeBasePlaceBrickType(type):
	for i in baseBrickPos:
		var b=getBrick(i.x,i.y)
		if b:
			b.changeType(type)
		else:
			var temp=brick.instantiate()
			temp.type=type
			temp.position=i*cellSize+Vector2(cellSize/2,cellSize/2)
			brickNode.add_child(temp)

func setEnemyFreeze(flag=true):
	for i in tanksNode.get_children():
		if i.get('objType')==Game.objType.ENEMY:
			i.setFreeze(flag)

func setPlayerFreeze(flag=true):
	for i in tanksNode.get_children():
		if i.get('objType')==Game.objType.PLAYER:
			i.setFreeze(flag)

#创建基地	
func createBase():
	var temp=base.instantiate()
	temp.position=Vector2(basePos.x*cellSize+cellSize,basePos.y*cellSize+cellSize)
	otherNode.add_child(temp)		

#获取地图中的砖块 x [0-25] y[0-25]
func getBrick(x:int,y:int):
	var temp=null
	for i in brickNode.get_children():
		if round((i.position.y-cellSize/2)/cellSize)==y\
			&&round((i.position.x-cellSize/2)/cellSize)==x:
			temp=i
			break
	return temp

#添加玩家
func addPlayer(playNo:int,data:Dictionary={},isFreeze=false):
	var temp=player.instantiate()
	if playNo==1:
		temp.playerId=Game.playerId.p1
		temp.position=Vector2(9*cellSize,25*cellSize)
	elif playNo==2:
		temp.playerId=Game.playerId.p2
		temp.position=Vector2(17*cellSize,25*cellSize)
	if !data.is_empty():
		temp.hasShip=data['hasShip']
		temp.level=data['level']
		temp.armour=data['armour']
		if data['level'] in [Game.level.MEDIUM]:
			temp.bulletPower=Game.bulletPower.FAST
		elif data['level'] in [Game.level.SUPER,Game.level.LARGE]:
			temp.bulletMax=2
			if data['level']==Game.level.SUPER:
				temp.bulletPower=Game.bulletPower.SUPER
			else:
				temp.bulletPower=Game.bulletPower.FAST
			
	tanksNode.call_deferred('add_child',temp)
	if isFreeze:
		temp.call_deferred('setFreeze',true)
						
#删除敌人出生点方块
func delEnemyPosBrick():
	for i in enemyPos:
		var brick=getBrick(i.x,i.y)
		if brick:
			brick.queue_free()
	
#删除基地周边的方块	
func delBasePlaceBrick():
	for i in baseBrickPos:
		var temp=getBrick(i.x,i.y)
		if temp:
			temp.queue_free()

#添加基地周边石头
func addBasePlaceStone():
	for i in baseBrickPos:
		var temp=brick.instantiate()
		temp.type=Game.brickType.STONE
		temp.position=i*cellSize+Vector2(cellSize/2,cellSize/2)
#		brickNode.add_child(temp)
		brickNode.call_deferred('add_child',temp)

#添加子弹
func addBullet(obj):
	bulletsNode.add_child(obj)

#添加其他对象
func addOther(obj):
	otherNode.add_child(obj)

func setP1LiveNum(num):
	p1Num.visible=true
	p1LiveNum=num
	p1Count.text=str(num)

	
func setP2LiveNum(num):
	p2Num.visible=true
	p2LiveNUm=num
	p2Count.text=str(num)


func setLevelName(name):
	levelName.text='%d'%name
				
#获取敌人总数
func getEnemyCount():
	var num=0;
	for i in tanksNode.get_children():
		if i.get('objType')==Game.objType.ENEMY:
			num+=1
	return num	
	
#添加敌人
func addEnemy(isFreeze=false):
	var temp=enemy.instantiate()
	temp.position=enemyRevivePos[randi()%3]*cellSize+Vector2(temp.tankSize/2,temp.tankSize/2)
	var types=[Game.enemyType.TYPEA,Game.enemyType.TYPEB,
				Game.enemyType.TYPEC,Game.enemyType.TYPED]
	temp.type=types[randi()%4]
	tanksNode.add_child(temp)
	if isFreeze:
		temp.setFreeze()
	removeEnemyLogo()
	enemyCount-=1
	
#添加物品 物品不在基地附近和玩家当前附近
func addBonus():
	for i in otherNode.get_children():
		if i.get('objType')==Game.objType.BONUS:
			otherNode.remove_child(i)
	var playerPos=[]
	for i in tanksNode.get_children():
		if i.get('objType')	==Game.objType.PLAYER:
			var p=Vector2(round(i.position.x/16),round(i.position.y/16))
			playerPos.append(p)
			playerPos.append(Vector2(p.x-1,p.y))
			playerPos.append(Vector2(p.x+1,p.y))
			
	#不在基地和玩家附近
	var pos = Vector2(randi()%25+1,randi()%25+1)
	while pos in basePlacePos && pos in playerPos:
		pos = Vector2(randi()%25+1,randi()%25+1)
	var temp=bonus.instantiate()
	temp.position=pos*cellSize
	temp.setRandomType()
	otherNode.call_deferred('add_child',temp)
	
#获取玩家数据
func getPlayerStatus():
	var temp={'p1':{
		'level':0,
		'armour':0,
		'hasShip':false
	},
	'p2':{
		'level':0,
		'armour':0,
		'hasShip':false
	}}
	for i in tanksNode.get_children():
		if i.objType==Game.objType.PLAYER:
			if i.playerId==Game.playerId.p1:
				temp['p1']['level']=i.level
				temp['p1']['armour']=i.armour
				temp['p1']['hasShip']=i.hasShip
			elif i.playerId==Game.playerId.p2:
				temp['p2']['level']=i.level
				temp['p2']['armour']=i.armour
				temp['p2']['hasShip']=i.hasShip
	return temp
	
#获取玩家
func getPlayer(id):
	var tank
	for i in tanksNode.get_children():
		if i.get('objType')==Game.objType.PLAYER && i.get('playerId')==id:
			tank=i
			break
	return tank
	
#清空敌人坦克
func clearEnemyTank()->Dictionary:
	var list={'typeA':0,'typeB':0,'typeC':0,'typeD':0}
	for i in tanksNode.get_children():
		if i.get('objType')==Game.objType.ENEMY&&i.get('state')!=Game.tankstate.IDLE:
			var type=i.get('type')
			if type==Game.enemyType.TYPEA:
				list['typeA']+=1
			elif type==	Game.enemyType.TYPEB:
				list['typeB']+=1
			elif type==	Game.enemyType.TYPEC:
				list['typeC']+=1
			elif type==Game.enemyType.TYPED:
				list['typeD']+=1
			i.setExplosion()	
	return list

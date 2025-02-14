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
var enemyLogo=preload("res://scene/enemyLogo.tscn")
var bonus=preload("res://scene/bonus.tscn")
onready var brickNode=$child/brick
onready var bulletsNode=$child/bullets
onready var tanksNode=$child/tanks
onready var otherNode=$child/other
onready var enemyList=$gui/enemyList
onready var levelName=$gui/vbox/name
onready var p1NUm=$gui/p1NUm
onready var p2Num=$gui/p2Num
onready var p1Count=$gui/p1NUm/hbox/Label
onready var p2Count=$gui/p2Num/hbox/Label

func _ready():
	pass # Replace with function body.

#载入文件
func loadMap(filePath:String):
	var file = File.new()
	if file.file_exists(filePath):
		file.open(filePath, File.READ)
		currentLevel=parse_json(file.get_as_text())
		file.close()
		for i in currentLevel['data']:
			if i['type'] in [0,1,2,3,4]:
				var temp=brick.instance()
				temp.position.x=i['x']*cellSize+cellSize/2
				temp.position.y=i['y']*cellSize+cellSize/2
				temp.type=i['type']
				temp.mapPos=Vector2(int(i['x']),int(i['y']))
				brickNode.add_child(temp)
		#删除玩家复活点和敌人复活点的砖块
		delPlayerPosBrick()
		delBasePlaceBrick()
		createBase()
	else:
		printerr('file not exists')

#加载敌人数量
func loadEnemyCount():
	for i in enemyList.get_children():
		i.queue_free()
	for i in range(enemyCount):
		var temp=enemyLogo.instance()
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
	
#删除基地周边的方块	
func delBasePlaceBrick():
	for i in basePlacePos:
		var temp=getBrick(i.x,i.y)
		if temp:
			temp.queue_free()


#创建基地	
func createBase():
	var temp=base.instance()
	temp.position=Vector2(basePos.x*cellSize+cellSize,basePos.y*cellSize+cellSize)
	otherNode.add_child(temp)		

#获取地图中的砖块 x [0-25] y[0-25]
func getBrick(x:int,y:int):
	var temp=null
	for i in brickNode.get_children():
		if i.mapPos.x==x&&i.mapPos.y==y:
			temp=i
			break
	return temp

#添加玩家
func addPlayer(playNo:int):
	if playNo==1:
		var temp=player.instance()
		temp.position=Vector2(9*cellSize,25*cellSize)
		tanksNode.add_child(temp)

#添加子弹
func addBullet(obj):
	bulletsNode.add_child(obj)

#添加其他对象
func addOther(obj):
	otherNode.add_child(obj)

func setP1LiveNum(num):
	p1LiveNum=num
	p1Count.text=str(num)
	
func setP2LiveNum(num):
	p2LiveNUm=num
	p2Count.text=str(num)

#获取敌人总数
func getEnemyCount():
	var num=0;
	for i in tanksNode.get_children():
		if i.get('objType')==Game.objType.ENEMY:
			num+=1
	return num		

#添加敌人
func addEnemy(isFreeze=false):
	var temp=enemy.instance()
	temp.position=enemyRevivePos[randi()%3]*cellSize+Vector2(temp.tankSize/2,temp.tankSize/2)
	var types=[Game.enemyType.TYPEA,Game.enemyType.TYPEB,
				Game.enemyType.TYPEC,Game.enemyType.TYPED]
	temp.type=types[randi()%4]
	tanksNode.add_child(temp)
	removeEnemyLogo()
	enemyCount-=1

#添加物品 物品不在基地附近和玩家当前附近
func addBonus():
	
	pass

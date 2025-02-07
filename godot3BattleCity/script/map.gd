extends Node2D


const cellSize=16	#每个格子的大小是16px
var mapSize=Vector2(cellSize*26,cellSize*26)

onready var brickNode=$child/brick
onready var bulletsNode=$child/bullets
onready var tanksNode=$child/tanks
onready var otherNode=$child/other



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
var currentLevel  #当前场景文件内容


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

#删除玩家复活点方块	
func delPlayerPosBrick():
	for i in player1:
		var brick=getBrick(i.x,i.y)
		if brick:
			brick.queue_free()
	for i in player2:
		var brick=getBrick(i.x,i.y)
		if brick:
			brick.queue_free()
	
#删除基地周边的方块	
func delBasePlaceBrick():
	for i in basePlacePos:
		var brick=getBrick(i.x,i.y)
		if brick:
			brick.queue_free()


#创建基地	
func createBase():
	var temp=base.instance()
	temp.position=Vector2(basePos.x*cellSize+cellSize,basePos.y*cellSize+cellSize)
	otherNode.add_child(temp)		

#获取地图中的砖块 x [0-25] y[0-25]
func getBrick(x:int,y:int):
	var brick=null
	for i in brickNode.get_children():
		if i.mapPos.x==x&&i.mapPos.y==y:
			brick=i
			break
	return brick

#添加玩家
func addPlayer(playNo:int):
	if playNo==1:
		var temp=player.instance()
		temp.position=Vector2(9*cellSize,25*cellSize)
		tanksNode.add_child(temp)

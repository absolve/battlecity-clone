extends Node2D

const mapDir="res://level"	#内置地图路径
onready var map=$map
onready var produceTimer=$produceTimer
var minEnemyCount=20	#最小同屏敌人数量 2人就6个
var scoreLabel=preload("res://scene/scoreLabel.tscn")

func _ready():
	randomize()
	OS.center_window()
	Game.map=map
	map.loadMap(mapDir+"/"+'1.json')
	map.loadEnemyCount()
	map.addPlayer(1)
#	map.addPlayer(2)
	map.removeEnemyLogo()
	
	Game.connect("baseDestroyed",self,"baseDestroyed")
	Game.connect('addBonus',self,'addBonus')
	Game.connect('destroyEnemy',self,'destroyEnemy')
#	produceTimer.start()

#基地爆炸
func baseDestroyed():
	print('baseDestroyed')

#添加物品
func addBonus():
	print('addBonus')

#敌人被摧毁
func destroyEnemy(type,playerId,pos):
	print('destroyEnemy')
	if playerId==Game.playerId.p1:
		if type==Game.enemyType.TYPEA:
			Game.p1Score['typeA']+=1
			Game.p1Data['p1Score']+=100
			addScore(100,pos)
		elif type==Game.enemyType.TYPEB:
			Game.p1Score['typeB']+=1	
			Game.p1Data['p1Score']+=200
			addScore(200,pos)
		elif type==Game.enemyType.TYPEC:
			Game.p1Score['typeC']+=1	
			Game.p1Data['p1Score']+=300
			addScore(300,pos)
		elif type==Game.enemyType.TYPED:
			Game.p1Score['typeD']+=1
			Game.p1Data['p1Score']+=400	
			addScore(400,pos)
	elif playerId==Game.playerId.p2:
		if type==Game.enemyType.TYPEA:
			Game.p2Score['typeA']+=1
			Game.p2Data['p2Score']+=100
			addScore(100,pos)
		elif type==Game.enemyType.TYPEB:
			Game.p2Score['typeB']+=1	
			Game.p2Data['p2Score']+=200
			addScore(200,pos)
		elif type==Game.enemyType.TYPEC:
			Game.p2Score['typeC']+=1	
			Game.p2Data['p2Score']+=300
			addScore(300,pos)
		elif type==Game.enemyType.TYPED:
			Game.p2Score['typeD']+=1	
			Game.p2Data['p2Score']+=400
			addScore(400,pos)

#添加分数
func addScore(s,pos):
	var temp=scoreLabel.instance()
	temp.setScore(s)
	temp.position=pos
	map.addOther(temp)

#保存用户数据
func savePlayerData():
	var temp=map.getPlayerStatus()
	Game.p1Data['level']=temp['p1']['level']
	Game.p1Data['armour']=temp['p1']['armour']
	Game.p1Data['hasShip']=temp['p1']['hasShip']
	Game.p2Data['level']=temp['p2']['level']
	Game.p2Data['armour']=temp['p2']['armour']
	Game.p2Data['hasShip']=temp['p2']['hasShip']
	
func _on_produceTimer_timeout():
	if map.enemyCount>0:
		if map.getEnemyCount()<minEnemyCount:
			map.addEnemy()
	else: #判断是不是所有敌人都消灭了
		if map.getEnemyCount()==0:
			produceTimer.stop()
			#保存玩家数据进入下一关
			savePlayerData()

func _on_nextLevel_timeout():
	Game.changeScene("res://scene/settlement.tscn")


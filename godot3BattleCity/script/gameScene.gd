extends Node2D

const mapDir="res://level"	#内置地图路径
onready var map=$map
onready var produceTimer=$produceTimer
var minEnemyCount=20	#最小同屏敌人数量 2人就6个

func _ready():
	randomize()
	OS.center_window()
	Game.map=map
	map.loadMap(mapDir+"/"+'1.json')
	map.loadEnemyCount()
	map.addPlayer(1)
	map.addPlayer(2)
	map.removeEnemyLogo()
	
	Game.connect("baseDestroyed",self,"baseDestroyed")
	Game.connect('addBonus',self,'addBonus')
	produceTimer.start()

#基地爆炸
func baseDestroyed():
	print('baseDestroyed')

#添加物品
func addBonus():
	print('addBonus')


func _on_produceTimer_timeout():
	if map.enemyCount>0:
		if map.getEnemyCount()<minEnemyCount:
			map.addEnemy()
	else: #判断是不是所有敌人都消灭了
		
		pass


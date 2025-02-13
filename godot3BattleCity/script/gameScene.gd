extends Node2D

const mapDir="res://level"	#内置地图路径
onready var map=$map
onready var produceTimer=$produceTimer
var minEnemyCount=8	#最小同屏敌人数量 2人就6个

func _ready():
	randomize()
	OS.center_window()
	Game.map=map
	map.loadMap(mapDir+"/"+'1.json')
	map.loadEnemyCount()
	map.addPlayer(1)
	map.removeEnemyLogo()
	
	Game.connect("baseDestroyed",self,"baseDestroyed")
	produceTimer.start()

#基地爆炸
func baseDestroyed():
	print('baseDestroyed')
	pass



func _on_produceTimer_timeout():
	if map.enemyCount>0:
		if map.getEnemyCount()<minEnemyCount:
			map.addEnemy()
	else: #判断是不是所有敌人都消灭了
		
		pass


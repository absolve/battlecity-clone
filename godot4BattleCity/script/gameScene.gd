extends Node2D

const mapDir="res://level"	#内置地图路径
var mapExtensionMap=OS.get_executable_path().get_base_dir()+"/level"

@onready var map=$map
@onready var produceTimer=$produceTimer
@onready var nextLevel=$nextLevel
@onready var shovelTimer=$shovelTimer
@onready var clockTimer=$clockTimer
@onready var player=$player

var minEnemyCount=4		#最小同屏敌人数量 2人就6个
var scoreLabel=preload("res://scene/score_label.tscn")
var hasShovel=false #有铲子
var hasClock=false #时钟
var state=Game.gameState.IDLE
var changeBrickTime=0
var changeBrickDelay=30
var brickType=Game.brickType.WALL
var gameOver=false
var autoHideLabel=preload("res://scene/auto_hide_label.tscn")

func _ready():
	randomize()
	Game.map=map
	map.loadMap(mapDir+"/"+Game.mapList[Game.gameLevel])
	map.loadEnemyCount()
	map.setLevelName(Game.gameLevel+1)
	if Game.p1Data['lives']>=0:  #坦克数量为0表示最后一辆，小于0就是没有了
		map.addPlayer(1,Game.p1Data)
		map.setP1LiveNum(Game.p1Data.lives)
	
	if Game.mode==Game.gameMode.DOUBLE:
		if Game.p2Data['lives']>=0:
			map.addPlayer(2,Game.p2Data)
			minEnemyCount=8
		map.setP2LiveNum(Game.p2Data.lives)
	
	Game.baseDestroyed.connect(baseDestroyed)
	Game.addBonus.connect(addBonus)
	Game.destroyEnemy.connect(destroyEnemy)
	Game.hitPlayer.connect(hitPlayer)
	Game.getBonus.connect(getBonus)
	Game.resetPlayerScore() #重新设置分数
	produceTimer.start()
	state=Game.gameState.START


#基地爆炸
func baseDestroyed():
	print('baseDestroyed')
	if !gameOver:
		_gameOver()
	
#添加物品
func addBonus():
	print('addBonus')
	SoundsUtil.playBouns()
	map.addBonus()

#敌人被摧毁
func destroyEnemy(type,playerId,pos):
	print('destroyEnemy')
	if playerId==Game.playerId.p1:
		if type==Game.enemyType.TYPEA:
			Game.p1Score['typeA']+=1
			Game.p1Data['score']+=100
			addScore(100,pos)
		elif type==Game.enemyType.TYPEB:
			Game.p1Score['typeB']+=1	
			Game.p1Data['score']+=200
			addScore(200,pos)
		elif type==Game.enemyType.TYPEC:
			Game.p1Score['typeC']+=1	
			Game.p1Data['score']+=300
			addScore(300,pos)
		elif type==Game.enemyType.TYPED:
			Game.p1Score['typeD']+=1
			Game.p1Data['score']+=400	
			addScore(400,pos)
	elif playerId==Game.playerId.p2:
		if type==Game.enemyType.TYPEA:
			Game.p2Score['typeA']+=1
			Game.p2Data['score']+=100
			addScore(100,pos)
		elif type==Game.enemyType.TYPEB:
			Game.p2Score['typeB']+=1	
			Game.p2Data['score']+=200
			addScore(200,pos)
		elif type==Game.enemyType.TYPEC:
			Game.p2Score['typeC']+=1	
			Game.p2Data['score']+=300
			addScore(300,pos)
		elif type==Game.enemyType.TYPED:
			Game.p2Score['typeD']+=1	
			Game.p2Data['score']+=400
			addScore(400,pos)
			
#玩家被摧毁
func hitPlayer(playerId):
	print('hitPlayer',playerId)	
	#如果玩家生命都为0，游戏结束
#	if gameOver:
#		return			
	if playerId==Game.playerId.p1:
		Game.p1Data.lives-=1
		if Game.p1Data.lives>=0:
			#只有生命数大于0的时候才可以添加新坦克
			map.addPlayer(1,{},gameOver)
			map.setP1LiveNum(Game.p1Data.lives)
	elif playerId==Game.playerId.p2:
		Game.p2Data.lives-=1
		if Game.p2Data.lives>=0:	
			map.addPlayer(2,{},gameOver)
			map.setP2LiveNum(Game.p2Data.lives)		
			
	if Game.mode==Game.gameMode.SINGLE:
		if Game.p1Data.lives<0:
			_gameOver()
	elif Game.mode==Game.gameMode.DOUBLE:
		if Game.p1Data.lives<0&&Game.p2Data.lives<0:
			_gameOver()
		if playerId==Game.playerId.p1&&Game.p1Data.lives<0:
			addPlayerGameOverLabel(playerId)
		if playerId==Game.playerId.p2&&	Game.p2Data.lives<0:
			addPlayerGameOverLabel(playerId)	
			
#添加分数
func addScore(s,pos):
	var temp=scoreLabel.instantiate()
	map.addOther(temp)
	temp.setScore(s)
	temp.position=pos+Vector2(-14,-14)
	

#保存用户数据
func savePlayerData():
	var temp=map.getPlayerStatus()
	Game.p1Data['level']=temp['p1']['level']
	Game.p1Data['armour']=temp['p1']['armour']
	Game.p1Data['hasShip']=temp['p1']['hasShip']
	Game.p2Data['level']=temp['p2']['level']
	Game.p2Data['armour']=temp['p2']['armour']
	Game.p2Data['hasShip']=temp['p2']['hasShip']			
						
#获取物品
func getBonus(type,objType,playerId):
	print(type,objType,playerId)
	if playerId==Game.playerId.p1:
		Game.p1Data['score']+=500
	elif playerId==Game.playerId.p2:
		Game.p2Data['score']+=500
	var tank=map.getPlayer(playerId)
	if !tank:
		return
		
	addScore(500,tank.position)
	if type==Game.bonusType.GRENADE:
		var list=map.clearEnemyTank()
		if playerId==Game.playerId.p1:
			Game.p1Score['typeA']+=list['typeA']
			Game.p1Score['typeB']+=list['typeB']
			Game.p1Score['typeC']+=list['typeC']
			Game.p1Score['typeD']+=list['typeD']
		elif playerId==Game.playerId.p2:
			Game.p2Score['typeA']+=list['typeA']
			Game.p2Score['typeB']+=list['typeB']
			Game.p2Score['typeC']+=list['typeC']
			Game.p2Score['typeD']+=list['typeD']	
	elif type==Game.bonusType.TANK:
		if playerId==Game.playerId.p1:
			Game.p1Data.lives+=1
			map.setP1LiveNum(Game.p1Data.lives)
		elif playerId==Game.playerId.p2:
			Game.p2Data.lives+=1
			map.setP2LiveNum(Game.p2Data.lives)
	
	elif type==Game.bonusType.HELMET:
		tank.startinvincible()
	elif type==Game.bonusType.BOAT:
		tank.setShip(true)
	elif type==Game.bonusType.STAR:
		tank.upgrade()
	elif type==Game.bonusType.GUN:
		tank.upgrade2Max()
	elif type==Game.bonusType.CLOCK:
		hasClock=true
		clockTimer.start()
		map.setEnemyFreeze()
	elif type==Game.bonusType.SHOVEL:
		hasShovel=true
		shovelTimer.start()
		map.delBasePlaceBrick()
		map.addBasePlaceStone()
			
	if type==Game.bonusType.TANK:	
		SoundsUtil.playAddLives()
	elif type==Game.bonusType.GRENADE:
		SoundsUtil.playBomb()
	else:
		SoundsUtil.playGetBouns()				

#游戏结束
func _gameOver():
	gameOver=true
	map.setPlayerFreeze()
	player.play("gameover")

	await player.animation_finished
	#yield(player,"animation_finished")
	nextLevel.start()

#添加一个标志			
func addPlayerGameOverLabel(id):
	var temp=autoHideLabel.instantiate()
	add_child(temp)
	if id==Game.playerId.p1:
		temp.rect_position=map.player1[0]*map.cellSize
	elif id==Game.playerId.p2:
		temp.rect_position=map.player2[0]*map.cellSize	
	
	
	
func _physics_process(delta):
	if state==Game.gameState.START:
		if hasShovel:
			if shovelTimer.get_time_left()<=5:
				changeBrickTime+=1
				if changeBrickTime>changeBrickDelay:
					changeBrickTime=0
					map.changeBasePlaceBrickType(brickType)
					if brickType==Game.brickType.WALL:
						brickType=Game.brickType.STONE
					else:
						brickType=Game.brickType.WALL	
						
						
							


func _on_produce_timer_timeout():
	if map.enemyCount>0:
		if map.getEnemyCount()<minEnemyCount:
			if hasClock:
				map.addEnemy(true)
			else:	
				map.addEnemy()
	else: #判断是不是所有敌人都消灭了
		if map.getEnemyCount()==0:
			produceTimer.stop()
			#保存玩家数据进入下一关
			savePlayerData()
			nextLevel.start()


func _on_next_level_timeout():
	var temp=load("res://scene/settlement.tscn")
	var scene=temp.instantiate()
	if gameOver:
		scene.isGameOver=gameOver
	get_tree().root.add_child(scene)
	get_tree().current_scene=scene
	queue_free()	


func _on_shovel_timer_timeout():
	hasShovel=false
	map.changeBasePlaceBrickType(Game.brickType.WALL)
	changeBrickTime=0
	brickType=Game.brickType.WALL


func _on_clock_timer_timeout():
	map.setEnemyFreeze(false)
	hasClock=false

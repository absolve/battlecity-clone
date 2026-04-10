extends Node2D

# 地图路径常量
const mapDir="res://level"	# 内置地图路径
var mapExtensionMap=OS.get_executable_path().get_base_dir()+"/level"  # 外部地图路径

# 节点引用
onready var map=$map  # 地图节点
onready var produceTimer=$produceTimer  # 敌人生成计时器
onready var nextLevel=$nextLevel  # 进入下一关计时器
onready var shovelTimer=$shovelTimer  # 铲子效果计时器
onready var clockTimer=$clockTimer  # 时钟效果计时器
onready var player=$player  # 玩家节点

# 游戏变量
var minEnemyCount=4  # 最小同屏敌人数量（双人模式为8个）
var scoreLabel=preload("res://scene/scoreLabel.tscn")  # 分数显示预制体
var hasShovel=false  # 是否获得铲子道具
var hasClock=false  # 是否获得时钟道具
var state=Game.gameState.IDLE  # 游戏状态
var changeBrickTime=0  # 基地砖块变化计时器
var changeBrickDelay=30  # 基地砖块变化延迟
var brickType=Game.brickType.WALL  # 砖块类型
var gameOver=false  # 游戏是否结束
var autoHideLabel=preload("res://scene/autoHideLabel.tscn")  # 自动隐藏标签预制体

# 游戏初始化
func _ready():
	randomize()  # 随机数初始化
	Game.map=map  # 设置全局地图引用
	map.loadMap(mapDir+"/"+Game.mapList[Game.gameLevel])  # 加载当前关卡地图
	# map.loadMap(mapDir+"/"+'1992.json')  # 测试特定地图
	map.loadEnemyCount()  # 加载敌人数量
	map.setLevelName(Game.gameLevel+1)  # 设置关卡名称
	# Game.mode=Game.gameMode.DOUBLE  # 测试双人模式
	
	# 添加玩家1
	if Game.p1Data['lives']>=0:  # 坦克数量为0表示最后一辆，小于0就是没有了
		map.addPlayer(1,Game.p1Data)  # 添加玩家1坦克
		map.setP1LiveNum(Game.p1Data.lives)  # 设置玩家1生命数
	
	# 添加玩家2（双人模式）
	if Game.mode==Game.gameMode.DOUBLE:
		if Game.p2Data['lives']>=0:
			map.addPlayer(2,Game.p2Data)  # 添加玩家2坦克
			minEnemyCount=8  # 双人模式增加敌人数量
		map.setP2LiveNum(Game.p2Data.lives)  # 设置玩家2生命数
		
	# 连接信号
	Game.connect("baseDestroyed",self,"baseDestroyed")  # 基地被摧毁信号
	Game.connect('addBonus',self,'addBonus')  # 添加道具信号
	Game.connect('destroyEnemy',self,'destroyEnemy')  # 敌人被摧毁信号
	Game.connect('hitPlayer',self,'hitPlayer')  # 玩家被击中信号
	Game.connect("getBonus",self,'getBonus')  # 获得道具信号
	Game.resetPlayerScore()  # 重新设置分数
	
	# 开始游戏
	produceTimer.start()  # 启动敌人生成计时器
	state=Game.gameState.START  # 设置游戏状态为开始

# 基地被摧毁处理
func baseDestroyed():
	print('baseDestroyed')  # 调试信息
	if !gameOver:  # 如果游戏未结束
		gameOver()  # 调用游戏结束函数
	
# 添加道具处理
func addBonus():
	print('addBonus')  # 调试信息
	SoundsUtil.playBouns()  # 播放道具出现音效
	map.addBonus()  # 地图添加道具

# 敌人被摧毁处理
func destroyEnemy(type,playerId,pos):
	print('destroyEnemy')  # 调试信息
	
	# 根据玩家ID和敌人类型增加分数
	if playerId==Game.playerId.p1:
		if type==Game.enemyType.TYPEA:
			Game.p1Score['typeA']+=1  # 增加A型敌人击杀数
			Game.p1Data['score']+=100  # 增加分数
			addScore(100,pos)  # 显示分数
		elif type==Game.enemyType.TYPEB:
			Game.p1Score['typeB']+=1  # 增加B型敌人击杀数	
			Game.p1Data['score']+=200  # 增加分数
			addScore(200,pos)  # 显示分数
		elif type==Game.enemyType.TYPEC:
			Game.p1Score['typeC']+=1  # 增加C型敌人击杀数	
			Game.p1Data['score']+=300  # 增加分数
			addScore(300,pos)  # 显示分数
		elif type==Game.enemyType.TYPED:
			Game.p1Score['typeD']+=1  # 增加D型敌人击杀数
			Game.p1Data['score']+=400  # 增加分数	
			addScore(400,pos)  # 显示分数
	elif playerId==Game.playerId.p2:
		if type==Game.enemyType.TYPEA:
			Game.p2Score['typeA']+=1  # 增加A型敌人击杀数
			Game.p2Data['score']+=100  # 增加分数
			addScore(100,pos)  # 显示分数
		elif type==Game.enemyType.TYPEB:
			Game.p2Score['typeB']+=1  # 增加B型敌人击杀数	
			Game.p2Data['score']+=200  # 增加分数
			addScore(200,pos)  # 显示分数
		elif type==Game.enemyType.TYPEC:
			Game.p2Score['typeC']+=1  # 增加C型敌人击杀数	
			Game.p2Data['score']+=300  # 增加分数
			addScore(300,pos)  # 显示分数
		elif type==Game.enemyType.TYPED:
			Game.p2Score['typeD']+=1  # 增加D型敌人击杀数	
			Game.p2Data['score']+=400  # 增加分数
			addScore(400,pos)  # 显示分数

# 玩家被击中处理
func hitPlayer(playerId):
	print('hitPlayer',playerId)  # 调试信息	
	# 如果玩家生命都为0，游戏结束
	# if gameOver:
	# 	return		
	
	if playerId==Game.playerId.p1:
		Game.p1Data.lives-=1  # 减少玩家1生命
		if Game.p1Data.lives>=0:
			# 只有生命数大于0的时候才可以添加新坦克
			map.addPlayer(1,{},gameOver)  # 添加新的玩家1坦克
			map.setP1LiveNum(Game.p1Data.lives)  # 更新玩家1生命显示
	elif playerId==Game.playerId.p2:
		Game.p2Data.lives-=1  # 减少玩家2生命
		if Game.p2Data.lives>=0:	
			map.addPlayer(2,{},gameOver)  # 添加新的玩家2坦克
			map.setP2LiveNum(Game.p2Data.lives)  # 更新玩家2生命显示		
		
	# 检查游戏是否结束
	if Game.mode==Game.gameMode.SINGLE:
		if Game.p1Data.lives<0:
			gameOver()  # 单人模式下玩家1生命耗尽，游戏结束
	elif Game.mode==Game.gameMode.DOUBLE:
		if Game.p1Data.lives<0&&Game.p2Data.lives<0:
			gameOver()  # 双人模式下所有玩家生命耗尽，游戏结束
		if playerId==Game.playerId.p1&&Game.p1Data.lives<0:
			addPlayerGameOverLabel(playerId)  # 显示玩家1游戏结束标签
		if playerId==Game.playerId.p2&&Game.p2Data.lives<0:
			addPlayerGameOverLabel(playerId)  # 显示玩家2游戏结束标签	
		
		
				
# 添加分数显示
func addScore(s,pos):
	var temp=scoreLabel.instance()  # 实例化分数显示
	map.addOther(temp)  # 添加到地图
	temp.setScore(s)  # 设置分数值
	temp.position=pos+Vector2(-14,-14)  # 设置分数显示位置
	

# 保存用户数据
func savePlayerData():
	var temp=map.getPlayerStatus()  # 获取玩家状态
	# 保存玩家1数据
	Game.p1Data['level']=temp['p1']['level']  # 坦克等级
	Game.p1Data['armour']=temp['p1']['armour']  # 坦克装甲
	Game.p1Data['hasShip']=temp['p1']['hasShip']  # 是否有船
	# 保存玩家2数据
	Game.p2Data['level']=temp['p2']['level']  # 坦克等级
	Game.p2Data['armour']=temp['p2']['armour']  # 坦克装甲
	Game.p2Data['hasShip']=temp['p2']['hasShip']  # 是否有船

# 获取道具处理
func getBonus(type,objType,playerId):
	print(type,objType,playerId)  # 调试信息
	
	# 增加分数
	if playerId==Game.playerId.p1:
		Game.p1Data['score']+=500  # 玩家1增加分数
	elif playerId==Game.playerId.p2:
		Game.p2Data['score']+=500  # 玩家2增加分数
	
	var tank=map.getPlayer(playerId)  # 获取玩家坦克
	if !tank:
		return  # 如果坦克不存在，返回
		
	addScore(500,tank.position)  # 显示分数
	
	# 根据道具类型执行不同效果
	if type==Game.bonusType.GRENADE:  # 手榴弹
		var list=map.clearEnemyTank()  # 清除所有敌人坦克
		# 增加敌人击杀数
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
	elif type==Game.bonusType.TANK:  # 坦克（增加生命）
		if playerId==Game.playerId.p1:
			Game.p1Data.lives+=1  # 玩家1增加生命
			map.setP1LiveNum(Game.p1Data.lives)  # 更新生命显示
		elif playerId==Game.playerId.p2:
			Game.p2Data.lives+=1  # 玩家2增加生命
			map.setP2LiveNum(Game.p2Data.lives)  # 更新生命显示
	
	elif type==Game.bonusType.HELMET:  # 头盔（无敌）
		tank.startinvincible()  # 启动无敌模式
	elif type==Game.bonusType.BOAT:  # 船（可以在水上行驶）
		tank.setShip(true)  # 设置坦克可以在水上行驶
	elif type==Game.bonusType.STAR:  # 星星（升级坦克）
		tank.upgrade()  # 升级坦克
	elif type==Game.bonusType.GUN:  # 枪（直接升级到最高级）
		tank.upgrade2Max()  # 直接升级到最高级
	elif type==Game.bonusType.CLOCK:  # 时钟（冻结敌人）
		hasClock=true  # 设置时钟效果
		clockTimer.start()  # 启动时钟计时器
		map.setEnemyFreeze()  # 冻结敌人
	elif type==Game.bonusType.SHOVEL:  # 铲子（基地防护）
		hasShovel=true  # 设置铲子效果
		shovelTimer.start()  # 启动铲子计时器
		map.delBasePlaceBrick()  # 移除基地周围的砖块
		map.addBasePlaceStone()  # 添加基地周围的石头
		
	# 播放相应音效
	if type==Game.bonusType.TANK:	
		SoundsUtil.playAddLives()  # 播放增加生命音效
	elif type==Game.bonusType.GRENADE:
		SoundsUtil.playBomb()  # 播放爆炸音效
	else:
		SoundsUtil.playGetBouns()  # 播放获得道具音效		

# 游戏结束处理
func gameOver():
	gameOver=true  # 设置游戏结束标志
	map.setPlayerFreeze()  # 冻结玩家
	player.play("gameover")  # 播放游戏结束动画
	yield(player,"animation_finished")  # 等待动画结束
	nextLevel.start()  # 启动进入下一关计时器

# 添加玩家游戏结束标签		
func addPlayerGameOverLabel(id):
	var temp=autoHideLabel.instance()  # 实例化自动隐藏标签
	# 设置标签位置
	if id==Game.playerId.p1:
		temp.rect_position=map.player1[0]*map.cellSize  # 玩家1出生点
	elif id==Game.playerId.p2:
		temp.rect_position=map.player2[0]*map.cellSize  # 玩家2出生点	
	add_child(temp)  # 添加标签到场景
				
		
# 物理过程处理
func _physics_process(delta):
	if state==Game.gameState.START:  # 如果游戏已开始
		if hasShovel:  # 如果有铲子效果
			if shovelTimer.get_time_left()<=5:  # 铲子效果即将结束
				changeBrickTime+=1  # 增加砖块变化计时器
				if changeBrickTime>changeBrickDelay:  # 达到变化延迟
					changeBrickTime=0  # 重置计时器
					map.changeBasePlaceBrickType(brickType)  # 改变基地周围砖块类型
					# 切换砖块类型
					if brickType==Game.brickType.WALL:
						brickType=Game.brickType.STONE
					else:
						brickType=Game.brickType.WALL		

# 敌人生成计时器超时处理
func _on_produceTimer_timeout():
	if map.enemyCount>0:  # 如果还有敌人需要生成
		if map.getEnemyCount()<minEnemyCount:  # 如果当前敌人数量小于最小数量
			if hasClock:  # 如果有时钟效果
				map.addEnemy(true)  # 生成冻结状态的敌人
			else:	
				map.addEnemy()  # 生成普通敌人
	else:  # 判断是不是所有敌人都消灭了
		if map.getEnemyCount()==0:  # 如果所有敌人都被消灭
			produceTimer.stop()  # 停止敌人生成计时器
			# 保存玩家数据进入下一关
			savePlayerData()  # 保存玩家数据
			nextLevel.start()  # 启动进入下一关计时器

# 进入下一关计时器超时处理
func _on_nextLevel_timeout():
	var temp=load("res://scene/settlement.tscn")  # 加载结算场景
	var scene=temp.instance()  # 实例化结算场景
	if gameOver:
		scene.isGameOver=gameOver  # 设置游戏结束标志
	get_tree().root.add_child(scene)  # 添加结算场景到根节点
	get_tree().current_scene=scene  # 设置当前场景为结算场景
	queue_free()  # 释放当前场景

# 铲子计时器超时处理
func _on_shovelTimer_timeout():
	hasShovel=false  # 取消铲子效果
	map.changeBasePlaceBrickType(Game.brickType.WALL)  # 恢复基地周围为普通砖块
	changeBrickTime=0  # 重置砖块变化计时器
	brickType=Game.brickType.WALL  # 重置砖块类型
	
# 时钟计时器超时处理
func _on_clockTimer_timeout():
	map.setEnemyFreeze(false)  # 取消敌人冻结
	hasClock=false  # 取消时钟效果

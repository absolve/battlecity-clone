extends Node2D

# 地图相关常量
const cellSize=16  # 每个格子的大小是16px
var mapSize=Vector2(cellSize*26,cellSize*26)  # 地图大小
var enemyCount=20  # 敌人总数
var p1LiveNum=2  # 玩家1生命数
var p2LiveNUm=2  # 玩家2生命数

# 玩家出生位置
var player1 = [Vector2(8,25),Vector2(9,25),Vector2(8,24),Vector2(9,24)]  # 玩家1出生点
var player2 =[Vector2(16,25),Vector2(17,25),Vector2(16,24),Vector2(17,24)]  # 玩家2出生点

# 敌人出生位置
var enemyPos=[Vector2(0,0),Vector2(0,1),Vector2(1,0),Vector2(1,1),
	Vector2(24,0),Vector2(25,0),Vector2(24,1),Vector2(24,2),
	Vector2(12,0),Vector2(13,0),Vector2(12,1),Vector2(13,1)]
# 敌人复活的位置	
var enemyRevivePos=[Vector2(0,0),Vector2(12,0),Vector2(24,0)]

# 基地旁的方块位置
var baseBrickPos=[Vector2(11,25),Vector2(11,24),Vector2(11,23),
			Vector2(12,23),Vector2(13,23),Vector2(14,23),
			Vector2(14,25),Vector2(14,24)]

# 基地位置
var basePlacePos=[Vector2(12,25),Vector2(13,25),Vector2(12,24),Vector2(13,24)]				
var basePos=Vector2(12,24)  # 基地中心位置

# 场景预制体
var brick=preload("res://scene/brick.tscn")  # 砖块预制体
var base=preload("res://scene/base.tscn")  # 基地预制体
var player=preload("res://scene/player.tscn")  # 玩家预制体
var enemy=preload("res://scene/enemy.tscn")  # 敌人预制体
var enemyLogo=preload("res://scene/enemy_Logo.tscn")  # 敌人图标预制体
var bonus=preload("res://scene/bonus.tscn")  # 道具预制体

var currentLevel  # 当前场景文件内容

# 节点引用（Godot 4 使用 @onready）
@onready var brickNode=$child/brick  # 砖块节点
@onready var bulletsNode=$child/bullets  # 子弹节点
@onready var tanksNode=$child/tanks  # 坦克节点
@onready var otherNode=$child/other  # 其他对象节点
@onready var enemyList=$gui/enemyList  # 敌人列表UI
@onready var levelName=$gui/vbox/name  # 关卡名称UI
@onready var p1Num=$gui/p1Num  # 玩家1生命UI
@onready var p2Num=$gui/p2Num  # 玩家2生命UI
@onready var p1Count=$gui/p1Num/hbox/Label  # 玩家1生命数标签
@onready var p2Count=$gui/p2Num/hbox/Label  # 玩家2生命数标签


# 载入地图文件
func loadMap(filePath:String):
	# Godot 4 使用 FileAccess.open() 替代 File.new().open()
	var file = FileAccess.open(filePath, FileAccess.READ)
	if file:
		var json=JSON.new()
		var currentLevel=json.parse_string(file.get_as_text())  # Godot 4 使用 .parse_string() 替代 .parse()
		file.close()
		
		# 加载地图砖块
		for i in currentLevel['data']:
			if int(i['type']) in [0,1,2,3,4]:  # 只加载有效的砖块类型
				var temp=brick.instantiate()  # Godot 4 使用 .instantiate() 替代 .instance()
				temp.position.x=int(i['x'])*cellSize+cellSize/2  # 设置砖块x坐标
				temp.position.y=int(i['y'])*cellSize+cellSize/2  # 设置砖块y坐标
				temp.type=int(i['type'])  # 设置砖块类型
				brickNode.add_child(temp)  # 添加到砖块节点
		
		# 删除玩家复活点和敌人复活点的砖块
		delPlayerPosBrick()  # 删除玩家出生点砖块
		delEnemyPosBrick()  # 删除敌人出生点砖块
		
		# 创建基地
		createBase()
	else:
		printerr('file not exists')  # 文件不存在错误	
	
	
	
# 加载敌人数量显示
func loadEnemyCount():
	# 清除旧的敌人图标
	for i in enemyList.get_children():
		i.queue_free()
	
	# 创建新的敌人图标
	for i in range(enemyCount):
		var temp=enemyLogo.instantiate()  # Godot 4 使用 .instantiate()
		enemyList.add_child(temp)


# 移除排在最后一个敌人图标
func removeEnemyLogo():
	var e=enemyList.get_children()  # 获取所有敌人图标	
	if e.size()>0:
		enemyList.remove_child(e.pop_back())  # 移除最后一个图标
	
# 删除玩家复活点方块	
func delPlayerPosBrick():
	# 删除玩家1出生点砖块
	for i in player1:
		var temp=getBrick(i.x,i.y)  # 获取砖块
		if temp:
			temp.queue_free()  # 释放砖块
	
	# 删除玩家2出生点砖块
	for i in player2:
		var temp=getBrick(i.x,i.y)  # 获取砖块
		if temp:
			temp.queue_free()  # 释放砖块

# 改变基地周围砖块类型
func changeBasePlaceBrickType(type):
	for i in baseBrickPos:  # 遍历基地周围位置
		var b=getBrick(i.x,i.y)  # 获取砖块
		if b:
			b.changeType(type)  # 改变砖块类型
		else:
			# 如果砖块不存在，创建新的砖块
			var temp=brick.instantiate()  # Godot 4 使用 .instantiate()
			temp.type=type  # 设置砖块类型
			temp.position=i*cellSize+Vector2(cellSize/2,cellSize/2)  # 设置位置
			brickNode.add_child(temp)  # 添加到砖块节点

# 设置敌人是否冻结
func setEnemyFreeze(flag=true):
	for i in tanksNode.get_children():  # 遍历所有坦克
		if i.get('objType')==Game.objType.ENEMY:  # 如果是敌人
			i.setFreeze(flag)  # 设置冻结状态

# 设置玩家是否冻结
func setPlayerFreeze(flag=true):
	for i in tanksNode.get_children():  # 遍历所有坦克
		if i.get('objType')==Game.objType.PLAYER:  # 如果是玩家
			i.setFreeze(flag)  # 设置冻结状态

# 创建基地	
func createBase():
	var temp=base.instantiate()  # Godot 4 使用 .instantiate()
	temp.position=Vector2(basePos.x*cellSize+cellSize,basePos.y*cellSize+cellSize)  # 设置基地位置
	otherNode.add_child(temp)  # 添加到其他节点		

# 获取地图中的砖块 x [0-25] y[0-25]
func getBrick(x:int,y:int):
	var temp=null
	for i in brickNode.get_children():  # 遍历所有砖块
		# 根据位置查找砖块
		if round((i.position.y-cellSize/2)/cellSize)==y\
			&&round((i.position.x-cellSize/2)/cellSize)==x:
			temp=i  # 找到砖块
			break
	return temp

# 添加玩家
func addPlayer(playNo:int,data:Dictionary={},isFreeze=false):
	var temp=player.instantiate()  # Godot 4 使用 .instantiate()
	
	# 根据玩家编号设置位置和ID
	if playNo==1:
		temp.playerId=Game.playerId.p1  # 玩家1 ID
		temp.position=Vector2(9*cellSize,25*cellSize)  # 玩家1出生位置
	elif playNo==2:
		temp.playerId=Game.playerId.p2  # 玩家2 ID
		temp.position=Vector2(17*cellSize,25*cellSize)  # 玩家2出生位置
	
	# 如果有数据，设置玩家属性
	if !data.is_empty():
		temp.hasShip=data['hasShip']  # 是否有船
		temp.level=data['level']  # 坦克等级
		temp.armour=data['armour']  # 坦克装甲
		
		# 根据坦克等级设置子弹属性
		if data['level'] in [Game.level.MEDIUM]:
			temp.bulletPower=Game.bulletPower.FAST  # 中型坦克子弹速度
		elif data['level'] in [Game.level.SUPER,Game.level.LARGE]:
			temp.bulletMax=2  # 大型和超级坦克可以发射2发子弹
			if data['level']==Game.level.SUPER:
				temp.bulletPower=Game.bulletPower.SUPER  # 超级坦克子弹威力
			else:
				temp.bulletPower=Game.bulletPower.FAST  # 大型坦克子弹速度
			
	tanksNode.call_deferred('add_child',temp)  # 延迟添加到坦克节点
	if isFreeze:
		temp.call_deferred('setFreeze',true)  # 延迟设置冻结状态
						
# 删除敌人出生点方块
func delEnemyPosBrick():
	for i in enemyPos:  # 遍历敌人出生位置
		var brick=getBrick(i.x,i.y)  # 获取砖块
		if brick:
			brick.queue_free()  # 释放砖块
	
# 删除基地周边的方块	
func delBasePlaceBrick():
	for i in baseBrickPos:  # 遍历基地周围位置
		var temp=getBrick(i.x,i.y)  # 获取砖块
		if temp:
			temp.queue_free()  # 释放砖块

# 添加基地周边石头
func addBasePlaceStone():
	for i in baseBrickPos:  # 遍历基地周围位置
		var temp=brick.instantiate()  # Godot 4 使用 .instantiate()
		temp.type=Game.brickType.STONE  # 设置为石头类型
		temp.position=i*cellSize+Vector2(cellSize/2,cellSize/2)  # 设置位置
		brickNode.call_deferred('add_child',temp)  # 延迟添加到砖块节点

# 添加子弹
func addBullet(obj):
	bulletsNode.add_child(obj)  # 添加到子弹节点

# 添加其他对象
func addOther(obj):
	otherNode.add_child(obj)  # 添加到其他节点

# 设置玩家1生命数
func setP1LiveNum(num):
	p1Num.visible=true  # 显示玩家1生命UI
	p1LiveNum=num  # 设置生命数
	p1Count.text=str(num)  # 更新生命数显示

	
# 设置玩家2生命数
func setP2LiveNum(num):
	p2Num.visible=true  # 显示玩家2生命UI
	p2LiveNUm=num  # 设置生命数
	p2Count.text=str(num)  # 更新生命数显示


# 设置关卡名称
func setLevelName(name):
	levelName.text='%d'%name  # 更新关卡名称显示
				
# 获取敌人总数
func getEnemyCount():
	var num=0
	for i in tanksNode.get_children():  # 遍历所有坦克
		if i.get('objType')==Game.objType.ENEMY:  # 如果是敌人
			num+=1  # 增加计数
	return num	
	
# 添加敌人
func addEnemy(isFreeze=false):
	var temp=enemy.instantiate()  # Godot 4 使用 .instantiate()
	
	# 随机选择一个出生位置
	temp.position=enemyRevivePos[randi()%3]*cellSize+Vector2(temp.tankSize/2,temp.tankSize/2)
	
	# 随机选择敌人类型
	var types=[Game.enemyType.TYPEA,Game.enemyType.TYPEB,
				Game.enemyType.TYPEC,Game.enemyType.TYPED]
	temp.type=types[randi()%4]  # 随机选择类型
	
	tanksNode.add_child(temp)  # 添加到坦克节点
	
	if isFreeze:
		temp.setFreeze()  # 设置冻结状态
	
	removeEnemyLogo()  # 移除一个敌人图标
	enemyCount-=1  # 减少敌人总数
	
# 添加道具（道具不在基地附近和玩家当前附近）
func addBonus():
	# 清除旧道具
	for i in otherNode.get_children():
		if i.get('objType')==Game.objType.BONUS:
			otherNode.remove_child(i)
	
	# 获取玩家位置
	var playerPos=[]
	for i in tanksNode.get_children():
		if i.get('objType')	==Game.objType.PLAYER:
			var p=Vector2(round(i.position.x/16),round(i.position.y/16))
			playerPos.append(p)  # 添加玩家当前位置
			playerPos.append(Vector2(p.x-1,p.y))  # 添加玩家左边位置
			playerPos.append(Vector2(p.x+1,p.y))  # 添加玩家右边位置
			
	# 随机生成道具位置（不在基地和玩家附近）
	var pos = Vector2(randi()%25+1,randi()%25+1)
	while pos in basePlacePos || pos in playerPos:  # 确保不在基地和玩家附近
		pos = Vector2(randi()%25+1,randi()%25+1)
	
	var temp=bonus.instantiate()  # Godot 4 使用 .instantiate()
	temp.position=pos*cellSize  # 设置道具位置
	temp.setRandomType()  # 随机设置道具类型
	otherNode.call_deferred('add_child',temp)  # 延迟添加到其他节点
	
# 获取玩家数据
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
	
	# 遍历所有坦克，获取玩家数据
	for i in tanksNode.get_children():
		if i.objType==Game.objType.PLAYER:
			if i.playerId==Game.playerId.p1:  # 玩家1数据
				temp['p1']['level']=i.level
				temp['p1']['armour']=i.armour
				temp['p1']['hasShip']=i.hasShip
			elif i.playerId==Game.playerId.p2:  # 玩家2数据
				temp['p2']['level']=i.level
				temp['p2']['armour']=i.armour
				temp['p2']['hasShip']=i.hasShip
	return temp
	
# 获取玩家
func getPlayer(id):
	var tank
	for i in tanksNode.get_children():  # 遍历所有坦克
		if i.get('objType')==Game.objType.PLAYER && i.get('playerId')==id:
			tank=i  # 找到玩家
			break
	return tank
	
# 清空敌人坦克
func clearEnemyTank()->Dictionary:
	var list={'typeA':0,'typeB':0,'typeC':0,'typeD':0}  # 统计各类型敌人数量
	
	for i in tanksNode.get_children():  # 遍历所有坦克
		if i.get('objType')==Game.objType.ENEMY&&i.get('state')!=Game.tankstate.IDLE:
			var type=i.get('type')  # 获取敌人类型
			
			# 统计各类型敌人
			if type==Game.enemyType.TYPEA:
				list['typeA']+=1
			elif type==	Game.enemyType.TYPEB:
				list['typeB']+=1
			elif type==	Game.enemyType.TYPEC:
				list['typeC']+=1
			elif type==Game.enemyType.TYPED:
				list['typeD']+=1
			
			i.setExplosion()  # 设置爆炸效果
	
	return list  # 返回统计结果

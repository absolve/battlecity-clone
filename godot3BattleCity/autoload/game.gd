extends Node

#方向
enum dir{
	UP,DOWN,LEFT,RIGHT
}

#玩家坦克级别
enum level{
	MIN,MEDIUM,LARGE,SUPER
}

#玩家id
enum playerId{
	p1,p2
}

#方块类型 砖块 石头 水 草丛 冰块
enum brickType{
	WALL=0,STONE,WATER,BUSH,ICE
}

#对象类型
enum objType{
	PLAYER=1001,ENEMY,BRICK,BASE,BULLET,BONUS
}

#奖励物品类型
enum bonusType{
	GRENADE,HELMET,CLOCK,SHOVEL,TANK,STAR,GUN,BOAT
}

#子弹威力
enum bulletPower{
	NORMAL,FAST,SUPER
}

#坦克状态
enum tankstate{
	IDLE,START,DEAD,FREEZE
}

#敌人坦克类型
enum enemyType{
	TYPEA=90,TYPEB,TYPEC,TYPED
}

#游戏状态
enum gameState{
	IDLE=70,START
}

enum gameMode{
	SINGLE,DOUBLE
}

enum objState{
	IDLE,START
}

#玩家数据
var p1Data={'score':0,'lives':2,'level':level.MIN,'armour':0,'hasShip':false}
var p2Data={'score':0,'lives':2,'level':level.MIN,'armour':0,'hasShip':false}
var p1Score={'typeA':0,'typeB':0,'typeC':0,'typeD':0}
var p2Score={'typeA':0,'typeB':0,'typeC':0,'typeD':0}
var gameLevel=0 #游戏关卡
var mode=gameMode.SINGLE

#信号
signal baseDestroyed
signal hitPlayer
signal addBonus
signal destroyEnemy
signal getBonus

var map
var mapList=[] #地图名字

func _ready():
	OS.center_window()
	printFont()
	loadBuiltInMap()


func changeScene(stagePath):
	set_process_input(false)
	get_tree().change_scene(stagePath)
	set_process_input(true)

#获取内置地图
func loadBuiltInMap():
	mapList.clear()
	var dir = Directory.new()
	if dir.open("res://level")== OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				mapList.append(file_name)
			file_name = dir.get_next()	
	else:
		print("An error occurred when trying to access the path.")	

func resetData():
	p1Data={'score':0,'lives':2,'level':level.MIN,'armour':0,'hasShip':false}
	p2Data={'score':0,'lives':2,'level':level.MIN,'armour':0,'hasShip':false}
	p1Score={'typeA':0,'typeB':0,'typeC':0,'typeD':0}
	p2Score={'typeA':0,'typeB':0,'typeC':0,'typeD':0}
	gameLevel=0

func resetPlayerScore():
	p1Score={'typeA':0,'typeB':0,'typeC':0,'typeD':0}
	p2Score={'typeA':0,'typeB':0,'typeC':0,'typeD':0}

#打印提示信息
func printFont():
	print(""" 
 ____    ____  ______  ______  _        ___         __  ____  ______  __ __ 
|    \\  /    ||      ||      || |      /   ]       /  ]|    ||      ||  |  |
|  o  )|  o  ||      ||      || |     /  [_       /  /  |  | |      ||  |  |
|     ||     ||_|  |_||_|  |_|| |___ |    _]     /  /   |  | |_|  |_||  ~  |
|  O  ||  _  |  |  |    |  |  |     ||   [_     /   \\_  |  |   |  |  |___, |
|     ||  |  |  |  |    |  |  |     ||     |    \\     | |  |   |  |  |     |
|_____||__|__|  |__|    |__|  |_____||_____|     \\____||____|  |__|  |____/ 
	""")

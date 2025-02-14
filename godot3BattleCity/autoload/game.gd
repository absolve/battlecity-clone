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
	IDLE,START,DEAD
}

#敌人坦克类型
enum enemyType{
	TYPEA=90,TYPEB,TYPEC,TYPED
}

#玩家数据
var p1Data={'p1Score':0,'p1Lives':2,'level':level.MIN,'armour':0,'hasShip':false}
var p2Data={'p2Score':0,'p2Lives':2,'level':level.MIN,'armour':0,'hasShip':false}
var gameLevel=1 #游戏关卡


#信号
signal baseDestroyed
signal hitPlayer
signal addBonus

var map

func _ready():
	OS.center_window()
	printFont()



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

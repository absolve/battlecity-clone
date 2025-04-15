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
var configFile="battleCity.ini"
var config={'Base':{'useExtensionMap':false},
				'Volume':{'Master':1,'Bg':0.5,'Sfx':0.5}}

func _ready():
	printFont()
	#loadConfig()
	initMap()

func changeScene(stagePath):
	set_process_input(false)
	get_tree().change_scene_to_file(stagePath)
	set_process_input(true)

#初始化地图
func initMap():
	if !config.Base.useExtensionMap:
		loadBuiltInMap()
	else:
		loadExtensionMap()	
	mapList.sort_custom(sort)
	
#获取内置地图
func loadBuiltInMap():
	mapList.clear()
	var dir = DirAccess.open("res://level")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				mapList.append(file_name)
			file_name = dir.get_next()	
	else:
		print("An error occurred when trying to access the path.")	

#载入扩展地图
func loadExtensionMap():
	mapList.clear()
	var baseDir=OS.get_executable_path().get_base_dir()
	var dir = DirAccess.open(baseDir+"/level")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir():
				mapList.append(file_name)
			file_name = dir.get_next()	
	else:
		print("An error occurred when trying to access the path.")	

func sort(a:String,b:String):
	var flag=true
	var aname=a.get_basename()
	var bname=b.get_basename()
	if aname.to_int()>=bname.to_int():
		flag=false
	return flag
	
func resetData():
	p1Data={'score':0,'lives':2,'level':level.MIN,'armour':0,'hasShip':false}
	p2Data={'score':0,'lives':2,'level':level.MIN,'armour':0,'hasShip':false}
	p1Score={'typeA':0,'typeB':0,'typeC':0,'typeD':0}
	p2Score={'typeA':0,'typeB':0,'typeC':0,'typeD':0}
	gameLevel=0

func resetPlayerScore():
	p1Score={'typeA':0,'typeB':0,'typeC':0,'typeD':0}
	p2Score={'typeA':0,'typeB':0,'typeC':0,'typeD':0}

#载入配置
func loadConfig():
	var baseDir=OS.get_executable_path().get_base_dir()
	var cfg = ConfigFile.new()
	var err = cfg.load(baseDir+"/"+configFile)
	if err == OK:
		for i in cfg.get_sections():
			if i =='Base':
				config.Base.useExtensionMap=cfg.get_value(i,'useExtensionMap',false)
			elif i =='Volume':
				config.Volume.Master=cfg.get_value(i,'Master')
				config.Volume.Bg=cfg.get_value(i,'Bg')
				config.Volume.Sfx=cfg.get_value(i,'Sfx')
				AudioServer.set_bus_volume_db(AudioServer.get_bus_index('Master'), linear_to_db(config.Volume.Master))
				AudioServer.set_bus_volume_db(AudioServer.get_bus_index('bg'), linear_to_db(config.Volume.Bg))
				AudioServer.set_bus_volume_db(AudioServer.get_bus_index('sfx'), linear_to_db(config.Volume.Sfx))
	
	else:
		newGameConfigFile()
				
#新建一个配置文件				
func newGameConfigFile():
	var cfg = ConfigFile.new()
	cfg.set_value("Base","useExtensionMap",false)
		
	cfg.set_value("Volume","Master",1)
	cfg.set_value("Volume","Bg",0.5)
	cfg.set_value("Volume","Sfx",0.5)
	
	cfg.save(OS.get_executable_path().get_base_dir()+"/"+configFile)	

#保存设置		
func saveConfig():
	var baseDir=OS.get_executable_path().get_base_dir()
	var cfg = ConfigFile.new()
	cfg.set_value("Base","useExtensionMap",config.Base.useExtensionMap)
		
	cfg.set_value("Volume","Master",config.Volume.Master)
	cfg.set_value("Volume","Bg",config.Volume.Bg)
	cfg.set_value("Volume","Sfx",config.Volume.Sfx)
	cfg.save(OS.get_executable_path().get_base_dir()+"/"+configFile)	


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

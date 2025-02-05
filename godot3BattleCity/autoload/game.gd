extends Node

#方向
enum dir{
	UP,DOWN,LEFT,RIGHT
}

#级别
enum level{
	MIN,MEDIUM,LARGE,SUPER
}

#玩家id
enum playerId{
	p1,p2
}

#方块类型
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


signal baseDestroyed

func _ready():
	pass # Replace with function body.




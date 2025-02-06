extends Area2D


export var type=Game.brickType.WALL #类型
export var mapPos=Vector2.ZERO #地图的位置 x [0-25] y[0-25]
onready var ani=$ani

func _ready():
	setType(type)

#设置类型
func setType(value):
	if value==Game.brickType.WALL:
		ani.play("0")
	elif value==Game.brickType.STONE:
		ani.play("1")	
	elif value==Game.brickType.WATER:
		ani.play("2")	
	elif value==Game.brickType.BUSH:
		ani.play("3")	
	elif value==Game.brickType.ICE:
		ani.play("4")	
	
#改变类型
func changeType(value):
	self.type=value
	setType(value)
	

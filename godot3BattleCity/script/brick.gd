extends Area2D

#类型
export var type=Game.brickType.WALL

onready var ani=$ani

func _ready():
	setType(type)

#设置类型
func setType(type):
	if type==Game.brickType.WALL:
		ani.play("0")
	elif type==Game.brickType.STONE:
		ani.play("1")	
	elif type==Game.brickType.WATER:
		ani.play("2")	
	elif type==Game.brickType.BUSH:
		ani.play("3")	
	elif type==Game.brickType.ICE:
		ani.play("4")	
	
#改变类型
func changeType(type):
	self.type=type
	setType(type)
	

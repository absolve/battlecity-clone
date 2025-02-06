extends Node2D

export var type=Game.brickType.WALL #类型

onready var ani=$ani

func _ready():
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

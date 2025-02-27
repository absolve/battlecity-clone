extends Area2D

@onready var ani=$ani

var objType=Game.objType.BONUS
var type=Game.bonusType.STAR

func _ready():
	if type==Game.bonusType.BOAT:
		ani.play("0")
	elif type==Game.bonusType.CLOCK:
		ani.play("1")
	elif type==Game.bonusType.GRENADE:
		ani.play("2")
	elif type==Game.bonusType.GUN:
		ani.play("3")
	elif type==Game.bonusType.HELMET:
		ani.play("4")	
	elif type==Game.bonusType.SHOVEL:
		ani.play("5")	
	elif type==Game.bonusType.STAR:
		ani.play("6")	
	elif type==Game.bonusType.TANK:	
		ani.play("7")
		
func setRandomType():
	var arr=[Game.bonusType.BOAT,Game.bonusType.CLOCK,
	Game.bonusType.GRENADE,Game.bonusType.GUN,Game.bonusType.HELMET,
	Game.bonusType.SHOVEL,Game.bonusType.STAR,Game.bonusType.TANK]
	type=arr[randi()%arr.size()]	

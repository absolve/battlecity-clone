extends AnimatedSprite2D


var big=false
var playSound=false
var own=Game.objType.ENEMY 
@onready var playerSound=$player
@onready var enemySound=$enemy

func _ready():
	if big:
		play("big")
	else:
		play("default")
		
	if playSound:
		if own==Game.objType.ENEMY:
			enemySound.play()
		elif own==Game.objType.PLAYER:
			playerSound.play()
	await self.animation_finished
	queue_free()

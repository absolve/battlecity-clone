extends Control

var isGameOver=false


func _ready():
	pass


func showScore():
	
	pass

func nextLevel():
	if isGameOver:
		gameOver()

	
func gameOver():
	Game.changeScene("res://scene/gameover.tscn")


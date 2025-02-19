extends Node2D


onready var bouns=$bouns
onready var addLives=$addLives

func _ready():
	pass


func playBouns():
	bouns.play()


func playAddLives():
	addLives.play()


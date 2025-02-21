extends Node2D


onready var bouns=$bouns
onready var addLives=$addLives
onready var getBouns=$GetBouns
onready var bomb=$bomb
onready var award=$award

func _ready():
	pass


func playBouns():
	bouns.play()


func playAddLives():
	addLives.play()

func playGetBouns():
	getBouns.play()

func playBomb():
	bomb.play()

func playAward():
	award.play()

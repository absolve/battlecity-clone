extends Node2D


@onready var bouns=$bouns
@onready var addLives=$addLives
@onready var getBouns=$GetBouns
@onready var bomb=$bomb
@onready var award=$award
@onready var point=$point
@onready var music=$music


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

func playPoint():
	point.play()

func playMusic():
	music.play()

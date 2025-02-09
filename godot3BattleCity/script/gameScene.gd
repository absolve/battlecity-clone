extends Node2D

const mapDir="res://level"	#内置地图路径
onready var map=$map


func _ready():
	OS.center_window()
	Game.map=map
	map.loadMap(mapDir+"/"+'1.json')
	map.addPlayer(1)



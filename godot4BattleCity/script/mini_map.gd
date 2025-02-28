extends Node2D
#这个用来显示地图内容

const cellSize=16	#每个格子的大小是16px
@export var mapScale=Vector2(1,1)
var tile=preload("res://scene/tile.tscn")
@onready var childNode=$child


func loadMap(filePath:String):
	var file = FileAccess.open(filePath, FileAccess.READ)
	if file:
		var json=JSON.new()
		var currentLevel=json.parse(file.get_as_text())
		file.close()
		for i in currentLevel['data']:
			if i['type'] in [0,1,2,3,4]:
				var temp=tile.instantiate()
				temp.position.x=i['x']*cellSize+cellSize/2
				temp.position.y=i['y']*cellSize+cellSize/2
				temp.type=i['type']
				childNode.add_child(temp)
		childNode.scale=mapScale

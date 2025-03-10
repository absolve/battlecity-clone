extends Node2D
#这个用来显示地图内容

const cellSize=16	#每个格子的大小是16px
@export var mapScale=Vector2(1,1)
var tile=preload("res://scene/tile.tscn")
@onready var childNode=$child


func loadMap(filePath:String):
	for i in childNode.get_children():
		childNode.remove_child(i)
	var file = FileAccess.open(filePath, FileAccess.READ)
	if file:
		var json=JSON.new()
		var currentLevel=json.parse_string(file.get_as_text())
		file.close()
		#print(filePath)
		for i in currentLevel['data']:
			if int(i['type']) in [0,1,2,3,4]:
				var temp=tile.instantiate()
				temp.position.x=int(i['x'])*cellSize+cellSize/2
				temp.position.y=int(i['y'])*cellSize+cellSize/2
				temp.type=int(i['type'])
				childNode.add_child(temp)
		childNode.scale=mapScale

extends Control

var isGameOver=false


onready var levelNode=$HBoxContainer2/level
onready var highScoreNode=$HBoxContainer/highScore
onready var p1ScoreNode=$VBoxContainer2/p1Score
onready var p2ScoreNode=$VBoxContainer3/p2Score
onready var totalResultNode=$totalResultNode
onready var p1TotalNode=$HBoxContainer3/p1Total
onready var p2TotalNode=$HBoxContainer3/p2Total
onready var p1ScoreListNode=$p1ScoreList


var p1Total=0
var p2Total=0
var scoreType=[Game.enemyType.TYPEA,Game.enemyType.TYPEB,
				Game.enemyType.TYPEC,Game.enemyType.TYPED]
var countIndex=0

func _ready():
	p1ScoreNode.text="%d"%Game.p1Data['p1Score']
	p2ScoreNode.text="%d"%Game.p2Data['p2Score']
	if Game.p1Data['p1Score']>=Game.p2Data['p2Score']:
		highScoreNode.text="%d"%Game.p1Data['p1Score']
	else:
		highScoreNode.text="%d"%Game.p2Data['p2Score']
	
	if Game.mode==Game.gameMode.SINGLE:
		pass
	elif Game.mode==Game.gameMode.DOUBLE:
		pass
	
		

func showScore():
	yield(get_tree(),"physics_frame")
	#从坦克A开始计算
	if countIndex==0:
		var resultP1=false
		var resultP2=true
		if Game.mode==Game.gameMode.DOUBLE:
			resultP2=false
		var tempP1Num=0
		var tempP2Num=0
		while tempP1Num<Game.p1Score['typeA']||tempP2Num<Game.p2Score['typeA']:
			if tempP1Num<Game.p1Score['typeA']:
				tempP1Num+=1
			
			if tempP2Num<Game.p2Score['typeA']:
				tempP2Num
			
			pass
			
		pass
	pass

#
func setP1NumLable(id,type,num):
	if id==0:
		if type==Game.enemyType.TYPEA:
			pass
		elif type==Game.enemyType.TYPEB:
			pass
		elif type==Game.enemyType.TYPEC:
			pass
		elif type==Game.enemyType.TYPED:
			pass
						
						

func nextLevel():
	if isGameOver:
		gameOver()

	
func gameOver():
	Game.changeScene("res://scene/gameover.tscn")


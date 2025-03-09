extends Control

@export var isGameOver=false

@onready var levelNode=$HBoxContainer2/level
@onready var highScoreNode=$HBoxContainer/highScore
@onready var p1ScoreNode=$VBoxContainer2/p1Score
@onready var p2ScoreNode=$VBoxContainer3/p2Score
@onready var totalResultNode=$totalResultNode
@onready var p1TotalNode=$totalResultNode/p1Total
@onready var p2TotalNode=$totalResultNode/p2Total
@onready var p1ScoreListNode=$p1ScoreList
@onready var p1TypeAScoreNode=$p1ScoreList/typeA/typeAScore
@onready var p1TypeANumNode=$p1ScoreList/typeA/HBoxContainer/typeANum
@onready var p1TypeBScoreNode=$p1ScoreList/typeB/typeBScore
@onready var p1TypeBNumNode=$p1ScoreList/typeB/HBoxContainer/typeBNum
@onready var p1TypeCScoreNode=$p1ScoreList/typeC/typeCScore
@onready var p1TypeCNumNode=$p1ScoreList/typeC/HBoxContainer/typeCNum
@onready var p1TypeDScoreNode=$p1ScoreList/typeD/typeDScore
@onready var p1TypeDNumNode=$p1ScoreList/typeD/HBoxContainer/typeDNum
@onready var p2ScoreListNode=$p2ScoreList
@onready var p2TypeANumNode=$p2ScoreList/typeA/HBoxContainer/typeANum
@onready var p2TypeAScoreNode=$p2ScoreList/typeA/typeAScore
@onready var p2TypeBNumNode=$p2ScoreList/typeB/HBoxContainer/typeBNum
@onready var p2TypeBScoreNode=$p2ScoreList/typeB/typeBScore
@onready var p2TypeCNumNode=$p2ScoreList/typeC/HBoxContainer/typeCNum
@onready var p2TypeCScoreNode=$p2ScoreList/typeC/typeCScore
@onready var p2TypeDNumNode=$p2ScoreList/typeD/HBoxContainer/typeDNum
@onready var p2TypeDScoreNode=$p2ScoreList/typeD/typeDScore
@onready var rewardNode=$reward

@onready var timer=$Timer

var p1Score=0
var p2Score=0
var scoreType=[Game.enemyType.TYPEA,Game.enemyType.TYPEB,
				Game.enemyType.TYPEC,Game.enemyType.TYPED]
var countIndex=0



func _ready():
	RenderingServer.set_default_clear_color('#000')
	p1Score=Game.p1Data['score']
	p2Score=Game.p2Data['score']
	p1ScoreNode.text="%d"%p1Score
	p2ScoreNode.text="%d"%p2Score
	levelNode.text='%d'%(Game.gameLevel+1)
	
	
	if p1Score>=p2Score:
		highScoreNode.text="%d"%p2Score
	else:
		highScoreNode.text="%d"%p2Score

	if Game.mode==Game.gameMode.SINGLE:
		pass
	elif Game.mode==Game.gameMode.DOUBLE:
		p2ScoreListNode.visible=true

func showScore():
	#从坦克A开始计算
	if countIndex==0:
		var tempP1Num=0
		var tempP2Num=0
		setNumLable(0,Game.enemyType.TYPEA,tempP1Num)
		if Game.mode==Game.gameMode.DOUBLE:
			setNumLable(1,Game.enemyType.TYPEA,tempP2Num)
		while tempP1Num<Game.p1Score['typeA']||tempP2Num<Game.p2Score['typeA']:
			if tempP1Num<Game.p1Score['typeA']:
				tempP1Num+=1
				setNumLable(0,Game.enemyType.TYPEA,tempP1Num)
				
			if tempP2Num<Game.p2Score['typeA']:
				tempP2Num+=1
				setNumLable(1,Game.enemyType.TYPEA,tempP2Num)
			SoundsUtil.playPoint()	
			await get_tree().create_timer(0.3).timeout
		if tempP1Num==0 && tempP2Num==0:
			await get_tree().create_timer(0.5).timeout

		countIndex+=1
		showScore()	
	elif countIndex==1:
		var tempP1Num=0
		var tempP2Num=0
		setNumLable(0,Game.enemyType.TYPEB,tempP1Num)
		if Game.mode==Game.gameMode.DOUBLE:
			setNumLable(1,Game.enemyType.TYPEB,tempP2Num)
		while tempP1Num<Game.p1Score['typeB']||tempP2Num<Game.p2Score['typeB']:
			if tempP1Num<Game.p1Score['typeB']:
				tempP1Num+=1
				setNumLable(0,Game.enemyType.TYPEB,tempP1Num)
				
			if tempP2Num<Game.p2Score['typeB']:
				tempP2Num+=1
				setNumLable(1,Game.enemyType.TYPEB,tempP2Num)
			SoundsUtil.playPoint()		
			await get_tree().create_timer(0.3).timeout
		if tempP1Num==0 && tempP2Num==0:
			await get_tree().create_timer(0.5).timeout
		countIndex+=1
		showScore()	
	elif countIndex==2:
		var tempP1Num=0
		var tempP2Num=0
		setNumLable(0,Game.enemyType.TYPEC,tempP1Num)
		if Game.mode==Game.gameMode.DOUBLE:
			setNumLable(1,Game.enemyType.TYPEC,tempP2Num)
		while tempP1Num<Game.p1Score['typeC']||tempP2Num<Game.p2Score['typeC']:
			if tempP1Num<Game.p1Score['typeC']:
				tempP1Num+=1
				setNumLable(0,Game.enemyType.TYPEC,tempP1Num)
				
			if tempP2Num<Game.p2Score['typeC']:
				tempP2Num+=1
				setNumLable(1,Game.enemyType.TYPEC,tempP2Num)
			SoundsUtil.playPoint()		
			await get_tree().create_timer(0.3).timeout
		if tempP1Num==0 && tempP2Num==0:
			await get_tree().create_timer(0.5).timeout
		countIndex+=1
		showScore()			
	elif countIndex==3:		
		var tempP1Num=0
		var tempP2Num=0
		setNumLable(0,Game.enemyType.TYPED,tempP1Num)
		if Game.mode==Game.gameMode.DOUBLE:
			setNumLable(1,Game.enemyType.TYPED,tempP2Num)
		while tempP1Num<Game.p1Score['typeD']||tempP2Num<Game.p2Score['typeD']:
			if tempP1Num<Game.p1Score['typeD']:
				tempP1Num+=1
				setNumLable(0,Game.enemyType.TYPED,tempP1Num)
				
			if tempP2Num<Game.p2Score['typeD']:
				tempP2Num+=1
				setNumLable(1,Game.enemyType.TYPED,tempP2Num)
			SoundsUtil.playPoint()		
			await get_tree().create_timer(0.3).timeout
		if tempP1Num==0 && tempP2Num==0:
			await get_tree().create_timer(0.5).timeout
		countIndex+=1
		showScore()	
	else:
		var p1Num=Game.p1Score['typeA']+\
				Game.p1Score['typeB']+Game.p1Score['typeC']+\
				Game.p1Score['typeD']
		p1TotalNode.visible=true
		p1TotalNode.text="%d"%p1Num
		if 	Game.mode==Game.gameMode.DOUBLE:	
			var p2Num=Game.p2Score['typeA']+\
				Game.p2Score['typeB']+Game.p2Score['typeC']+\
				Game.p2Score['typeD']
			p2TotalNode.text="%d"%p2Num
			p2TotalNode.visible=true
			if p1Num>p2Num:
				SoundsUtil.playAward()
				Game.p1Data['score']+=1000
				rewardNode.visible=true
				rewardNode.set_position(Vector2(8,400))
			elif p1Num<p2Num&&p2Num!=0:
				SoundsUtil.playAward()
				Game.p2Data['score']+=1000	
				rewardNode.visible=true
				rewardNode.set_position(Vector2(392,400))
		await get_tree().create_timer(0.5).timeout
		timer.start()	
			
#
func setNumLable(id,type,num):
	if id==0:
		if type==Game.enemyType.TYPEA:
			p1TypeAScoreNode.text='%d'%(num*100)
			p1TypeANumNode.text='%d'%num
		elif type==Game.enemyType.TYPEB:
			p1TypeBScoreNode.text='%d'%(num*200)
			p1TypeBNumNode.text='%d'%num
		elif type==Game.enemyType.TYPEC:
			p1TypeCScoreNode.text='%d'%(num*300)
			p1TypeCNumNode.text='%d'%num
		elif type==Game.enemyType.TYPED:
			p1TypeDScoreNode.text='%d'%(num*400)
			p1TypeDNumNode.text='%d'%num
	elif  id==1:					
		if type==Game.enemyType.TYPEA:
			p2TypeAScoreNode.text='%d'%(num*100)
			p2TypeANumNode.text='%d'%num
		elif type==Game.enemyType.TYPEB:
			p2TypeBScoreNode.text='%d'%(num*200)
			p2TypeBNumNode.text='%d'%num
		elif type==Game.enemyType.TYPEC:
			p2TypeCScoreNode.text='%d'%(num*300)
			p2TypeCNumNode.text='%d'%num
		elif type==Game.enemyType.TYPED:
			p2TypeDScoreNode.text='%d'%(num*400)
			p2TypeDNumNode.text='%d'%num	
			
func nextLevel():
	if isGameOver:
		gameOver()
		return
	if Game.gameLevel>=Game.mapList.size()-1:
		var temp=load("res://scene/info.tscn")
		var scene=temp.instantiate()
		scene.disableInput=true
		get_tree().root.add_child(scene)
		get_tree().current_scene=scene
		queue_free()
	else:
		Game.gameLevel+=1
		var temp=load("res://scene/splash.tscn")
		get_tree().change_scene_to_packed(temp)
				
		
func gameOver():
	var temp=load("res://scene/gameover.tscn")
	get_tree().change_scene_to_packed(temp)	


func _on_timer_timeout() -> void:
	nextLevel()


func _on_start_timer_timeout() -> void:
	#显示分数	
	showScore()

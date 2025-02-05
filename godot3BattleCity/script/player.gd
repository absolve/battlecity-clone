extends "res://script/tank.gd"

#玩家id 用来区分按键
var playerId=Game.playerId.p1



func _ready():
	if dir==Game.dir.UP:
		radar.rotation_degrees=-90
	elif dir==Game.dir.DOWN:
		radar.rotation_degrees=90
	elif dir==Game.dir.LEFT:
		radar.rotation_degrees=180
	elif dir==Game.dir.RIGHT:
		radar.rotation_degrees=0

func _physics_process(delta):
	
	lastDir=dir
	if Input.is_action_pressed("p1_down"):
		vec=Vector2(0,speed)
		dir=Game.dir.DOWN
	elif Input.is_action_pressed("p1_up"):
		vec=Vector2(0,-speed)
		dir=Game.dir.UP
	elif Input.is_action_pressed("p1_left"):
		vec=Vector2(-speed,0)
		dir=Game.dir.LEFT
	elif Input.is_action_pressed("p1_right"):
		vec=Vector2(speed,0)
		dir=Game.dir.RIGHT
	else:
		vec=Vector2.ZERO	
		
	if lastDir!=dir:	#转向的需要修改位置
		turnDirection()
		
	animation(dir,vec)		
	position+=vec*delta

#改变方向的时候调整位置
func turnDirection():
	if dir==Game.dir.LEFT||dir==Game.dir.RIGHT:
		position.y=round((position.y)/16)*16
	else:
		position.x=round((position.x)/16)*16
	if dir==Game.dir.UP:
		radar.rotation_degrees=-90
	elif dir==Game.dir.DOWN:
		radar.rotation_degrees=90
	elif dir==Game.dir.LEFT:
		radar.rotation_degrees=180
	elif dir==Game.dir.RIGHT:
		radar.rotation_degrees=0
	
func animation(dir,vec):
	if dir==Game.dir.UP:
		ani.flip_v=false
		ani.flip_h=false
		ani.rotation_degrees=0
	elif dir==Game.dir.DOWN:
		ani.flip_v=true
		ani.flip_h=false
		ani.rotation_degrees=0
	elif dir==Game.dir.LEFT:
		ani.flip_v=false
		ani.flip_h=true
		ani.rotation_degrees=-90
	elif dir==Game.dir.RIGHT:	
		ani.flip_v=false
		ani.flip_h=false
		ani.rotation_degrees=90

			
	if vec!=Vector2.ZERO:	
		ani.play("small_run")
	else:
		ani.play("small")	

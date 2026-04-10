extends "res://script/tank.gd"

# 敌人相关变量
var objType=Game.objType.ENEMY  # 对象类型
var type=Game.enemyType.TYPEA  # 敌人类型
var targetPos=Vector2(12,24)*cellSize  # 基地位置
var allDir=[Game.dir.LEFT,Game.dir.RIGHT,Game.dir.UP,Game.dir.DOWN]  # 所有方向
var moveTime=0  # 移动时间
var keepMoveTime=0  # 保持移动的时间
var bullet=preload("res://scene/bullet.tscn")  # 子弹预制体
var explode=preload("res://scene/explode.tscn")  # 爆炸预制体
var fireTime=0  # 开火计时
var fireDelay=100  # 开火延迟
var armourColor=['#52582f','#fff2d1','#ddab7b']  # 装甲颜色1
var armourColor1=['#1b3f5f','#d8f2b9','#7f963b']  # 装甲颜色2
var armourColor2=['#0d472f','#d9ffe7','#5ea77b']  # 装甲颜色3
var armourColor3=['#8f0077','#ffffff','#db2b00']  # 有物品的颜色
var hasItem=false  # 是否有物品

# 节点引用
onready var player=$player  # 玩家节点
onready var hitSound=$hit  # 被击中音效

# 初始化函数
func _ready():
	dir=Game.dir.DOWN  # 初始方向向下
	collision_layer=2  # 碰撞层
	
	# 根据敌人类型设置属性
	if type==Game.enemyType.TYPEA:
		armour=randi()%2  # 随机装甲值 0-1
	elif type==Game.enemyType.TYPEB:
		armour=randi()%2  # 随机装甲值 0-1
		speed=100  # 增加速度
	elif type==Game.enemyType.TYPEC:
		armour=randi()%4  # 随机装甲值 0-3
		bulletPower=Game.bulletPower.FAST  # 提高子弹速度
	elif type==Game.enemyType.TYPED:
		armour=randi()%3+1  # 随机装甲值 1-3
		bulletPower=Game.bulletPower.FAST  # 提高子弹速度
		speed-=10  # 降低速度
	
	# 随机生成物品
	if randi()%10>=7:  # 30%的概率有物品
		if armour<3:
			armour+=1  # 增加装甲
		hasItem=true  # 设置有物品
	# hasItem=true  # 测试用，强制有物品	
	
	keepMoveTime=randi()%300+80  # 随机保持移动的时间
	startInit()  # 开始初始化

# 物理过程处理
func _physics_process(delta):
	if state==Game.tankstate.START:  # 如果坦克状态为开始
		lastDir=dir  # 记录上一个方向
		isStop=false  # 是否停止移动
		
		# 根据方向设置速度向量
		if dir==Game.dir.DOWN:
			vec=Vector2(0,speed)
		elif dir==Game.dir.UP:
			vec=Vector2(0,-speed)
		elif dir==Game.dir.LEFT:
			vec=Vector2(-speed,0)
		elif dir==Game.dir.RIGHT:
			vec=Vector2(speed,0)
		
		moveTime+=1  # 增加移动时间
		fireTime+=1  # 增加开火时间
		
		# 敌人的主要目标是向基地出发	
		if moveTime>keepMoveTime:  # 改变方向
			moveTime=0  # 重置移动时间
			keepMoveTime=randi()%300+60  # 重新随机保持移动的时间
			var p=randf()  # 随机概率值
			
			# 根据敌人类型决定行为
			if type==Game.enemyType.TYPEA:
				if p>0.3:  # 70%的概率向基地移动
					targetEagle(p)
				else:  # 30%的概率随机移动
					var temp=getNewDir(lastDir)
					dir	= temp[randi()%temp.size()]
			elif type==Game.enemyType.TYPEB||type==Game.enemyType.TYPEC:		
				if p>0.5:  # 50%的概率向基地移动
					targetEagle(p)
				else:  # 50%的概率随机移动
					var temp=getNewDir(lastDir)
					dir	= temp[randi()%temp.size()]
			elif type==Game.enemyType.TYPED:
				if p>0.1:  # 90%的概率向基地移动	
					targetEagle(p)
				else:  # 10%的概率随机移动
					var temp=getNewDir(lastDir)
					dir	= temp[randi()%temp.size()]			
			
		# 开火
		if fireTime>fireDelay:
			fireTime=0  # 重置开火时间
			fireDelay=randi()%100+40  # 随机开火延迟
			fire()  # 开火		
		
		if lastDir!=dir:  # 转向的需要修改位置
			turnDirection()
		
		# 处理动画
		animation(dir,vec)

		# 获取碰撞区域
		var areas=[]
		if dir==Game.dir.LEFT:
			areas=leftArea.get_overlapping_areas()
		elif dir==Game.dir.RIGHT:
			areas=rightArea.get_overlapping_areas()
		elif dir==Game.dir.UP:
			areas=topArea.get_overlapping_areas()
		elif dir==Game.dir.DOWN:
			areas=bottomArea.get_overlapping_areas()
		
		
		# 处理碰撞
		for i in areas:
			if i == leftArea||i ==rightArea||i==topArea\
			||i==bottomArea||i==self:
				continue	
			# 处理与砖块和基地的碰撞
			if i.get('objType') in [Game.objType.BRICK,Game.objType.BASE]:
				var type=i.get('type')
				if type==Game.brickType.BUSH||type==Game.brickType.ICE:
					if type==Game.brickType.ICE:
						isOnIce=true  # 在冰上
					continue
				isStop=true  # 碰到障碍物，停止移动
			# 处理与其他坦克的碰撞
			if i.get('objType') in [Game.objType.ENEMY,Game.objType.PLAYER]:
				if global_position.distance_to(i.global_position)<10:
					continue  # 距离太近，忽略
				else:	
					isStop=true  # 碰到其他坦克，停止移动
		
		# 移动坦克
		if !isStop:
			position+=vec*delta	
		else:
			keepMoveTime-=25  # 碰到障碍物，减少保持移动的时间

		# 边界检查
		if position.x<=tankSize/2:
			position.x=tankSize/2  # 左边界
			keepMoveTime-=20  # 减少保持移动的时间
		if position.x>=mapSize.x-tankSize/2:	
			position.x=mapSize.x-tankSize/2  # 右边界
			keepMoveTime-=20  # 减少保持移动的时间
		if position.y<=tankSize/2:
			position.y=tankSize/2  # 上边界
			keepMoveTime-=20  # 减少保持移动的时间
		if position.y>=mapSize.y-tankSize/2:	
			position.y=mapSize.y-tankSize/2  # 下边界
			keepMoveTime-=20  # 减少保持移动的时间
			
# 改变方向的时候调整位置
func turnDirection():
	if dir==Game.dir.LEFT||dir==Game.dir.RIGHT:
		position.y=round((position.y)/16)*16  # 水平方向移动时，调整y坐标
	else:
		position.x=round((position.x)/16)*16  # 垂直方向移动时，调整x坐标
	

# 向基地出发
func targetEagle(p):
	var dx=position.x-targetPos.x  # 计算与基地的x距离
	var dy=position.y-targetPos.y  # 计算与基地的y距离
	
	# 优先向距离基地更近的方向移动
	if abs(dx)>abs(dy):
		if dx<0:
			dir=Game.dir.RIGHT  # 基地在右边
		else:
			dir=Game.dir.LEFT  # 基地在左边
	else:
		if dy<0:
			dir=Game.dir.DOWN  # 基地在下面
		else:
			dir=Game.dir.UP  # 基地在上面	
	
	# 有20%的概率随机改变方向
	if p>0.8:
		var temp=getNewDir(lastDir)
		dir	= temp[randi()%temp.size()]

# 获取一个新方向（排除当前方向）	
func getNewDir(dir):
	var temp=[]
	for i in allDir:
		if i!=dir:
			temp.append(i)  # 添加除当前方向外的所有方向
	return temp

# 开火
func fire():
	if canShoot:  # 如果可以开火
		canShoot=false  # 禁用开火
		shootTimer.start()  # 启动射击计时器
		
		# 创建子弹
		var temp=bullet.instance()
		temp.position=position  # 设置子弹位置
		temp.dir=dir  # 设置子弹方向
		temp.own=Game.objType.ENEMY  # 设置子弹所有者
		temp.setPower(bulletPower)  # 设置子弹威力
		temp.ownId=get_instance_id()  # 设置所有者ID
		
		Game.map.addBullet(temp)  # 添加到地图

# 添加爆炸效果
func addExplosion(isBig=true):
	var temp=explode.instance()  # 实例化爆炸效果
	temp.big=isBig  # 设置爆炸大小
	temp.position=position  # 设置爆炸位置
	temp.playSound=true  # 播放爆炸音效
	Game.map.addOther(temp)  # 添加到地图
			
# 开始初始化
func startInit():
	monitorable=false  # 禁用碰撞检测
	monitoring=false  # 禁用碰撞检测
	initTimer.start()  # 启动初始化计时器
	ani.play('flash')  # 播放闪烁动画

# 设置坦克是否冻结
func setFreeze(flag=true):
	if flag:
		isFreeze=flag  # 设置冻结状态
		state=Game.tankstate.FREEZE  # 设置坦克状态为冻结
		if ani.animation!='flash':
			ani.stop()  # 停止动画
	else:
		isFreeze=false  # 取消冻结状态
		if initTimer.is_stopped():
			state=Game.tankstate.START  # 设置坦克状态为开始

# 处理动画
func animation(dir,vec):
	# 设置坦克朝向
	if dir==Game.dir.UP:
		ani.flip_v=true
		ani.flip_h=false
		ani.rotation_degrees=0
	elif dir==Game.dir.DOWN:
		ani.flip_v=false
		ani.flip_h=false
		ani.rotation_degrees=0
	elif dir==Game.dir.LEFT:
		ani.flip_v=false
		ani.flip_h=false
		ani.rotation_degrees=90		
	elif dir==Game.dir.RIGHT:	
		ani.flip_v=false
		ani.flip_h=true
		ani.rotation_degrees=-90
	
	# 根据敌人类型和移动状态播放不同动画
	if type==Game.enemyType.TYPEA:
		if vec!=Vector2.ZERO:	
			ani.play('typeA_run')  # A型敌人运行动画
		else:
			ani.play("typeA")  # A型敌人 idle动画	
	elif type==Game.enemyType.TYPEB:
		if vec!=Vector2.ZERO:	
			ani.play('typeB_run')  # B型敌人运行动画
		else:
			ani.play("typeB")  # B型敌人 idle动画	
	elif type==Game.enemyType.TYPEC:
		if vec!=Vector2.ZERO:	
			ani.play('typeC_run')  # C型敌人运行动画
		else:
			ani.play("typeC")  # C型敌人 idle动画	
	elif type==Game.enemyType.TYPED:
		if vec!=Vector2.ZERO:	
			ani.play('typeD_run')  # D型敌人运行动画
		else:
			ani.play("typeD")  # D型敌人 idle动画	
	
			
# 设置颜色
func setColor():
	if armour>0:
		ani.material.set_shader_param('ischange',true)  # 启用颜色改变
		
	if hasItem:	
		if armour>0:
			# 有物品且有装甲时的颜色
			ani.material.set_shader_param('newColor1',Color(armourColor3[0]))
			ani.material.set_shader_param('newColor2',Color(armourColor3[1]))
			ani.material.set_shader_param('newColor3',Color(armourColor3[2]))
			player.play("blink")  # 播放闪烁动画
		else:
			if ani.material.get_shader_param('ischange'):
				ani.material.set_shader_param('ischange',false)  # 禁用颜色改变		
			player.play("RESET")  # 重置动画	
	else:	
		# 根据装甲值设置颜色
		if armour>=3:
			ani.material.set_shader_param('newColor1',Color(armourColor2[0]))
			ani.material.set_shader_param('newColor2',Color(armourColor2[1]))
			ani.material.set_shader_param('newColor3',Color(armourColor2[2]))
		elif armour==2:	
			ani.material.set_shader_param('newColor1',Color(armourColor1[0]))
			ani.material.set_shader_param('newColor2',Color(armourColor1[1]))
			ani.material.set_shader_param('newColor3',Color(armourColor1[2]))
		elif armour==1:	
			ani.material.set_shader_param('newColor1',Color(armourColor[0]))
			ani.material.set_shader_param('newColor2',Color(armourColor[1]))
			ani.material.set_shader_param('newColor3',Color(armourColor[2]))
		else:
			if ani.material.get_shader_param('ischange'):
				ani.material.set_shader_param('ischange',false)  # 禁用颜色改变	

# 设置爆炸
func setExplosion():
	addExplosion()  # 添加爆炸效果
	set_deferred('monitorable',false)  # 禁用碰撞检测
	set_deferred('monitoring',false)  # 禁用碰撞检测
	call_deferred('queue_free')  # 延迟释放坦克	

# 初始化计时器超时处理
func _on_initTimer_timeout():
	if !isFreeze:
		state=Game.tankstate.START  # 设置坦克状态为开始
	else:
		animation(dir,Vector2.ZERO)  # 播放 idle动画	
	set_deferred('monitorable',true)  # 启用碰撞检测
	set_deferred('monitoring',true)  # 启用碰撞检测
	setColor()  # 设置颜色

# 碰撞处理
func _on_tank_area_entered(area):
	if isDestroy||area==null:
		return  # 如果坦克已被摧毁或区域为空，返回
	
	# 处理子弹碰撞
	if area!=null&&area.get('objType')==Game.objType.BULLET:	
		if area.get('own')==Game.objType.PLAYER:  # 玩家的子弹
			if armour>0:
				armour-=1  # 减少装甲
				if hasItem:  # 添加物品
					Game.emit_signal("addBonus")
				setColor()  # 更新颜色	
				hitSound.play()  # 播放被击中音效
			else:
				# 坦克被摧毁
				isDestroy=true	
				state=Game.tankstate.DEAD  # 设置坦克状态为死亡
				addExplosion()  # 添加爆炸效果
				visible=false  # 隐藏坦克
				set_deferred('monitorable',false)  # 禁用碰撞检测
				set_deferred('monitoring',false)  # 禁用碰撞检测
				Game.emit_signal("destroyEnemy",type,area.get('playerId'),position)  # 发送敌人被摧毁信号
				call_deferred('queue_free')  # 延迟释放坦克	
				




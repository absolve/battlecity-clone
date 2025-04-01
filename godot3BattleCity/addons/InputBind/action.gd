extends VBoxContainer


onready var _events=$events
onready var _action=$PanelContainer/MarginContainer/HBoxContainer/action
onready var _tip=$PanelContainer/MarginContainer/HBoxContainer/tip
var event=preload("res://addons/InputBind/event.tscn")
var actionName=''	#动作名字
var keyName=''  #游戏中按键的名字
var tip=''  #提示

func _ready():
	_action.text=str(keyName)
	_tip.text=str(tip)
	init()

func init():
	var list=InputMap.get_action_list(actionName)
	print(list)
	for i in list:
		var temp=event.instance()	
		if i is InputEventKey:  #按键
			temp.eventName=str(i.as_text() ,' -Key')
		elif i is InputEventJoypadButton:	#手柄按钮
			temp.eventName=str('device:',i.device," button:",i.button_index,':',Input.get_joy_button_string(i.button_index) ,' -JoypadButton')		
		elif i is InputEventJoypadMotion:	#摇杆
			temp.eventName=str('device:',i.device," axis:",i.axis,' ',Input.get_joy_axis_string(i.axis) ,' -JoypadMotion')		
		elif i is InputEventMouseButton:#鼠标
			temp.eventName=str('device:',i.device," ",InputBind.MOUSE_BTN_NAME[i.button_index],' -Mouse')		
		_events.add_child(temp)
		
		var removeBtn=temp.find_node("btn")
		removeBtn.connect("pressed",self,"removeEvent",[i,temp])

#重新设置		
func reset():
	for i in _events.get_children():
		_events.remove_child(i)
	init()

#删除事件
func removeEvent(event,node):
	InputMap.action_erase_event(actionName,event)
	node.queue_free()
	

func _on_TextureButton_pressed():
	InputBind.emit_signal("addEvent",actionName,get_global_rect(),self)
	

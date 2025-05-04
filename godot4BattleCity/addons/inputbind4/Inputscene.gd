extends VBoxContainer

var action=preload("res://addons/inputbind4/action.tscn")
@onready var actions=$MarginContainer/VBoxContainer/ScrollContainer/actions
@onready var eventDialog=$eventDialog
@onready var popMenu=$PopupMenu
@onready var scroll=$MarginContainer/VBoxContainer/ScrollContainer
@onready var tipDialog=$AcceptDialog

var actionNode  
var actionName

func _ready():
	for i in InputBind.actions:
		var temp=action.instantiate()
		temp.actionName=i.id
		temp.keyName=i.name
		temp.tip=i.tip
		actions.add_child(temp)
	for i in range(InputBind.EVENT_TYPE.size()):
		popMenu.add_item(InputBind.EVENT_TYPE[i])
	InputBind.addEvent.connect(addEvent)
	InputBind.setEvent.connect(setEvent)
	
#添加事件 打开菜单
func addEvent(actionName,pos,node):
	print(actionName,pos)	
	var rect=Rect2(Vector2(pos.end.x - 100,pos.position.y),
	Vector2(100,25*InputBind.EVENT_TYPE.size()))
	popMenu.popup(rect)
	actionNode=node
	self.actionName=actionName

#设置事件
func setEvent(useEvent:InputEvent):
	InputMap.action_add_event(actionName,useEvent)
	actionNode.reset()	
	

func _on_default_pressed() -> void:
	InputMap.load_from_project_settings()
	for i in actions.get_children():
		i.reset()


func _on_popup_menu_id_pressed(id: int) -> void:
	if id==0:
		eventDialog.setMode(eventDialog.InputTypes.KEYBOARD)
		eventDialog.popup_centered()
	elif id==1:
		eventDialog.setMode(eventDialog.InputTypes.MOUSE)
		eventDialog.popup_centered()
	elif id==2:
		eventDialog.setMode(eventDialog.InputTypes.JOY_BUTTON)
		eventDialog.popup_centered()
	elif id==3:
		eventDialog.setMode(eventDialog.InputTypes.JOY_AXIS)
		eventDialog.popup_centered()


func _on_save_pressed() -> void:
	InputBind.saveConfig()
	tipDialog.popup_centered()

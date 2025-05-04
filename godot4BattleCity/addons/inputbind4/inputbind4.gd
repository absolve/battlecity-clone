@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_autoload_singleton("InputBind","res://addons/inputbind4/InputBind.gd")


func _exit_tree() -> void:
	remove_autoload_singleton("InputBind")

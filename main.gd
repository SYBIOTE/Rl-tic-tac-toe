extends ColorRect



func _on_TextureRect_gui_input(event):
	$Label3.visible=true
	$Timer.start()


func _on_Timer_timeout():
	$Timer.stop()
	get_tree().change_scene("res://board.tscn")

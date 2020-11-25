extends Node2D
var ik
var jk
var pic
var valueAI1=[]
var valueAI2=[]
func update_display(i,j,picsym):
	ik=i
	jk=j
	pic=picsym
	#print("transfered",ik," ",jk," ",pic)

func return_display():
	return [ik,jk,pic]


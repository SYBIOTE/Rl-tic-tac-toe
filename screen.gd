extends ColorRect
const LENGTH=3
onready var visualscreen=[[$TextureButton,$TextureButton2,$TextureButton3],
[$TextureButton4,$TextureButton5,$TextureButton6],
[$TextureButton7,$TextureButton8,$TextureButton9]
]
onready var resultpage=$result
onready var result_text=$result/Label
var p1=agent.new()
var p2=agent.new()
var env=environment.new()
const NUM = 10000
var orderswitch=2
var player_win=0
var AI_win=0
var draws=0
var trained=false
func _ready():
	trained=load_game(3)
	print("trained",trained)
	set_process(false)
	print("start")
	var state_winner_triples = get_state_hash_and_winner(env)
	var Vx
	var Vo 
	if !trained:
		print("training")
		Vx= initialV_x(env, state_winner_triples)
		Vo = initialV_o(env, state_winner_triples)
	else:
		print("trained data")
		Vx=load_game(2)
		Vo=load_game(1)
	
	p2.setV(Vx)
	p1.setV(Vo)
#	p1.set_verbose(true)
#	p2.set_verbose(true)
	p1.set_symbol(env.x)
	p2.set_symbol(env.o)
	env=environment.new()
	set_symbol(env.o)
	set_process(true)


var sym
var movecor = []
var played = false
var picsym 
func set_symbol(symbol):
	sym = symbol
	if symbol == env.x:
		picsym=preload("res://cross.png")
	else:
		picsym=preload("res://circle.jpg")
func action():
	
	print("make your move")
	var i = movecor[0]
	var j = movecor[1]
	print(i,j)
	if env.is_empty(i, j):
		env.board[i][j] = sym
		env.board[movecor[0]][movecor[1]]= sym
		#print(visualscreen[movecor[0]][movecor[1]].pressed)
		update_display([movecor[0],movecor[1],picsym],true)
		$response.start()
		#print("final",visualscreen[movecor[0]][movecor[1]].pressed)
		played=false
func recieveinput(inputcor):
	movecor = inputcor
	print(visualscreen[movecor[0]][movecor[1]].pressed)
	played=true
var turn="computer" 
var onecall=false
var c_p
func _process(delta):
	if !onecall and !trained:
		onecall=true
		for t in range(1, NUM):
			if t % 500 == 0:
				print(t)
			play_game(p1, p2, environment.new())
		trained=true
		p1.set_verbose(true)
		p2.set_verbose(true)
		p2.eps=.01
		save()
	
	$Label3.visible=false
	
	
	if orderswitch==1:
		vs_human(p2)
	if orderswitch==2:
		vs_human(p1) 
		
	if env.game_over(false):
		print("over")
		c_p.update(env)
		$Timer.start()
		set_process(false)
	
	if Input.is_action_just_pressed("stop"):
		get_tree().quit()

func vs_human(AI):
	c_p=AI
	if turn=="human":
		if played==false:
			pass
		else:
			print("player turn")
			action()
			print(env.board)
			#env.draw_board()
			print("computers turn now")
			
	else:
		c_p.action(env,true)
		update_display()
		print(env.board)
		#env.draw_board()
		var state = env.get_state()
		c_p.update_st_his(state)
		
		turn="human"
		print("players turn now")



class environment:
	var board 
	const x=  -1
	const o=  1
	
	var winner = null
	var ended = false
	var num_states= pow(3,(LENGTH*LENGTH))
	func _init():
		board=[[0,0,0],
				[0,0,0],
				[0,0,0]]
		ended=false
		winner=null
		
	func draw_board():
		for i in range(0, LENGTH):
			var string=""
			print(" ◘◘◘◘◘◘◘◘◘◘◘◘")
			for j in range(0, LENGTH):
				if board[i][j] == x:
					string+=" x ◘"
				elif board[i][j] == o:
					string+=" o ◘"
				else:
					string+="   ◘"
			print(string)
		print(" ◘◘◘◘◘◘◘◘◘◘◘◘")

	func get_triad():
		return [o , x ,0]
	func is_empty(i,j):
		return board[i][j] == 0
	func reward(sym):
		if not game_over(false):
			return 0
		
		if winner == sym:
			return 1
		if winner == null:
			return .1
		else:
			return -1
		
	func get_state():
		var k=0
		var h=0
		var v
		for i in range(0,LENGTH):
			for j in range(0, LENGTH):
				if board[i][j] == 0:
					v = 0
				elif board[i][j] == x:
					v = 1
				elif board[i][j] == o:
					v = 2
				h += (pow(3,k)) * v
				k += 1
		return h
	func game_over(recalc,culprit=false):
		var syms=[x,o]
		if not recalc and ended:
			return ended
		for i in range(0, LENGTH):
			for player in syms:
				if board[i][0]+board[i][1]+board[i][2] == player * LENGTH:
					if !culprit:
						print("hor")
					winner = player
					ended = true
					return true
		
		for j in range(0, LENGTH):
			for player in  syms:  #changed here
				if board[0][j]+board[1][j]+board[2][j] == player * LENGTH:
					if !culprit:
						print("ver")
					winner = player
					ended = true
					return true
					break
		#print("ver checked")
		for player in syms:
			if board[0][0]+board[1][1]+board[2][2]== player * LENGTH:
				if !culprit:
					print("dia")
				winner = player
				ended = true
				return true
				break
			if board[0][2]+board[1][1]+board[2][0] == player * LENGTH:
				if !culprit:
					print("dia")
				winner = player
				ended = true
				return true
		var flag = false
		if board[0][0]!=0 && board[0][1]!=0 && board[0][2]!=0 && board[1][0]!=0 && board[1][1]!=0 && board[1][2]!=0 && board[2][0]!=0 && board[2][1]!=0 && board[2][2]!=0 :
			flag=true
		else:
			flag=false
		if flag==true: 
			if !culprit:
				print(" draw")
			flag=false
			winner = null
			ended = true
			return true

		winner = null
		return false
class agent:
	var eps
	var alpha 
	var verbose = false
	var state_history =[]
	var v
	var sym
	var picsym
	var next_move = null
	func _init(epsilon=.1,alphavar=.5):
		eps = epsilon
		alpha = alphavar
	func setV(value):
		v = value
	func set_symbol(symbol):
		sym = symbol
		if sym == -1:
			picsym=preload("res://cross.png")
		else:
			picsym=preload("res://circle.jpg")
	func set_verbose(ver):
		verbose = ver
	func reset_history():
		state_history = []

	func action(env,show=false):
		randomize()
		var pos2value = {}
		
		var r = randf()
		var best_state = null
		if r<eps:
			if verbose:
				print("random action")
			var possible_moves = []
			for i in range(0, LENGTH):
				for j in range(0, LENGTH):
					if env.is_empty(i, j):
						var move = [i,j]
						possible_moves.append(move)
			var idx = rand_range(0,len(possible_moves))
			next_move= possible_moves[idx]
		else:
			pos2value = {}
			var best_value = -1
			for i in range(0, LENGTH):
				for j in range(0, LENGTH):
					if env.is_empty(i, j):
						# print(sym)
						env.board[i][j] = sym
						var state = env.get_state()
						# env.draw_board()
						env.board[i] [j] = 0
						pos2value[[i,j]] = v[state]
						# print("essentially reward",pos2value[(i, j)])
						if v[state] > best_value:
							best_value = v[state]
							best_state = state
							next_move = [i, j]
							# print("next _move",next_move)
			if verbose:
				var q
				if sym==-1:
					q="x"
				else:
					q="o"
				print("now playing  ",q)
				for i in range(0, LENGTH):
					var string=""
					print(" ◘◘◘◘◘◘◘◘◘◘◘◘")
					for j in range(0, LENGTH):
						if env.is_empty(i,j):
							
							var move=stepify(pos2value[[i,j]],.01)
							string+=" "+str(move)+" ◘"
						else:
							if env.board[i][j] == env.x:
								string+=" x ◘"
							elif env.board[i][j] == env.o:
								string+=" o ◘"
							else:
								string+="   ◘"
					print(string)
				print(" ◘◘◘◘◘◘◘◘◘◘◘◘")
		env.board[next_move[0]] [next_move[1]] = sym
			
		if show ==true:
			print("computer plays",next_move)
			board.update_display(next_move[0],next_move[1],picsym)
		
	func update(env):
		var reward = env.reward(sym)
		var target = reward
		var invertedsthis =[]
		invertedsthis = state_history.duplicate()
		invertedsthis.invert()
		for prev in invertedsthis:
			var value = v[prev] + alpha * (target - v[prev])
			v[prev] = value
			target = value
		reset_history()
	func update_st_his(s):
		state_history.append(s)


		
		
func update_display(needthis = board.return_display(),human=false):
	visualscreen[needthis[0]][needthis[1]].texture_pressed = needthis[2]
	if !visualscreen[needthis[0]][needthis[1]].pressed && !human:
		visualscreen[needthis[0]][needthis[1]].pressed = true
	if visualscreen[needthis[0]][needthis[1]].pressed:
		visualscreen[needthis[0]][needthis[1]].toggle_mode=false



func play_game(p1,p2,env,player=null):
	
#	print("new game",env.board)
	var c_p=null
	var over=false 
	
	while not env.game_over(false,true):
		
		if c_p==p1:
			c_p=p2
		else:
			c_p=p1
				
		# env.draw_board()
		c_p.action(env)
		# print("action taken")
		
		var state = env.get_state()
		# env.draw_board()
		p1.update_st_his(state)
		#print("p1 state updated with ", state)
		p2.update_st_his(state)
		#print("p2 state updated with ", state)
#		update_display()
#	print("end game",env.board
#	print("over")
	p1.update(env)
	p2.update(env)
#	reset_board()



func reset_board():
	print("board reset")
	env=environment.new()
	for i in range(0, 3):
		
			visualscreen[i][0].texture_pressed=null
			visualscreen[i][0].pressed=false
			visualscreen[i][0].toggle_mode=true
			visualscreen[i][1].texture_pressed=null
			visualscreen[i][1].pressed=false
			visualscreen[i][0].toggle_mode=true
			visualscreen[i][2].texture_pressed=null
			visualscreen[i][2].pressed=false
			visualscreen[i][0].toggle_mode=true
func get_state_hash_and_winner(env, i=0, j=0):
	var results = []
	#print(env.get_triad())
	for v in env.get_triad():
		env.board[i][j] = v
		if j == 2:
			if i == 2:
				var state = env.get_state()
				var ended = env.game_over(true,true) # the real culprit
				var winner = env.winner
				results.append([state, winner, ended])
			else:
				results += get_state_hash_and_winner(env, i + 1, 0)
		else:
			results += get_state_hash_and_winner(env, i, j + 1)
	return results

func initialV_x(env,state_winner_triples):
	#_________________________________________________load the existing value here
	var V = []
	V.resize(env.num_states)
	var v

	
	for i in state_winner_triples:
		if i[2]:
			if i[1] == env.x:
				v = 1
			else:
				v = 0
		else:
			v = 0.5
		V[i[0]] = v
	
	return V

func initialV_o(env, state_winner_triples):
	#_________________________________________________load the existing value here
	var V = []
	V.resize(env.num_states)
	var v
	for i in state_winner_triples:
		if i[2]:
			if i[1] == env.o:
				v = 1
			else:
				v = 0
		else:
			v = 0.5
		V[i[0]] = v
	return V





func _on_TextureButton_gui_input(event):
	if event is InputEventMouseButton && env.is_empty(0,0):
		recieveinput([0,0])
		print("tap")

	
func _on_TextureButton2_gui_input(event):
	if event is InputEventMouseButton && env.is_empty(0,1):
		recieveinput([0,1])
		print("tap")

	
func _on_TextureButton3_gui_input(event):
	if event is InputEventMouseButton && env.is_empty(0,2):
		recieveinput([0,2])
		print("tap")

	
func _on_TextureButton6_gui_input(event):
	if event is InputEventMouseButton && env.is_empty(1,2):
		recieveinput([1,2])
		print("tap")


func _on_TextureButton7_gui_input(event):
	if event is InputEventMouseButton && env.is_empty(2,0):
		recieveinput([2,0])


func _on_TextureButton5_gui_input(event):
	if event is InputEventMouseButton && env.is_empty(1,1):
		recieveinput([1,1])
		print("tap")


func _on_TextureButton4_gui_input(event):
	if event is InputEventMouseButton && env.is_empty(1,0):
		recieveinput([1,0])
		print("tap")


func _on_TextureButton9_gui_input(event):
	if event is InputEventMouseButton && env.is_empty(2,2):
		recieveinput([2,2])
		print("tap")


func _on_TextureButton8_gui_input(event):
	if event is InputEventMouseButton && env.is_empty(2,1):
		recieveinput([2,1])
		print("tap")



onready var anim=$result/Label/AnimationPlayer


func _on_replay_gui_input(event):
	if event is InputEventMouseButton:
		save()
		#___________________________________________________call save here
		resultpage.visible=false
		set_process(true)
		anim.stop()


func _on_Timer_timeout():
	$Timer.stop()
	if env.winner==null:
		draws+=1
		result_text.set_text("Draw")
		anim.play("interploate")
	elif env.winner == c_p.sym:
		AI_win+=1
		result_text.set_text("AI Wins")
		anim.play("interploate")
	else:
		player_win+=1
		result_text.set_text("You Win")
		anim.play("interploate")
		print()
	var string="your wins-"+str(player_win)+"\nAI wins-"+str(AI_win)+"\ndraws-"+str(draws)
	$result/Label2.set_text(string)
	
	resultpage.visible=true
	if orderswitch==1:
		set_symbol(env.o)
		print("as fp")
		var turn="human"
		orderswitch=2
	else:
		set_symbol(env.x)
		orderswitch=1
		print("as sp")
		var turn="computer"
	reset_board()


func _on_response_timeout():
	$response.stop()
	turn="computer"

func save():
	var save = {
	"ai1" :  p1.v,
	"ai2" :  p2.v,
	"trained": trained
	}
	print(save["trained"])
	var save_game=File.new()
	save_game.open("user://savegame.save",File.WRITE)
	save_game.store_line(to_json(save))
	save_game.close()
	
	#saves the value function
func load_game(index):
	var save_game = File.new()
	if not save_game.file_exists("user://savegame.save"):
		return 
	save_game.open("user://savegame.save",File.READ)
	while not save_game.eof_reached():
		var current_line = parse_json(save_game.get_line())
		if index==1:
			return current_line["ai1"]
		elif index==2:
			return current_line["ai2"]
		else:
			return current_line["trained"]

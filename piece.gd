extends Node2D

# Declare member variables here. Examples:
enum colors {WHITE, BLACK}
enum piece_types {PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING} 
export (piece_types) var piece_type

var myType
var myColor

var selected = false
var hasMoved = false
var is_in_check = false

var start_x = 0
var start_y = 0

var moves = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match myType:
		piece_types.PAWN:
			$Sprite.frame = 0 if myColor == colors.BLACK else 6
		piece_types.ROOK:
			$Sprite.frame = 1 if myColor == colors.BLACK else 7
		piece_types.KNIGHT:
			$Sprite.frame = 2 if myColor == colors.BLACK else 8
		piece_types.BISHOP:
			$Sprite.frame = 3 if myColor == colors.BLACK else 9
		piece_types.QUEEN:
			$Sprite.frame = 4 if myColor == colors.BLACK else 10
		piece_types.KING:
			$Sprite.frame = 5 if myColor == colors.BLACK else 11
	

 #Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if selected:
		position = lerp(position, get_global_mouse_position(), 20*delta)

func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:	
	if Input.is_action_just_pressed("click"):
		
		start_x = int(floor(get_global_mouse_position().x/64))
		start_y = int(floor(get_global_mouse_position().y/64))
		
		get_node("/root/Board").AssignAttackedSquares()

		
#		if (get_node("/root/Board").board_data[start_y][start_x].piece.myColor == colors.WHITE and \
#			get_node("/root/Board").whites_turn) or \
#			(get_node("/root/Board").board_data[start_y][start_x].piece.myColor == colors.BLACK and \
#			!get_node("/root/Board").whites_turn):
		selected = true
		moves = GetLegalMoves(start_y, start_x, myType)

		for move in moves:
			get_node("/root/Board").board_data[move[0]][move[1]].move_indicator.visible = true
				
	elif Input.is_action_just_released("click") and selected:
		for y in 8:
			for x in 8:
				get_node("/root/Board").board_data[y][x].move_indicator.visible = false
				get_node("/root/Board").board_data[y][x].attack_indicator.get_child(0).visible = false
				get_node("/root/Board").board_data[y][x].attack_indicator.get_child(1).visible = false
			
		selected = false
			
		var x = int(floor(get_global_mouse_position().x/64))
		var y = int(floor(get_global_mouse_position().y/64))

		if moves.has([y, x]):
			# remove enemy piece
			if get_node("/root/Board").board_data[y][x].piece != null:
				print("eat piece! (", piece_types.keys()[get_node("/root/Board").board_data[y][x].piece.myType], ")")
				get_node("/root/Board").board_data[y][x].piece.queue_free()
				get_node("/root/Board").board_data[y][x].piece = null
					
			get_node("/root/Board").board_data[y][x].piece = self
			get_node("/root/Board").board_data[start_y][start_x].piece = null
			
			position.x = x * 64 + 32
			position.y = y * 64 + 32
			
			hasMoved = true	
			get_node("/root/Board").whites_turn = !get_node("/root/Board").whites_turn
			moves = []
			return
		else:
			position.x = start_x * 64 + 32
			position.y = start_y * 64 + 32
	
func GetLegalMoves(y: int, x: int, type: int) -> Array:
	var legal_moves = []
	
	var pieceRange = range(1, 2) if myType == piece_types.KING else range(1, 8)
	
	if myType == piece_types.ROOK or myType == piece_types.QUEEN or myType == piece_types.KING:
		for left in pieceRange:
			if !AddMove(y, x-left, legal_moves):
				break
					
		for right in pieceRange:
			if !AddMove(y, x+right, legal_moves):
				break
			
		for down in pieceRange:
			if !AddMove(y+down, x, legal_moves):
				break
			
		for up in pieceRange:
			if !AddMove(y-up, x, legal_moves):
				break

	if myType == piece_types.BISHOP or myType == piece_types.QUEEN or myType == piece_types.KING:
		for upRight in pieceRange :
			if !AddMove(y-upRight, x+upRight, legal_moves):
				break
		
		for upLeft in pieceRange :
			if !AddMove(y-upLeft, x-upLeft, legal_moves):
				break
			
		for downRight in pieceRange:
			if !AddMove(y+downRight, x+downRight, legal_moves):
				break
		
		for downLeft in pieceRange :
			if !AddMove(y+downLeft, x-downLeft, legal_moves):
				break

	if myType == piece_types.PAWN:
		if myColor == colors.WHITE:
			# movement
			if !hasMoved:
				AddMove(y - 2, x, legal_moves)
			AddMove(y - 1, x, legal_moves)
			
			# captures
			AddMove(y - 1, x - 1, legal_moves)
			AddMove(y - 1, x + 1, legal_moves)
			
		else:
			if !hasMoved:
				AddMove(y + 2, x, legal_moves)
			AddMove(y + 1, x, legal_moves)
			
				
			# captures
			AddMove(y + 1, x-1, legal_moves)
			AddMove(y + 1, x+1, legal_moves)

	if myType == piece_types.KNIGHT:
		AddMove(y - 2, x - 1, legal_moves)
		AddMove(y - 2, x + 1, legal_moves)
		AddMove(y + 1, x - 2, legal_moves)
		AddMove(y - 1, x - 2, legal_moves)
		AddMove(y + 1, x + 2, legal_moves)
		AddMove(y - 1, x + 2, legal_moves)
		AddMove(y + 2, x + 1, legal_moves)
		AddMove(y + 2, x - 1, legal_moves)
		
	return legal_moves

func AddMove(y: int, x: int, legal_moves: Array) -> bool:	
	if (y >= 0 and y < 8 and x >= 0 and x < 8):
		
		var target_square = get_node("/root/Board").board_data[y][x]
		
		if target_square.piece != null:
			if (!myType == piece_types.PAWN) or (myType == piece_types.PAWN and x != start_x):
				if target_square.piece.myColor == myColor:
					SetAttackedSquare(y, x)
					return false
					
				SetAttackedSquare(y, x)			
				legal_moves.append([y, x])	

				return false
				
		elif target_square.piece == null:
			if !myType == piece_types.PAWN or (myType == piece_types.PAWN and x == start_x):
				SetAttackedSquare(y, x)
				legal_moves.append([y, x])
	else:
		return false

	return true

func SetAttackedSquare(y: int, x: int) -> void:
	if myColor == colors.WHITE:
		get_node("/root/Board").board_data[y][x].is_attacked_by_white = true
	elif myColor == colors.BLACK:
		get_node("/root/Board").board_data[y][x].is_attacked_by_black= true

extends Node2D

# Declare member variables here. Examples:
enum colors {WHITE, BLACK}
enum piece_types {PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING} 
export (piece_types) var piece_type

var myColor

var selected = false
var hasMoved = false

var start_x = 0
var start_y = 0

var moves = []
var legal_moves = []

var capture_piece = preload("res://art/capture_piece.png")
var check_outline = preload("res://check_outline.tres")

func init(stored_move: bool) -> void:
	hasMoved = stored_move
	
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass

 #Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if selected:
		position = lerp(position, get_global_mouse_position(), 20*delta)
	
func _on_Area2D_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:	
	if Input.is_action_just_pressed("click"):
		
		legal_moves = GetLegalMoves(floor(get_global_mouse_position().y/64), int(floor(get_global_mouse_position().x/64)), true)
		
		get_node("/root/Board").AssignAttackedSquares()	

#		ShowAttackedSquares()
		
		if selected:
			for move in legal_moves:		
				if get_node("/root/Board").board_data[move[0]][move[1]].piece != null:
					get_node("/root/Board").board_data[move[0]][move[1]].move_indicator.get_node("Icon").texture = load("res://art/capture_piece.png")
				else:
					get_node("/root/Board").board_data[move[0]][move[1]].move_indicator.get_node("Icon").texture = load("res://art/move_indicator.png")
					
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
		
		if legal_moves.has([y, x]):	
			get_node("/root/Board").MovePieceTo(start_y, start_x, y, x)		
		else:
			get_node("/root/Board").AssignAttackedSquares()
			get_node("/root/Board").IsKingInCheck()
			position.x = start_x * 64 + 32
			position.y = start_y * 64 + 32


func MoveRookTo(_y: int, _x: int, y: int, x: int) -> void:
		get_node("/root/Board").board_data[y][x].piece = self
		position.x = x * 64 + 32
		position.y = y * 64 + 32
		get_node("/root/Board").board_data[_y][_x].piece = null


func AddStoredPieceAt(y: int, x: int, storedPiece: Node2D) -> void:
	var type = "P"
	match storedPiece.piece_type:
		piece_types.PAWN:
			type = "P"
		piece_types.ROOK:
			type = "R"
		piece_types.KNIGHT:
			type = "N"
		piece_types.BISHOP:
			type = "B"
		piece_types.QUEEN:
			type = "Q"
		piece_types.KING:
			type = "K"
	get_node("/root/Board").AddPiece(y, x, storedPiece.myColor == colors.BLACK, type, storedPiece.hasMoved)

func GetLegalMoves(y: int, x: int, selectable: bool) -> Array:
	start_y = y 
	start_x = x
	
	if get_node("/root/Board").board_data[y][x].piece != null:
		if (get_node("/root/Board").board_data[y][x].piece.myColor == colors.WHITE and \
			get_node("/root/Board").whites_turn) or \
			(get_node("/root/Board").board_data[y][x].piece.myColor == colors.BLACK and \
			!get_node("/root/Board").whites_turn):
				selected = selectable		
				moves = get_node("/root/Board").board_data[y][x].piece.GetMoves(y, x)

	legal_moves = []
	for move in moves:
		#  "play" this move on the board
		var stored_piece = null
		var target_square = get_node("/root/Board").board_data[move[0]][move[1]]
		var my_square = get_node("/root/Board").board_data[y][x]

		if target_square.piece != null:
			stored_piece = target_square.piece
			target_square.piece.queue_free()	

		target_square.piece = self
		my_square.piece = null

		# then we have to assign attacked squares
		get_node("/root/Board").AssignAttackedSquares()

		# at this point, we can check if the move is legal: 		
		# if the king is on a square that is attacked by opposite color, move is illegal
		if !get_node("/root/Board").IsKingInCheck():
			legal_moves.push_back(move)

		# finally, we must return the board to its state before the move was played
		if stored_piece != null:
			AddStoredPieceAt(move[0], move[1], stored_piece)
		else:
			target_square.piece = null

		my_square.piece = self
		
	return legal_moves
	
func AddMove(y: int, x: int) -> bool:	
	if (y >= 0 and y < 8 and x >= 0 and x < 8):	
		var target_square = get_node("/root/Board").board_data[y][x]
		
		if target_square.piece != null:
			if target_square.piece.myColor == myColor:
				SetAttackedSquare(y, x)
				return false

			SetAttackedSquare(y, x)			
			moves.append([y, x])	

			return false
#
		elif target_square.piece == null:
			SetAttackedSquare(y, x)
			moves.append([y, x])
	else:
		return false

	return true

func AddPawnMove(y: int, x: int) -> bool:
	if (y >= 0 and y < 8 and x >= 0 and x < 8):	
		var target_square = get_node("/root/Board").board_data[y][x]
			
		if x != start_x:			
			SetAttackedSquare(y, x)	
			
			if target_square.piece != null and target_square.piece.myColor != myColor:			
				moves.append([y, x])
				
		elif x == start_x and target_square.piece == null:
			moves.append([y, x])
		elif x == start_x and target_square.piece != null:
			return false
		
	else:
		return false

	return true

func AddCastleMove(y: int, x: int, kingside: bool) -> bool:
	var target_square 
	
	if kingside:
		if get_node("/root/Board").board_data[y][x+3].piece != null:
			if get_node("/root/Board").board_data[y][x+3].piece.hasMoved:
				return false
		else:
			return false
			
		for right in range(1 , 3):
			target_square = get_node("/root/Board").board_data[y][x+right]
			
			if myColor == colors.WHITE and (target_square.is_attacked_by_black or target_square.piece != null) or \
			myColor == colors.BLACK and (target_square.is_attacked_by_white or target_square.piece != null):
				return false
				
	elif !kingside:
		if get_node("/root/Board").board_data[y][x-4].piece != null:
			if get_node("/root/Board").board_data[y][x-4].piece.hasMoved:
				return false
		else:
			return false
			
		for left in range(1 , 4):
			target_square = get_node("/root/Board").board_data[y][x-left]

			if target_square.piece != null:
				return false
			
			if left < 3:
				if myColor == colors.WHITE and (target_square.is_attacked_by_black) or \
				myColor == colors.BLACK and (target_square.is_attacked_by_white):
					return false

	if !get_node("/root/Board").IsKingInCheck():
		if kingside:
			moves.append([y, x+2])
		else:
			moves.append([y, x-2])
		return true
	
	return false


func SetAttackedSquare(y: int, x: int) -> void:
	if myColor == colors.WHITE:
		get_node("/root/Board").board_data[y][x].is_attacked_by_white = true
	elif myColor == colors.BLACK:
		get_node("/root/Board").board_data[y][x].is_attacked_by_black= true

func ShowAttackedSquares() -> void:
	for y in 8:
		for x in 8:
			if get_node("/root/Board").board_data[y][x].is_attacked_by_white:
				get_node("/root/Board").board_data[y][x].attack_indicator.get_child(0).visible = true
			if get_node("/root/Board").board_data[y][x].is_attacked_by_black:
				get_node("/root/Board").board_data[y][x].attack_indicator.get_child(1).visible = true

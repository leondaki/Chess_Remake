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
		var y = int(floor(get_global_mouse_position().y/64))
		var x = int(floor(get_global_mouse_position().x/64))
		
		if get_node("/root/Board").board_data[y][x].piece != null:
			if (get_node("/root/Board").board_data[y][x].piece.myColor == colors.WHITE and \
				get_node("/root/Board").whites_turn) or \
				(get_node("/root/Board").board_data[y][x].piece.myColor == colors.BLACK and \
				!get_node("/root/Board").whites_turn):
					selected = true			
					legal_moves = GetLegalMoves(y, x)		
					get_node("/root/Board").AssignAttackedSquares()	
#					ShowAttackedSquares()
		
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
			get_node("/root/Board").IsKingInCheck(false)
			position.x = start_x * 64 + 32
			position.y = start_y * 64 + 32


func GetLegalMoves(y: int, x: int) -> Array:
	start_y = y 
	start_x = x
	
	moves = get_node("/root/Board").board_data[y][x].piece.GetMoves(y, x)

	legal_moves = []
	for move in moves:
		#  "play" this move on the board
		var stored_piece = null
		var piece_has_moved
		var en_passantable = false
		
		var my_square = get_node("/root/Board").board_data[y][x]
		var target_square = get_node("/root/Board").board_data[move[0]][move[1]]
		
		var is_en_passant_move = false	
		if my_square.piece.piece_type == my_square.piece.piece_types.PAWN and \
		x != move[1] and target_square.piece == null:
			is_en_passant_move = true
		
		if is_en_passant_move:
			if my_square.piece.myColor == my_square.piece.colors.WHITE:
				stored_piece = get_node("/root/Board").board_data[move[0]+1][move[1]].piece.duplicate()
				en_passantable = get_node("/root/Board").board_data[move[0]+1][move[1]].piece.capturable_en_passant
				get_node("/root/Board").board_data[move[0]+1][move[1]].piece.queue_free()
				get_node("/root/Board").board_data[move[0]+1][move[1]].piece = null
			elif my_square.piece.myColor == my_square.piece.colors.BLACK:
				stored_piece = get_node("/root/Board").board_data[move[0]-1][move[1]].piece.duplicate()
				en_passantable = get_node("/root/Board").board_data[move[0]-1][move[1]].piece.capturable_en_passant
				get_node("/root/Board").board_data[move[0]-1][move[1]].piece.queue_free()
				get_node("/root/Board").board_data[move[0]-1][move[1]].piece = null
				
		elif target_square.piece != null:
			stored_piece = target_square.piece.duplicate()
			piece_has_moved = target_square.piece.hasMoved
			
			if target_square.piece.piece_type == my_square.piece.piece_types.PAWN:
				en_passantable = target_square.piece.capturable_en_passant

			target_square.piece.queue_free()
			target_square.piece = null	

		target_square.piece = self
		my_square.piece = null

		# then we have to assign attacked squares
		get_node("/root/Board").AssignAttackedSquares()

		# at this point, we can check if the move is legal: 		
		# if the king is on a square that is attacked by opposite color, move is illegal
		if !get_node("/root/Board").IsKingInCheck(false):
			legal_moves.push_back(move)

		# finally, we must return the board to its state before the move was played
		my_square.piece = self
			
		if stored_piece != null:
			var type = "P"
			match stored_piece.piece_type:
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
					
			if is_en_passant_move:
				if my_square.piece.myColor == target_square.piece.colors.WHITE:
					get_node("/root/Board").AddPiece(move[0]+1, move[1], get_node("/root/Board").whites_turn, type, true, en_passantable)
					target_square.piece = null
				else:
					get_node("/root/Board").AddPiece(move[0]-1, move[1], get_node("/root/Board").whites_turn, type, true, en_passantable)
					target_square.piece = null
			else:
				get_node("/root/Board").AddPiece(move[0], move[1], get_node("/root/Board").whites_turn, type, piece_has_moved, en_passantable)
		else:
			target_square.piece = null

	return legal_moves

func MoveRookTo(_y: int, _x: int, y: int, x: int) -> void:
	get_node("/root/Board").board_data[y][x].piece = self
	position.x = x * 64 + 32
	position.y = y * 64 + 32
	get_node("/root/Board").board_data[_y][_x].piece = null


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

extends Node2D

# Declare member variables here. Examples:
#var starting_fen = "8/2k1P3/8/4p1K1/8/8/8/8"
var starting_fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
#var starting_fen = "r1bqkb1r/pppp1ppp/2n2n2/1B2p3/4P3/5N2/PPPP1PPP/RNBQK2R"

# pieces 
var PAWN = preload("res://Pieces/PAWN.tscn")
var ROOK = preload("res://Pieces/ROOK.tscn")
var KNIGHT = preload("res://Pieces/KNIGHT.tscn")
var BISHOP = preload("res://Pieces/BISHOP.tscn")
var QUEEN = preload("res://Pieces/QUEEN.tscn")
var KING = preload("res://Pieces/KING.tscn")

var move_indicator = load("res://move_indicator.tscn")
var attack_indicator = load("res://attack_indicator.tscn")
var red_square = load("res://check_indicator.tscn")

var height = 8
var width = 8

var board_data = []

var whites_turn = true
var num_moves = []

class Square:
	var x
	var y
	
	var piece
	var move_indicator
	var attack_indicator
	
	var is_attacked_by_white = false
	var is_attacked_by_black = false
	
	func _init(_x: int, _y: int):
		x = _x*64 + 32
		y = _y*64 + 32

class Move:
	var piece_color
	var piece_type
	
	var from
	var to
	
	func _init(_type: String, _from: Array, _to: Array):
		piece_type = _type
		from = _from
		to = _to
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CreateBoard()		
	ReadFEN()
	CountMoves()
	
func CreateBoard() -> void:
	for y in height:
		board_data.append([])
		for x in width:
			board_data[y].append(Square.new(x, y))

			var indicator = move_indicator.instance()
			board_data[y][x].move_indicator = indicator
			
			indicator.position.x = x*64 + 32
			indicator.position.y = y*64 + 32
			
			indicator.visible = false
			add_child(indicator)
			
			
			var atk_indicator = attack_indicator.instance()
			board_data[y][x].attack_indicator = atk_indicator
			
			atk_indicator.position.x = x*64 + 16
			atk_indicator.position.y = y*64 + 16
			
			add_child(atk_indicator)

func ReadFEN() -> void:
	# read the starting fen
	var i = 0
	var j = 0	
	for s in starting_fen:
		if s != "/" and !s.is_valid_integer():
			AddPiece(i, j, s == s.to_lower(), s, false)
			j += 1
			if j == width:
				j = 0
				i += 1
		elif s.is_valid_integer():
			j += int(s)
			if j == width:
				j = 0
				i += 1	
					
func AddPiece(i: int, j: int, isBlack: bool, type: String, hasMoved: bool) -> void:
	var new_piece
	
	match type.to_upper():
		"P":
			new_piece = PAWN.instance()
		"R":
			new_piece = ROOK.instance()
		"N":
			new_piece = KNIGHT.instance()
		"B":
			new_piece = BISHOP.instance()
		"Q":
			new_piece = QUEEN.instance()
		"K":
			new_piece = KING.instance()
			
	if isBlack:
		new_piece.myColor = new_piece.colors.BLACK
	else:
		new_piece.myColor = new_piece.colors.WHITE
	
	new_piece.init(hasMoved)
	
	board_data[i][j].piece = new_piece

	new_piece.position.x = j * 64 + 32
	new_piece.position.y = i * 64 + 32

	add_child(new_piece)

func AssignAttackedSquares() -> void:
	for y in 8:
		for x in 8:
			board_data[y][x].is_attacked_by_black = false
			board_data[y][x].is_attacked_by_white = false

	for y in 8:
		for x in 8:
			var target_square = board_data[y][x]
			if target_square.piece != null:
				target_square.piece.GetMoves(y, x)

func IsKingInCheck() -> bool:
	for y in 8:
		for x in 8:
			var target_square = board_data[y][x]

			if target_square.piece != null:
				if (target_square.piece.piece_type == target_square.piece.piece_types.KING):
					if (target_square.piece.myColor == target_square.piece.colors.WHITE and \
						target_square.is_attacked_by_black and whites_turn) or \
						(target_square.piece.myColor == target_square.piece.colors.BLACK and \
						 target_square.is_attacked_by_white and !whites_turn):
							target_square.piece.get_child(0).material = target_square.piece.check_outline
							return true
					else:
						target_square.piece.get_child(0).material = null
	return false

func CountMoves() -> int:
	num_moves = []
	for y in 8:
		for x in 8:
			var target_square = board_data[y][x]
					
			if target_square.piece != null:
				if target_square.piece.myColor == target_square.piece.colors.BLACK and !whites_turn or \
				target_square.piece.myColor == target_square.piece.colors.WHITE and whites_turn:
					for move in target_square.piece.GetLegalMoves(y, x, false):
						var files = ["a", "b", "c", "d", "e", "f", "g", "h"]
						num_moves.append(Move.new(target_square.piece.piece_types.keys()[target_square.piece.piece_type], \
						 [files[x], 8-y], [files[move[1]], 8-move[0]]))
	
#	for move in num_moves:		
#		print(move.piece_type, ": ", move.from[0], move.from[1], " ~> ", move.to[0], move.to[1])	
#
#
#	if !whites_turn:		
#		print('Black has ', num_moves.size(), ' legal moves.')
#	else:
#		print('White has ', num_moves.size(), ' legal moves.')
	
	return num_moves.size()


func MovePieceTo(start_y: int, start_x: int, y: int, x: int) -> void:
	var start_square = board_data[start_y][start_x]
	var target_square = board_data[y][x]
	
	# pawn promotion (auto queen)	
	if start_square.piece.piece_type == start_square.piece.piece_types.PAWN and \
		(start_square.piece.myColor == start_square.piece.colors.WHITE and y == 0 or \
		start_square.piece.myColor == start_square.piece.colors.BLACK and y == 7):	
			var new_queen = QUEEN.instance()
			
			if whites_turn:
				new_queen.myColor = new_queen.colors.WHITE
			else:
				new_queen.myColor = new_queen.colors.BLACK
		
			add_child(new_queen)
			
			start_square.piece.queue_free()
			start_square.piece = new_queen

	# move rooks after castling
	if start_square.piece.piece_type == start_square.piece.piece_types.KING:
		if x - start_x == 2: 
			get_node("/root/Board").board_data[y][start_x+3].piece.MoveRookTo(y, start_x+3, y, x-1)
		elif x - start_x == -2:
			get_node("/root/Board").board_data[y][start_x-4].piece.MoveRookTo(y, start_x-4, y, x+1)

	if target_square.piece != null:
		target_square.piece.queue_free()
		
	start_square.piece.hasMoved = true	
	board_data[y][x].piece = start_square.piece 
	start_square.piece = null
	
	target_square.piece.position.x = x * 64 + 32
	target_square.piece.position.y = y * 64 + 32
	whites_turn = !whites_turn	

	AssignAttackedSquares()

	var king_checked = IsKingInCheck()

	if CountMoves() == 0:
		print("CHECKMATE!") if king_checked else print("Stalemate.")

		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

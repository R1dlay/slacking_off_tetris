#Base Tetris logic adapted from video: 
#Title: Beginner Godot Tutorial - How to Make Tetris
#Author: Coding With Russ
#Date: Nov 5, 2023
#URL: https://youtu.be/2T2Fkzwf6FM?si=EsoPkz0qBYQ7HkaJ

extends Node2D

# === Signals === (snake_case)

# === Enums === (PascalCase, members CONSTANT_CASE)

# === Constants === (CONSTANT_CASE)
# = Grid Variables =
#Grid size variables
const COLS : int = 10;
const ROWS : int = 20;

# = Movement Variables =
#Grid starting position, which is where a tetromino is initially spawned
const START_POS := Vector2i(5, 1)

#The max amount of steps until a piece is moved
const STEPS_REQ : int = 100

#Stores the proper direction vectors in an easily accesible array
const DIRECTIONS := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]

# === Exported Vars === (snake_case)

# === Public Vars === (snake_case)
# = Grid Variables =
#The grid is layered as the board in the background and the active piece layer drawn on top of it
@onready var board_layer: TileMapLayer = $BoardLayer
@onready var active_layer: TileMapLayer = $ActiveLayer

# = Movement Variables =
#Has a counter for each direction, which moves a piece when it hits the max steps
var steps : Array

#Establishes a variable for tracking a tetromino's position as it falls
var cur_pos : Vector2i

#Establishes a variable for determining how fast pieces fall
var speed : float

# = Tetrominoes =
#The Teris grid uses a tilemap, then draws the pieces onto the grid as they drop. This simplifies collision and
#objects but does require that every piece be mapped out on a small grid. Think of it as a "memory" of shapes and
#their rotations that the grid can draw on to the tilemap. Each array represents a rotation of a particular 
#tetromino, and each point in the array represents a vector that contains ann X and Y point. The last array for
#each section collects all the rotation of a particular tetromino letter/shape.

#I/Line Tetromino
var i_0 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(3, 1)]
var i_90 := [Vector2i(2, 0), Vector2i(2, 1), Vector2i(2, 2), Vector2i(2, 3)]
var i_180 := [Vector2i(0, 2), Vector2i(1, 2), Vector2i(2, 2), Vector2i(3, 2)]
var i_270 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(1, 3)]
var i := [i_0, i_90, i_180, i_270]

#T Tetromino
var t_0 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var t_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var t_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var t_270 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var t := [t_0, t_90, t_180, t_270]

#O/Square Tetromino
var o_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_90 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_180 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1)]
var o := [o_0, o_90, o_180, o_270]

#Z Tetromino
var z_0 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1)]
var z_90 := [Vector2i(2, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]
var z_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
var z_270 := [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(0, 2)]
var z := [z_0, z_90, z_180, z_270]

#S Tetromino
var s_0 := [Vector2i(1, 0), Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1)]
var s_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
var s_180 := [Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2), Vector2i(1, 2)]
var s_270 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(1, 2)]
var s := [s_0, s_90, s_180, s_270]

#L Tetromino
var l_0 := [Vector2i(2, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var l_90 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2), Vector2i(2, 2)]
var l_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(0, 2)]
var l_270 := [Vector2i(0, 0), Vector2i(1, 0), Vector2i(1, 1), Vector2i(1, 2)]
var l := [l_0, l_90, l_180, l_270]

#J Tetromino
var j_0 := [Vector2i(0, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1)]
var j_90 := [Vector2i(1, 0), Vector2i(2, 0), Vector2i(1, 1), Vector2i(1, 2)]
var j_180 := [Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(2, 2)]
var j_270 := [Vector2i(1, 0), Vector2i(1, 1), Vector2i(0, 2), Vector2i(1, 2)]
var j := [j_0, j_90, j_180, j_270]

#This shapes array colects all of the different tetrominoes into one array, with each element being the array that
#collects every rotation for the specific shape
var shapes := [i, t, o, z, s, l, j]

#This duplicate of the shapes array represents the "bag," and is the array used in the 7-bag randomization to preserve
#the original array of all the shapes, as this one will be continually modified
var bag := shapes.duplicate()

# = Tetromino Tileset =
#Provides the ID of the tileset that is used for drawing the Tetrominoes, referred to as the atlas in functions
var tile_id : int = 0

#Provides an index from the tilest that corresponds to the current and next Tetromino being dropped
var piece_atlas : Vector2i
var next_piece_atlas : Vector2i

# = Game State Variables =
#Variables that define what type o piece the current active one is, and what type of piece the next one will be
var piece_type
var next_piece_type

#Variables that track the current game piece object. piece_type simply defined what the current piece is in a simple
#variable that is easy to access, while active_piece contains all the relevant information for drawing it onto the 
#grid. rotation_index keeps track of the active_piece's current rotation
var active_piece : Array
var rotation_index : int = 0

# === Private Vars === (_underscored_snake_case)

# === Godot Methods ===

func  _ready() -> void:
	new_game()

func new_game():
	#Resets the piece dropping speed and step counters
	speed = 1
	steps = [0, 0, 0] #0: Left, 1: Right, 2: Down
	
	piece_type = pick_piece()
	
	piece_atlas = Vector2i(shapes.find(piece_type), 0)
	
	create_piece()

#Built in virtual function that is called when a discrete user action is detected
func _input(event):
	#These inputs are here to prevent the rapid rotation you would get from one brief click in process, which is
	#called every single frame
	#Listens for the rotate clockwise input
	if Input.is_action_pressed("rotate_cw"):
		#Calls the corresponding rotation function 
		rotate_piece_cw()
	#Listens for the rotate counterclockwise input
	elif Input.is_action_just_pressed("rotate_ccw"):
		#Calls the corresponding rotation function 
		rotate_piece_ccw()

#Built-in function called every frame
func _process(_delta):
	#Listens for inputs from the player in the cardinal directions (besides up)
	if Input.is_action_pressed("left"):
		#Greatly increments left steps
		steps[0] += 10
	elif Input.is_action_pressed("right"):
		#Greatly increments right steps
		steps[1] += 10
	elif Input.is_action_pressed("down"):
		#Greatly increments down steps
		steps[2] += 10
	
	#Increments the down steps counter every frame by speed
	steps[2] += speed
	
	#Checks each direction's step counter
	for x in range (steps.size()):
		#If a direction's step counter has surpassed the steps required, the piece is moved in the proper direction
		#and the step counter for that direction is reset
		if steps[x] > STEPS_REQ:
			move_piece(DIRECTIONS[x])
			steps[x] = 0

##This function randomly picks a tetromino using 7-bag randomization. This is where a "bag" of all seven tetrominoes 
##is created, and from there the game randomly picks from the "bag" until it is empty, where it is once again filled
##with each tetromino once. This makes sure the player continually sees every single tetromino, and no tetromino is
##seen too much.
func pick_piece():
	#Local piece variable
	var piece
	
	#Checks if the bag array is empty or not
	if not bag.is_empty():
		#If the bag is not empty, it is shuffled and the front piece is popped out of the array and assigned to piece
		bag.shuffle()
		piece = bag.pop_front()
	else:
		#If the bag is empty, it is refilled using the shapes array and then the same code from above runs
		bag = shapes.duplicate()
		bag.shuffle()
		piece = bag.pop_front()
		
	#Method returns the local piece variable
	return piece

##This function is used to draw the pieces onto the grid. The first argument it takes is any tetromino as piece, which
##contains the coordinates for how the piece should be drawn onto the grid at any given rotation. The second argument
##is a vector which determines which position on the grid it should start drawing the piece. The last argument is the
##coordinates on the tetromino atlas for the color desired
func draw_piece(piece, pos, atlas):
	#Iterates through the coordinates of the piece fed to the function
	for x in piece:
		#For each coordinate iteration a colored tile is drawn onto the position using the tetromino atlas and the
		#piece position, which is adjusted based on the local coordinates of the individual piece shape
		active_layer.set_cell(pos + x, tile_id, atlas)

##Much like draw_piece, this function iterates through each coordinate in a given tetrominoes orientation. However,
##it references the active piece and current grid position instead, and uses that to clear a previous piece drawing.
func clear_piece():
	#Iteration through active tetromino orientation
	for x in active_piece:
		#Erases tetromino drawing using the current position value
		active_layer.erase_cell(cur_pos + x)

##Creates a new tetromino at the top of the board
func create_piece():
	#Resets the variables so it can spawn a new piece at the start position
	steps = [0, 0, 0]
	cur_pos = START_POS
	active_piece = piece_type[rotation_index]
	
	#Calls the draw piece function with the reset variables
	draw_piece(active_piece, cur_pos, piece_atlas)

##Rotates the current active piece clockwise
func rotate_piece_cw():
	#Checks if the rotation is valid
	if can_rotate_cw():
		#Clears the piece from the board to prevent ghost pieces
		clear_piece()
		
		#Modifies the rotation index by + 1, using the modular division operator to loop it if it goes out of range
		rotation_index = (rotation_index + 1) % 4
		#Assigns the active piece the new rotation index
		active_piece = piece_type[rotation_index]
		
		#Redraws the piece with its newly assigned rotation index
		draw_piece(active_piece, cur_pos, piece_atlas)

##Rotates the current active piece counterclockwise
func rotate_piece_ccw():
	#Checks if the rotation is valid
	if can_rotate_ccw():
		#Clears the piece from the board to prevent ghost pieces
		clear_piece()
		
		#Modifies the rotation index by + 1, using the posmod function to loop it if it goes out of range while ensuring
		#that the result is positive
		rotation_index = posmod((rotation_index - 1), 4)
		#Assigns the active piece the new rotation index
		active_piece = piece_type[rotation_index]
		
		#Redraws the piece with its newly assigned rotation index
		draw_piece(active_piece, cur_pos, piece_atlas)

##Fed a direction vector, which is then used to move the active tetromino's position
func move_piece(dir):
	#Using the established function, verifies if the directional movement is valid within the grid
	if can_move(dir):
		#Clears the previous piece drawing before starting any movement
		clear_piece()
		
		#Increments current position in the direction that is fed to the method
		cur_pos += dir
		
		#Calls draw piece with the new position
		draw_piece(active_piece, cur_pos, piece_atlas)

##Using the outer board layer, the function returns the tile source ID at the given coordinates, in this case the
##position being feed to the function. If the position exists, true is returned, and if it doesn't, false is returned
##I need to research more of the minutiae as to why this works this way with tilemaplayer as opposed to how it works
##in the video with Tilemap
func is_free(pos):
	return board_layer.get_cell_source_id(pos) == -1

##verifies whether the current active piece can move in the direction that is being fed to the function
func can_move(dir):
	#Local can move boolean
	var cm = true
	
	#Iterates through each coordinate in the active piece
	for x in active_piece:
		#Checks the "is free" function against each coordinate of the tetromino relative to the current position and
		#direction that the piece being attempted to be moved in.
		if is_free(x + cur_pos + dir + dir): #Direction is used twice because there is an offset for some reason, another thing to look into exactly why
			#If a space is not free, can move is set to false
			cm = false
			
	#Returns whether the piece can move or not
	return cm

##Checks if rotating clockwise is valid, or if it interferes with the grid border
func can_rotate_cw():
	#Local "can rotate" boolean
	var cr = true
	
	#Tests the rotation using a temporary rotation index variable
	var temp_rotation_index = (rotation_index + 1) % 4
	
	#Checks the temporary rotation against the current piece and its position
	for x in piece_type[temp_rotation_index]:
		#If the position it is attempting to be moved into is not free, "can rotate" is set to false
		if not is_free(x + cur_pos):
			cr = false

##Checks if rotating counterclockwise is valid, or if it interferes with the grid border
func can_rotate_ccw():
	#Local "can rotate" boolean
	var cr = true
	
	#Tests the rotation using a temporary rotation index variable
	var temp_rotation_index = posmod((rotation_index - 1), 4)
	
	#Checks the temporary rotation against the current piece and its position
	for x in piece_type[temp_rotation_index]:
		#If the position it is attempting to be moved into is not free, "can rotate" is set to false
		if not is_free(x + cur_pos):
			cr = false

# === Further Methods === (public snake_case, private _underscored_snake_case, local vars snake_case)

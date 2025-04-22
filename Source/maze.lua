import "mazeSquare"

local pd <const> = playdate
local gfx <const> = pd.graphics

local tilemap = gfx.imagetable.new("Images/maze_tilemap")

local map = gfx.tilemap.new()
map:setImageTable(tilemap)
map:setSize( 15, 9 )

-- Maximum map size: 15 x 9 tiles

class('Maze').extends()

function Maze:init( seed )
    self.seed = seed
    print("Seed entered: ", self.seed)
    self.squares = {}

    mazeIndex = 1

    xCoord = 6 -- Top left corner of screen (accounting for border)
    yCoord = 4

    for i = 1, 9 do -- 9 rows
        for j = 1, 15 do -- 15 columns
            print("Creating maze square at: ", j, ", ", i, " with render value of ", self.seed:sub(mazeIndex,mazeIndex))
            self.squares[mazeIndex] = { tile =  MazeSquare( xCoord, yCoord, self.seed:sub(mazeIndex,mazeIndex) ) }
            print("Maze square created at: ", self.squares[mazeIndex].tile.xCoord, ",", self.squares[mazeIndex].tile.yCoord, "with render value of", self.squares[mazeIndex].tile.renderValue)
            map:setTileAtPosition( j, i, self.squares[mazeIndex].tile.renderValue )
            mazeIndex = mazeIndex + 1
            xCoord = xCoord + 26
        end
        yCoord = yCoord + 26
    end
    
    map:draw( 6, 4 )

end
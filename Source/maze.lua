import "mazeSquare"

local pd <const> = playdate
local gfx <const> = pd.graphics

local tilemap = gfx.imagetable.new("Images/maze_tilemap")

local map = gfx.tilemap.new()
map:setImageTable(tilemap)
map:setSize( 15, 9 )

-- Maximum map size: 15 x 9 tiles

class('Maze').extends()

function Maze:init( seed, startX, startY )
    self.seed = seed
    print("Seed entered: ", self.seed)
    self.squares = {}

    self.startX = startX
    self.startY = startY

    mazeIndex = 1

    -- xCoord = 6 -- Top left corner of screen (accounting for border)
    -- yCoord = 4 -- Not needed anymore

    for i = 1, 9 do -- 9 rows
        self.squares[i] = {} -- Create 2D Array (table) - easier to manage player position
    
        for j = 1, 15 do -- 15 columns
            self.squares[i][j] = 
                { tile = MazeSquare( j, i, self.seed:sub( mazeIndex, mazeIndex ) ) }
            map:setTileAtPosition( j, i, self.squares[i][j].tile.renderValue)
            mazeIndex = mazeIndex + 1
        end
        
    end
    
    map:draw( 6, 4 )

end

function Maze:updateMaze()
    map:draw(6, 4)
end
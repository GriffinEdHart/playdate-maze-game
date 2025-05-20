import "mazeSquare"

local pd <const> = playdate
local gfx <const> = pd.graphics

local tilemap = gfx.imagetable.new("Images/maze_tilemap")



local map = gfx.tilemap.new()
map:setImageTable(tilemap)
map:setSize( 15, 9 )

-- Maximum map size: 15 x 9 tiles

class('Maze').extends()

function Maze:init( levelData )
    self.seed = levelData.seed
    print("Seed entered: ", self.seed)
    self.squares = {}



    mazeIndex = 1

    -- xCoord = 6 -- Top left corner of screen (accounting for border)
    -- yCoord = 4 -- Not needed anymore

    for i = 1, 9 do -- 9 rows
        self.squares[i] = {} -- Create 2D Array (table) - easier to manage player position
    
        for j = 1, 15 do -- 15 columns
            if j == levelData.levelEnd.x and i == levelData.levelEnd.y then
                isEnd = 1
            else
                isEnd = 0
            end
            isFruit = 0
            self.squares[i][j] = 
                { tile = MazeSquare( j, i, self.seed:sub( mazeIndex, mazeIndex, isEnd, isFruit ) ) }
            map:setTileAtPosition( j, i, self.squares[i][j].tile.renderValue)
            mazeIndex = mazeIndex + 1
        end
        
    end
    
    
    map:draw( 6, 4 )
    

end

function Maze:updateMaze()
    map:draw(6, 4)
    -- startImage:draw(levelData.levelStart.x * 26 - 15, levelData.levelStart.y * 26 - 15)
    -- exitImage:draw(levelData.levelEnd.x * 26 - 15, levelData.levelEnd.y * 26 - 15)
end
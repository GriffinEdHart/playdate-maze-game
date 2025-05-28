import "mazeSquare"

local pd <const> = playdate
local gfx <const> = pd.graphics

local tilemap = gfx.imagetable.new("Images/maze_tilemap")



local map = gfx.tilemap.new()
map:setImageTable(tilemap)
map:setSize( 15, 9 )

-- Maximum map size: 15 x 9 tiles

class('Maze').extends()

-- function Maze:init( levelData )
--     self.seed = levelData.seed
--     -- print("Seed entered: ", self.seed)
--     self.squares = {}



--     mazeIndex = 1

--     -- xCoord = 6 -- Top left corner of screen (accounting for border)
--     -- yCoord = 4 -- Not needed anymore

--     for i = 1, 9 do -- 9 rows
--         self.squares[i] = {} -- Create 2D Array (table) - easier to manage player position
    
--         for j = 1, 15 do -- 15 columns
--             if j == levelData.levelEnd.x and i == levelData.levelEnd.y then
--                 isEnd = 1
--             else
--                 isEnd = 0
--             end
--             isFruit = 0
--             self.squares[i][j] = 
--                 MazeSquare( j, i, self.seed:sub( mazeIndex, mazeIndex, isEnd, isFruit ) ) 
--             map:setTileAtPosition( j, i, self.squares[i][j].renderValue)
--             mazeIndex = mazeIndex + 1
--         end
        
--     end
    
    
--     map:draw( 6, 4 )
    

-- end

-- function Maze:init() -- Create random maze (for endless mode)
    
--     self.squares = {}
--     self.startSquare = nil
--     self.endSquare = nil

--     for x = 1, 15 do
--         self.squares[x] = {}
--         for y = 1, 9 do
--             self.squares[x][y] =  MazeSquare(x, y)
--         end
--     end

--     print("Initialized empty 15x9 maze.")

--     self:generateRandomMaze()

--     map:draw( 6, 4 )
-- end

function Maze:init( levelData )
    self.width = 15 -- These are hard-coded into a lot of the algorithm.
    self.height = 9 -- I might update those later. -GH
    self.squares = {}
    self.startSquare = nil
    self.endSquare = nil
    self.fruits = {}

    for x = 1, self.width do
        self.squares[x] = {}
        for y = 1, self.height do
            self.squares[x][y] = MazeSquare(x, y)
        end
    end

    if type(levelData) == "table" then
        -- Initialize level mode --
        print("Initializing level mode.")
        self.seed = levelData.seed

        local mazeIndex = 1

        for y = 1, self.height do
            for x = 1, self.width do
                local currentSquare = self.squares[x][y]

                if x == levelData.levelEnd.x and y == levelData.levelEnd.y then
                    currentSquare.isEnd = true
                end

                if x == levelData.levelStart.x and y == levelData.levelStart.y then
                    currentSquare.isStart = true
                    self.startSquare = currentSquare
                end

                currentSquare.isFruit = false
                for _, fruitData in pairs(levelData.fruits or {}) do
                    if x == fruitData.x and y == fruitData.y then
                        currentSquare.isFruit = true
                        table.insert(self.fruits, currentSquare)
                        break -- One fruit per square.
                    end
                end

                local charValue = self.seed:sub(mazeIndex, mazeIndex)
                local renderValue = tonumber(charValue, 16)

                currentSquare.renderValue = renderValue + 1 -- Plus one for a 1-indexed tilemap array.
                currentSquare.openUp =    (renderValue & 1) > 0 and 1 or 0
                currentSquare.openRight = (renderValue & 2) > 0 and 1 or 0
                currentSquare.openDown =  (renderValue & 4) > 0 and 1 or 0
                currentSquare.openLeft =  (renderValue & 8) > 0 and 1 or 0

                map:setTileAtPosition(x, y, currentSquare.renderValue)

                mazeIndex = mazeIndex + 1
            end
        end

        self.endSquare = self.squares[levelData.levelEnd.x][levelData.levelEnd.y]

    else
        -- Initialize Endless Mode --
        print("Initializing endless mode...")

        self:generateRandomMaze()

        -- Set random fruits here --
    end

    map:draw(6, 4)
end

function Maze:getSquare(x, y)
    if x >= 1 and x <= 15 and y >= 1 and y <= 9 then
        return self.squares[x][y]
    end
    return nil
end

function Maze:getNeighbors(square)
    local neighbors = {}
    local x = square.xCoord
    local y = square.yCoord

    -- Up
    local upNeighbor = self:getSquare(x, y - 1)
    if upNeighbor then table.insert(neighbors, {sq = upNeighbor, dir = 1}) end
    -- Right
    local rightNeighbor = self:getSquare(x + 1, y)
    if rightNeighbor then table.insert(neighbors, {sq = rightNeighbor, dir = 2}) end
    -- Down
    local downNeighbor = self:getSquare(x, y + 1)
    if downNeighbor then table.insert(neighbors, {sq = downNeighbor, dir = 3}) end
    -- Left
    local leftNeighbor = self:getSquare(x - 1, y)
    if leftNeighbor then table.insert(neighbors, {sq = leftNeighbor, dir = 4}) end

    return neighbors
    
    
end

function Maze:generateRandomMaze()
    print("Starting random maze generation...")

    local visited = {}
    for x = 1, 15 do
        visited[x] = {}
        for y = 1, 9 do
            visited[x][y] = false
        end
    end

    local frontierWalls = {}

    local startX = math.random(1, self.width)
    local startY = math.random(1, self.height)
    local currentSquare = self:getSquare(startX, startY)

    visited[startX][startY] = true
    local cellsVisitedCount = 1
    local totalCells = self.width * self.height

    local neighborsOfStart = self:getNeighbors(currentSquare)
    for _, neighborData in ipairs(neighborsOfStart) do
        local neighbor = neighborData.sq
        local direction = neighborData.dir

        if not visited[neighbor.xCoord][neighbor.yCoord] then
            table.insert(frontierWalls, {
                cell1 = currentSquare,
                cell2 = neighbor,
                dir1 = direction, -- Direction from cell1 to cell2
                dir2 = (direction == 1 and 3) or (direction == 2 and 4) or (direction == 3 and 1) or (direction == 4 and 2) -- Direction from cell2 to cell1
            })
        end
    end

    while #frontierWalls > 0 and cellsVisitedCount < totalCells do
        local randomIndex = math.random(1, #frontierWalls)
        local wallToProcess = frontierWalls[randomIndex]
        table.remove(frontierWalls, randomIndex)

        local cell1 = wallToProcess.cell1
        local cell2 = wallToProcess.cell2
        local dir1 = wallToProcess.dir1
        local dir2 = wallToProcess.dir2

        if not visited[cell2.xCoord][cell2.yCoord] then
            cell1:openSide(dir1)
            cell2:openSide(dir2)

            visited[cell2.xCoord][cell2.yCoord] = true
            cellsVisitedCount = cellsVisitedCount + 1

            local neighborsOfCell2 = self:getNeighbors(cell2)
            for _, neighborData in ipairs(neighborsOfCell2) do
                local nextNeighbor = neighborData.sq
                local nextDirection = neighborData.dir

                if not visited[nextNeighbor.xCoord][nextNeighbor.yCoord] then
                    table.insert(frontierWalls, {
                        cell1 = cell2,
                        cell2 = nextNeighbor,
                        dir1 = nextDirection,
                        dir2 = (nextDirection == 1 and 3) or (nextDirection == 2 and 4) or (nextDirection == 3 and 1) or (nextDirection == 4 and 2)
                    })
                end
            end
        end
    end

    print(string.format("Maze generation complete. Visited %d/%d cells.", cellsVisitedCount, totalCells))

    self.squares[15][9].openUp = 0
    self.squares[15][9].openRight = 0
    self.squares[15][9].openDown = 0
    self.squares[15][9].openLeft = 0

    self:calculateRenderValues()
    self:setRandomStartAndEnd()

    self:generateFruits(math.random(2, 8)) -- Generate a random number of fruits (between 2 and 8)

    return self
end

function Maze:calculateRenderValues()
    for x = 1, self.width do
        for y = 1, self.height do
            local square = self.squares[x][y]
            square:updateRenderValue()
            map:setTileAtPosition(x, y, self.squares[x][y].renderValue)
        end
    end
end

function Maze:setRandomStartAndEnd()
    local startX = math.random(1, 14)
    local startY = math.random(1, 8)
    self.startSquare =self:getSquare(startX, startY)
    self.startSquare.isStart = true

    local endX, endY
    repeat
        endX = math.random(1, 14)
        endY = math.random(1, 8)
    until not (startX == endX and startY == endY)

    self.endSquare = self:getSquare(endX, endY)
    self.endSquare.isEnd = true

    print(string.format("Set Start: (%d, %d), End: (%d, %d)", startX, startY, endX, endY))
end

function Maze:generateFruits(numFruits)
    self.fruits = {}

    print(string.format("Attempting to create %d fruits", numFruits))

    local fruitsSpawned = 0
    local maxAttempts = self.width * self.height * 5

    while fruitsSpawned < numFruits and maxAttempts > 0 do
        local randomX = math.random(1, self.width - 1)
        local randomY = math.random(1, self.height - 1)
        local square = self.squares[randomX][randomY]

        if not square.isStart and not square.isEnd and not square.isFruit then
            square.isFruit = true
            table.insert(self.fruits, square)
            fruitsSpawned = fruitsSpawned + 1
        end
        maxAttempts = maxAttempts - 1
    end

    if fruitsSpawned < numFruits then
        print(string.format("ERROR: Only spawned %d out of %d requested fruits.", fruitsSpawned, numFruits))
    end
end

function Maze:updateMaze()
    map:draw(6, 4)
    -- startImage:draw(levelData.levelStart.x * 26 - 15, levelData.levelStart.y * 26 - 15)
    -- exitImage:draw(levelData.levelEnd.x * 26 - 15, levelData.levelEnd.y * 26 - 15)
end
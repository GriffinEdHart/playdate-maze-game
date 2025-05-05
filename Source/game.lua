

local ticksPerRevolution = 2

class('Game').extends()

function Game:init()
    self.player = nil
    self.maze = nil
    self.path = nil
    self.playerDirection = 2 -- 1 = up, 2 = right, 3 = down, 4 = left
    self.locBufX = 0
    self.locBufY = 0
    self.mazePosX = 1
    self.mazePosY = 1
    self.playerStartX = -6
    self.playerStartY = -8 -- retrieved by trial and error
    self.gameWon = false -- To handle changing levels
    self.isCrankDocked = playdate.isCrankDocked()
    self.totalCrankAngle = 0
    self.previousCrankAngle = 0
    self.moveSensitivity = 5
    self.score = 0
    self.pathIndex = 1
end

function Game:setup()
    self.playerDirection = 2
    self.maze = Maze("000000000000000004000000000000003AC40000000002AAAFD00000000000001500002EC000000050000053A8000003AAAAA9000000000000000000000000000000000", 1, 4) -- Hard-coded right now - Will figure out how to do multiple levels soon. -- 1, 4 correspond to the starting position of the player in the maze
    
    self.playerStartX = self.playerStartX + (26 * self.maze.startX) -- original offset + (tile size * starting index)
    self.playerStartY = self.playerStartY + (26 * self.maze.startY)
    
    self.mazePosX = self.maze.startX -- Initialize tracker for player location within the maze
    self.mazePosY = self.maze.startY
    self.player = Player(self.playerStartX, self.playerStartY)
    self.locBufX = self.playerStartX
    self.locBufY = self.playerStartY
    self.path = Path(self.locBufX, self.locBufY)
end

function Game:update(dt)
    self:handleInput()
    self.updatePlayerPosition()
    -- Win condition here?
end

function Game:draw()
    self.player:update()
    self.maze:updateMaze()
    if self.isCrankDocked then
        playdate.ui.crankIndicator:draw()
    end
end

function Game:traversePath()
    for i = self.pathIndex, #self.path.path do
        local point = self.path.path[i].pathDot
        self.player:moveTo( point.xCoord, point.yCoord )
        point:remove()
        self.pathIndex = self.pathIndex + 1
        self.player:update()
        self.maze.updateMaze()
        playdate.wait(100)
    end
end


function Game:handleInput()
    if playdate.buttonIsPressed(playdate.kButtonUp) then
        self.playerDirection = 1
    end
    if playdate.buttonIsPressed(playdate.kButtonRight) then
        self.playerDirection = 2
    end
    if playdate.buttonIsPressed(playdate.kButtonDown) then
        self.playerDirection = 3
    end
    if playdate.buttonIsPressed(playdate.kButtonLeft) then
        self.playerDirection = 4
    end

    if playdate.buttonIsPressed(playdate.kButtonA) then
        -- self.player:traverse(self.path)
        self:traversePath()
    end

    local crankTicks = playdate.getCrankTicks(ticksPerRevolution)
    if crankTicks == 1 then
        if self.playerDirection == 1 then
            print(self.maze.squares[self.mazePosY][self.mazePosX].tile.openUp)
            if self.maze.squares[self.mazePosY][self.mazePosX].tile.openUp == 1 then
                self.locBufY -= 26
                self.mazePosY = self.mazePosY - 1
                self.path:addPoint( self.locBufX, self.locBufY )
            end            
        elseif self.playerDirection == 2 then
            print(self.maze.squares[self.mazePosY][self.mazePosX].tile.openRight)
            print(self.maze.squares[self.mazePosY][self.mazePosX].tile.openRight == 1)
            if self.maze.squares[self.mazePosY][self.mazePosX].tile.openRight == 1 then
                self.locBufX += 26
                self.mazePosX = self.mazePosX + 1
                self.path:addPoint( self.locBufX, self.locBufY )
            end
        elseif self.playerDirection == 3 then
            print(self.maze.squares[self.mazePosY][self.mazePosX].tile.openDown)
            if self.maze.squares[self.mazePosY][self.mazePosX].tile.openDown == 1 then
                self.locBufY += 26
                self.mazePosY = self.mazePosY + 1
                self.path:addPoint(self.locBufX, self.locBufY)
            end
        elseif self.playerDirection == 4 then
            print(self.maze.squares[self.mazePosY][self.mazePosX].tile.openRight)
            if self.maze.squares[self.mazePosY][self.mazePosX].tile.openRight == 1 then
                self.locBufX -= 26
                self.mazePosX = self.mazePosX - 1
                self.path:addPoint( self.locBufX, self.locBufY )
            end
        end
    end
end

function Game:updatePlayerPosition()
    local crankTicks = playdate.getCrankTicks(ticksPerRevolution)

	if crankTicks == 1 then
		if self.playerDirection == 1 then
			locBufY -= 10
		end
		if self.playerDirection == 2 then
			locBufX += 10
		end
		if self.playerDirection == 3 then
			locBufY += 10
		end
		if self.playerDirection == 4 then
			locBufX -= 10
		end

		self.path:addPoint( locBufX, locBufY )

	end

    -- Check for wall collisions here


end
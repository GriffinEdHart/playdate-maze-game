local pd <const> = playdate
local gfx <const> = pd.graphics

local startImage = gfx.image.new("Images/startTile")
local exitImage = gfx.image.new("Images/exitTile")

startSprite = gfx.sprite.new( startImage )
endSprite = gfx.sprite.new( exitImage )

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

function Game:setup(levelData)
    self.player = nil
    self.playerDirection = 2
    self.maze = Maze(levelData)
    
    self.playerStartX = self.playerStartX + (26 * levelData.levelStart.x) -- original offset + (tile size * starting index)
    self.playerStartY = self.playerStartY + (26 * levelData.levelStart.y)
    self.mazePosX = levelData.levelStart.x -- Initialize tracker for player location within the maze
    self.mazePosY = levelData.levelStart.y
    
    

    
    startSprite:moveTo( -6 + (26 * levelData.levelStart.x), -8 + (26 * levelData.levelStart.y) )
    endSprite:moveTo( -6 + (26 * levelData.levelEnd.x), -8 + (26 * levelData.levelEnd.y) )
    startSprite:add()
    endSprite:add()
    

    self.player = Player(self.playerStartX, self.playerStartY, levelData.levelStart.x, levelData.levelStart.y)
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
    -- startImage:draw(levelData.levelStart.x * 26 - 15, levelData.levelStart.y * 26 - 15)
    -- exitImage:draw(levelData.levelEnd.x * 26 - 15, levelData.levelEnd.y * 26 - 15)
    self.player:update()
    gfx.sprite.update()
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
    self.player.curX = self.mazePosX
    self.player.curY = self.mazePosY
    print(self.player.curX)
    print(self.player.curY)
    if self.player.curX == levelData.levelEnd.x and self.player.curY == levelData.levelEnd.y then
        print("Level Complete!!!")
        self.gameWon = true
        self.player:derender()
        return
    end
    -- print(self.maze.squares[self.mazePosY][self.mazePosX].tile.openLeft)
    -- print(self.maze.squares[self.mazePosY][self.mazePosX].tile.openDown)
    -- print(self.maze.squares[self.mazePosY][self.mazePosX].tile.openRight)
    -- print(self.maze.squares[self.mazePosY][self.mazePosX].tile.openUp)
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
            print(self.maze.squares[self.mazePosY][self.mazePosX].tile.openLeft)
            if self.maze.squares[self.mazePosY][self.mazePosX].tile.openLeft == 1 then
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
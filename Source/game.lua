local pd <const> = playdate
local gfx <const> = pd.graphics

local startImage = gfx.image.new("Images/startTile")
local exitImage = gfx.image.new("Images/exitTile")

startSprite = gfx.sprite.new( startImage )
endSprite = gfx.sprite.new( exitImage )

local ticksPerRevolution = 2

local parScore = 500

local penaltyScale = 100

local tinyFont = gfx.font.new("font/Roobert-9-Condensed")

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
    self.endX = 0
    self.endY = 0
    self.gameWon = false -- To handle changing levels
    self.gameLost = false -- For endless mode
    self.isCrankDocked = playdate.isCrankDocked()
    self.totalCrankAngle = 0
    self.previousCrankAngle = 0
    self.moveSensitivity = 5
    self.score = 0
    self.pathIndex = 1
    self.fruits = {}
    self.cranksLeft = nil -- For Endless Mode
    self.isEndlessMode = false -- For Endless Mode
    math.randomseed()
end

function Game:setup(levelData)
    self.player = nil
    self.playerDirection = 2
    self.maze = Maze(levelData)
    
    self.playerStartX = self.playerStartX + (26 * levelData.levelStart.x) -- original offset + (tile size * starting index)
    self.playerStartY = self.playerStartY + (26 * levelData.levelStart.y)
    self.mazePosX = levelData.levelStart.x -- Initialize tracker for player location within the maze
    self.mazePosY = levelData.levelStart.y
    
    self.endX = levelData.levelEnd.x
    self.endY = levelData.levelEnd.y

    
    startSprite:moveTo( -6 + (26 * levelData.levelStart.x), -8 + (26 * levelData.levelStart.y) )
    endSprite:moveTo( -6 + (26 * levelData.levelEnd.x), -8 + (26 * levelData.levelEnd.y) )
    startSprite:add()
    endSprite:add()

    self:initFruits()
    

    self.player = Player(self.playerStartX, self.playerStartY, levelData.levelStart.x, levelData.levelStart.y)
    self.locBufX = self.playerStartX
    self.locBufY = self.playerStartY
    self.path = Path(self.locBufX, self.locBufY)
end

function Game:setupEndless( cranks ) -- Game setup for endless mode
    self.isEndlessMode = true
    self.cranksLeft = cranks
    self.playerDirection = 2
    self.maze = Maze() -- Generates a new random maze.startSprite:moveTo( self.playerStartX, self.playerStartY )
    endSprite:moveTo( -6 + (26 * self.endX), -8 + (26 * self.endY) )
    startSprite:add()
    endSprite:add()

    self.playerStartX = self.playerStartX + (26 * self.maze.startSquare.xCoord) -- original offset + (tile size * starting index)
    self.playerStartY = self.playerStartY + (26 * self.maze.startSquare.yCoord)
    self.mazePosX = self.maze.startSquare.xCoord -- Initialize tracker for player location within the maze
    self.mazePosY = self.maze.startSquare.yCoord

    self.endX = self.maze.endSquare.xCoord
    self.endY = self.maze.endSquare.yCoord

    startSprite:moveTo( self.playerStartX, self.playerStartY )
    endSprite:moveTo( -6 + (26 * self.endX), -8 + (26 * self.endY) )
    startSprite:add()
    endSprite:add()

    self.player = Player(self.playerStartX, self.playerStartY, self.maze.startSquare.xCoord, self.maze.startSquare.yCoord)
    self.locBufX = self.playerStartX
    self.locBufY = self.playerStartY

    self.path = Path(self.locBufX, self.locBufY)

    

    self:initFruits()

end

function Game:update(dt)
    self:handleInput()
    self.updatePlayerPosition()
    -- Win condition here?
end

function Game:draw()
        
    gfx.sprite:update()
    
    self.maze:updateMaze()
    
    if self.isCrankDocked then
        playdate.ui.crankIndicator:draw()
    end

    if self.isEndlessMode and self.cranksLeft then
        local cranksText = "" .. self.cranksLeft
        
        gfx.setFont(tinyFont)
        
        local textWidth, textHeight = gfx.getTextSize(cranksText)

        local padding = 2
        local boxPadding = 3
        local xTextPos = pd.display.getWidth() - textWidth
        local yTextPos = pd.display.getHeight() - textHeight
        local xBoxPos = xTextPos - boxPadding
        local yBoxPos = yTextPos - boxPadding
        local boxWidth = textWidth + (boxPadding * 2)
        local boxHeight = textHeight + (boxPadding * 2)

        gfx.setImageDrawMode(gfx.kDrawModeCopy)
        gfx.fillRect(xBoxPos, yBoxPos, boxWidth, boxHeight, gfx.kColorBlack)


        gfx.setImageDrawMode(gfx.kDrawModeFillWhite)
        gfx.drawText(cranksText, xTextPos, yTextPos)
        gfx.setImageDrawMode(gfx.kDrawModeCopy)

    end
end

function Game:traversePath()
    for i = self.pathIndex, #self.path.path do
        local point = self.path.path[i].pathDot
        self.player:moveTo( point.xCoord, point.yCoord )
        self.player.curX = (point.xCoord + 6) // 26
        self.player.curY = (point.yCoord + 8) // 26

        for _, fruit in ipairs(self.fruits) do
            if not fruit.pickedUp and self.player.curX == fruit.xCoord and self.player.curY == fruit.yCoord then
                print("Picked up " .. fruit.name .. " at X: " .. fruit.x .. ", Y: " .. fruit.y)
                fruit.pickedUp = true
                fruit:derender()

                self.score = self.score + 100
                if self.isEndlessMode then
                    self.cranksLeft = self.cranksLeft + 5
                end
                break
            end
        end

        point:remove()
        self.pathIndex = self.pathIndex + 1
        self.player:update()
        self.maze.updateMaze()
        playdate.wait(100)
    end
    if self.player.curX == self.endX and self.player.curY == self.endY then
        print("Level Complete!!!")
        self.gameWon = true
        print(string.format("Fruit Score: %q", self.score))
        self.score = self.score + self:calculateScore(self.pathIndex)
        print(string.format("Level Score: %q", self.score))
        self.player:derender()
        for _, fruit in ipairs(self.fruits) do
            fruit:derender()
        end
        if self.isEndlessMode then
            self.cranksLeft = self.cranksLeft + 10
        end
        return
    end
    if self.isEndlessMode and self.cranksLeft < 1 then
        print("You Lose!")
        self.gameLost = true
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

    if self.isEndlessMode then
        if self.cranksLeft < 1 then
            self:traversePath()
        end
    end

    local crankTicks = playdate.getCrankTicks(ticksPerRevolution)
    if crankTicks == 1 then
        if self.playerDirection == 1 then
            -- print(self.maze.squares[self.mazePosY][self.mazePosX].tile.openUp)
            if self.maze.squares[self.mazePosX][self.mazePosY].openUp == 1 then
                self.locBufY -= 26
                self.mazePosY = self.mazePosY - 1
                self.path:addPoint( self.locBufX, self.locBufY )
                if self.isEndlessMode then
                    self.cranksLeft = self.cranksLeft - 1
                end
            end            
        elseif self.playerDirection == 2 then
            -- print(self.maze.squares[self.mazePosY][self.mazePosX].tile.openRight)
            -- print(self.maze.squares[self.mazePosY][self.mazePosX].tile.openRight == 1)
            if self.maze.squares[self.mazePosX][self.mazePosY].openRight == 1 then
                self.locBufX += 26
                self.mazePosX = self.mazePosX + 1
                self.path:addPoint( self.locBufX, self.locBufY )
                if self.isEndlessMode then
                    self.cranksLeft = self.cranksLeft - 1
                end
            end
        elseif self.playerDirection == 3 then
            -- print(self.maze.squares[self.mazePosY][self.mazePosX].tile.openDown)
            if self.maze.squares[self.mazePosX][self.mazePosY].openDown == 1 then
                self.locBufY += 26
                self.mazePosY = self.mazePosY + 1
                self.path:addPoint(self.locBufX, self.locBufY)
                if self.isEndlessMode then
                    self.cranksLeft = self.cranksLeft - 1
                end
            end
        elseif self.playerDirection == 4 then
            -- print(self.maze.squares[self.mazePosY][self.mazePosX].tile.openLeft)
            if self.maze.squares[self.mazePosX][self.mazePosY].openLeft == 1 then
                self.locBufX -= 26
                self.mazePosX = self.mazePosX - 1
                self.path:addPoint( self.locBufX, self.locBufY )
                if self.isEndlessMode then
                    self.cranksLeft = self.cranksLeft - 1
                end
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

function Game:initFruits()
    for _, fruit in ipairs(self.fruits) do
        if fruit then
            fruit:derender()
        end
    end
    self.fruits = {}

    if self.maze and self.maze.fruits then
        for i, fruitMazeSquare in ipairs(self.maze.fruits) do
            local fruitName = string.format("fruit_%d_%d", fruitMazeSquare.xCoord, fruitMazeSquare.yCoord)

            local fruitSprite = Fruit(fruitMazeSquare.xCoord, fruitMazeSquare.yCoord, fruitName)
            table.insert(self.fruits, fruitSprite)
        end
        print(string.format("Initialized %d fruit sprites from the maze.", #self.fruits))
    else
        print("ERROR: Maze object or maze.fruits table not available for fruit initialization.")
    end
end

function Game:calculateScore(crankCount)
    if crankCount <= 0 then
        return parScore
    else
        penalty = math.floor(penaltyScale * math.log(crankCount + 1))
        print(string.format("Penalty score: %q", penalty))
        return parScore - penalty
    end
end
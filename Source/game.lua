

local ticksPerRevolution = 2

class('Game').extends()

function Game:init()
    self.player = nil
    self.maze = nil
    self.path = nil
    self.playerDirection = 2 -- 1 = up, 2 = right, 3 = down, 4 = left
    self.locBufX = 0
    self.locBufY = 0
    self.playerStartX = 200
    self.playerStartY = 120
    self.gameWon = false -- To handle changing levels
    self.isCrankDocked = false
    self.totalCrankAngle = 0
    self.previousCrankAngle = 0
    self.moveSensitivity = 5
    self.score = 0
end

function Game:setup()
    self.playerDirection = 2
    self.player = Player(self.playerStartX, self.playerStartY)
    self.locBufX = self.playerStartX
    self.locBufY = self.playerStartY
    self.maze = Maze("000000000000000004000000000000003AC40000000002AAAFD00000000000001500002EC000000050000053A8000003AAAAA9000000000000000000000000000000000") -- Hard-coded right now - Will figure out how to do multiple levels soon.
    self.path = Path(self.locBufX, self.locBufY)
end

function Game:update(dt)
    self:handleInput()
    self.updatePlayerPosition()
    self.maze:updateMaze()

    -- Win condition here?
end

function Game:draw()
    self:drawMaze()
    self:drawPlayer()
    if self.isCrankDocked then
        playdate.ui.crankIndicator:draw()
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
        self.player:traverse(self.path)
    end

    local crankTicks = playdate.getCrankTicks(ticksPerRevolution)
    if crankTicks == 1 then
        if self.playerDirection == 1 then
            self.locBufY -= 10
        elseif self.playerDirection == 2 then
            self.locBufX += 10
        elseif self.playerDirection == 3 then
            self.locBufY += 10
        elseif self.playerDirection == 4 then
            self.locBufX -= 10
        end
        self.path:addPoint(self.locBufX, self.locBufY)
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

function Game:drawMaze()
    self.maze:updateMaze()
end

function Game:drawPlayer()
    playdate.graphics.sprite:update()
end

import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/crank"


import "path"
import "player"
import "maze"
import "stateMachine"
import "game"
import "fruit"

local pd <const> = playdate
local gfx <const> = pd.graphics
local ds <const> = pd.datastore
-- local Game = require("game")
-- local StateMachine = require("stateMachine")

local game = Game()
local gameStateMachine = StateMachine("mainMenu")

local kText = { font = gfx.getSystemFont(), color = gfx.kColorWhite }

-- local testFile = pd.datastore.read("data/test1")
-- print(testFile.seed)

local levelNum = 1
local gameScore = 0

local gameStates = {
	mainMenu = {
		enter = function()
			pd.display.setRefreshRate(30)
			game.gameStarted = false
			print("Entered Main Menu")
		end,
		update = function()
			gfx.clear(gfx.kColorWhite)
			gfx.drawText("Crank Maze", 100, 50, kText)
			gfx.drawText("Press A to start", 80, 80, kText)
			if pd.buttonIsPressed(pd.kButtonMenu) then
				pd.reboot()
			end
			if pd.buttonIsPressed(pd.kButtonA) then
				print("A button pressed")
				gameStateMachine:changeState("levelMode")
			end
			if pd.buttonIsPressed(pd.kButtonB) then
				print("B button pressed")
				gameStateMachine:changeState("endlessMode")
			end
		end,
		exit = function()
			print("Exited Main Menu")
		end,
	},
	levelMode = {
		enter = function()
			game = Game()
			pd.display.setRefreshRate(30)
			gfx.clear(gfx.kColorWhite)
			levelData = ds.read(string.format("data/level%q", levelNum))
			game:setup(levelData)
			gfx.clear(gfx.kColorWhite)
			gfx.drawText(string.format("Level %q", levelNum), 100, 50, kText)
			gfx.drawText(string.format("Score: %q", gameScore), 80, 80, kText)
			pd.wait(2000)
			game:draw()
			print("Entered Level Mode")
		end,
		update = function()
			game:update(pd.getElapsedTime())
			pd.resetElapsedTime()
			-- game.maze:updateMaze()
			game:draw()
			
			if game.gameWon then
				gameScore = gameScore + 10 + game.score
				levelNum = levelNum + 1
				gameStateMachine:changeState("levelMode")
			end
			-- gfx.drawText("Score: " .. game.score, 10, 20, kText)
		end,
		exit = function()
			print("Exited Level Mode")
		end
	},
	endlessMode = {
		enter = function()
			pd.display.setRefreshRate(30)
			game:reset()
			game:setup()
			print("Entered Endless Mode")
		end,
		update = function()
			gfx.clear(gfx.kColorWhite)
			game:update(pd.getElapsedTime())
			pd.resetElapsedTime()
			game:draw()
			if game.gameWon then
				game.score = game.score + 10
				game:reset()
				game:setup()
				game.gameWon = false
			end
			gfx.graphics.drawText("Score: " .. game.score, 10, 20, kText)
		end,
		exit = function()
			print("Exited Endless Mode")
		end
	},
}

for stateName, state in pairs(gameStates) do
	gameStateMachine:addState(stateName, state)
end

function pd.update()
	local dt = pd.getElapsedTime()
	pd.resetElapsedTime()
	gameStateMachine:update(dt)
	pd.drawFPS(0, 0)
	playdate.timer.updateTimers()
end

function pd.crankDocked()
	game.isCrankDocked = true
	game.previousCrankAngle = 0
	game.totalCrankAngle = 0
end

function pd.crankUndocked()
	game.isCrankDocked = false
end

pd.crankDockedCallback = pd.crankDocked
pd.crankUndockedCallback = pd.crankUndocked

gameStateMachine:changeState("mainMenu")


















-- local playerSprite = nil

-- local playerDirection = 2 -- 1 = up -- 2 = right -- 3 = down -- 4 = left

-- local ticksPerRevolution = 2

-- local locBufX = 0
-- local locBufY = 0

-- local playerStartX = 200
-- local playerStartY = 120

-- local maze = Maze("000000000000000004000000000000003AC40000000002AAAFD00000000000001500002EC000000050000053A8000003AAAAA9000000000000000000000000000000000")

-- function gameSetUp()

-- 	playerDirection = 2 -- Start looking to the right (this may change based on the layout of each maze)

-- 	player = Player( playerStartX, playerStartY )

-- 	locBufX = playerStartX
-- 	locBufY = playerStartY

-- 	-- local backgroundImage = gfx.image.new( "Images/background" )
-- 	-- assert ( backgroundImage )

-- 	path = Path( locBufX, locBufY )
-- end

-- gameSetUp()

-- gfx.setBackgroundColor( gfx.kColorWhite )



-- function playdate.update()
	
	
-- 	if playdate.buttonIsPressed( playdate.kButtonUp ) then
--         playerDirection = 1
--     end
--     if playdate.buttonIsPressed( playdate.kButtonRight ) then
--         playerDirection = 2
--     end
--     if playdate.buttonIsPressed( playdate.kButtonDown ) then
--         playerDirection = 3
--     end
--     if playdate.buttonIsPressed( playdate.kButtonLeft ) then
--         playerDirection = 4
--     end

-- 	if playdate.buttonIsPressed( playdate.kButtonA ) then
-- 		player:traverse( path )
-- 	end
	

-- 	local crankTicks = playdate.getCrankTicks(ticksPerRevolution)

-- 	if crankTicks == 1 then
-- 		if playerDirection == 1 then
-- 			locBufY -= 10
-- 		end
-- 		if playerDirection == 2 then
-- 			locBufX += 10
-- 		end
-- 		if playerDirection == 3 then
-- 			locBufY += 10
-- 		end
-- 		if playerDirection == 4 then
-- 			locBufX -= 10
-- 		end

-- 		path:addPoint( locBufX, locBufY )

-- 	end

-- 	gfx.sprite.update()

-- 	maze:updateMaze()

-- 	if playdate.isCrankDocked() then
-- 		playdate.ui.crankIndicator:draw()
-- 	end

--     playdate.timer.updateTimers()
-- 	playdate.drawFPS(0,0) -- FPS widget
-- end


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
local numCranks = 30

local font = gfx.font.new("font/Mini Sans 2X")

local gameStates = {
	mainMenu = {
		enter = function()
			pd.display.setRefreshRate(30)
			game.gameStarted = false
			levelNum = 1 -- Reset values
			gameScore = 0
			numCranks = 30
			print("Entered Main Menu")
		end,
		update = function()
			gfx.clear(gfx.kColorWhite)
			gfx.setFont(font)
			gfx.drawText("Crank Your Hog", 110, 30, kText)
			gfx.drawText("Press A to start Level Mode", 10, 100, kText)
			gfx.drawText("Press B to start Endless Mode", 10, 130, kText)
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
			gfx.setFont(font)
			gfx.clear(gfx.kColorWhite)

			local success, result = pcall(function()
				local path = string.format("data/level%q", levelNum)
				levelData = ds.read(path)
				if not levelData then
					error("No data found for level: " .. path)
				end
				game:setup(levelData)
			end)

			
			if success then
				gfx.clear(gfx.kColorWhite)
				gfx.drawText(string.format("Level %q", levelNum), 10, 50, kText)
				gfx.drawText(string.format("Score: %q", gameScore), 30, 80, kText)
				pd.wait(2000)
				game:draw()
				print("Entered Level Mode")
			else
				local errorMessage = result
				print("Error: " .. errorMessage)
				
				gfx.clear(gfx.kColorWhite)
				gfx.drawText(string.format("Congratulations, you win!"), 50, 50, kText)
				gfx.drawText(string.format("Your final score: %q", gameScore), 10, 80, kText)
				pd.wait(2000)
				gameStateMachine:changeState("mainMenu")
			end
			
		end,
		update = function()
			game:update(pd.getElapsedTime())
			pd.resetElapsedTime()
			-- game.maze:updateMaze()
			game:draw()
			gfx.setFont(font)
			
			if game.gameWon then
				gameScore = gameScore + game.score
				print(string.format("Total Score: %q", gameScore))
				levelNum = levelNum + 1
				gameStateMachine:changeState("levelMode")
			end
			-- gfx.drawText("Score: " .. game.score, 10, 20, kText)
		end,
		exit = function()
			print("Exited level mode.")
		end
	},
	endlessMode = {
		enter = function()
			game = Game()
			pd.display.setRefreshRate(30)
			gfx.clear(gfx.kColorWhite)

			game:setupEndless(numCranks)

			gfx.clear(gfx.kColorWhite)
			gfx.drawText(string.format("Level %q", levelNum), 10, 50, kText)
			gfx.drawText(string.format("Score: %q", gameScore), 30, 80, kText)
			gfx.drawText(string.format("Cranks Remaining: %q", numCranks), 30, 110, kText)
			pd.wait(2000)
			game:draw()

			print("Entered Endless Mode")
		end,
		update = function()
			game:update(pd.getElapsedTime())
			pd.resetElapsedTime()
			-- game.maze:updateMaze()
			game:draw()
			gfx.setFont(font)
			
			if game.gameWon then
				gameScore = gameScore + game.score
				numCranks = game.cranksLeft
				print(string.format("Total Score: %q", gameScore))
				levelNum = levelNum + 1
				gameStateMachine:changeState("endlessMode")
			end
			if game.gameLost then
				gameScore = gameScore + game.score
				numCranks = game.cranksLeft
				gfx.clear(gfx.kColorWhite)
				gfx.drawText(string.format("Game over!"), 100, 50, kText)
				gfx.drawText(string.format("You completed %q levels.", levelNum), 10, 80, kText)
				gfx.drawText(string.format("Your final score: %q", gameScore), 10, 110, kText)
				pd.wait(2000)
				gameStateMachine:changeState("mainMenu")
			end
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


import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/ui"
import "CoreLibs/crank"

import "path"
import "player"
import "maze"

local gfx <const> = playdate.graphics
local font = gfx.font.new('font/Mini Sans 2X') -- DEMO

local playerSprite = nil

local playerDirection = 2 -- 1 = up -- 2 = right -- 3 = down -- 4 = left

local ticksPerRevolution = 2

local locBufX = 0
local locBufY = 0

local playerStartX = 200
local playerStartY = 120

local maze = Maze("000000000000000004000000000000003AC40000000002AAAFD00000000000001500002EC000000050000053A8000003AAAAA9000000000000000000000000000000000")

function gameSetUp()

	playerDirection = 2 -- Start looking to the right (this may change based on the layout of each maze)

	player = Player( playerStartX, playerStartY )

	locBufX = playerStartX
	locBufY = playerStartY

	-- local backgroundImage = gfx.image.new( "Images/background" )
	-- assert ( backgroundImage )

	path = Path( locBufX, locBufY )
end

gameSetUp()

gfx.setBackgroundColor( gfx.kColorWhite )



function playdate.update()
	
	
	if playdate.buttonIsPressed( playdate.kButtonUp ) then
        playerDirection = 1
    end
    if playdate.buttonIsPressed( playdate.kButtonRight ) then
        playerDirection = 2
    end
    if playdate.buttonIsPressed( playdate.kButtonDown ) then
        playerDirection = 3
    end
    if playdate.buttonIsPressed( playdate.kButtonLeft ) then
        playerDirection = 4
    end

	if playdate.buttonIsPressed( playdate.kButtonA ) then
		player:traverse( path )
	end
	

	local crankTicks = playdate.getCrankTicks(ticksPerRevolution)

	if crankTicks == 1 then
		if playerDirection == 1 then
			locBufY -= 10
		end
		if playerDirection == 2 then
			locBufX += 10
		end
		if playerDirection == 3 then
			locBufY += 10
		end
		if playerDirection == 4 then
			locBufX -= 10
		end

		path:addPoint( locBufX, locBufY )

	end

	gfx.sprite.update()

	if playdate.isCrankDocked() then
		playdate.ui.crankIndicator:draw()
	end

    playdate.timer.updateTimers()
	playdate.drawFPS(0,0) -- FPS widget
end

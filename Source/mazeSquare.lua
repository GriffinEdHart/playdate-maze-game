local pd <const> = playdate
local gfx <const> = pd.graphics

class('MazeSquare').extends()

function MazeSquare:init( x, y )
   self.xCoord = x
   self.yCoord = y
   self.openUp = 0 --    0 0 0 1
   self.openRight = 0 -- 0 0 1 0
   self.openDown = 0 --  0 1 0 0
   self.openLeft = 0 --  1 0 0 0
   self.renderValue = 0 -- 0 by default, means no open sides.
end

function MazeSquare:openSide( side )
    if side == 1 then
        self.openUp = 1
    elseif side == 2 then
        self.openRight = 1
    elseif side == 3 then
        self.openDown = 1
    elseif side == 4 then
        self.openLeft = 1
    else
        print("Open side failed, side: ", side)
    end
end

function MazeSquare:updateRenderValue()
    self.renderValue = (self.openUp * 2 ^ 0) + (self.openRigt * 2 ^ 1) + (self.openDown * 2 ^ 2) + (self.openLeft * 2 ^ 3)
end
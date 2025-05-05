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

function MazeSquare:init( x, y, renderValue )
    
    
    self.xCoord = x
    self.yCoord = y
    
    self.renderValue = tonumber( renderValue, 16 ) + 1
    print(self.renderValue)
    bits = "0000"

    if self.renderValue - 1 == 0 then
        bits = "0000"
    elseif self.renderValue - 1 == 1 then
        bits = "0001"
    elseif self.renderValue - 1 == 2 then
        bits = "0010"
    elseif self.renderValue - 1 == 3 then
        bits = "0011"
    elseif self.renderValue - 1 == 4 then
        bits = "0100"
    elseif self.renderValue - 1 == 5 then
        bits = "0101"
    elseif self.renderValue - 1 == 6 then
        bits = "0110"
    elseif self.renderValue - 1 == 7 then
        bits = "0111"
    elseif self.renderValue - 1 == 8 then
        bits = "1000"
    elseif self.renderValue - 1 == 9 then
        bits = "1001"
    elseif self.renderValue - 1 == 10 then
        bits = "1010"
    elseif self.renderValue - 1 == 11 then
        bits = "1011"
    elseif self.renderValue - 1 == 12 then
        bits = "1100"
    elseif self.renderValue - 1 == 13 then
        bits = "1101"
    elseif self.renderValue - 1 == 14 then
        bits = "1110"
    elseif self.renderValue - 1 == 15 then
        bits = "1111"
    else
        bits = "0000"
    end


    print(bits)


    -- bits = toBits(self.renderValue - 1, 4) -- trash. doesn't work.

    self.openLeft = tonumber(bits:sub(1,1))
    self.openDown = tonumber(bits:sub(2,2))
    self.openRight = tonumber(bits:sub(3,3))
    self.openUp = tonumber(bits:sub(4,4))
    
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
    self.renderValue = (self.openUp * 2 ^ 0) + (self.openRigt * 2 ^ 1) + (self.openDown * 2 ^ 2) + (self.openLeft * 2 ^ 3) + 1
end

function toBits(num,bits)
    -- returns a table of bits, most significant first.
    bits = bits or math.max(1, select(2, math.frexp(num)))
    local t = {} -- will contain the bits        
    for b = bits, 1, -1 do
        t[b] = math.fmod(num, 2)
        num = math.floor((num - t[b]) / 2)
    end
    return t
end

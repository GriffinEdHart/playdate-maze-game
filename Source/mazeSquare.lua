local pd <const> = playdate
local gfx <const> = pd.graphics

class('MazeSquare').extends()

-- function MazeSquare:init( x, y )
--    self.xCoord = x
--    self.yCoord = y
--    self.openUp = 0 --    * * * 0
--    self.openRight = 0 -- * * 0 *
--    self.openDown = 0 --  * 0 * *
--    self.openLeft = 0 --  0 * * *
--    self.renderValue = 0
--    self.isStart = false
--    self.isEnd = false
--    self.isFruit = false
--    self.isVisited = false
-- end

-- function MazeSquare:init( x, y, renderValue, isStart, isEnd, isFruit )
    
--     self.isStart = isStart
--     self.isEnd = isEnd
--     self.isFruit = isFruit
    
--     self.xCoord = x
--     self.yCoord = y
    
--     self.renderValue = tonumber( renderValue, 16 ) + 1
--     -- print(self.renderValue)
--     self.bits = "0000"

--     if self.renderValue - 1 == 0 then
--         self.bits = "0000"
--     elseif self.renderValue - 1 == 1 then
--         self.bits = "0001"
--     elseif self.renderValue - 1 == 2 then
--         self.bits = "0010"
--     elseif self.renderValue - 1 == 3 then
--         self.bits = "0011"
--     elseif self.renderValue - 1 == 4 then
--         self.bits = "0100"
--     elseif self.renderValue - 1 == 5 then
--         self.bits = "0101"
--     elseif self.renderValue - 1 == 6 then
--         self.bits = "0110"
--     elseif self.renderValue - 1 == 7 then
--         self.bits = "0111"
--     elseif self.renderValue - 1 == 8 then
--         self.bits = "1000"
--     elseif self.renderValue - 1 == 9 then
--         self.bits = "1001"
--     elseif self.renderValue - 1 == 10 then
--         self.bits = "1010"
--     elseif self.renderValue - 1 == 11 then
--         self.bits = "1011"
--     elseif self.renderValue - 1 == 12 then
--         self.bits = "1100"
--     elseif self.renderValue - 1 == 13 then
--         self.bits = "1101"
--     elseif self.renderValue - 1 == 14 then
--         self.bits = "1110"
--     elseif self.renderValue - 1 == 15 then
--         self.bits = "1111"
--     else
--         self.bits = "0000"
--     end


--     -- print(self.bits)


--     -- bits = toBits(self.renderValue - 1, 4) -- trash. doesn't work.

--     self.openLeft = tonumber(self.bits:sub(1,1))
--     self.openDown = tonumber(self.bits:sub(2,2))
--     self.openRight = tonumber(self.bits:sub(3,3))
--     self.openUp = tonumber(self.bits:sub(4,4))
    
-- end


function MazeSquare:init( x, y, renderValue, isStart, isEnd, isFruit)
    self.xCoord = x
    self.yCoord = y

    -- Initialize all to default/closed for Endless Mode logic
    self.openUp = 0
    self.openRight = 0
    self.openDown = 0
    self.openLeft = 0
    self.renderValue = 0 -- Default for endless mode, calculated later
    self.isStart = false
    self.isEnd = false
    self.isFruit = false

    if type(renderValue) == "string" then
        self.renderValue = tonumber( renderValue, 16 ) + 1
        self.isStart = isStart or false
        self.isEnd = isEnd or false
        self.isFruit = isFruit or false

        self.openUp = (self.renderValue % 2 == 1) and 1 or 0
        self.openRight = ((self.renderValue >> 1) % 2 == 1) and 1 or 0 -- Defaults to false if not provided
        self.openDown = ((self.renderValue >> 2) % 2 == 1) and 1 or 0
        self.openLeft = ((self.renderValue >> 3) % 2 == 1) and 1 or 0
    end
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
    self.renderValue = (self.openUp * 2 ^ 0) + (self.openRight * 2 ^ 1) + (self.openDown * 2 ^ 2) + (self.openLeft * 2 ^ 3) + 1
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

local pd <const> = playdate
local gfx <const> = pd.graphics
local image <const> = gfx.image.new("Images/pathDot")

class('PathDot').extends(gfx.sprite)

function PathDot:init( x, y )
    self.xCoord = x
    self.yCoord = y
    self:moveTo( x, y )
    self:setImage(image)
    self:add()
    -- print("Placed Dot at (", self.xCoord, ", ", self.yCoord, ")")
end

function PathDot:remove()
    self:setImage(nil)
end

function PathDot:update()

end

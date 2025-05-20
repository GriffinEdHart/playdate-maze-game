import "path"

local pd <const> = playdate
local gfx <const> = pd.graphics
local image <const> = gfx.image.new("Images/playerImage")

class('Player').extends(gfx.sprite)

function Player:init( x, y, curX, curY )
    self:moveTo( x, y )
    self:setImage(image)
    self:add()
    self.pathIndex = 1
    self.curX = curX
    self.curY = curY
end

function Player:traverse( path )
    for i = self.pathIndex, #path.path do
        local point = path.path[i].pathDot
        print("Looking at point located at (", point.xCoord, ", ", point.yCoord, ")")
        self:moveTo( point.xCoord, point.yCoord )
        point:remove()
        self:update()
        pd.wait(100)
        self.pathIndex = self.pathIndex + 1
    end
end

function Player:derender()
    self:remove()
end
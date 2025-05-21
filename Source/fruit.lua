local pd <const> = playdate
local gfx <const> = pd.graphics
local image <const> = gfx.image.new("Images/fruit")

class('Fruit').extends(gfx.sprite)

function Fruit:init( x, y, fruitName )
    self.xCoord = x
    self.yCoord = y
    self.pickedUp = false
    self.name = fruitName

    print(self.name .. " has been placed at " .. self.xCoord .. ", " .. self.yCoord)

    if image then
        self:moveTo((self.xCoord * 26) - 6, (self.yCoord * 26) - 8)
        self:setImage(image)
        self:add()
        print(self.name .. " has been placed at " .. self.x .. ", " .. self.y)
    else
        print("ERROR: Could not load fruit image for " .. self.name)
    end
end

function Fruit:derender()
    self:remove()
end
import "pathDot"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('Path').extends()

function Path:init( x, y )
    self.path = {}
    self.index = 1
    self.path[self.index] = { pathDot = PathDot( x, y ) }

    self.index = self.index + 1
end

function Path:addPoint( x, y )
    self.path[self.index] = {
        pathDot = PathDot( x, y )
    }

    self.index = self.index + 1

end

function Path:removePoint( i )
    self.path[i] = {
        PathDot:remove()
    }

end
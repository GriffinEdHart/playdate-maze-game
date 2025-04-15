import "mazeSquare"

local pd <const> = playdate
local gfx <const> = pd.graphics

gfx.tilemap.new()
gfx.tilemap.setImageTable("Images/maze_tilemap-26-26")
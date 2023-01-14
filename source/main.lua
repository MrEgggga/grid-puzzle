local gfx = playdate.graphics

local arrows = {
  gfx.image.new('images/up.png'),
  gfx.image.new('images/down.png'),
  gfx.image.new('images/left.png'),
  gfx.image.new('images/right.png'),
}

math.randomseed(playdate.getSecondsSinceEpoch())

local grid = {}

local function init()
  for i = 1,12 do
    local row = {}
    for j = 1,20 do
      row[j] = math.random(1, 4)
    end
    grid[i] = row
  end
end

init()

function playdate.update()
  for i = 1,12 do
    for j = 1,20 do
      arrows[grid[i][j]]:draw(i * 20 - 20, j * 20 - 20)
    end
  end
end
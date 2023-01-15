import "CoreLibs/math"
import "CoreLibs/graphics"

local gfx = playdate.graphics
local mat = playdate.math

local displayTitle = false

local arrows = {
  gfx.image.new('images/up.png'),
  gfx.image.new('images/down.png'),
  gfx.image.new('images/left.png'),
  gfx.image.new('images/right.png'),
  gfx.image.new('images/no.png')
}

math.randomseed(playdate.getSecondsSinceEpoch())

local grid = {}

local pos = {x=10,y=6}
local last = {x=pos.x,y=pos.y}
local l = 1
local score = 0

playdate.display.setRefreshRate(50)

local fntScore = gfx.font.new('fonts/mont-bold.pft')
local fntText = gfx.font.new('fonts/mont-thin.pft')

local function init()
  for i = 1,10 do
    local row = {}
    for j = 1,20 do
      row[j] = math.random(1, 4)
    end
    grid[i] = row
  end
  pos = {x=10,y=6}
  last = {x=pos.x,y=pos.y}
  l = 0
  score = 0

  gfx.clear()
  for i = 1,10 do
    for j = 1,20 do
      print(i,j)
      arrows[grid[i][j]]:draw(j * 20 - 20, i * 20 - 20)
    end
  end
  fntScore:drawText(score, 0, 200)
end

init()

function playdate.update()
  if displayTitle then
    gfx.clear(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    fntText:drawTextAligned("grid puzzle", 200, 105, kTextAlignment.center)
    return
  end

  local current, pressed, released = playdate.getButtonState()
  if l >= 1 and (pressed & (playdate.kButtonA | playdate.kButtonUp | playdate.kButtonDown | playdate.kButtonLeft | playdate.kButtonRight)) > 0 then
    last = {x=pos.x, y=pos.y}
    local dir = grid[pos.y][pos.x]
    if dir == 1 then
      pos.y -= 1
    elseif dir == 2 then
      pos.y += 1
    elseif dir == 3 then
      pos.x -= 1
    elseif dir == 4 then
      pos.x += 1
    elseif dir == 5 then
      return init()
    end
    l = 0

    local new = 0
    if pressed & playdate.kButtonUp > 0 then
      new = 1
    elseif pressed & playdate.kButtonDown > 0 then
      new = 2
    elseif pressed & playdate.kButtonLeft > 0 then
      new = 3
    elseif pressed & playdate.kButtonRight > 0 then
      new = 4
    elseif pressed & playdate.kButtonA > 0 then
      new = 5
    end
    if pos.x < 1 or pos.x > 20 or pos.y < 1 or pos.y > 10 then
      return init()
    end
    if new == grid[last.y][last.x] then
      grid[last.y][last.x] = 5
      score += 1
    else
      grid[last.y][last.x] = new
      if new == 5 then score += 1 end
    end
  elseif l < 1 then
    l += 0.1
    if l > 1 then l = 1 end
  end

  -- draw state
  gfx.setColor(gfx.kColorWhite)
  gfx.fillRect(pos.x * 20 - 40, pos.y * 20 - 40, 60, 60)
  gfx.fillRect(0, 200, 100, 40)
  local px1, px2, py1, py2 =
    math.max(pos.x - 1, 1),
    math.min(pos.x + 1, 20),
    math.max(pos.y - 1, 1),
    math.min(pos.y + 1, 10)
  for i = py1,py2 do
    for j = px1,px2 do
      print(i,j)
      arrows[grid[i][j]]:draw(j * 20 - 20, i * 20 - 20)
    end
  end
  
  local posX = mat.lerp(last.x, pos.x, l)
  local posY = mat.lerp(last.y, pos.y, l)
  gfx.setColor(gfx.kColorXOR)
  gfx.fillRect(posX * 20 - 20, posY * 20 - 20, 20, 20)

  fntScore:drawText(score, 0, 200)
end
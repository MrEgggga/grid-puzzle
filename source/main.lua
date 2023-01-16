import "CoreLibs/math"
import "CoreLibs/graphics"

local gfx = playdate.graphics
local mat = playdate.math

local displayTitle = false

local menu = playdate.getSystemMenu()

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

local textPage = false
local whichPage = 0
local justTextPage = false
local pages = {
  "controls: d-pad. pressing any direction on the d-pad\n" ..
  "will send you one step in the current direction of the\n" ..
  "arrow you're standing on and change that arrow to\n" ..
  "whichever direction you pressed. pressing in the\n" ..
  "same direction as the current arrow will change the\n" ..
  "current arrow to an X instead, granting you one\n" ..
  "point but preventing you from landing on that square\n" ..
  "again. landing on an X or going off the edge of the\n" ..
  "screen results in a game over.",

  "game by jmibo\n" ..
  "https://github.com/MrEgggga/grid-puzzle/\n" ..
  "more games at https://jmibo.neocities.org/"
}

local manItem, error = menu:addMenuItem("game manual", function ()
  textPage = true
  justTextPage = false
  whichPage = 1
end)

local credItem, error = menu:addMenuItem("credits", function ()
  textPage = true
  justTextPage = false
  whichPage = 2
end)

playdate.display.setRefreshRate(50)

local fntScore = gfx.font.new('fonts/mont-bold.pft')
local fntText = gfx.font.new('fonts/mont-thin.pft')

local function fullRedraw()
  gfx.clear()
  for i = 1,10 do
    for j = 1,20 do
      arrows[grid[i][j]]:draw(j * 20 - 20, i * 20 - 20)
    end
  end
  fntScore:drawText(score, 0, 200)

  local posX = mat.lerp(last.x, pos.x, l)
  local posY = mat.lerp(last.y, pos.y, l)
  gfx.setColor(gfx.kColorXOR)
  gfx.fillRect(posX * 20 - 20, posY * 20 - 20, 20, 20)
end

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
  l = 0.9
  score = 0
  fullRedraw()
end

init()

function playdate.update()
  if displayTitle then
    gfx.clear(gfx.kColorBlack)
    gfx.setImageDrawMode(gfx.kDrawModeNXOR)
    fntText:drawTextAligned("grid puzzle", 200, 105, kTextAlignment.center)
    return
  end

  local updateFrame = false

  if textPage then
    if not justTextPage then
      gfx.clear(gfx.kColorBlack)
      gfx.setImageDrawMode(gfx.kDrawModeNXOR)
      fntText:drawText("grid puzzle", 0, 0)
      gfx.drawText(pages[whichPage], 0, 40)
      gfx.drawTextAligned("(press B)", 400, 220, kTextAlignment.right)
    end
    justTextPage = true
    if playdate.buttonJustPressed(playdate.kButtonB) then
      textPage = false
    end
    return
  elseif justTextPage then
    justTextPage = false
    fullRedraw()
  end

  local current, pressed, released = playdate.getButtonState()
  if l >= 1 and (pressed & (
      playdate.kButtonA |
      playdate.kButtonUp |
      playdate.kButtonDown |
      playdate.kButtonLeft |
      playdate.kButtonRight)) > 0 then
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
    updateFrame = true
    l += 0.1
    if l > 1 then l = 1 end
  end

  -- draw state
  if updateFrame then
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
        arrows[grid[i][j]]:draw(j * 20 - 20, i * 20 - 20)
      end
    end

    local posX = mat.lerp(last.x, pos.x, l)
    local posY = mat.lerp(last.y, pos.y, l)
    gfx.setColor(gfx.kColorXOR)
    gfx.fillRect(posX * 20 - 20, posY * 20 - 20, 20, 20)

    fntScore:drawText(score, 0, 200)
  end
end
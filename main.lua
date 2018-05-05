local size = 400

local sand = {}
local transform
local dropAllowed = false
local stabilizeAllowed = true

function love.load(arg)
	for i = 0, size + 1 do
		sand[i] = {}
		
		for j = 0, size + 1 do
			sand[i][j] = 0
		end
	end
	
	transform = love.math.newTransform()
	local scale = math.min(love.graphics.getWidth(), love.graphics.getHeight()) / size
	
	transform:translate((love.graphics.getWidth() - love.graphics.getHeight()) / 2, 0)
	transform:scale(scale, scale)	
	
	love.mouse.setPosition(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
end

local drop, stabilize
function love.update(dt)
	if dropAllowed then
		drop(10)
	end
	
	if stabilizeAllowed then
		stabilize()
	end
end

function love.keypressed(key)
	if key == "lshift" then
		dropAllowed = not dropAllowed
	elseif key == "escape" then
		love.event.push("quit")
	elseif key == "space" then
		stabilizeAllowed = not stabilizeAllowed
	elseif key == "x" then
		love.mouse.setPosition(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
	elseif key == "c" then
		dropAllowed = false
		stabilizeAllowed = true
		
		for x = 0, size + 1 do
			for y = 0, size + 1 do
				sand[x][y] = 0
			end
		end
	end
end

function love.mousepressed(x, y, number)
	drop(10000)
end

drop = function(suchMany)
	local mx, my = love.mouse.getPosition()
	local x, y = transform:inverseTransformPoint(mx, my)
	
	x, y = math.floor(x), math.floor(y)
	if x > 0 and x <= size and y > 0 and y <= size then
		sand[x][y] = sand[x][y] + suchMany
	end
	
	love.window.setTitle(("%s:%s"):format(x, y))
end

stabilize = function()
	local count = 0
	repeat
		local stable = true
		
		for x = 1, size do
			for y = 1, size do
				local count = sand[x][y]
				
				if count >= 4 then
					sand[x][y] = count - 4
					
					sand[x][y - 1] = sand[x][y - 1] + 1
					sand[x][y + 1] = sand[x][y + 1] + 1
					sand[x - 1][y] = sand[x - 1][y] + 1
					sand[x + 1][y] = sand[x + 1][y] + 1
					
					stable = false
				end
			end
		end
		
		count = count + 1
	until stable or count == 10
end

local getSandColor
function love.draw()
	love.graphics.applyTransform(transform)
	
	for i = 1, size + 1 do
		for j = 1, size + 1 do
			local r, g, b = getSandColor(sand[i][j])
			love.graphics.setColor(r / 255, g / 255, b / 255, 1)
			love.graphics.rectangle("fill", i, j, 1, 1)
		end
	end
end

getSandColor = function(num)
	if num < 4 then
		local stuff = 64 * num
		return stuff, stuff, stuff
	else
		return 255, 0, 0
	end
end
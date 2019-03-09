pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	grav=0.1
	lx=8
	dx=16
	rx=32
	balls={}
end

function _update()
	if btnp(0) then add(balls,ball:new({x=lx})) end
	if btnp(3) then add(balls,ball:new({x=dx})) end
	if btnp(1) then add(balls,ball:new({x=rx})) end

	--delete balls at the bottom
	for i=1,#balls do
		if i<=#balls then
			if balls[i].y>127 then del(balls,balls[i]) end
		end
	end

	--update ball positions
	for i in all(balls) do
			update_pos(i)
	end
end

function _draw()
	cls()
	for i in all(balls) do
		circfill(i.x,i.y,4)
	end
end
-->8
ball = {
	x=0,
	y=0,
	vx=0,
	vy=0,
}

function ball:new(o)
	self.__index = self
	return setmetatable(o or {}, self)
end

function update_pos(ball)
	ball.vy+=grav
	ball.y+=ball.vy
end

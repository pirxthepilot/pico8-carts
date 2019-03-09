pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	init_things()
	grav=0.1
	lx=8
	dx=16
	rx=32
end

function _update()
	if btnp(0) then	new_ball(lx,0,0,0) end
	if btnp(3) then	new_ball(dx,0,0,0) end
	if btnp(1) then	new_ball(rx,0,0,0) end

	--update ball positions
	for i in all(balls) do
			i:update()
	end
end

function _draw()
	cls()
	for i in all(balls) do
		i:draw()
	end
end
-->8
function init_things()
	balls = {}
end

function new_ball(_x,_y,_vx,_vy)
	add(balls,{
		x=_x,
		y=_y,
		vx=_vx,
		vy=_vy,
		update=function(self)
			self.vy+=grav
			self.y+=self.vy
			if self.y>127 then
				del(balls,self)
			end
		end,
		draw=function(self)
			circfill(self.x,self.y,4)
		end
	})
end

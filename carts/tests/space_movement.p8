pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	init_all()
	grav=0.01
	frict=0.9
	rad=2
	dlim=3
	make_obj(63,63,rad)
end

function _update60()
	-- button presses
	if btn(0) then
		bstate.l=true
		bstate.r=false
	end
	if btn(1) then
		bstate.r=true
		bstate.l=false
	end
	if btn(2) then
		bstate.u=true
		bstate.d=false
	end
	if btn(3) then
		bstate.d=true
		bstate.u=false
	end

	-- obj movement
	for i in all(objs) do
		-- up/down
		if bstate.u then
			i:move_u()
		elseif bstate.d then
			i:move_d()
		end
		-- right/left
		if bstate.r then
			i:move_r()
		elseif bstate.l then
			i:move_l()
		end
	end
	
	-- particle movement
	for i in all(particles) do
		i:update()
	end
end

function _draw()
	cls()
	-- objs
	for i in all(objs) do
		i:draw()
	end
	-- particles
	for i in all(particles) do
		i:draw()
	end
end
-->8
-- init defines

function init_all()
	objs={}
	particles={}
	bstate={
		l=false,
		r=false,
		u=false,
		d=false
	}
end
-->8
-- objects

function make_obj(_x,_y,_r)
	add(objs,{
		x=_x,
		y=_y,
		dx=0,
		dy=0,
		r=_r,
		a=grav,
		move_r=function(self)
			if btn(1) then
				self.dx+=self.a
				addpart(self.x,self.y,10,190,170)
			end
			self.x+=self.dx
		end,
		move_l=function(self)
			if btn(0) then
				self.dx-=self.a
				addpart(self.x,self.y,10,10,350)
			end
			self.x+=self.dx
		end,
		move_d=function(self)
			if btn(3) then
				self.dy+=self.a
				addpart(self.x,self.y,10,100,80)
			end
			self.y+=self.dy
		end,
		move_u=function(self)
			if btn(2) then
				self.dy-=self.a
				addpart(self.x,self.y,10,280,260)
			end
			self.y+=self.dy
		end,
		draw=function(self)
			--print("dx:"..self.dx.." dy:"..self.dy)
			circfill(self.x,self.y,self.r)
		end
	})
end
-->8
-- particles

function addpart(_x,_y,_age,max_a,min_a)
	local _spd=0.2

	add(particles,{
		angle=rndangle(max_a,min_a),
		x=_x,
		y=_y,
		vx=0,
		vy=0,
		age=_age+flr(rnd(5)),
		-- update
		update=function(self)
			-- expire
			if self.age==0 then
				del(particles,self)
			end
			-- movement
			self.vx+=_spd*cos(self.angle)
			self.vy+=_spd*sin(self.angle)
			self.x+=self.vx
			self.y+=self.vy
			self.age-=1
		end,
		-- draw
		draw=function(self)
			pset(self.x,self.y,7)
		end
	})
end
-->8
-- helper functions

-- convert degrees to rotation
function rotval(degrees)
	return degrees/360
end

-- get angle diff
-- input: rightmost,leftmost
--        (clockwise dir)
-- input in rotation!
function rotdiff(_r,_l)
	return (_r-_l)%1
end

-- random angle given r and l
-- input in degrees!
function rndangle(_r,_l)
	local r=rotval(_r)
	local l=rotval(_l)
	local diff=rotdiff(r,l)
	return (l+(rnd()*diff))%1
end

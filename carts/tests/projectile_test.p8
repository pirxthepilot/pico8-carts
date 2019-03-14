pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	grav=0.1
	oy=80
	parts={}
	veins={}
	lava_cols={7,8,9,10}
end

function _update()
	for i=0,1 do
		local r_maxdy=rnd(2)
		local r_maxage=rndrange(r_maxdy*20,r_maxdy*40)
		local r_angle=rndangle(285,255)
		local r_color=lava_cols[flr(rnd(#lava_cols))+1]
		make_part(31,oy,0,0,r_maxdy,r_maxage,r_angle,r_color)
	end
	for i in all(parts) do
		update_part(i)
	end
end

function _draw()
	cls()
	rectfill(0,oy,127,oy+2,10)
	for i in all(parts) do
		draw_part(i)
	end
end
-->8
-- lava particles
function make_part(_x,_y,_dx,_dy,_maxdy,_maxage,_a_rot,_col)
	add(parts, {
		x=_x,
		y=_y,
		dx=_dx,
		dy=_dy,
		maxdy=_maxdy,
		age=0,
		maxage=_maxage,
		a_rot=_a_rot,
		up=true,
		col=_col
	})
end

function update_part(p)
	if p.age>=p.maxage then
		del(parts,p)
		return
	end
	if p.up then
		if p.dy>-p.maxdy then
			p.dy-=grav
		else
			p.up=false
		end
	else
		p.dy+=grav
	end
	p.y+=p.dy
	p.dx+=grav*cos(p.a_rot)
	p.x+=p.dx
	p.age+=1
end

function draw_part(p)
	//print('x:'..p.x..' y:'..p.y)
	pset(p.x,p.y,p.col)
end
-->8
-- lava veins
function make_vein(_x,_y)
	add(veins, {
		x=_x,
		y=_y,
		len=rndrange(1,10),
		maxdy=rnd(2),
		maxage=rndrange(r_maxdy*20,r_maxdy*40),
		angle=rndangle(285,255),
		color=lava_cols[flr(rnd(#lava_cols))+1]
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

-- random number from a range
function rndrange(lower,upper)
	local interval=upper-lower+1
	local r=flr(rnd(interval))
	return r+lower
end
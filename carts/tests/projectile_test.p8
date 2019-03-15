pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function _init()
	lava_init()
	make_veinset(61,oy,veinset_count)
	make_veinset(62,oy,veinset_count)
	make_veinset(63,oy,veinset_count)
end

function _update()
	-- veinsets and veins
	for i in all(veinsets) do
		-- lava vein and particle creation
		if #i.veins<i.count then
			make_vein(i.veins,i.x,i.y)
		end
		--if #veins<vein_count then
		--	make_vein(31,oy)
		--end
		-- update veins
		for j in all(i.veins) do
			update_vein(i.veins,j)
		end
	end

	-- update lava particles
	for i in all(parts) do
		update_part(i)
	end
end

function _draw()
	cls()
	rectfill(0,oy,127,oy+2,10)
	lava_draw()
end
-->8
-- lava
-- lava init
function lava_init()
	grav=0.1
	oy=80
	lava_cols={8,9,10}
	parts={}
	veinsets={}
	veinset_count=8
	min_vein_len=2
	max_vein_len=10
end

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
	pset(p.x,p.y,p.col)
end
-->8
-- lava veins
function make_vein(_vein,_x,_y)
	local r_maxdy=rnd(2)
	add(_vein, {
		x=_x,
		y=_y,
		len=rndrange(min_vein_len,max_vein_len),
		maxdy=r_maxdy,
		maxage=rndrange(r_maxdy*20,r_maxdy*40),
		angle=rndangle(285,255),
		color=lava_cols[flr(rnd(#lava_cols))+1]
	})
end

function update_vein(_veins,v)
	if v.len==0 then
		del(_veins,v)
		return
	end
	make_part(v.x,v.y,0,0,v.maxdy,v.maxage,v.angle,v.color)
	v.len-=1
end

function make_veinset(_x,_y,_count)
	add(veinsets, {
		x=_x,
		y=_y,
		count=_count,
		veins={}
	})
end

-- Draw the lava particles
function lava_draw()
	for i in all(parts) do
		draw_part(i)
	end
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
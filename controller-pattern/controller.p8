pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
-- main
function _init()
	player=make_actr(64,64,1)
	enemy=make_actr(20,64,0.5)
end

function _update()
	for cmd in all(read_plyr_cmds()) do
		cmd(player)
	end
	
	-- enemy
	local ecmd=read_enmy_cmd(enemy,player)
	if ecmd!=nil then
		ecmd(enemy)
	end
	
	actr_step(player)
	actr_step(enemy)
end

function _draw()
	cls()
	circfill(player.x,player.y,3,8)
	circfill(enemy.x,enemy.y,3,9)
end
-->8
-- command
function cmd_jmp(a)
	actr_jmp(a)
end

function cmd_lft(a)
	actr_mov(a,-1)
end

function cmd_rght(a)
	actr_mov(a,1)
end
-->8
-- actor
function make_actr(x,y,spd)
	return {
		x=x,
		y=y,
		vy=0,
		facing=1,
		spd=spd
	}
end

function actr_jmp(a)
	if a.y>=64 then a.vy=-2.5 end
end

function actr_mov(a,dx)
	a.x+=dx*a.spd
	if dx!=0 then a.facing=sgn(dx) end
end

function actr_step(a)
	a.vy+=0.2
	a.y+=a.vy
	if a.y>64 then
		a.y=64
		a.vy=0
	end
end
-->8
-- director
binds={
	[0]=cmd_lft,
	[1]=cmd_rght,
	[4]=cmd_jmp,
	[5]=cmd_jmp
}

function read_plyr_cmds()
	local cmds={}
	for b=0,1 do
		if btn(b) then add(cmds,binds[b]) end
	end
	
	for b=4,5 do
		if btnp(b) then add(cmds,binds[b]) end
	end
	return cmds
end

function read_enmy_cmd(e,target)
	if e.x<target.x then return cmd_rght end
	if e.x>target.x then return cmd_lft end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

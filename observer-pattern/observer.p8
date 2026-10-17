pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
--main
function _init()
	player=make_actor(64,64,1,1)
	player.hp=3
	enemy=make_actor(20,64,0.5,2)
	item={x=100,y=64,spr=3,alive=true}
	hit_t=0
	init_audio()
	init_banner()
end

function _update()
	for cmd in all(read_plyr_cmds()) do
		cmd(player)
	end
	
	local ecmd=read_enemy_cmd(enemy,player)
	if ecmd!=nil then
		ecmd(enemy)
	end
	
	actor_step(player)
	actor_step(enemy)
	check_hits()
	
	if msg_t>0 then msg_t-=1 end
end

function _draw()
	cls()
	rectfill(0,64,127,127,3)
	if item.alive then
		spr(item.spr,item.x-4,item.y-8)
	end
	spr(enemy.spr,enemy.x-4,enemy.y-8,1,1,enemy.facing<0)
	spr(player.spr,player.x-4,player.y-8,1,1,player.facing<0)
	for i=1,player.hp do
		spr(3,2+(i-1)*9,2)
	end
	if msg_t>0 then
		print(msg,52,20,7)
	end
end

boxes={
	[1]={x=1,y=0,w=6,h=8},
	[2]={x=0,y=0,w=8,h=7},
	[3]={x=0,y=1,w=8,h=6}
}

function spr_rect(a)
	local b=boxes[a.spr]
	return a.x-4+b.x,a.y-8+b.y,b.w,b.h
end

function overlap(a,b)
	local ax,ay,aw,ah=spr_rect(a)
	local bx,by,bw,bh=spr_rect(b)
	return ax<bx+bw and bx<ax+aw
	and ay<by+bh and by<ay+ah
end

function check_hits()
	if hit_t>0 then
		hit_t-=1
	elseif overlap(player,enemy) then
		player_take_hit(1)
		hit_t=30
	end
	
	if item.alive and overlap(player,item) then
		player_heal()
		item.alive=false
	end
end
-->8
--publisher
function player_jump()
	if not player.on_ground then return end
	player.vy=-3
	player.on_ground=false
	player_actions.notify("jump")
end

function player_take_hit(dmg)
	if player.hp<=0 then return end
	player.hp-=dmg
	player_actions.notify("hit")
end

function player_heal()
	if	player.hp>=5 then return end
	player.hp+=1
	player_actions.notify("heal")
end
-->8
--subject
player_actions={
	subscribers={}
}

function player_actions.subscribe(event,fn)
	local list=player_actions.subscribers[event]
	if not list then
		list={}
		player_actions.subscribers[event]=list
	end
	add(list,fn)
end

function player_actions.unsubscribe(event,fn)
	local list=player_actions.subscribers[event]
	if list then
		del(list,fn)
	end
end

function player_actions.notify(event)
	local list=player_actions.subscribers[event]
	if not list then return end
	for fn in all(list) do
		fn(event)
	end
end
-->8
--sfx observer
sfx_ids={
	jump=0,
	hit=1,
	heal=2
}

function on_sfx(event)
	local id=sfx_ids[event]
	if id then
		sfx(id)
	end
end

function init_audio()
	player_actions.subscribe("jump",on_sfx)
	player_actions.subscribe("hit",on_sfx)
	player_actions.subscribe("heal",on_sfx)
end
-->8
--controls
--actor
function make_actor(x,y,spd,s)
	return {
		x=x,
		y=y,
		vy=0,
		facing=1,
		spd=spd,
		spr=s,
		on_ground=true
	}
end


function actor_move(a,dx)
	a.x+=dx*a.spd
	if dx!=0 then a.facing=sgn(dx) end
end

function actor_step(a)
	a.vy+=0.2
	a.y+=a.vy
	if a.y>64 then
		a.y=64
		a.vy=0
		a.on_ground=true
	else
		a.on_ground=false
	end
end

-- command
function cmd_jmp(a)
	player_jump()
end

function cmd_lft(a)
	actor_move(a,-1)
end

function cmd_rght(a)
	actor_move(a,1)
end

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

function read_enemy_cmd(e,target)
	if e.x<target.x then return cmd_rght end
	if e.x>target.x then return cmd_lft end
end
-->8
--banner observer
msg=""
msg_t=0

function on_banner(event)
	msg=event
	msg_t=45
end

function init_banner()
	player_actions.subscribe("jump",on_banner)
	player_actions.subscribe("hit",on_banner)
	player_actions.subscribe("heal",on_banner)
end
__gfx__
00000000007007000080080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000007777770008008000ee00ee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070007c77c7088888888eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000777777008a88a80eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000777700088888800eeeeee0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700007777000088880000eeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000077770000088000000ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
0001000003050070500b0500d0501105015050180501b0501e0502105000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000085500855007550055500355002500183001b3001f3002230000200002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00090000391503b1503d1500f10017100001000010000100001000010000100001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

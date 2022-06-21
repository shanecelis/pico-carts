pico-8 cartridge // http://www.pico-8.com
version 15
__lua__
-- hello!
-- let me know if you have any
-- questions about what you
-- find in here.
-- twitter: @2darray




-- load a level
function newday()

	-- pick a chaotic random seed
	-- ("cancel" previous random seeds)
	srand(rotl(time()*1.234123,16))

	-- music starts at different spots,
	-- to avoid telegraphing the sunset
	music(1+rnd(8))
	
	-- spawn our character
	guy={}
	
	guy.x=64*8
	guy.y=32*8+28
	guy.vx=0
	guy.vy=0
	guy.accel=.4
	guy.damping=.85
	
	-- crosshair stuff
	aiming=false
	harpooning=false
	aimx=0
	aimy=0
	aimvx=0
	aimvy=0
	
	-- percentage of one footstep per frame
	-- (here, 1 step = 8 frames)
	stepspeed=.125
	
	-- rendering info
	hipx=guy.x
	hipy=guy.y
	faceangle=0
	
	-- create endpoints of four limbs
	lfoot=makefoot()
	rfoot=makefoot()
	lhand=makehand()
	rhand=makehand()
	
	-- hook/rope stuff
	hookdamp=.95
	hookx=guy.x
	hooky=guy.y
	hookz=0
	hookvx=0
	hookvy=0
	hookvz=0
	hooklen=1
	hookout=false
	hookflash=0
	
	hooktimer=0
	harptimer=0
	
	-- list of the fish we're holding,
	-- and their total value
	heldfish={}
	heldvalue=0
	
	-- are we standing in front of the store?
	canstore=false

	-- are we currently entering the store?
	enterstore=false
	
	-- screen/state transition commands
	gotostore=false
	gotogame=false
	
	-- camera position
	cx=guy.x
	cy=guy.y
	
	-- clock
	timeofday=0
	
	-- list for harpoon impact particles
	specks={}
	
	-- the beastie
	beast={}
	beast.x=rnd(1024)
	beast.y=rnd(512)

	-- enable these lines to force the beast
	-- to spawn near the store:
	-- beast.x=70*8
	-- beast.y=32*8
	
	beast.vx=0
	beast.vy=0
	beast.damping=.8
	beast.active=false
	beast.spawntimer=0
	beast.speed=0
	playingbeastsong=false
	
	-- store is in the middle of the map
	storex=64*8
	storey=32*8
	
	-- discard yesterday's generated map/sprites
	reload(0,0,0x3000)
	
	-- water data!
	-- velocity:
	flowfield={}
	-- distance to shore/depth:
	distfield={}
	-- "dry" spots
	catchfield={}

	-- initialize water data grids
	for x=0,127 do
		flowfield[x]={}
		catchfield[x]={}
		for y=0,63 do
			flowfield[x][y]={0,0}
		end
	end
	
	-- now we're gonna generate our map

	-- first we'll draw a random brushstoke,
	-- marking tiles as water.
	-- their flowfield speed is based
	-- on the brush speed
	local rx=rnd(128)
	local ry=rnd(64)
	local vx=0
	local vy=0
	
	for i=1,6000 do
		vx+=rnd(.5)-.25
		vy+=rnd(.5)-.25
		vx*=.9
		vy*=.9
		rx+=vx
		ry+=vy
		
		for x=rx,rx+1 do
			for y=ry,ry+1 do
				x=flr(x)%128
				y=flr(y)%64
				local dx=x-storex/8
				local dy=y-storey/8
				-- don't put any water
				-- right next to the shop
				if dx*dx+dy*dy>10*10 then
					mset(x,y,19)
					local flow=flowfield[x][y]
					flow[1]+=vx
					flow[2]+=vy
				end
			end
		end
	end
	
	-- delete single-tile islands
	for x=0,127 do
		for y=0,63 do
			if mget(x,y)!=19 then
				if mget(x+1,y)==19 then
					if mget(x-1,y)==19 then
						if mget(x,y+1)==19 then
							if mget(x,y-1)==19 then
								mset(x,y,19)
							end
						end
					end
				end
			end
		end
	end
	
	-- similar brushstroke strategy
	-- for making paths and docks
	rx=rnd(128)
	ry=rnd(64)
	vx=0
	vy=0
	
	for i=1,5000 do
		local r=.001
		local tile=mget(rx,ry)
		if tile==19 or tile==21 then
			r=.2
		end
		if rnd()<r then
			rx=rnd(128)
			ry=rnd(64)
		end
		vx+=rnd(.2)-.1
		vy+=rnd(.2)-.1
		vx*=.97
		vy*=.97
		rx+=vx
		ry+=vy
		for x=rx,rx+1 do
			x%=128
			local y=ry%64
			local tile=mget(x,y)
			if tile!=19 and tile!=21 then
				-- ground tiles become paths
				mset(x,y,1)
			else
				-- water tiles become docks
				mset(x,y,21)
			end
		end
	end
	
	-- find shoreline water tiles
	for x=0,127 do
		for y=0,63 do
			local tile=mget(x,y)
			if tile==19 or tile==21 then
				local shore=false
				for i=x-1,x+1 do
					for j=y-1,y+1 do
						if i!=x or j!=y then
							if i==x or j==y then
								local tile2=mget(i,j)
								if tile2<19 or tile2>22 then
									shore=true
								end
							end
						end
					end
				end
				if (shore) mset(x,y,tile+1)
			end
		end
	end
	
	-- find distance from each water tile
	-- to the nearest shore
	for x=0,127 do
		distfield[x]={}
		for y=0,63 do
			distfield[x][y]=shoredist(x,y)
		end
	end
	
	-- add variation to grass tiles
	for x=0,127 do
		for y=0,63 do
			local tile=mget(x,y)
			if tile==16 then
				-- nearby grass has similar density
				local wave=sin(x*y/234.34)*cos(x*x*y/137.79)
				
				-- less grass near pathways
				local mindist=5
				for i=x-4,x+4 do
					for j=y-4,y+4 do
						local tile2=mget(i,j)
						if tile2==1 then
							mindist=min(mindist,
							            sqrt((i-x)^2+(j-y)^2))

						end
					end
				end
				wave-=(1-mindist/5)*(1+rnd())
				
				-- pick a grass sprite
				-- (based on our density)
				if wave<-.5 then
					tile=48
				elseif wave<0 then
					tile=32
				end
				mset(x,y,tile)
			end
		end
	end
end

-- first time startup!
function _init()
	state="title"
	fadevalue=1
	storescroll=0
	money=0
	
	dayduration=60
	
	-- stuff we can buy, with prices
	storeitems={25,"clock",
	            100,"sensor",
	            250,"compass",
	            1000,"harpoon"}
	-- item hint strings include arrows/spacing
	-- (to save some tokens)
	itemhints={"       counts\n------>down to\n       sunset",
	           "       finds\n  ---->valuable\n       fish",
	           "       points\n   --->toward\n       home",
	           "       catches\n    -->fish\n       instantly"}
	
	-- items we currently own
	items={}
	
	-- particle colors for different materials
	watercols={1,2,12,13}
	dirtcols={5,4,9}
	grasscols={4,3,11}
end

function _draw()
	if state=="title" then
		-- draw the title screen!

		cls(1)
		-- dithered letterbox bars
		fillp(0b1010010110100101.1)
		rectfill(0,30,127,97,2)
		fillp()

		-- title card
		for i=0,1 do
			if (i==0) pal(7,5)
			spr(64,46,7-i,5,3)
			pal()
		end

		-- credits and such
		sprint("a game by eli piilonen",20,101,13,5)
		sprint("with music by david carney",12,110,6,5)
		sprint("press 🅾️ (keyboard: z)",20,119,14,2)
	
		-- particle stream
		srand(1)
		for i=1,900 do
			local x=(rnd(128)-time()*15+sin(cos(time()*(.05+rnd(.05))))*(5+rnd(5)))%128
			local y=44+rnd(40)+sin(cos(time()*(.03+rnd(.06))))*(5+rnd(5))
			pset(x,y,watercols[i%#watercols+1])
		end
	elseif state=="game" then
		cls(3)
		camera(cx-64,cy-64)
		
		-- iterate through the tiles on the map
		for mx=flr((cx-71)/8),(cx+71)/8 do
			for my=flr((cy-71)/8),(cy+71)/8 do
				-- the map loops:
				local mapx=mx%128
				local mapy=my%64

				-- each tile gets its own random seed:
				srand(mapx*64+mapy)

				-- render the current tile
				local tile=mget(mapx,mapy)
				if tile==16 or tile==32 then
					-- grass tile
					if rnd()<.5 then
						pal(11,8+rnd(4))
						spr(tile+1,
						    mx*8+rnd(3)-1,
						    my*8+rnd(2),
						    1,1,
						    rnd()<.5,
						    rnd()<.5)
						pal()
					end

					-- wiggly bits
					local wob=sin(time()+mapx/8.1+mapy/12.2)
					local flipx=rnd()>.5
					local flipy=rnd()>.5
					spr(tile+1,
					    mx*8,
					    my*8,
					    1,1,
					    flipx,
					    flipy)
					pal(11,8+rnd(4))
					spr(tile+1,
					    mx*8+.5+wob*(.5+rnd()),
					    my*8-1,
					    1,1,
					    flipx,
					    flipy)
					pal()
				elseif tile==1 then
					-- pathway tile
					spr(2+rnd(6),
					    mx*8,
					    my*8,
					    1,1,
					    rnd()<.5)
				elseif tile>18 and tile<23 then
					-- water tile
					if tile==20 or tile==22 then
						-- shoreline - bunch of circles
						for i=1,6 do
							circfill(mx*8+1+rnd(6),
							         my*8+1+rnd(6),
							         4,
							         1)
						end
					else
						-- deep water - just a rect
						rectfill(mx*8,my*8,
						         mx*8+7,
						         my*8+7,
						         1)
					end

					-- draw moving water dots
					-- (visualize the flowfield)
					local col=13
					if rnd()<.5 then
						col=12
					end
					local flow=flowfield[mapx][mapy]
				
					-- each tile draws two pixels
					-- which move along the tile's flow
					-- direction. points always stay
					-- inside their single 8x8 tile
					local r=rnd(8)
					local r2=rnd(8)
					local scroll=time()*4
					local hx1=mx*8+flr(r+flow[1]*scroll)%8
					local hx2=mx*8+flr(r+flow[1]*(scroll+.3))%8
					local hy1=my*8+flr(r2+flow[2]*scroll)%8
					local hy2=my*8+flr(r2+flow[2]*(scroll+.3))%8
					pset(hx1,hy1,col)
					pset(hx2,hy2,col)
					
					if tile>20 then
						-- bridge/dock tile
						local yoff=0
						if abs(mapx*8+4-guy.x)<6 and abs(mapy*8+4-guy.y)<6 then
							yoff=1
						end
						spr(34+rnd(4),mx*8,my*8+yoff,1,1,rnd()<.5)
					else
						if items.sensor then
							-- show expensive fish locations!
							if aiming then
								if catchfield[mapx][mapy] then
									spr(51,mx*8,my*8)
								else
									local flow=flowfield[mapx][mapy]
									local dist=distfield[mapx][mapy]

									-- only an estimate:
									local value=(abs(flow[1])+abs(flow[2])+1)*dist

									if value>40 and time()*value/10%1<.5 then
										local col=2
										if (value>100) col=14
										fillp(0b1010010110100101.1)
										rect(mx*8,my*8,
										     mx*8+7,
										     my*8+7,
										     col)
										fillp()
									end
								end
							end
						end
					end
					
					--rect(mx*8,my*8,mx*8+7,my*8+7,distfield[mapx][mapy]/2+2)
				end
			end
		end
		
		-- draw the parts of the store
		-- which are behind the player
		drawstore(-1)
		
		if guy.drawhook and hooky<rhand.y then
			-- hook is behind the player - draw it first
			drawhook()
		end
		
		if bolt and bolt.ey<rhand.y then
			-- harpoon bolt is behind the player
			drawbolt()
		end
		
		-- harpoon impact particles
		for i,speck in pairs(specks) do
			line(speck.ox,speck.oy-speck.oz,
			     speck.x,speck.y-speck.z,
			     speck.cols[flr(speck.life*#speck.cols*speck.colmult)+1])
		end
		
		-- shadow from player's head
		for i=guy.x-2,guy.x+2 do
			shadow(i,guy.y+1)
			if i>guy.x-2 and i<guy.x+2 then
				shadow(i,guy.y)
				shadow(i,guy.y+2)
			end
		end

		-- shadows for player's limbs
		for i=0,1,.2 do
			for j=1,2 do
				for k=1,2 do
 				local foot=lfoot
 				local hand=lhand
 				if (k==2) foot,hand=rfoot,rhand
  			shadow(hipx+(foot.x-hipx)*i,
  			       hipy+(foot.y-hipy)*i+j)
  			shadow(guy.x+(hand.x-guy.x)*i,
  			       guy.y+(hand.y-guy.y)*i+j-1)
 			end
 		end
		end
		
		local facex=cos(faceangle)
		local facey=sin(faceangle)
		
		-- draw legs
		for i=1,2 do
			local foot=lfoot
			if (i==2) foot=rfoot
			limb(hipx,hipy,5.5,foot.x,foot.y,foot.z,7,facex,facey,0,14,2)
		end

		-- draw torso
		sline(guy.x,guy.y-9,hipx,hipy-5.5,2,2)
		
		-- draw arms
		for i=1,2 do
			local hand=lhand
			if (i==2) hand=rhand
			limb(guy.x,guy.y,9,hand.x,hand.y,hand.z,6.5,(-facex+facey*(1.5-i))*.7,(-facey-facex*(1.5-i))*.7,0,14,2)
		end
		
		-- draw harpoon gun
		if harpooning then
			for i=0,1 do
				line(rhand.x,rhand.y-rhand.z-i,
				     rhand.x+facex*1.5,rhand.y-rhand.z-i+facey*1.5,
				     5+i)
			end
		end
		
		-- draw player's head
		circfill(guy.x,guy.y-11,3,2)
		circfill(guy.x,guy.y-11,2,14)
		
		if guy.drawhook and hooky>=rhand.y then
			-- hook is in front of us
			drawhook()
		end
		
		if bolt and bolt.ey>=rhand.y then
			-- harpoon bolt is in front of us
			drawbolt()
		end
		
		-- crosshair
		if aiming then
			local ti=time()
			for x=-2,2 do
				for y=-2,2 do
					if abs(x)-abs(y)!=0 then
						local bcol=5
						if (harpooning) bcol=8
						pset(aimx+x,aimy+y,bcol+(ti*4+x/4+y/4)%3)
					end
				end
			end
		end
		
		-- draw the parts of the store that are
		-- in front of the player
		drawstore(1)
		
		-- __the beeeaaast__
		-- i fought the beast on a cliff, i fought the beast in a swamp, i fought the beast in the toilets of a nightclub
		if timeofday>1 then
			drawbeast()
		end
		
		-- action prompts
		local action="🅾️ (hold) aim"
		local col=6
		if items.harpoon then
			action="🅾️/❎ (hold) aim"
		end
		if hookout then
			action="🅾️ reel"
			if heldfishtimer<0 then
				print("🅾️",hookx-4,hooky-8-(time()*8)%2,8+(time()*8)%3)
			end
		end
		if canstore then
			action="🅾️ enter"
			col=7
			circfill(storex-1,storey,5,1)
			sprint("🅾️",storex-4,storey-3,13+(time()*4)%2,2)
		end
		if aiming or enterstore then
			action=""
		end
		
		oprint(action,cx-62,cy+57,col,1)
		
		-- night-time screen filter
		local t=max((1-timeofday)*9,0)

		-- as t increases, fewer "1" bits remain:
		local modifier=shr(0b0001000100010001.0001000100010001,4*flr(t*8))
		
		local ti=time()/64
		
		-- take some number of screen-pixels
		-- and reduce their color by 1
		for i=0x6000,0x7fff,4 do
			poke4(i,peek4(i)-rotr(modifier,flr(i*ti)*4))
		end
		
		-- hud
		local str="$"..money.." in cash"
		oprint(str,cx+62-#str*4,cy-62,11,3)
		str="$"..heldvalue.." in fish"
		oprint(str,cx+62-#str*4,cy-54,14,2)
		
		if items.clock and timeofday<1 then
			-- clock display
			local timer=flr((1-timeofday)*dayduration)
			local mins=flr(timer/60)..":"
			local secs=timer%60
			if (secs<10) secs="0"..secs
			oprint(mins..secs,cx+46,cy-46,11-timeofday*3,4-timeofday*3)
		end
		
		if items.compass then
			-- point us home
			local dx=(storex-guy.x)/8
			local dy=(storey-guy.y)/8
			-- make sure we point the shortest way
			-- (the map loops!)
			dx-=flr((dx+64)/128)*128
			dy-=flr((dy+32)/64)*64
			local angle=atan2(dx,dy)
			local ax=flr(cos(angle)*5+.5)
			local ay=flr(sin(angle)*5+.5)
			local x=cx+55
			local y=cy+54
			circ(x,y+1,7,5)
			circ(x,y,7,7)
			line(x,y+1,x+ax,y+ay+1,5)
			line(x,y,x+ax,y+ay,7)
		end
		
		-- enable this to show cpu usage
		--print("cpu: "..flr(stat(1)*100).."%",cx-63,cy-63,7)
	elseif state=="fish" then
		-- "you caught a fish" screen
		cls()
		camera()
		
		-- draw a blurred screenshot of
		-- the normal game
		-- (see "savescreen()" function)
		sspr(0,0,128,64,0,0,128,128)
		
		-- entrance timer
		local t=1-fishanimtimer
		-- easing function
		t=1-(t^4*2-t^2)
		
		-- dithered background circle
		fillp(0b1010010110100101.1)
		circfill(64,64,t*cfish.size*5+15,13)
		fillp()
		
		-- render the fish
		drawfish(cfish,64,256-t*192,1)
		
		--print("cpu: "..flr(stat(1)*100).."%",1,1,7)
		
		-- show fish stats
		oprint("size: "..flr(cfish.size*10)/10,40,130-30*t,12,1)
		oprint("quality: "..flr(cfish.quality*10)/10,42,147-40*t,14,2)
		oprint("value: $"..cfish.value,44,164-50*t,11,3)
		
		if cfish.live==0 then
			-- unhappy face
			oprint("(dead: 1/4 value)",28,121,9,5)
		end

		oprint("press 🅾️",3,-7+9*t,7,5)

	elseif state=="store" then
		cls()

		if storepage=="sell" then
			-- end-of-day results page
			camera(0,-storescroll^2*128)
			message="you didn't catch any fish"
			if guy.dead then
				message="you were caught by a monster"
			end
			if heldvalue>0 then
			 	message="you sold "..#heldfish.." fish for $"..heldvalue.."!"
			end
			sprint(message,64-#message*2,10,11,3)

			sprint("press 🅾️",1,120,14,2)

			-- draw the fish we've sold
			if #heldfish>0 then
				if #heldfish<3 then
					-- 1 or 2 fish: just draw them
					for i=1,#heldfish do
						local fish=heldfish[i]
						local x=(i-1)*48+64-(#heldfish-1)*24
						drawfish(fish,x,64,.4)
						oprint("$"..fish.value,x-6,64-15,11,3)
					end
				else
					-- 3 or more fish:
					-- have to do a fish-marquee
					for i=0,3 do
						local fish=heldfish[flr(i+time()/2)%#heldfish+1]
						local x=32-time()/2%1*64+i*64
						drawfish(fish,x,64,.4)
						oprint("$"..fish.value,x-6,64-15,11,3)
					end
				end
			end
		elseif storepage=="buy" then
			-- simple-ass store ui

			cls()
			camera(storescroll^2*128,0)
			
			sprint("you have $"..money,5,5,11,3)
			
			for i=1,#itemhints+1 do
				local x=18
				local y=45+i*7
				local col1=9
				local col2=4
				local str="all done"
				local canbuy=true
				if (i<=#itemhints) then
					col1=6
					col2=5
					
					local itemname=storeitems[i*2]
					if (items[itemname]) then
						canbuy=false
						col1=4
						col2=2
					end
					str="$"..storeitems[i*2-1].."-"..itemname
					y-=5
				
					if buyindex==i then
						local hint=itemhints[i]
						sprint(hint,56,y-6,14,2)
					end
				end
				if buyindex==i then
					x+=2
					if canbuy then
						col1+=1
					end
				end
				sprint(str,x,y,col1,col2)
				if not canbuy then
					line(x-1,y+2,x+#str*4,y+2,13)
				end
			end
		end
	elseif state=="victory" then
		-- ridiculously simple ending screen
		-- (we'll say it's "minimalist")
		cls()
		camera()
		local messages={"you have quieted the source",
		                "of your anxiety",
		                "",
		                "your nightmares fade",
		                "and you rest peacefully"}
		for i=1,5 do
			sprint(messages[i],64-#messages[i]*2,30+i*7,7,5)
		end
	end

	-- scene transition
	if fadevalue>0 then
		for i=1,15 do
			pal(i,i*(1-min(fadevalue,1))+rnd(),1)
		end
	end
end


function _update()
	if gotostore or gotogame then
		-- scene transitions
		fadevalue+=.05
		if fadevalue>1 then
			if gotostore then
				state="store"
				storepage="sell"
				money+=heldvalue
			end
			if gotogame then
				state="game"
				newday()
			end
			fadevalue=1
			gotostore=false
			gotogame=false
		end
	elseif fadevalue>0 then
		-- scene isloaded!
		-- fade the view back in
		fadevalue-=.05
	end
	
	-- happy music slows down when
	-- the day is ending
	local speed=32
	if state=="game" then
		speed=32+(timeofday-.9)*80
		speed=mid(speed,32,99)
	end
	for i=2,27 do
		poke(0x3200+68*i+65,speed)
	end

	if state=="title" then
		-- highly advanced main menu system
		if btnp(4) then
			gotogame=true
		end
	elseif state=="game" then
		-- timeofday is 0-1,
		-- dayduration is measured in seconds
		timeofday+=1/30/dayduration
		
		-- fade out harpoon bolt
		if bolt then
			bolt.life-=1/20
			if bolt.life<0 then
				bolt=nil
			end
		end
		
		-- update harpoon impact particles
		for i,speck in pairs(specks) do
			speck.ox=speck.x
			speck.oy=speck.y
			speck.oz=speck.z
			
			speck.vz-=.3
			speck.vx*=.95
			speck.vy*=.95
			speck.vz*=.95
			speck.x+=speck.vx
			speck.y+=speck.vy
			speck.z+=speck.vz
			
			speck.life-=.03/speck.lifetime
			
			if speck.z<0 then
				-- particles bounce off the ground
				speck.z=0
				speck.vx*=.8
				speck.vy*=.8
				speck.vz*=-.5
			end
			
			if (speck.life<0) del(specks,speck)
		end
		
		-- some hook-state management
		if hookout then
			guy.drawhook=true
		else
			-- reel in the hook
			local dx=rhand.x-hookx
			local dy=rhand.y-hooky
			local dz=rhand.z-hookz
			hookx+=dx/2
			hooky+=dy/2
			hookz+=dz/2
			local sqrdist=dx*dx+dy*dy+dz*dz

			-- still show the hook, unless
			-- it's already reached our hand
			if sqrdist>64 then
				guy.drawhook=true
			else
				guy.drawhook=false
			end
		end
		
		-- aiming logic
		if btn(4) or (btn(5) and items.harpoon) then
			if not aiming and not hookout and not blockhook then
				-- begin aiming
				-- (hook or harpoon)
				aiming=true
				aimx=guy.x+cos(faceangle)*32
				aimy=guy.y+sin(faceangle)*32
				aimvx=0
				aimvy=0
				if btn(5) and items.harpoon then
					harpooning=true
				end
			end
			
			-- face toward your aim target
			faceangle=atan2(aimx-guy.x,aimy-guy.y)
		else
			blockhook=false
			if aiming then
				-- we've released the aim button.
				-- throw! or shoot!
				aiming=false
				if harpooning then
					harpooning=false
					useharpoon(aimx,aimy)
					blockhook=true
				else
					hookout=true
					sfx(30)

					-- this timer counts down to a "bite"
					-- while the hook is in the water.
					-- if you miss the prompt, it resets
					heldfishtimer=getfishtime()
					
					-- hooktimer is used to animate the
					-- character's right hand
					hooktimer=0

					-- set hook properties based on aim
					hookx=guy.x
					hooky=guy.y
					hookz=8
					local adx=aimx-guy.x
					local ady=aimy-guy.y
					hookvx=adx/12
					hookvy=ady/12
					hookvz=3
					hooklen=sqrt(adx*adx+ady*ady)+4
				end
			end
		end
		
		if btnp(4) and hookout then
			-- we've hit the "reel in" button
			hookout=false
			blockhook=true
			if hookinwater and heldfishtimer<0 then
				-- reeling in while the "catch"
				-- prompt is active!

				-- take a screenshot
				savescreen()

				-- create a fish and go to the
				-- "fish" state
				generatefish(hookx,hooky)

				-- hook cleanup for when we close
				-- the fish screen:
				hookx=rhand.x
				hooky=rhand.y
				hookz=rhand.z
			end
		end

		-- input management

		-- we'll imagine a virtual analog stick
		-- based on keyboard input, so we
		-- can avoid making diagonal movement
		-- extra-fast
		local inputx=0
		local inputy=0
		
		if not enterstore then
			-- measure our virtual analog stick
			if (btn(0)) inputx-=1
			if (btn(1)) inputx+=1
			if (btn(2)) inputy-=1
			if (btn(3)) inputy+=1
		else
			-- entering the store overrides
			-- all user movement input
			if storex>guy.x+2 then
				inputx=1
			elseif storex<guy.x-2 then
				inputx=-1
			end
			if guy.y>storey+5 then
				inputy=-.6
			else
				-- the player has reached the
				-- inside of the store. scene change!
				gotostore=true
			end
		end
		
		-- fix the speed of diagonal movement
		if inputx!=0 and inputy!=0 then
			inputx*=.707
			inputy*=.707
		end
		
		-- apply our analog stick to either
		-- our character or our crosshair
		if not aiming then
			guy.vx+=inputx*guy.accel
			guy.vy+=inputy*guy.accel
		else
			aimvx+=inputx*guy.accel
			aimvy+=inputy*guy.accel
		end
		
		-- velocity damping:
		guy.vx*=guy.damping
		guy.vy*=guy.damping
		aimvx*=guy.damping
		aimvy*=guy.damping
		
		-- move the crosshair
		aimx+=aimvx
		aimy+=aimvy
		
		-- crosshair must stay within 64 pixels
		local adx=aimx-guy.x
		local ady=aimy-guy.y
		local aimdist=sqrt(adx*adx+ady*ady)
		if aimdist>64 then
			adx/=aimdist
			ady/=aimdist
			aimx=guy.x+adx*64
			aimy=guy.y+ady*64
		end
		
		-- used for animating right hand
		if harpooning then
			harptimer+=1/10
		else
			harptimer-=1/10
		end
		harptimer=mid(harptimer,0,1)
		
		if hookout then
			-- used for animating the right hand
			hooktimer+=1/10
			if (hooktimer>1) hooktimer=1
			
			-- update the hook
			hookinwater=false
			hookvz-=.3
			hookx+=hookvx
			hooky+=hookvy
			hookz+=hookvz
			
			-- constrain hook to rope length
			local dx=hookx-guy.x
			local dy=hooky-guy.y
			local length=sqrt(dx*dx+dy*dy)
			if length>hooklen then
				hookx+=(guy.x+dx/length*hooklen-hookx)/2
				hooky+=(guy.y+dy/length*hooklen-hooky)/2
				length=hooklen
			end
			
			-- measure how much slack the rope has
			hookslack=(hooklen-length)/2
			
			-- character faces toward he hook
			faceangle=atan2(hookx-guy.x,hooky-guy.y)
			
			if hookz<=0 then
				-- we hit the ground plane
				hookz=0

				-- did we hit water?
				local mapx=flr(hookx/8)%128
				local mapy=flr(hooky/8)%64
				local tile=mget(mapx,mapy)
				if tile==19 or tile==20 then
					-- yes:  hook hit the water
					if (hookvz<-1) sfx(33)
					hookvz=0
					
					hookinwater=true
					
					-- can only catch a fish
					-- once per tile, per day
					if not catchfield[mapx][mapy] then
						heldfishtimer-=1/30
						if heldfishtimer<-1 then
							-- you missed the "catch" prompt
							heldfishtimer=getfishtime()
						end
					else
						-- this tile is dry - no fish here
						heldfishtimer=getfishtime()
					end

					-- hook gets pulled by water movement
					local flow=flowfield[mapx][mapy]
					hookvx+=flow[1]/80
					hookvy+=flow[2]/80
				else
					-- hook bounces off the ground
					hookvz*=-.8
					hookvx*=.8
					hookvy*=.8
				end
			end

			-- velocity damping
			hookvx*=hookdamp
			hookvy*=hookdamp
			hookvz*=hookdamp
			
			-- fish timer resets any time
			-- the hook is out of water
			if not hookinwater then
				heldfishtimer=getfishtime()
			end
		else
			-- hook is not out
			-- (lower our right hand)
			hooktimer-=1/20
			if (hooktimer<0) hooktimer=0
		end
		
		-- update our facing angle to aim
		-- toward our movement direction
		if inputx!=0 or inputy!=0 then
			if abs(guy.vx)>.3 or abs(guy.vy)>.3 then
				local newangle=atan2(guy.vx,guy.vy)
				if (newangle>faceangle+.5) newangle-=1
				if (newangle<faceangle-.5) newangle+=1
				if abs(newangle-faceangle)<.025 then
					faceangle=newangle
				else
					faceangle+=sgn(newangle-faceangle)*.025
				end
			end
		end
		
		-- check if we can enter the store from here
		canstore=false
		if not enterstore then
			local dx=guy.x+guy.vx-storex
			local dy=guy.y+guy.vy-storey
			if abs(dx)<40 and abs(dy)<40 then
				local dist=sqrt(dx*dx+dy*dy)
				if dist<26.5 then
					guy.vx=0
					guy.vy=0
				end
				
				if dy>0 and abs(dx)<10 then
					canstore=true
					if btnp(4) then
						-- we triggered the "enter store" prompt
						enterstore=true
						aiming=false
						harpooning=false
						blockhook=true
						music(-1)
					end
				end
			end
		end
		
		-- apply character movement.
		-- check for incoming collisions
		-- before moving
		if not iswall(guy.x+guy.vx,guy.y) then
			guy.x+=guy.vx
		else
			guy.vx=0
		end
		if not iswall(guy.x,guy.y+guy.vy) then
			guy.y+=guy.vy
		else
			guy.vy=0
		end
		
		-- move hips toward comfy positions
		hipx=(lfoot.x+rfoot.x+guy.x*3)/5
		hipy=(lfoot.y+rfoot.y+guy.y*3)/5

		-- find our ground-plane facing vector
		local ax=cos(faceangle)*1.5
		local ay=sin(faceangle)*1.5
		
		-- update both feet
		for i=1,2 do
			-- find our current foot and
			-- our "other foot"
			local foot=lfoot
			local ofoot=rfoot
			local hand=lhand

			-- px,py is perpendicular to our facing vector
			local px=ay
			local py=-ax
			if (i==2) then
				-- second loop cycle: switch sides
				px,py=-px,-py
				foot,ofoot=rfoot,lfoot
				hand=rhand
			end
			
			-- how far is this foot from a
			-- comfortable position?
			local dx=hipx+guy.vx+px-foot.x
			local dy=hipy+guy.vy+py-foot.y
			local dist=dx*dx+dy*dy
			
			if foot.step then
				-- foot is currently stepping

				foot.stept+=stepspeed
				if foot.stept>1 then
					-- this step has finished
					foot.stept=1
					foot.step=false
				end

				-- where is this step landing?
				local goalx=guy.x+px+guy.vx*2
				local goaly=guy.y+py+guy.vy*2

				-- animate from step-start to landing-position
				foot.x=foot.stepsx+(goalx-foot.stepsx)*foot.stept
				foot.y=foot.stepsy+(goaly-foot.stepsy)*foot.stept

				-- raise and lower the foot as it steps
				foot.z=(1-abs(foot.stept-.5)*2)*4
			else
				-- this foot is not stepping

				-- is the other foot stepping?
				if ofoot.stept>.7 then
					-- no; we're allowed to step
					if dist>2.25 then
						-- we're allowed to step,
						-- and we're pretty far from
						-- a comfy position.
						-- it's steppin' time!
						foot.step=true
						foot.stept=0
						foot.stepsx=foot.x
						foot.stepsy=foot.y
					end
				end
			end

			-- each hand's position is just based
			-- on the opposite foot's position
			hand.x=guy.x+(ofoot.x-hipx)*.5+px*2
			hand.y=guy.y+(ofoot.y-hipy)*.5+py*2
			hand.z=5.5+ofoot.z*.5
		end

		-- raise our hand for hook-holding
		rhand.x+=(ax*3-ay)*hooktimer
		rhand.y+=(ay*3+ax)*hooktimer
		rhand.z+=2*hooktimer
		
		-- raise our hand for harpoon-aiming
		rhand.x+=(ax*4+ay)*harptimer
		rhand.y+=(ay*4-ax)*harptimer
		rhand.z+=2*harptimer
		
		-- find camera's target position
		local goalcx=guy.x+guy.vx*12
		local goalcy=guy.y+guy.vy*12

		-- camera moves toward hook or crosshair
		if aiming then
			goalcx+=(aimx-guy.x)/2
			goalcy+=(aimy-guy.y)/2
		elseif hookout then
			goalcx+=(hookx-guy.x)/2
			goalcy+=(hooky-guy.y)/2
		end

		-- camera eases toward its target
		cx+=(goalcx-cx)/8
		cy+=(goalcy-cy)/8
		
		-- now let's check if the player has
		-- walked past the edge of the map.
		-- this is allowed, but we should
		-- secretly push everything back,
		-- so our coordinates don't get too large.

		-- movex,movey is the amount that we're
		-- going to push everything.
		-- if we don't need to push, they'll
		-- stay at zero.
		local movex=0
		local movey=0

		-- check x-axis looping:
		if guy.x<0 then
			movex=1024
		end
		if guy.x>1024 then
			movex=-1024
		end 
		
		-- move all persistent-position objects
		guy.x+=movex
		cx+=movex
		hipx+=movex
		lfoot.x+=movex
		rfoot.x+=movex
		lfoot.stepsx+=movex
		rfoot.stepsx+=movex
		lhand.x+=movex
		rhand.x+=movex
		aimx+=movex
		hookx+=movex
		
		-- now the same for the y-axis
		if guy.y<0 then
			movey=512
		end
		if guy.y>512 then
			movey=-512
		end
		guy.y+=movey
		cy+=movey
		hipy+=movey
		lfoot.y+=movey
		rfoot.y+=movey
		lfoot.stepsy+=movey
		rfoot.stepsy+=movey
		lhand.y+=movey
		rhand.y+=movey
		aimy+=movey
		hooky+=movey
		
		-- beast logic
		if timeofday>1 then
			local dx=guy.x-beast.x
			local dy=guy.y-beast.y
			
			-- beast always approaches the short way
			if dx>64*8 then
				dx-=128*8
				beast.x+=128*8
			end
			if dx<-64*8 then
				dx+=128*8
				beast.x-=128*8
			end
			
			if dy>32*8 then
				dy-=64*8
				beast.y+=64*8
			end
			if dy<-32*8 then
				dy+=64*8
				beast.y-=64*8
			end
			
			-- beastie song gets faster as
			-- they get closer
			if stat(20)==31 or beast.spawntimer==0 then
				local mdx=dx/8
				local mdy=dy/8
				local bdist=sqrt(mdx*mdx+mdy*mdy)
				local musicspeed=flr(bdist*.3)+3
				musicspeed=mid(musicspeed,4,30)
				poke(0x3200+65,musicspeed)
				poke(0x3200+133,musicspeed)
			end
			
			-- slight delay between the happy song
			-- and the beastie song
			if timeofday>1.04 and not playingbeastsong and not enterstore then
				playingbeastsong=true
				music(0)
			elseif timeofday>1 and timeofday<1.04 then
				music(-1)
			end

			-- the beastie appears gradually
			beast.spawntimer+=.01
			if (beast.spawntimer>1) beast.spawntimer=1
			
			-- they also get faster over time
			-- (so you can't run away forever)
			beast.speed+=.0005
			
			-- accelerate toward the player
			if abs(dx)>10 then
				beast.vx+=sgn(dx)*beast.speed
			end
			if abs(dy)>10 then
				beast.vy+=sgn(dy)*beast.speed
			end
			
			-- did we eat the player?
			if not guy.dead and not enterstore and beast.spawntimer>=1 then
				if abs(dx)<=10 and abs(dy)<=10 then
					guy.dead=true
					heldvalue=0
					heldfish={}
					music(-1)
					gotostore=true
				end
			end
			
			-- velocity damping
			beast.vx*=beast.damping
			beast.vy*=beast.damping
			
			-- move the beastie
			beast.x+=beast.vx
			beast.y+=beast.vy
		end
	elseif state=="fish" then
		-- one animation timer drives
		-- all "fish entrance" motions
		if (fishanimtimer<1) then
			fishanimtimer+=1/32
			if (fishanimtimer==.75) then
				sfx(32)
			end
		end

		if btnp(4) then
			closefish()
		end
	elseif state=="store" then
		if storepage=="sell" then
			if fadevalue<=0 then
				if stat(20)==-1 then
					-- start the store music
					music(9)
				end

				-- go to the next page
				if btnp(4) then
					storescroll+=.01
					sfx(31)
				end
			end
			if (storescroll>0) storescroll+=1/10
			if storescroll>1 then
				storepage="buy"
				buyindex=1
			end
		elseif storepage=="buy" then
			storescroll=max(storescroll-1/15,0)
			
			-- get the number of menu items.
			-- one per item, and a "quit" option
			local menucount=#storeitems/2+1

			-- menu item selection input
			if btnp(2) then
				buyindex-=1
				sfx(31)
			end
			if btnp(3) then
				buyindex+=1
				sfx(31)
			end
			if (buyindex==0) buyindex=menucount
			if (buyindex>menucount) buyindex=1
		
			-- did we hit the "ok" key?
			if btnp(4) then
				if buyindex==menucount then
					-- picked the "quit" option
					gotogame=true
					music(-1)
				else
					-- picked an item
					local price=storeitems[buyindex*2-1]
					local itemname=storeitems[buyindex*2]

					-- can we afford it?
					-- do we already have it?
					if money>=price and not items[itemname] then
						-- purchase an item
						items[itemname]=true
						money-=price
						sfx(32)
					end
				end
			end
		end
	elseif state=="victory" then
		if btnp(4) and fadevalue<.1 then
			-- return to the main menu
			cls()
			flip()
			_init()
			fadevalue=5
		end
	end
end

-- spawn harpoon impact particles
function makespeck(x,y,force,count)
	local tile=mget(x/8%128,y/8%64)

	-- pick a set of colors based on
	-- which material we've hit
	local cols=watercols
	if tile==21 or tile==22 then
		cols=dirtcols
	elseif tile!=19 and tile!=20 then
		cols=grasscols
		if (rnd()<.5) cols=dirtcols
	end
	
	-- create our particles
	for i=1,count do
		local speck={}
		speck.x=x
		speck.y=y
		speck.z=0
		
		speck.ox=x
		speck.oy=y
		speck.oz=0
		speck.vx=rnd(force)-force/2
		speck.vy=rnd(force)-force/2
		speck.vz=rnd(force)
		
		speck.cols=cols
		speck.colmult=rnd()
		
		speck.life=1
		speck.lifetime=rnd()+.5
		
		add(specks,speck)
	end
end


function makefoot()
	-- set up a foot object
	local foot={}
	foot.x=guy.x
	foot.y=guy.y
	foot.z=0
	
	foot.stept=1
	foot.step=false
	
	foot.stepsx=foot.x
	foot.stepsy=foot.y
	
	return foot
end
function makehand()
	-- set up a hand object
	local hand={}
	hand.x=guy.x
	hand.y=guy.y
	hand.z=4
	
	return hand
end

-- this function is similar to pset(),
-- but it darkens an existing screen pixel
-- instead of setting it to a certain color
function shadow(x,y)
	local pixel=pget(x,y)

	-- never darken past dark-blue!
	-- (the night-time filter also lowers
	-- color values by 1, but it doesn't
	-- test for darkening "too far")
	if pixel!=1 then
		pset(x,y,pixel-1)
	end
end

function iswall(x,y)
	-- player collision test!
	-- check a 2x2 square - any open tiles
	-- means it's a valid standing position.
	-- (allows walking over "diagonal bridges")
	for i=0,3 do
		local tile=mget((x+i%2)/8%128,(y+i/2)/8%64)
		if (tile!=19 and tile!=20) return false
	end
	return true
end

function shoredist(mx,my)
	-- how close is a water tile
	-- to the nearest land tile?
	local output=32000
	local mdist=1
	while output==32000 do
		for x=mx-mdist,mx+mdist do
			for y=my-mdist,my+mdist do
				local tile=mget(x,y)
				if tile<19 or tile>22 then
					local dx=abs(x-mx)
					local dy=abs(y-my)
					if dx==mdist or dy==mdist then
						local dist=dx*dx+dy*dy
						if dist<output then
							output=dist
						end
					end
				end
			end
		end
		mdist+=1
	end
	return output
end

-- we call this when we catch a fish:
function savescreen()
	-- capture a screenshot at half
	-- of normal y-resolution.
	-- (so we don't delete our map data!)
	camera()
	for x=0,127 do
		for y=0,127,2 do
			-- blur our image on the x-axis
			local col=pget(x,y)+pget(x+1,y)+pget(x-1,y)
			sset(x,y/2,col/3)
		end
	end
end

-- shoot a harpoon bolt
function useharpoon(aimx,aimy)
	sfx(29)

	bolt={}
	bolt.sx=rhand.x
	bolt.sy=rhand.y
	bolt.sz=rhand.z
	bolt.ex=aimx
	bolt.ey=aimy
	bolt.ez=0
	bolt.life=1
	
	-- spawn impact particles
	makespeck(aimx,aimy,4,30)
	
	local tile=mget(bolt.ex/8%128,bolt.ey/8%64)
	if tile==19 or tile==20 then
		-- we shot the water
		
		if not catchfield[flr(aimx/8)%128][flr(aimy/8)%64] then
			-- draw a bolt-line immediately, so it can
			-- appear in our screenshot
			drawbolt()

			-- catch a fish like normal
			savescreen()
			generatefish(aimx,aimy,true)
		end
	end
	
	-- did we shoot the beastie?
	if timeofday>1 and abs(aimx-beast.x)<25 and abs(aimy-beast.y)<25 then
		state="victory"
		fadevalue=5
		music(-1)
	end
end

function generatefish(x,y,dead)
	-- create a fish for a certain map-tile

	-- convert to looped-map coordinates
	x=flr(x/8)%128
	y=flr(y/8)%64
	
	fishanimtimer=0
	
	-- mark this tile as dry
	catchfield[x][y]=true
	
	-- get water velocity and shore distance
	-- (shore distance is assumed to also mean "depth")
	local flow=flowfield[x][y]
	local shoredist=distfield[x][y]
	
	-- go to fish-viewing scene
	state="fish"
	
	sfx(34)
	
	-- create our fish object
	cfish={}
	
	-- dead fish are worth much less
	cfish.live=1
	if (dead) cfish.live=0
	
	-- generate fish measurements
	cfish.size=shoredist+rnd()
	cfish.quality=sqrt(flow[1]*flow[1]+flow[2]*flow[2])

	-- fish value is basically size*quality
	cfish.value=flr(cfish.size*(cfish.quality+1)*(.25+.75*cfish.live))+1
	cfish.seed=x*64+y+time()*100

	-- create two dither patterns per fish
	-- (one for body, one for fins)
	for k=0,1 do
		local dithers={0,0,0,0}

		-- only fancy fish get patterns
		if cfish.quality>2 then
			-- each pattern is 4x4 random noise
			for i=0,16 do
				if rnd()<.2 then
					-- we need to generate four versions
					-- of each pattern, scrolling on
					-- the x-axis, so we can lock
					-- the texture to the moving parts
					-- of the fish. we can scroll on
					-- the y-axis with bitshifting, but
					-- that doesn't work for x.
					for j=1,4 do
						local x=(i%4-j)%4
						local y=flr(i/4)
						local k=y*4+x
						dithers[j]+=2^k
					end
				end
			end
			-- duplicate the integer bits of each pattern
			-- into the fractional bits - this lets
			-- us scroll on the y axis with bitshifting
			for i=1,4 do
				dithers[i]=bor(dithers[i],rotr(dithers[i],16))
			end
		end

		-- save our patterns to the fish
		if k==0 then
			cfish.bdithers=dithers
		elseif k==1 then
			cfish.fdithers=dithers
		end
	end

	-- add fish to the player's bag
	add(heldfish,cfish)

	-- update player's total fish-value
	heldvalue+=cfish.value
end

function drawfish(cfish,fishx,fishy,scale)
	-- each fish has its own random seed
	srand(cfish.seed)

	-- convert fish size to onscreen-length
	local length=flr(20+cfish.size*5)
	length=min(length,120)
	
	-- how many body-radius keyframes?
	local keycount=-flr(-length/(5+rnd(20)))

	-- spawn body-radius keyframes
	local keys={}

	-- first keyframe is the front/mouth
	keys[1]=0
	for i=2,keycount do
		-- other keyframes have random widths
		keys[i]=(rnd(length/8)+length/16)*scale
		if i==keycount-2 then
			-- pinch in the second to last keyframe,
			-- for a tail shape
			keys[i]*=.5
		end
	end
	
	-- generate fish properties.
	-- remember that we've set a
	-- random seed: each fish will
	-- get the same results when it
	-- performs this again and again:

	-- body color:
	local bcol=flr(rnd(15))
	-- quality:
	local qual=cfish.quality/2
	-- clamped quality:
	local cqual=mid(qual,0,1)
	-- vertical stripe color parameters:
	local colstepx=flr(rnd(15)*cqual)
	local colstepy=flr(rnd(4)*cqual)
	-- fin color offset:
	local colstepk=flr(rnd(4)*cqual)
	-- vertical stripe size parameters:
	local colsize=flr(rnd(25)*(1-cqual)+7)
	local colsize2=flr(rnd(25)*(1-cqual)+7)
	-- fin stripe positions offset:
	local fcoloff=rnd(colsize)
	-- how many lengthwise stripes?
	local stripes=flr(rnd(3)*cqual+1)
	-- fin position, from front to back:
	local finpos=rnd(.3)+.3
	-- fin size:
	local finmult=rnd(.8)*qual+.7
	-- fin exponent/steepness:
	local finexp=rnd(3)+2
	-- swim animation strength:
	local xwob=-rnd(length/20)
	local ywob=rnd(length/20)
	-- swim animation speed:
	local wobspeed=(rnd(.5)+.5)*cfish.live
	-- eye position, size, and color:
	local eyexpos=rnd(.15)+.1
	local eyeypos=rnd(.6)+.2
	local eyesize=2+rnd(length/40)
	pupilcol=rnd(15)
	-- dither pattern colors:
	local dcolbody=flr(rnd(9))+2
	local dcolfin=flr(rnd(9))+2
	
	local eyex,eyey
	
	local bdithers=cfish.bdithers
	local fdithers=cfish.fdithers
	
	-- to draw the fish, we'll step through
	-- its screen-x positions and draw
	-- a bunch of vertical lines.
	-- however, these lines will move around
	-- for the fish's swimming animation, so
	-- really we want to draw tall boxes
	-- connecting the previous slice to
	-- our current slice.
	local oldx=fishx-length*scale/2

	-- step through x positions:
	for i=0,length-1,1/scale do
		-- x-position as a percentage
		local t=i/length		

		-- keyframe index:
		local ki=flr(t*(keycount-1))+1
		-- interpolation value:
		local kf=t*(keycount-1)-ki+1

		-- smoothstep to avoid sharp corners
		kf=3*kf*kf-2*kf*kf*kf

		-- get interpolated width at this point
		-- (distance from spine to top/bottom of body)
		local rad=keys[ki]+(keys[ki+1]-keys[ki])*kf

		-- vertical stripe colors
		local coli=flr(i/colsize)
		local coli2=flr((i+fcoloff)/colsize2)
		
		-- get slice's animated screen position
		local xoff=cos(time()*wobspeed-t)*(1+xwob*t)
		local x=fishx+(-length/2+i+xoff)*scale
		local y=fishy+(sin(time()*wobspeed-t)*(1+ywob*t))*scale
		
		-- we're about to apply a dither pattern
		-- using the fillp() function...
		-- but patterns should "lock" to our slices
		-- while the slices are moving. pico8's
		-- dither patterns are all defined in
		-- screen space, so we'll need to scroll
		-- the pattern manually.
		-- our pattern is 16 bits of yes/no pixels,
		-- and we've copied it into the fractional
		-- 16 bits of itself. bdithers[1] might be
		-- 0b1111111101010101.1111111101010101
		-- and bdithers[2] through [4] are the same
		-- pattern, scrolled left one pixel at a time.
		-- we pick an item out of those four based on
		-- our x position, and then we bit-rotate the
		-- pattern in increments of 4 at a time
		-- to scroll the pattern on the y axis.
		-- finally, we make sure that the
		-- "one-halves" bit (0b0.1) is set to false,
		-- because pico8 checks that to see if the
		-- dither pattern uses transparency, and
		-- we don't want that.

		fillp(band(rotr(bdithers[flr((xoff+fishx)%4)+1],flr(y%4)*4),bnot(0b0.1)))

		
		-- did we pass the intended eye position?
		if i<length*eyexpos and i+1/scale>=length*eyexpos then
			-- we found where the eye should go
			-- (lock it to this slice's movement)
			eyex=x
			eyey=y-rad*eyeypos
		end
		
		-- draw this slice
		for j=0,stripes-1 do
			-- each slice is a few stacked lines
			-- (for drawing lengthwise stripes)
			y1=y-rad+j*rad*2/stripes
			y2=y-rad+(j+1)*rad*2/stripes
		
			-- figure out this spot's color
			local col=((colstepx*coli+colstepy*(j%2))%8+bcol)%15+1
			
			-- instead of drawing one tall line,
			-- we'll draw a tall box connecting the previous
			-- slice to this one
			rectfill(oldx+1,y1,x,y2,col+16*dcolbody)
		end
		-- speckly details on top/bottom,
		-- especially for high-quality fish
		for i=0,rad/2 do
			if rnd()*cqual>(i/(rad/2)) then
				for j=-1,1,2 do
					pset(x,y+(rad-i)*j,pget(x,y+(rad-i)*j)-1)
				end
			end
		end
		
		-- find current fin size for this slice
		local fin=(1-mid(abs(t-finpos)/finpos,0,1))^finexp+mid(1-abs(t-.95)*2,0,1)^finexp
		local frad=length/3*fin*finmult*scale
		
		-- fin-radius for this slice
		-- ("spine to edge" distance)
		frad=min(frad,60)
		
		-- only draw fins where they extend beyond the body
		if frad>rad then
			-- same crazy texture-mapping as above
			fillp(band(rotr(fdithers[flr((xoff+fishx)%4)+1],flr(y%4)*4),bnot(0b0.1)))
			
			-- pick fin color
			col=((colstepx*coli2+colstepk)%8+bcol)%15+1
			-- draw fin slices (top and bottom)
			rectfill(oldx+1,y-frad,x,y-rad-2,col+16*dcolfin)
			rectfill(oldx+1,y+rad+2,x,y+frad,col+16*dcolfin)
			-- outline
			line(x,y-frad-1,x,y-frad-2,0)
			line(x,y+frad+1,x,y+frad+2,0)
			
			-- add some speckles, especially
			-- for high-quality fish
			for i=0,(frad-rad)/2 do
				if rnd()*cqual>(i/((frad-rad)/2)) then
					local col=pget(x,y-frad+i)
					pset(x,y-frad+i,col-1)
					local col2=pget(x,y+frad-i)
					pset(x,y+frad-i,col2-1)
				end	
			end
		end
		-- body outline
		rect(oldx,y-rad-1,x,y-rad-2,0)
		rect(oldx,y+rad+1,x,y+rad+2,0)
		
		-- remember this slice's x position
		-- (so the next slice can connect to it)
		oldx=x
	end
	
	fillp()
	
	-- draw the eye
	circfill(eyex,eyey+1,eyesize*scale,5)
	circfill(eyex,eyey,eyesize*scale,6)
	circfill(eyex,eyey,(eyesize-1)*scale,7)

	-- dead fish have no pupils
	if cfish.live>0 then
		circfill(eyex-eyesize/3,eyey,eyesize/2*scale,pupilcol)
	end
end

function drawbeast()
	local t=time()
	
	-- open/close parameter
	local mopen=sin(t)*.4+.6

	-- draw teeth in two passes:
	-- shadow pass, then tooth pass
	for k=0,1 do
		-- two rows of teeth
		for j=1,-1,-2 do
			-- i is the local x position:
			for i=-3.5,3.5 do
				-- center teeth are bigger
				local size=(3.5-abs(i))*2+4

				-- get world position
				x=beast.x+i*3.5
				y=beast.y-10

				-- mouth open/close animation
				y+=j*(4-abs(i))*(mopen+.1)*3

				-- which sprite? (left/right tooth)
				sx=64
				if (i>0) sx=80

				-- adjust y positions of teeth
				if (j==1) y+=8-size

				-- spawning teeth rise out of the ground.
				-- clipping hides underground parts:
				clip(x-size/2-cx+64,y-cy+64,
				     size,size+8)
				y+=(1-beast.spawntimer)*20
		
				if k==1 then
					-- draw a tooth sprite
					sspr(sx,0,16,16,
					     x-size/2,
					     y,
					     size,size,
					     false,
					     j==1)
				else
					-- draw a tooth shadow
					for l=1,15 do
						shadow(x+rnd(size)-size/2,
						       y+rnd(size)-size/2+8)
					end
				end
			end
		end
	end
	-- return to default fullscreen drawing
	clip()

	-- draw a bunch of spinny dots
	for i=10,100 do
		-- wiggles
		local x=cos(t/4+i/35.19)*20
		local y=sin(t*.318+i/30.93)*20
		local z=sin(cos(t/6.57+i/40.71))*20+beast.spawntimer*10

		-- normalize local point
		local dist=sqrt(x*x+y*y+z*z)
		x=x/dist*25
		y=y/dist*25
		z=z/dist*25
		
		-- half of the dots are dithered
		if i%2==0 then
			fillp(0b1010010110100101.1)
		end

		-- only draw above-ground dots
		if z>0 then
			-- dots change in size
			local scale=(sin(t*i/30)/2+.5)
			scale*=min(z/4,1)
			scale*=beast.spawntimer*8

			if (scale>1) then
				-- draw a dot and an outline
				circfill(beast.x+x,
				         beast.y+y-z,
				         scale-2,
				         1)
				circ(beast.x+x,
				     beast.y+y-z,
				     scale,
				     1)
			end
		end
		fillp()
	end
end

-- exit the "fish" state
function closefish()
	state="game"

	-- restore the top half of the sprite sheet,
	-- since savescreen() had overwritten it
	reload(0,0,0x1000)
end

-- draw a 3d limb
-- similar to line(), but includes
-- a z-axis, and enforces a limb-length
-- through bending or clamping.
-- bendx/y/z tells us which direction
-- a knee/elbow should bend toward
function limb(x1,y1,z1,x2,y2,z2,length,bendx,bendy,bendz,col,col2)
	-- how long is the requested line?
	local dx=x2-x1
	local dy=y2-y1
	local dz=z2-z1
	local dist=sqrt(dx*dx+dy*dy+dz*dz)

	if dist>length then
		-- requested line is too long:
		-- clamp its length
		x2=x1+dx/dist*length
		y2=y1+dy/dist*length
		z2=z1+dz/dist*length
		
		-- then draw it
		sline(x1,y1-z1,x2,y2-z2,col,col2)
	else
		-- requested line is too short:
		-- introduce a knee/elbow
		local x3=(x1+x2)/2
		local y3=(y1+y2)/2
		local z3=(z1+z2)/2

		-- now push the joint outward
		local bend=(length-dist)/1.4
		x3+=bendx*bend
		y3+=bendy*bend
		z3+=bendz*bend
		
		-- instead of connecting shoulder
		-- to hand like above, we'll do
		-- shoulder to elbow and elbow
		-- to hand as two lines
		sline(x1,y1-z1,x3,y3-z3,col,col2)
		sline(x2,y2-z2,x3,y3-z3,col,col2)
	end
end

-- draw a shadowed line
function sline(x1,y1,x2,y2,col1,col2)
	line(x1+1,y1,x2+1,y2,col2)
	line(x1-1,y1,x2-1,y2,col2)
	line(x1,y1+1,x2,y2+1,col2)
	line(x1,y1,x2,y2,col1)
end

-- shadowed print
function sprint(str,x,y,col1,col2)
	print(str,x,y+1,col2)
	print(str,x,y,col1)
end

-- outlined print
function oprint(str,x,y,col1,col2)
	print(str,x+1,y,col2)
	print(str,x-1,y,col2)
	print(str,x,y+1,col2)
	print(str,x,y-1,col2)
	print(str,x,y,col1)
end

-- pick how long you'll have to wait
-- before a fish bites
function getfishtime()
	return 1+rnd(9)
end

-- rope's "droop curve"
-- (droops most in the center)
function droop(t)
	t=abs(t-.5)*2
	t*=t
	return 1-t
end

function drawhook()
	-- draw the hook and the rope

	-- how much should the rope swing upward?
	-- (right after being thrown)
	local float=(hookz)

	-- draw rope shadow on the ground
	local dx=hookx-rhand.x
	local dy=hooky-rhand.y
	local dist=sqrt(dx*dx+dy*dy)
	for i=0,1,1.5/dist do
		shadow(rhand.x+dx*i,
		       rhand.y+dy*i)
	end

	-- rope is two parts: lower dark part
	-- and brighter top part, like sline()
	for j=1,0,-1 do
		-- step along the rope
		for i=0,.95,.05 do
			-- interpolate from hook to hand
			local x1=hookx+(rhand.x-hookx)*i
			local y1=hooky+(rhand.y-hooky)*i
			local z1=hookz+(rhand.z-hookz)*i
			local x2=hookx+(rhand.x-hookx)*(i+.05)
			local y2=hooky+(rhand.y-hooky)*(i+.05)
			local z2=hookz+(rhand.z-hookz)*(i+.05)
			
			local slack=hookslack

			-- no slack while we're reeling in
			if not hookout then
				slack=0
				float=0
			end

			-- droop our current and next position
			z1-=droop(i)*(slack-float)
			z2-=droop(i+.05)*(slack-float)
			
			-- rope can't fall through the ground
			if (z1<0) z1=0
			if (z2<0) z2=0
			
			-- draw our current segment
			line(x1,y1-z1+j,x2,y2-z2+j,5-3*j)
		end
	end

	-- draw the actual hook
	if not hookinwater or not hookout then
		spr(50,hookx-1,hooky-hookz-1)
	end
end

function drawbolt()
	-- just draw a line for the bolt
	-- color fades out, dithering comes in
	local col=5+bolt.life*2.9
	if bolt.life<.5 then
		fillp(0b1010010110100101.1)
	end

	line(bolt.sx,bolt.sy-bolt.sz,
	     bolt.ex,bolt.ey-bolt.ez,
	     col)
	fillp()
end

-- draw part of the store,
-- either the part in front
-- of or behind the player
function drawstore(sort)
	-- several rings of stones
	for j=0,5 do
		-- how many stones in half of this ring?
		local count=flr((6-j)*1.5)

		-- mirror the left and right sides
		for k=0,1 do
			-- spawn the rocks on this side?
			for i=0,count do
				-- find our rock's angle
				local a=i/count
				if k==0 then
					a=.25-a*.4
				else
					a=.25+a*.4
				end

				-- higher rings are smaller
				local t=j/5
				local x=storex+cos(a)*20*(1-t)
				local y=storey+sin(a)*20*(1-t)

				-- protection for looping map
				if abs(x-guy.x)>64*8 then
					x+=sgn(guy.x-x)*128*8
				end
				if abs(y-guy.y)>32*8 then
					y+=sgn(guy.y-y)*64*8
				end
				
				-- later rings are higher up
				local z=j*5

				-- make sure we're on the correct side
				-- of the player for this pass
				if sgn(y-guy.y)==sort then
					-- draw a rock
					spr(15,x-4,y-z-4)
				end
			end
		end
	end
end
__gfx__
00000000666666660660006606660066000000600000000000066600000066000007777777776000000777777777600000000000000000000000000000799940
00000000666666666666005566660055006000600000006066055500066066000078777777777600007877777777760000000000000000000000000009999990
00700700666666666665066056650600066600500600005066006660066056660078777777776600007877777777760000000000000000000000000097999999
00077000666666665660666605506660066500000660000055066666056606660078777777776000000777777777660000000000000000000000000097999994
00077000666666660550666600005660055006600550006006055555665500000077777777766000000787777777660000000000000000000000000099999994
00700700666666666660566506600650000006600000065066660066666066600007877777766000000787777777600000000000000000000000000099999994
00000000666666665666055006600500066005500060050066666065566066500007877777660000000077777777600000000000000000000000000009999944
00000000666666660555000005500000055000000050000055555050055055000007777777600000000007777776600000000000000000000000000004999440
33333333000b00000000000011111111dddddddd44444444d4d4d4d4000000000000777777600000000007777776000000000000000000000000000000000000
33333333000000000000000011111111dddddddd444444444d4d4d4d000000000000777776000000000000777776000000000000000000000000000000000000
33333333b0000b000000000011111111dddddddd44444444d4d4d4d4000000000000777776000000000000777766000000000000000000000000000000000000
33333333000b000b0000000011111111dddddddd444444444d4d4d4d000000000000077760000000000000077760000000000000000000000000000000000000
33333333000000000000000011111111dddddddd44444444d4d4d4d4000000000000007760000000000000077600000000000000000000000000000000000000
33333333b0b000000000000011111111dddddddd444444444d4d4d4d000000000000007760000000000000077600000000000000000000000000000000000000
3333333300000b000000000011111111dddddddd44444444d4d4d4d4000000000000000770000000000000076000000000000000000000000000000000000000
333333330b0000000000000011111111dddddddd444444444d4d4d4d000000000000000080000000000000080000000000000000000000000000000000000000
00000000000000b00444440004444400044440000444440000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000004444444044004440444444404444444000000000000000000000000000000000000000000000000000000000000000000000000000000000
0033330000b000002444442024444420244444202404442000000000000000000000000000000000000000000000000000000000000000000000000000000000
00333300000000002000002020000020200000202000002000000000000000000000000000000000000000000000000000000000000000000000000000000000
00333300000000000444440004444400040444000444440000000000000000000000000000000000000000000000000000000000000000000000000000000000
00333300b00000004444444044444440444444404444444000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000b0002444442024444420244444204444042000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000002000002020000020200000202000002000000000000000000000000000000000000000000000000000000000000000000000000000000000
30000003000000000700000000dddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000756000000d0000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000006000000d0d00d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000330000000000000000000d00dd00d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000330000000000000000000d00dd00d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000d0d00d0d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000d0000d0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
30000003000000000000000000dddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000777777077770700070070007000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000777777077770770077077007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007700007700777077077007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007700007700777777077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007700007700770777007777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007700007700770077000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007700077770770077000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000007700077770770077000770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777077770077700700070077777077777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777077770777770770077077777077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77000007700770000770077077000077007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77770007700777700777777077770077777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77770007700077770777777077770077777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77000007700000770770077077000077007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77000077770777770770077077777077007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77000077770077700770077077777077007700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
00000000000000000000000000000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
00000000000000000000000000000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
00000000000000000000000000000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
00000000000000000000000000000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
00000000000000000000000000000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
00000000000000000000000000000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
00000000000000000000000000000000010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
01010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101
__map__
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
1010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010
__sfx__
010b00000c5160f716125160f7000f51612716155160f7000c5160f716125160f7000f51612716155160f7000c5160f716125160f7000f51612716155160f7000c5160f716125160f7000f51612716155160f700
010b00000021500000000000000000415000000000000000002150000000000000000041500000000000000000215000000000000000004150000000000000000021500000000000000000415000000000000000
012000000c735007051073517735007051373500705007050c735007050e73517735007051373500705007050c735007051073517735007051373500705007050c735007050e7351a73500705177350070500705
01200000097350070500705137350070500705157350070509735007050070513735007050070510735007050573500705007051073500705007050c7350070504735007050e735007050b735007050c73500705
012000000c735007051073517735007051373500705007050c735007050e73517735007051373500705007050c735007051073517735007051373500705007050c735007050e7350070510735007051373500705
0120000007735077350c7350c7350e7350e73513735137350773507735077350c7350c7350c7350e7350e7350e7351373513735137351373513735137351373518735137350e7350c7350773505735077350c735
0120000013735107350e7350773505735077350e7351073513735107350e7350773505735077350e73510735137350e7350c7350573504735057350c7350e735107350e7350c7350e7350c735097350c7350e735
012000001373510735177350773505735137350e735107351373510735177350773505735157350e73510735137350e7350c7350573504735057350c7350e735107350e7350c7350e7350c735187351773518735
0120000013735107350e735077350573515735137351573513735107350e7350773505735077350e735107351373511735107051073504735057350c7350e735107350e7350c7350e7350c735097350c7350e735
012000001373510735177350773505735137350e735107351373510735177350773505735157350e73510735137350e7350c7350573504735057350c7350e735107350e7350c7350e7350c735187351773518735
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
012000001850517505185050c515005051051517515005051351500505005050c515005050e51517515005051351500505005050c515005021051517515005051351500505005050c515005050e5151a51500505
01200000175150050500505095050951500505005051351500505155150050509515005050050513515005050050510515005050551500505005051051500505005050c5150050504515005050e515005050b515
012000000c5050c515105050c5150c5051051517515005051351500505005050c515005050e51517515005051351500505005050c515005051051517515005051351500505005050c515005050e5150050510515
0120000007505135150c50507515075150c5150c5150e5150e51513515135150751507515075150c5150c5150c5150e5150e5150e5151351513515135151351513515135151351518515135150e5150c51507515
0120000005515075150c51513515105150e5150751505515075150e5151051513515105150e5150751505515075150e51510515135150e5150c5150551504515055150c5150e515105150e5150c5150e5150c515
01200000095150c5150e5151351510515175150751505515135150e515105151351510515175150751505515155150e51510515135150e5150c5150551504515055150c5150e515105150e5150c5150e5150c515
0120000018515175151851513515105150e515075150551515515135151551513515105150e5150751505515075150e515105151351511515105051051504515055150c5150e515105150e5150c5150e5150c515
01200000095150c5150e5151351510515175150751505515135150e515105151351510515175150751505515155150e51510515135150e5150c5150551504515055150c5150e515105150e5150c5150e5150c515
012000000071200712007120071200712007120071200712007120071200712007120071200712007120071200712007120071200712007120071200712007120571205712057120571205712057120571205712
012000000471204712047120471204712047120471204712047120471204712047120471204712047120471202712027120271202712027120271202712027120071200712007120071200712007120071200712
012000000071200712007020070200702007020070200702007020070200702007020000200002000020000200002000020000200002000020000200002000020772207722077220772207722077220772207722
012000000272202722027220272202722027220272202722027220272200702027220272200702027220272200702027220272200702007020070200702007020070200702007020070200702007020070200702
012000000071200712007120071200712007120071200712007120071200712007120071200712007120071200712007120071200712007120071200712007120071200712007120071200712007120071200712
012000000771207712077120771207712077120771207712077120771207712077120771207712077120771207712077120771207712077120771207712077120771207712077120771207712077120771207712
012000000972209722097220972209722097220972209722097220972209722097220972209722097220972209722097220972209722097220972209722097220972209722097220972209722097220972209722
012000000772207722077220772207722077220772207722077220772207722077220772207722077220772207722077220772207722077220772207722077220772207722077220772207722077220772207722
010e000000615006000061500600006000060000615006001341300600006000060000615006000061500600006000060000615006000c000006000061500600134130060000600006000c615006000060000600
010600002461600413000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010a000000614186150c6000c60516500185001b5001b5001f500225002450027500330001b0002700033000295002750024500225001d5001b50018500165001600027000220001d0001b000160000030000300
010800001801500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010600000f7161b5162771633716275161b7160f5161b5161d5001b500165000f5000c50005500035000050000500005000050000500005000050000500005000050000500005000050000500005000000000000
01050000187140c7161b7160f715187040c7061b7060f705000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01010000096200f620196202062028620246201f6201a6201762016620106200c6200961006610016100161000000000000000000000000000000000000000000000000000000000000000000000000000000000
00010000355262b6561f526226262b5261b5260e5560e0261605630056140160903609036115362f03621036140260e0260e026170261c0260f52609526085260000000000000000000000000000000000000000
__music__
03 00014344
01 020c1444
00 030d1544
00 040e1644
00 050f1744
00 06501844
00 07511944
00 08121a44
02 09131b44
01 1c144344
00 1c154344
00 1c194344
02 1c424344


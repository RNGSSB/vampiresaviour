-- TurtleWax 1.5 for IKEMEN by Kamekaze and Jesuszilla
--
-- Available system maps (in all TW implementations):
-- All input times are in ticks.
--
-- Map(tw_ver) - TurtleWax version. (defaults to current version)
-- Map(tw_debug) - Set to nonzero to enable debug print statements (mainly for verifying command priority). Setting this will
--                 also cause the script to crash if tw_ver does not match the one in this file. (defaults to 0)
-- Map(tw_Buffer_ChangeStateNo) - StateNo to change to (set by TurtleWax when provided a valid buffering.lua file)
-- Map(tw_MashPCt) - Total buffer time for HHS presses. (defaults to 10)
-- Map(tw_MashCt) - Number of button presses required for "mashing" to be considered "active"
-- Map(tw_ChargePartition) - Set to 1 to enable charge partitioning. (defaults to 0, off)
-- Map(tw_ChargePartitionTime) - Time a charge partition should last. (defaults to 15)
-- Map(tw_D_ChargeTime) - Total charge time to hold for a Down charge.  (defaults to 48)
-- Map(tw_D_BufferTime) - Total buffer time for Down charge once it's active (defaults to 9)
-- Map(tw_U_ChargeTime) - Total charge time to hold for an Up charge.  (defaults to 48)
-- Map(tw_U_BufferTime) - Total buffer time for Up charge once it's active. (defaults to 9)
-- Map(tw_B_ChargeTime) - Total charge time to hold for a Back charge.  (defaults to 48)
-- Map(tw_B_BufferTime) - Total buffer time for Back charge once it's active. (defaults to 9)
-- Map(tw_F_ChargeTime) - Total charge time to hold for a Forward charge.  (defaults to 48)
-- Map(tw_F_BufferTime) - Total buffer time for Forward charge once it's active (defaults to 9)
-- Map(tw_Dash_input1_BufferTime) - Total buffer time for the first input in any dash (FF,BB) command. (defaults to 9)
-- Map(tw_Dash_input2_BufferTime) - Total buffer time for the second input in any dash (FF,BB) command. (defaults to 6)
-- Map(tw_Input_Delay_frames) - Total number of frames to additionally delay all inputs for (defaults to 0, no additional delay)
-- Map(tw_Buffer_Snk) - Set to 1 to treat the character's buffer as an SNK (KOF) style buffer. (defaults to 0)
-- Map(tw_MoveStrength) - Read-only. Set by the "strength" parameter in the move's table definition in buffering.lua.
-- Map(tw_Btn6) - Set to 1 to signify that this is a 6-button character. (defaults to 1, is 6-button)
-- Map(tw_Assert_NoBufferTimeDec) - Set to nonzero to assert no buffer decrementing. The buffer can still move along, but
--                                  this can allow for things such as "infinite" buffer time such as SFA2/SFZ2 Custom
--                                  Combo/Variable Combo.
--
-- All available standard move map names are found in the "name" parameter of each command definition at the end of this file.

main.f_commandAdd("start", "s", 1, 1)
main.f_commandAdd("m", "m", 1, 1)

main.f_commandAdd("holdfwd", "/$F", 1, 1)
main.f_commandAdd("holddown", "/$D", 1, 1)
main.f_commandAdd("holdback", "/$B", 1, 1)
main.f_commandAdd("holdup", "/$U", 1, 1)

main.f_commandAdd("x", "x", 1, 1)
main.f_commandAdd("y", "y", 1, 1)
main.f_commandAdd("z", "z", 1, 1)
main.f_commandAdd("w", "w", 1, 1)
main.f_commandAdd("a", "a", 1, 1)
main.f_commandAdd("b", "b", 1, 1)
main.f_commandAdd("c", "c", 1, 1)
main.f_commandAdd("d", "d", 1, 1)

main.f_commandAdd("hold_x", "/x", 1, 1)
main.f_commandAdd("hold_y", "/y", 1, 1)
main.f_commandAdd("hold_z", "/z", 1, 1)
main.f_commandAdd("hold_w", "/w", 1, 1)
main.f_commandAdd("hold_a", "/a", 1, 1)
main.f_commandAdd("hold_b", "/b", 1, 1)
main.f_commandAdd("hold_c", "/c", 1, 1)
main.f_commandAdd("hold_d", "/d", 1, 1)	
main.f_commandAdd("hold_start", "/s", 1, 1)

function serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then tmp = tmp .. name .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end



tw ={}
tw.ver = 1.5

--attacking buttons x/y/z/a/b/c
tw.p_att={{0},{0},{0},{0}}
tw.h_att={{0},{0},{0},{0}}
tw.r_att={{0},{0},{0},{0}}
--directions 
tw.p_dir={{0},{0},{0},{0}}
tw.h_dir={{0},{0},{0},{0}}
tw.r_dir={{0},{0},{0},{0}}
--used for hundred hand slap/mash motions
tw.m_att ={0,0,0,0}
--used for storing changestateNos
tw.buffer_changeStateNo = {{},{},{},{}}
--store where our rotation started
local rotset={0,0,0,0}
--p2 bodydist/p2dist 
local enemydx={0.0,0.0,0.0,0.0}
local enemybdx={0.0,0.0,0.0,0.0}
--HHS storage
local hhsp={0,0,0,0}
local hhsk={0,0,0,0}
local mashtimer={0,0,0,0}
local mashtimerk={0,0,0,0}
--charging storage
local ch_valb = {0,0,0,0}
local ch_valf = {0,0,0,0}
local ch_vald = {0,0,0,0}
local ch_valu = {0,0,0,0}

local chp_tb = {0,0,0,0}
local chp_tf = {0,0,0,0}
local chp_td = {0,0,0,0}
local chp_tu = {0,0,0,0}

--hitpause is 1f off for whatever reason, so we use this.
local hptfix={0,0,0,0}
--end of that shit

--used to prevent run/backdash if another input is active that would overwrite it
local cmd_Activef={false,false,false,false}
local cmd_Activeb={false,false,false,false}
--bit declarations for readiblity
local Bit1 = 1
local Bit2 = 2
local Bit3 = 4
local Bit4 = 8
local Bit5 = 16
local Bit6 = 32
local Bit7 = 64
local Bit8 = 128
local Bit9 = 256
local Bit10 = 512
local Bit11 = 1024
local Bit12 = 2048
local Bit13 = 4096
local Bit14 = 8192
local Bit15 = 16384
local Bit16 = 32768
local Bit17 = 65536
local Bit18 = 131072
local Bit32 = -2147483648
--readiblity is the only reason I bothered here.
local up = Bit5
local down = Bit6
local left = Bit7
local right = Bit8

local release_Up = Bit1
local release_Down = Bit2
local release_Left = Bit3
local release_Right = Bit4
--tbh these aren't even used.
local hold_up = up+release_Up
local hold_down = down+release_Down
local hold_left = left+release_Left
local hold_right = right+release_Right


--declare our buttons
local x = Bit10
local y = Bit11
local z = Bit12
local s = Bit13
local a = Bit14
local b = Bit15
local c = Bit16
local w = Bit17
local d = Bit18
local release_x = Bit1
local release_y = Bit2
local release_z = Bit3
local release_Start = Bit4
local release_a = Bit5
local release_b = Bit6
local release_c = Bit7
local release_w = Bit8
local release_d = Bit9

-- input types (NEW: 1.5)
local press = 0
local hold = 1
local release = 2
local multidirectional = 3

--used for turtlewaxy.lua aka externally defined commands
tw.up = up
tw.down=down
tw.left=left
tw.right=right
tw.release_up = release_Up
tw.release_down = release_Down
tw.release_left = release_Left
tw.release_right = release_Right
tw.x = x
tw.y=y
tw.z=z
tw.w =w
tw.a=a
tw.b=b
tw.c=c
tw.d=d
tw.release_x=release_x
tw.release_y=release_y
tw.release_z=release_z
tw.release_w=release_w
tw.release_a=release_a
tw.release_b=release_b
tw.release_c=release_c
tw.release_d=release_d
tw.release_start=release_Start
tw.press = press
tw.hold = hold
tw.release = release
tw.multidirectional = multidirectional
tw.debug = false

--required for easy bit math below and readability
local r_AllBits = release_Up+release_Down+release_Left+release_Right
local p_AllBits = up+down+left+right
local r_AllBits_att = release_x+release_y+release_z+release_a+release_b+release_c+release_w+release_d
local r_PBits = release_x+release_y+release_z
local r_KBits = release_a+release_b+release_c
local p_AllBits_att = x+y+z+a+b+c+w+d
local p_PBits_att = x+y+z
local p_KBits_att = a+b+c

--we don't have a deepcopy function, so we made one. Same with all the bitwise shit.
function tw.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[tw.deepcopy(orig_key)] = tw.deepcopy(orig_value)
        end
        setmetatable(copy, tw.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Allocates a table of size size
function tw.allocate_buffer_size(size)
	local t = {}
	-- We always need
	for i=1,size do
		t[i] = 0
	end
	return t
end

--default charge values
local b_charge=48
local d_charge=48
local f_charge=48
local u_charge=48
--default using snk style buffer value
local snk={false,false,false,false,false,false,false,false}
local defaults ={}
defaults.btn6=0
defaults.MashPCt=0
defaults.MashCt=0
defaults.tw_ChargePartitionTime=0
defaults.D_ChargeTime=0
defaults.D_BufferTime=0
defaults.B_ChargeTime=0
defaults.B_BufferTime=0
defaults.F_ChargeTime=0
defaults.F_BufferTime=0
defaults.charge_partition=0
defaults.input_delay_frames=0
--max 4 players
tw.defaults ={
	[1]=tw.deepcopy(defaults),
	[2]=tw.deepcopy(defaults),
	[3]=tw.deepcopy(defaults),
	[4]=tw.deepcopy(defaults),
}


--sets values if the user hasn't defined them.
function tw.setDefaults(p)
	player(p)
	if  map('tw_btn6')==0 then
		charMapSet(p, 'tw_btn6', 1,'set')
	end
	if map('tw_MashPCt')==0 then
		charMapSet(p, 'tw_MashPCt',10,'set')
	end
	if  map('tw_MashCt')==0 then
		charMapSet(p, 'tw_MashCt', 5,'set')
	end
	if  map('tw_ChargePartitionTime')==0 then
		charMapSet(p, 'tw_ChargePartitionTime', 15,'set')
	end
	if map('tw_D_ChargeTime')==0 then
		charMapSet(p, 'tw_D_ChargeTime', d_charge,'set')
	end
	if  map('tw_D_BufferTime')==0 then
		charMapSet(p, 'tw_D_BufferTime', 9,'set')
	end
	if map('tw_U_ChargeTime')==0 then
		charMapSet(p, 'tw_U_ChargeTime', u_charge,'set')
	end
	if  map('tw_U_BufferTime')==0 then
		charMapSet(p, 'tw_U_BufferTime', 9,'set')
	end
	if map('tw_B_ChargeTime')==0 then
		charMapSet(p, 'tw_B_ChargeTime', b_charge,'set')
	end
	if map('tw_B_BufferTime')==0 then
		charMapSet(p, 'tw_B_BufferTime', 9,'set')
	end
	if map('tw_F_ChargeTime')==0 then
		charMapSet(p, 'tw_F_ChargeTime', f_charge,'set')
	end
	if map('tw_F_BufferTime')==0 then
		charMapSet(p, 'tw_F_BufferTime', 9,'set')
	end
	if map('tw_Input_Delay_frames') < 0 then
		charMapSet(p, 'tw_Input_Delay_frames', 0, 'set')
	end
	if map('tw_Dash_input1_BufferTime')==0 then
		charMapSet(p, 'tw_Dash_input1_BufferTime', 9, 'set')
	end
	if map('tw_Dash_input2_BufferTime')==0 then
		charMapSet(p, 'tw_Dash_input2_BufferTime', 6, 'set')
	end
	if map('tw_ver') <= 0 then
		charMapSet(p, 'tw_ver', tw.ver, 'set')
	end

	snk[p]= map('tw_Buffer_Snk')==1

	-- Update TW notification
	if map('tw_ver') > 0 and (math.floor(map('tw_ver')*10.0)) ~= math.floor(tw.ver*10.0) then
		local err_msg = string.format('The version of turtlewax implemented (%f) does not match TW mod version (%f), please update it!', map('tw_ver'), tw.ver)
		print(err_msg)
		charMapSet(p, 'update_tw', 1,'set')
		if tw.debug then assert(false, err_msg) end
	end

	tw.defaults[p].btn6= map('tw_Btn6')
	tw.defaults[p].MashPCt= map('tw_MashPCt')
	tw.defaults[p].MashCt= map('tw_MashCt')
	tw.defaults[p].chargePartitionTime= map('tw_ChargePartitionTime')
	tw.defaults[p].D_ChargeTime= map('tw_D_ChargeTime')
	tw.defaults[p].D_BufferTime= map('tw_D_BufferTime')
	tw.defaults[p].U_ChargeTime= map('tw_U_ChargeTime')
	tw.defaults[p].U_BufferTime= map('tw_U_BufferTime')
	tw.defaults[p].B_ChargeTime= map('tw_B_ChargeTime')
	tw.defaults[p].B_BufferTime= map('tw_B_BufferTime')
	tw.defaults[p].F_ChargeTime= map('tw_F_ChargeTime')
	tw.defaults[p].F_BufferTime= map('tw_F_BufferTime')
	tw.defaults[p].charge_partition= map('tw_charge_partition')
	tw.defaults[p].input_delay_frames = map('tw_Input_Delay_frames')
	tw.defaults[p].dash_times = { map('tw_Dash_input1_BufferTime'), map('tw_Dash_input2_BufferTime') }
	tw.debug = tw.debug or (map('tw_Debug') ~= 0)


	--attacking buttons x/y/z/a/b/c
	tw.p_att[p] = tw.allocate_buffer_size(1 + tw.defaults[p].input_delay_frames)
	tw.h_att[p] = tw.allocate_buffer_size(1 + tw.defaults[p].input_delay_frames)
	tw.r_att[p] = tw.allocate_buffer_size(1 + tw.defaults[p].input_delay_frames)
	--directions 
	tw.p_dir[p] = tw.allocate_buffer_size(1 + tw.defaults[p].input_delay_frames)
	tw.h_dir[p] = tw.allocate_buffer_size(1 + tw.defaults[p].input_delay_frames)
	tw.r_dir[p] = tw.allocate_buffer_size(1 + tw.defaults[p].input_delay_frames)

	-- Store the char dirs
	local char = start.f_getCharData(start.p[p].t_selected[1].ref)
	local scriptDir = char.dir
	local stateNoScript = scriptDir .. 'buffering.lua'
	local test = io.open(stateNoScript, 'r')
	if test ~= nil then
		-- Close this out; we don't need it
		io.close(test)
		local f = assert(loadfile(stateNoScript, 't'), 'error in ' .. stateNoScript)

		-- Clear the extra specials so we can load the character's
		tw.extraspecials = nil
		-- Load the buffering table
		tw.buffer_changeStateNo[p] = f(p)
		-- Merge any specials from the character
		if tw.extraspecials ~= nil and tw.table_length(tw.extraspecials) > 0 then
			if tw.debug then print('Character has their own specials, merging...') end
			tw.specialbuffer[p] = main.f_tableMerge(tw.specialbuffer[p], tw.extraspecials)
		end
		if tw.debug then print('Discovering all common buffers...') end
		for k,v in pairs(tw.specialbuffer[p]) do
			tw.findAlikeBuffers(p,k, v.name)
		end
		if tw.debug then print(serializeTable(tw.buffer_changeStateNo[p], char.name)) end
	elseif tw.debug then assert(false, 'buffering.lua file to set stateno does not exist! It is required as of TW 1.5!')
	end
end

function tw.table_length(t)
	if type(t) ~= 'table' then return 0 end
	if t ~= nil then
		local length = 0
		for k,v in pairs(t) do
			length = length+1
		end
		return length
	end
	return 0
end

--the shit we had to make because lua 5.1 sucks balls

function tw.bitResult(input,b1,b2)
	if b2 ~= nil then
		if tw.BitAND( input,tw.BitOR( b1,b2))  > 0 then
			return 1
		else
			return 0
		end
	else
		if tw.BitAND(input,b1)  > 0 then
			return 1
		else
			return 0
		end
	end
end

function tw.bitResult2(cond1,cond2)
	if cond1>0 and cond2>0 then
		return 1
	else
		return 0
	end
end


 function tw.BitNOT(n)
    local p,c=1,0
    while n>0 do
        local r=n%2
        if r<1 then c=c+p end
        n,p=(n-r)/2,p*2
    end
    return c
end

 function tw.BitAND(a,b)--Bitwise and
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>1 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

 function tw.BitOR(a,b)--Bitwise or
    local p,c=1,0
    while a+b>0 do
        local ra,rb=a%2,b%2
        if ra+rb>0 then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    return c
end

 function tw.BitXOR(a,b)--Bitwise xor
    local p,c=1,0
    while a>0 and b>0 do
        local ra,rb=a%2,b%2
        if ra~=rb then c=c+p end
        a,b,p=(a-ra)/2,(b-rb)/2,p*2
    end
    if a<b then a=b end
    while a>0 do
        local ra=a%2
        if ra>0 then c=c+p end
        a,p=(a-ra)/2,p*2
    end
    return c
end


local systime={0,0,0,0}
local defaultset ={false,false,false,false,false,false,false,false}

local scriptaction = nil
local redirected_player = nil

function tw.start()
    --if using playback mod for recording and playback on training mode.
    if k_playback ~= nil then
        scriptaction = k_playback.scriptaction
        redirected_player = k_playback.p2
    end

    if not main.pauseMenu and not paused() then
        tw.poll(1,scriptaction,1)
        tw.poll(2,scriptaction,2)
        if config.Players >2 and (teammode()=='simul' or teammode()=='tag') then
            tw.poll(3,scriptaction,3)
            if config.Players >3 then
                tw.poll(4,scriptaction,4)
            end
        end
    end
end



function tw.poll(p,script,r)
	tw.setDist(p)

	if roundstart() then
		defaultset[p] =false
	end
	--we know at this point that any value overriding our defaults will be 
	--set
	if roundsexisted() < 1  and not defaultset[p] then
		local extra_special_tmp = tw.extraspecials
		if tw.specialbuffer == nil then
			tw.specials=main.f_tableMerge(tw.extraspecials,tw.specials)
			--set buffers for all players
			tw.specialbuffer={
				[1]=tw.deepcopy(tw.specials),
				[2]=tw.deepcopy(tw.specials),
				[3]=tw.deepcopy(tw.specials),
				[4]=tw.deepcopy(tw.specials),
				[5]=tw.deepcopy(tw.specials),
				[6]=tw.deepcopy(tw.specials),
				[7]=tw.deepcopy(tw.specials),
				[8]=tw.deepcopy(tw.specials),
			}
		end

		tw.setDefaults(p)
		tw.extraspecials = extra_special_tmp
		defaultset[p]=true
	end

	-- Defaults have been set, we can process now
	if defaultset[p] then

		systime[p]=gametime()
		if player(p) and map('LockInput')==0 then
			--lets set our anything I guess.
			charMapSet(p, 'tw_Mashing',  0,'set')
			if script ~= nil then
				tw.h_dir[r][tw.defaults[p].input_delay_frames + 1] = script[1]
				tw.p_dir[r][tw.defaults[p].input_delay_frames + 1] = script[2]
				tw.h_att[r][tw.defaults[p].input_delay_frames + 1] = script[3]
				tw.p_att[r][tw.defaults[p].input_delay_frames + 1] = script[4]
				if #script>4 then
					tw.m_att[r] = script[5]
				end
				tw.setDirMp(r)
				tw.setBtnMp(r)
			else

			tw.shiftDirBuffers(p)
			tw.setDir(p,r)
			tw.shiftBtnBuffers(p)
			tw.setBtn(p,r)
			tw.setDirMp(p)
			tw.setBtnMp(p)

			end

			if tw.BitAND(tw.p_att[p][1],x) >0 or tw.BitAND(tw.p_att[p][1],y) >0 or tw.BitAND(tw.p_att[p][1],z) > 0 or tw.BitAND(tw.p_att[p][1],w) >0 or tw.BitAND(tw.p_att[p][1],a) >0 or tw.BitAND(tw.p_att[p][1],b) >0 or tw.BitAND(tw.p_att[p][1],c) >0 or tw.BitAND(tw.p_att[p][1],d) >0 or tw.BitAND(tw.p_dir[p][1],up) >0 or tw.BitAND(tw.p_dir[p][1],down) >0 or tw.BitAND(tw.p_dir[p][1],left) >0 or tw.BitAND(tw.p_dir[p][1],right) >0 then
				charMapSet(p, 'tw_Mashing',  1,'set')
			end
			--lets store some charge time!
			tw.setCharge(p)
		else
			--if lockinput is set, clear our buffers!
			tw.clearAll(p)
		end
		tw.checkHHS(p)

		--lets set our specials!
		for k, v in pairs(tw.specialbuffer[p]) do
			--if a special is marked as snkonly, we don't waste precious cylcles looking at it.
			if (tw.specialbuffer[p][k].snkonly<=0 or snk[p]) and ((snk and tw.specialbuffer[p][k].snkonly>-1) or not snk[p]) then
				tw.checkSpecials(p,k,snk[p])
			end
		end

		-- Check state
		tw.setStateNo(p)

		--always check run last!
		tw.checkRun(p)
		--tw.stopRun(p)
	end

end

-- Responsible for setting character state when the table is supplied
function tw.setStateNo(p)
	player(p)
	local isAir = statetype() == 'A'
	local stateTypeHasSet = map('tw_Buffer_ChangeStateNo') > -1

	-- Don't do useless processing
	if not stateTypeHasSet then
		if isAir and tw.buffer_changeStateNo[p].air ~= nil then
			tw.checkEmbeddedMaps(p, tw.buffer_changeStateNo[p].air, nil)
		elseif tw.buffer_changeStateNo[p].ground ~= nil then
			tw.checkEmbeddedMaps(p, tw.buffer_changeStateNo[p].ground, nil)
		end
	elseif stateno() == math.floor(map('tw_Buffer_ChangeStateNo')) and time() == 1 then
		-- Reset on ChangeState
		charMapSet(p, 'tw_Buffer_ChangeStateNo', -1, 'set')
	end
end

function tw.checkEmbeddedMaps(p, map_table, parent_command)
	player(p)
	local has_set_state = false
	if map('tw_Buffer_ChangeStateNo') < 0 then
		for k,v in pairs(map_table) do
			if type(k) == 'string' then
				k = string.lower(k)
				if k == 'tw_neutral' or k == 'super' or k == 'special' or k == 'basic' then
					if v ~= nil then
						has_set_state = tw.checkStateNo(p, v, parent_command)
					end
				elseif map(k) > 0 then
					-- Need to kick off the parent command
					if parent_command == nil then
						tw.checkEmbeddedMaps(p, v, k)
					-- Don't redefine the parent command
					else
						tw.checkEmbeddedMaps(p, v, parent_command)
					end
				end
			end

			if has_set_state then break end
		end
		if not has_set_state then
			for i,v in ipairs(map_table) do
				if v ~= nil then
					has_set_state = tw.checkStateNo(p, v, parent_command)
				end
				if has_set_state then break end
			end
		end
	end
	return has_set_state
end

function tw.checkStateNo(p, def, parent_command)
	player(p)
	local has_set_state = false
	if parent_command == nil or map(parent_command) > 0 then
		if def.stateNo ~= nil then
			if (def.limiter == nil or (def.limiter(p) == true)) and (not def.button or map(def.button) > 0) then
				if tw.debug then
					if def.button then print(string.format('button pressed = %s', def.button)) end
					print(string.format('parent_command = %s, map(parent_command) = %f', tostring(parent_command), parent_command ~= nil and map(parent_command) or 0))
				end

				-- Set the state
				charMapSet(p, 'tw_Buffer_ChangeStateNo', def.stateNo, 'set')

				-- Reset the map for the command and the button too
				if parent_command ~= nil then
					for k,v in pairs(tw.specialbuffer[p]) do
						if string.lower(v.name) == parent_command then
							-- Zero out the buffer
							if tw.debug then print('Zeroing out the buffer for ' .. parent_command) end
							tw.specialbuffer[p][k].b_t = 0
							charMapSet(p, v.name, 0, 'set')
							break
						end
					end
				end

				-- Set button if defined
				if def.button then
					charMapSet(p, def.button, 0, 'set')
				end

				-- Set strength if specified
				if def.strength ~= nil and def.strength >= 0 then
					charMapSet(p, 'tw_MoveStrength', def.strength, 'set')
				end

				-- Clear alike buffers?
				if def.clear_alike and parent_command ~= nil then
					tw.resetAlikeBuffers(p, parent_command)
				end

				-- Determine that we've set our state
				has_set_state = true
			end
		else
			has_set_state = tw.checkEmbeddedMaps(p, def, parent_command)
		end
	end
	return has_set_state
end

function tw.shiftBtnBuffers(p)
	if gametime()==systime[p] then
		local delayTime_f = #tw.h_att[p]
		if delayTime_f > 1 then
			tw.p_att[p][1] = tw.BitOR(math.floor(tw.p_att[p][1]/x), tw.p_att[p][2])
			tw.h_att[p][1] = tw.BitOR(math.floor(tw.h_att[p][1]/x), tw.h_att[p][2])
			tw.r_att[p][1] = tw.BitOR(math.floor(tw.r_att[p][1]/x), tw.r_att[p][2])
			for i=2,delayTime_f-1 do
				tw.p_att[p][i] = tw.p_att[p][i+1]
				tw.h_att[p][i] = tw.h_att[p][i+1]
				tw.r_att[p][i] = tw.r_att[p][i+1]
			end
			tw.p_att[p][delayTime_f] = 0
			tw.h_att[p][delayTime_f] = 0
			tw.r_att[p][delayTime_f] = 0
		else
			tw.p_att[p][1] = math.floor(tw.p_att[p][1]/x)
			tw.h_att[p][1] = math.floor(tw.h_att[p][1]/x)
			tw.r_att[p][1] = math.floor(tw.r_att[p][1]/x)
		end
	end
end

function tw.shiftDirBuffers(p)
	if gametime()==systime[p] then
		local delayTime_f = #tw.h_dir[p]
		if delayTime_f > 1 then
			tw.p_dir[p][1] = tw.BitOR(math.floor(tw.p_dir[p][1]/up), tw.p_dir[p][2])
			tw.h_dir[p][1] = tw.BitOR(math.floor(tw.h_dir[p][1]/up), tw.h_dir[p][2])
			tw.r_dir[p][1] = tw.BitOR(math.floor(tw.r_dir[p][1]/up), tw.r_dir[p][2])
			for i=2,delayTime_f-1 do
				tw.p_dir[p][i] = tw.p_dir[p][i+1]
				tw.h_dir[p][i] = tw.h_dir[p][i+1]
				tw.r_dir[p][i] = tw.r_dir[p][i+1]
			end
			tw.p_dir[p][delayTime_f] = 0
			tw.h_dir[p][delayTime_f] = 0
			tw.r_dir[p][delayTime_f] = 0
		else
			tw.p_dir[p][1] = math.floor(tw.p_dir[p][1]/up)
			tw.h_dir[p][1] = math.floor(tw.h_dir[p][1]/up)
			tw.r_dir[p][1] = math.floor(tw.r_dir[p][1]/up)
		end
	end
end

function tw.clearAll(p)
	local delayTime_f = tw.defaults[p].input_delay_frames + 1
	-- Clear all arrays
	for i=1,delayTime_f do
		tw.p_att[p][i] = 0
		tw.h_att[p][i] = 0
		tw.r_att[p][i] = 0
		tw.p_dir[p][i] = 0
		tw.h_dir[p][i] = 0
		tw.r_dir[p][i] = 0
	end
end

function tw.setCharge(p)
	local cpt = tw.defaults[p].charge_partition

	--check holding left
	if tw.BitAND(tw.h_dir[p][1],left) > 0 or tw.BitAND(tw.r_dir[p][1],release_Left) > 0 then
		ch_valb[p]=ch_valb[p]+1
		if cpt then
			chp_tb[p]=tw.defaults[p].tw_ChargePartitionTime
		end
		if ch_valb[p] > tw.defaults[p].B_ChargeTime then
			charMapSet(p, 'tw_B_ChargeReady',tw.defaults[p].B_BufferTime ,'set')
		end
	else
		if hptfix[p]==0 then
			if map('tw_B_ChargeReady')>0  then
				charMapSet(p, 'tw_B_ChargeReady', -1 ,'add')
			end
			if chp_tb[p]>0 then
				chp_tb[p]=chp_tb[p]-1
			end

			if not cpt or chp_tb[p]==0 then
				ch_valb[p]=0
			end
		end
	end

	--check holding right
	if tw.BitAND(tw.h_dir[p][1],right) > 0 or tw.BitAND(tw.r_dir[p][1],release_Right) > 0 then
		ch_valf[p]=ch_valf[p]+1
		if cpt then
			chp_tf[p]=tw.defaults[p].tw_ChargePartitionTime
		end
		if ch_valf[p] > tw.defaults[p].F_ChargeTime then
			charMapSet(p, 'tw_F_ChargeReady', tw.defaults[p].F_BufferTime ,'set')
		end
	else
		if hptfix[p]==0 then
			if map('tw_F_ChargeReady')>0  then
				charMapSet(p, 'tw_F_ChargeReady', -1 ,'add')
			end

			if chp_tf[p]>0 then
				chp_tf[p]=chp_tf[p]-1
			end

			if not cpt or chp_tf[p]==0 then
				ch_valf[p]=0
			end
		end
	end

	--check holding down
	if tw.BitAND(tw.h_dir[p][1],down) > 0 or tw.BitAND(tw.r_dir[p][1],release_Down) > 0  then
		ch_vald[p]=ch_vald[p]+1
		if cpt then
			chp_td[p] = tw.defaults[p].tw_ChargePartitionTime
		end
		if ch_vald[p] > tw.defaults[p].D_ChargeTime then
			charMapSet(p, 'tw_D_ChargeReady',tw.defaults[p].D_BufferTime ,'set')
		end
	else
		if hptfix[p]==0 then
			if map('tw_D_ChargeReady')>0 then
				charMapSet(p, 'tw_D_ChargeReady', -1 ,'add')
			end
			if chp_td[p]>0 then
				chp_td[p]=chp_td[p]-1
			end

			if not cpt or chp_td[p]==0 then
				ch_vald[p]=0
			end

		end
	end

	--check holding up
	if tw.BitAND(tw.h_dir[p][1],up) > 0 or tw.BitAND(tw.r_dir[p][1],release_Up) > 0  then
		ch_vald[p]=ch_vald[p]+1
		if cpt then
			chp_td[p]=tw.defaults[p].tw_ChargePartitionTime
		end
		if ch_vald[p] > tw.defaults[p].U_ChargeTime then
			charMapSet(p, 'tw_U_ChargeReady',tw.defaults[p].U_BufferTime ,'set')
		end
	else
		if hptfix[p]==0 then
			if map('tw_U_ChargeReady')>0 then
				charMapSet(p, 'tw_U_ChargeReady', -1 ,'add')
			end
			if chp_tu[p] > 0 then
				chp_tu[p] = chp_tu[p]-1
			end

			if not cpt or chp_tu[p]==0 then
				ch_valu[p]=0
			end

		end
	end
end



function tw.setDist(p)
	player(p)
	local px= posX()
	enemynear()
	local eposx= posX()
	player(p)
	local facing =facing()
	local state =statetype()
	enemynear()
	local estate= statetype()
	player(p)
	local cgf  = const("size.ground.front")
	enemynear()
	local ecgf = const("size.ground.front")
	player(p)
	local caf  = const("size.air.front")
	enemynear()
	local ecaf = const("size.air.front")

	local basedist = (px - eposx)

	enemydx[p]=basedist *(-facing)

	if state~="A" and estate ~="A" then
		enemybdx[p]=(basedist +(cgf+ecgf)*facing)*(-facing)
	end

	if state=="A" and estate ~="A" then
		enemybdx[p]=(basedist +(caf+ecgf)*facing)*(-facing)
	end

	if state~="A" and estate =="A" then
		enemybdx[p]=(basedist +(cgf+ecaf)*facing)*(-facing)
	end

	if state=="A" and estate =="A" then
		enemybdx[p]=(basedist +(caf+ecaf)*facing)*(-facing)
	end

	charMapSet(p, 'tw_enemydx', enemydx[p],'set')
	charMapSet(p, 'tw_enemybdx', enemybdx[p] ,'set')
end

function tw.setDir(p,r)
	local pl = p
	if r ~=p and r ~=nil then
		pl=r
	end

	player(p)
	local fcond1=  (((facing()==1 and enemydx[p] >=0 or enemydx[p]<0 and facing()==-1) and  map('turncheck')==0) or map('turncheck')==1 and facing()==1)  --((map(45556197429'tw_enemydx') >=0 and  map('turncheck')==0) or ( map('turncheck')==1 and facing()==1))
	local fcond2=(((facing()==-1 and enemydx[p] >=0 or enemydx[p]<0 and facing()==1) and  map('turncheck')==0) or map('turncheck')==1 and facing()==-1)  --((enemydx[p] <0 and map('turncheck')==0 ) or  (map('turncheck')==1 and facing()==-1 ))

	local tr_r=map('_iksys_trainingDummyMode') == 3 and fcond1 or (map('_iksys_trainingDirection') == 1 and fcond1 or map('_iksys_trainingDirection') == -1 and fcond2) and not commandGetState(main.t_cmd[pl], 'holdback')
	local tr_l=  map('_iksys_trainingDummyMode') == 3 and fcond2 or (map('_iksys_trainingDirection') == -1 and fcond1 or map('_iksys_trainingDirection') == 1 and fcond2)and not commandGetState(main.t_cmd[pl], 'holdfwd')
	local tr_d=  map('_iksys_trainingGuardMode') == 1 and map('guardtime')>0 or map('_iksys_trainingDummyMode') == 1
	local tr_u = map('_iksys_trainingDummyMode') == 3 or map('_iksys_trainingDummyMode') == 2

	local buffer_len = #tw.p_dir[p]

	if  commandGetState(main.t_cmd[pl], '$U') or commandGetState(main.t_cmd[pl], 'holdup') or tr_u then --player(p) and (command("up2") or command("holdup"))
		--hold up init 
		tw.h_dir[p][buffer_len] = tw.BitOR(tw.h_dir[p][buffer_len],up)
		if commandGetState(main.t_cmd[pl], '$U') then
			--press up init
			tw.p_dir[p][buffer_len] = tw.BitOR(tw.p_dir[p][buffer_len],up)
		end
	end

	if tw.BitAND(tw.h_dir[p][1],up) == 0 and tw.BitAND(tw.h_dir[p][1],release_Up) > 0  then
		--release up init 
		tw.r_dir[p][1] = tw.BitOR(tw.r_dir[p][1],up)
	end

	if  commandGetState(main.t_cmd[pl], '$D')  or commandGetState(main.t_cmd[pl], 'holddown') or tr_d  then --player(p) and (command("down2") or command("holddown"))
		--hold down init 
		tw.h_dir[p][buffer_len] = tw.BitOR(tw.h_dir[p][buffer_len],down)
		if commandGetState(main.t_cmd[pl], '$D') then
			--press down init
			tw.p_dir[p][buffer_len] = tw.BitOR(tw.p_dir[p][buffer_len],down)
		end
	end

	if tw.BitAND(tw.h_dir[p][1],down) == 0 and tw.BitAND(tw.h_dir[p][1],release_Down) > 0 then
		--release down init 
		tw.r_dir[p][1] = tw.BitOR(tw.r_dir[p][1],down)
	end

	if  ((commandGetState(main.t_cmd[pl], '$B') or commandGetState(main.t_cmd[pl], 'holdback') or tr_l) and fcond1) or ((commandGetState(main.t_cmd[pl], '$F') or commandGetState(main.t_cmd[pl], 'holdfwd') or tr_r) and fcond2) then
		--hold left init 
		tw.h_dir[p][buffer_len] =tw.BitOR(tw.h_dir[p][buffer_len],left)
		if (commandGetState(main.t_cmd[pl], '$B') and fcond1) or (commandGetState(main.t_cmd[pl], '$F') and fcond2) then
			--press left init
			tw.p_dir[p][buffer_len] = tw.BitOR(tw.p_dir[p][buffer_len],left)
		end
	end

	if tw.BitAND(tw.h_dir[p][1],left) == 0 and tw.BitAND(tw.h_dir[p][1],release_Left) > 0 then
		--release left init 
		tw.r_dir[p][1] = tw.BitOR(tw.r_dir[p][1],left)
	end

	if  ((commandGetState(main.t_cmd[pl], '$F') or commandGetState(main.t_cmd[pl], 'holdfwd')  or tr_r) and fcond1) or ((commandGetState(main.t_cmd[pl], '$B') or commandGetState(main.t_cmd[pl], 'holdback')  or tr_l) and fcond2) then
		--hold right init 
		tw.h_dir[p][buffer_len] = tw.BitOR(tw.h_dir[p][buffer_len],right)
		if (commandGetState(main.t_cmd[pl], '$F') and fcond1) or (commandGetState(main.t_cmd[pl], '$B') and fcond2) then
			--press right init
			tw.p_dir[p][buffer_len] = tw.BitOR(tw.p_dir[p][buffer_len],right)
		end
	end

	if tw.BitAND(tw.h_dir[p][1],right) == 0 and tw.BitAND(tw.h_dir[p][1],release_Right) > 0 then
		--release right init 
		tw.r_dir[p][1] = tw.BitOR(tw.r_dir[p][1],right)
	end

	-- Hitbox sanitization
	if tw.BitAND(tw.h_dir[p][buffer_len], (up+down)) == (up+down) then
		tw.h_dir[p][buffer_len] = tw.BitXOR(tw.h_dir[p][buffer_len], (up+down))
	end
	if tw.BitAND(tw.h_dir[p][buffer_len], (left+right)) == (left+right) then
		tw.h_dir[p][buffer_len] = tw.BitXOR(tw.h_dir[p][buffer_len], (left+right))
	end
	if tw.BitAND(tw.p_dir[p][buffer_len], (up+down)) == (up+down) then
		tw.p_dir[p][buffer_len] = tw.BitXOR(tw.p_dir[p][buffer_len], (up+down))
	end
	if tw.BitAND(tw.p_dir[p][buffer_len], (left+right)) == (left+right) then
		tw.p_dir[p][buffer_len] = tw.BitXOR(tw.p_dir[p][buffer_len], (left+right))
	end
end

function tw.setDirMp(p)
	tw.setCharge(p)
	charMapSet(p, 'u_Up', tw.BitAND(tw.p_dir[p][1],up) ,'set')
	charMapSet(p, 'u_Dn', tw.BitAND(tw.p_dir[p][1],down),'set')
	charMapSet(p, 'u_Bk', tw.BitAND(tw.p_dir[p][1],left) ,'set')
	charMapSet(p, 'u_Fd', tw.BitAND(tw.p_dir[p][1],right),'set')

	charMapSet(p, 'u_h_Up', tw.BitAND(tw.h_dir[p][1],up) ,'set')
	charMapSet(p, 'u_h_Dn', tw.BitAND(tw.h_dir[p][1],down),'set')
	charMapSet(p, 'u_h_Bk', tw.BitAND(tw.h_dir[p][1],left) ,'set')
	charMapSet(p, 'u_h_Fd', tw.BitAND(tw.h_dir[p][1],right),'set')

	charMapSet(p, 'p_Up', tw.bitResult(tw.p_dir[p][1],up,release_Up) ,'set')
	charMapSet(p, 'p_Dn', tw.bitResult(tw.p_dir[p][1],down,release_Down) ,'set')
	charMapSet(p, 'p_Bk', tw.bitResult(tw.p_dir[p][1],left,release_Left) ,'set')
	charMapSet(p, 'p_Fd', tw.bitResult(tw.p_dir[p][1],right,release_Right),'set')
	charMapSet(p, 'h_Up', tw.bitResult(tw.h_dir[p][1],up,release_Up) ,'set')
	charMapSet(p, 'h_Dn', tw.bitResult(tw.h_dir[p][1],down,release_Down) ,'set')
	charMapSet(p, 'h_Bk', tw.bitResult(tw.h_dir[p][1],left,release_Left) ,'set')
	charMapSet(p, 'h_Fd', tw.bitResult(tw.h_dir[p][1],right,release_Right),'set')
	charMapSet(p, 'r_Up', tw.bitResult(tw.r_dir[p][1],release_Up) ,'set')
	charMapSet(p, 'r_Dn', tw.bitResult(tw.r_dir[p][1],release_Down) ,'set')
	charMapSet(p, 'r_Bk', tw.bitResult(tw.r_dir[p][1],release_Left) ,'set')
	charMapSet(p, 'r_Fd', tw.bitResult(tw.r_dir[p][1],release_Right),'set')
end

function tw.setBtn(p,r)
	local pl = p
	if r ~=nil then
		pl=r
	end

	local tr_x = map('_iksys_trainingButtonJam') == 4 and map('jam')>0
	local tr_y = map('_iksys_trainingButtonJam') == 5 and map('jam')>0
	local tr_z = map('_iksys_trainingButtonJam') == 6 and map('jam')>0
	local tr_w = map('_iksys_trainingButtonJam') == 9 and map('jam')>0
	local tr_a = map('_iksys_trainingButtonJam') == 1 and map('jam')>0
	local tr_b = map('_iksys_trainingButtonJam') == 2 and map('jam')>0
	local tr_c = map('_iksys_trainingButtonJam') == 6 and map('jam')>0
	local tr_d = map('_iksys_trainingButtonJam') == 8 and map('jam')>0
	local tr_s = map('_iksys_trainingButtonJam') == 7 and map('jam')>0


	if hptfix[p]>0 then
		hptfix[p]=hptfix[p]-1
	end

	if player(p) and hitpausetime()>0 then
		hptfix[p] = (player(p) and hitpausetime())+1
	end

	tw.m_att[p] = math.floor(tw.m_att[p]/x)

	local buffer_len = #tw.h_att[p]

	if commandGetState(main.t_cmd[pl], 'x') or commandGetState(main.t_cmd[pl], 'hold_x') or tr_x then
		--hold x init 
		tw.h_att[p][buffer_len] = tw.BitOR(tw.h_att[p][buffer_len],x)
	end 

	if commandGetState(main.t_cmd[pl], 'x') or tr_x then
		--x init 
		tw.p_att[p][buffer_len] = tw.BitOR(tw.p_att[p][buffer_len],x)
	end

	if tw.BitAND(tw.p_att[p][1], x) > 0 then
		--mash x init
		tw.m_att[p] = tw.BitOR(tw.m_att[p],x)
	end

	if tw.BitAND(tw.h_att[p][1],x)==0 and tw.BitAND(tw.h_att[p][1],release_x)>0 then
		--release x init 
		tw.r_att[p][1] = tw.BitOR(tw.r_att[p][1],release_x)
	end 


	if commandGetState(main.t_cmd[pl], 'y') or commandGetState(main.t_cmd[pl], 'hold_y') or tr_y then
		--hold y init 
		tw.h_att[p][buffer_len] = tw.BitOR(tw.h_att[p][buffer_len],y)
	end 

	if commandGetState(main.t_cmd[pl], 'y') or tr_y then
		--y init 
		tw.p_att[p][buffer_len] = tw.BitOR(tw.p_att[p][buffer_len],y)
	end

	if tw.BitAND(tw.p_att[p][1], y) > 0 then
		--mash y init
		tw.m_att[p] = tw.BitOR(tw.m_att[p],y)
	end

	if tw.BitAND(tw.h_att[p][1],y)==0 and tw.BitAND(tw.h_att[p][1],release_y)>0 then
		--release y init 
		tw.r_att[p][1] = tw.BitOR(tw.r_att[p][1],release_y)
	end 

	if commandGetState(main.t_cmd[pl], 'z') or commandGetState(main.t_cmd[pl], 'hold_z') or tr_z then
		--hold z init 
		tw.h_att[p][buffer_len] =tw.BitOR(tw.h_att[p][buffer_len],z)
	end 

	if commandGetState(main.t_cmd[pl], 'z') or tr_z  then
		--z init 
		tw.p_att[p][buffer_len] = tw.BitOR(tw.p_att[p][buffer_len],z)
	end

	if tw.BitAND(tw.p_att[p][1], z) > 0 then
		--mash z init
		tw.m_att[p] = tw.BitOR(tw.m_att[p],z)
	end

	if tw.BitAND(tw.h_att[p][1],z)==0 and tw.BitAND(tw.h_att[p][1],release_z)>0 then
		--release z init 
		tw.r_att[p][1] = tw.BitOR(tw.r_att[p][1],release_z)
	end 

	if commandGetState(main.t_cmd[pl], 'w') or commandGetState(main.t_cmd[pl], 'hold_w') or tr_w then
		--hold w init 
		tw.h_att[p][buffer_len] = tw.BitOR(tw.h_att[p][buffer_len],w)
	end

	if commandGetState(main.t_cmd[pl], 'w') or tr_w then
		--w init 
		tw.p_att[p][buffer_len] = tw.BitOR(tw.p_att[p][buffer_len],w)
	end

	if tw.BitAND(tw.p_att[p][1], w) > 0 then
		--mash w init
		tw.m_att[p] = tw.BitOR(tw.m_att[p],x)
	end

	if tw.BitAND(tw.h_att[p][1],w)==0 and tw.BitAND(tw.h_att[p][1],release_w)>0 then
		--release w init 
		tw.r_att[p][buffer_len] = tw.BitOR(tw.r_att[p][buffer_len],release_w)
	end 


	if commandGetState(main.t_cmd[pl], 'start') or commandGetState(main.t_cmd[pl], 'hold_start') or tr_s then
		--hold start init 
		tw.h_att[p][buffer_len] = tw.BitOR(tw.h_att[p][buffer_len],s)
	end 

	if commandGetState(main.t_cmd[pl], 'start') or tr_s then
		--start init 
		tw.p_att[p][buffer_len] = tw.BitOR(tw.p_att[p][buffer_len],s)
	end

	if tw.BitAND(tw.p_att[p][1], s) > 0 then
		--mash start init
		tw.m_att[p] = tw.BitOR(tw.m_att[p],s)
	end

	if tw.BitAND(tw.h_att[p][1],s)==0 and tw.BitAND(tw.h_att[p][1],release_Start)>0 then
		--release start init 
		tw.r_att[p][1] = tw.BitOR(tw.r_att[p][1],release_Start)
	end 


	if commandGetState(main.t_cmd[pl], 'a') or commandGetState(main.t_cmd[pl], 'hold_a') or tr_a then
		--hold a 
		tw.h_att[p][buffer_len] = tw.BitOR(tw.h_att[p][buffer_len],a)
	end

	if commandGetState(main.t_cmd[pl], 'a') or tr_a  then
		--a init 
		tw.p_att[p][buffer_len] = tw.BitOR(tw.p_att[p][buffer_len],a)
	end

	if tw.BitAND(tw.p_att[p][1], a) > 0 then
		--mash a init
		tw.m_att[p] = tw.BitOR(tw.m_att[p],a)
	end

	if tw.BitAND(tw.h_att[p][1],a) == 0 and tw.BitAND(tw.h_att[p][1],release_a) > 0 then
		--release a
		tw.r_att[p][1] = tw.BitOR(tw.r_att[p][1],release_a)
	end

	if commandGetState(main.t_cmd[pl], 'b') or commandGetState(main.t_cmd[pl], 'hold_b') or tr_b then
		--hold b
		tw.h_att[p][buffer_len] = tw.BitOR(tw.h_att[p][buffer_len],b)
	end

	if commandGetState(main.t_cmd[pl], 'b') or tr_b then
		--b init 
		tw.p_att[p][buffer_len] = tw.BitOR(tw.p_att[p][buffer_len],b)
	end

	if tw.BitAND(tw.p_att[p][1], b) > 0 then
		--mash b init
		tw.m_att[p] = tw.BitOR(tw.m_att[p],b)
	end

	if tw.BitAND(tw.h_att[p][1],b) == 0 and tw.BitAND(tw.h_att[p][1],release_b) > 0 then
		--release b
		tw.r_att[p][1] = tw.BitOR(tw.r_att[p][1],release_b)
	end 

	if  commandGetState(main.t_cmd[pl], 'c') or commandGetState(main.t_cmd[pl], 'hold_c') or tr_c then
		--hold c
		tw.h_att[p][buffer_len] = tw.BitOR(tw.h_att[p][buffer_len],c)
	end

	if commandGetState(main.t_cmd[pl], 'c') or tr_c then
		--c init 
		tw.p_att[p][buffer_len] = tw.BitOR(tw.p_att[p][buffer_len],c)
	end

	if tw.BitAND(tw.p_att[p][1], c) > 0 then
		--mash c init
		tw.m_att[p] = tw.BitOR(tw.m_att[p],c)
	end

	if tw.BitAND(tw.h_att[p][1],c) == 0 and tw.BitAND(tw.h_att[p][1],release_c)>0 then
		--release c init 
		tw.r_att[p][1] = tw.BitOR(tw.r_att[p][1], release_c)
	end

	if commandGetState(main.t_cmd[pl], 'd') or commandGetState(main.t_cmd[pl], 'hold_d') or tr_d then
		--hold d init 
		tw.h_att[p][buffer_len] = tw.BitOR(tw.h_att[p][buffer_len],d)
	end

	if commandGetState(main.t_cmd[pl], 'd') or tr_d then
		--d init 
		tw.p_att[p][buffer_len] = tw.BitOR(tw.p_att[p][buffer_len],d)
	end

	if tw.BitAND(tw.p_att[p][1], d) > 0 then
		--mash d init
		tw.m_att[p] = tw.BitOR(tw.m_att[p],d)
	end

	if tw.BitAND(tw.h_att[p][1],d) == 0 and tw.BitAND(tw.h_att[p][1],release_d) > 0 then
		--release d init 
		tw.r_att[p][1] = tw.BitOR(tw.r_att[p][1],release_d)
	end

end

function tw.setBtnMp(p)
	charMapSet(p, 'x', tw.bitResult(tw.p_att[p][1],x,release_x) ,'set')
	charMapSet(p, 'y', tw.bitResult(tw.p_att[p][1],y,release_y) ,'set')
	charMapSet(p, 'z', tw.bitResult(tw.p_att[p][1],z,release_z) ,'set')
	charMapSet(p, 'w', tw.bitResult(tw.p_att[p][1],w,release_w),'set')
	charMapSet(p, 'a', tw.bitResult(tw.p_att[p][1],a,release_a),'set')
	charMapSet(p, 'b', tw.bitResult(tw.p_att[p][1],b,release_b),'set')
	charMapSet(p, 'c', tw.bitResult(tw.p_att[p][1],c,release_c),'set')
	charMapSet(p, 'd', tw.bitResult(tw.p_att[p][1],d,release_d),'set')

	charMapSet(p, 'u_x', tw.BitAND(tw.p_att[p][1],x) ,'set')
	charMapSet(p, 'u_y', tw.BitAND(tw.p_att[p][1],y) ,'set')
	charMapSet(p, 'u_z', tw.BitAND(tw.p_att[p][1],z) ,'set')
	charMapSet(p, 'u_w', tw.BitAND(tw.p_att[p][1],w),'set')
	charMapSet(p, 'u_a', tw.BitAND(tw.p_att[p][1],a),'set')
	charMapSet(p, 'u_b', tw.BitAND(tw.p_att[p][1],b),'set')
	charMapSet(p, 'u_c', tw.BitAND(tw.p_att[p][1],c),'set')
	charMapSet(p, 'u_d', tw.BitAND(tw.p_att[p][1],d),'set')

	charMapSet(p, 'm_x', tw.bitResult(tw.m_att[p],x,release_x) ,'set')
	charMapSet(p, 'm_y', tw.bitResult(tw.m_att[p],y,release_y) ,'set')
	charMapSet(p, 'm_z', tw.bitResult(tw.m_att[p],z,release_z) ,'set')
	charMapSet(p, 'm_w', tw.bitResult(tw.m_att[p],w,release_w),'set')
	charMapSet(p, 'm_a', tw.bitResult(tw.m_att[p],a,release_a),'set')
	charMapSet(p, 'm_b', tw.bitResult(tw.m_att[p],b,release_b),'set')
	charMapSet(p, 'm_c', tw.bitResult(tw.m_att[p],c,release_c),'set')
	charMapSet(p, 'm_d', tw.bitResult(tw.m_att[p],d,release_d),'set')


	charMapSet(p, 'h_x', tw.bitResult(tw.h_att[p][1],x,release_x),'set')
	charMapSet(p, 'h_y', tw.bitResult(tw.h_att[p][1],y,release_y),'set')
	charMapSet(p, 'h_z', tw.bitResult(tw.h_att[p][1],z,release_z),'set')
	charMapSet(p, 'h_w', tw.bitResult(tw.h_att[p][1],w,release_w),'set')
	charMapSet(p, 'h_a', tw.bitResult(tw.h_att[p][1],a,release_a),'set')
	charMapSet(p, 'h_b', tw.bitResult(tw.h_att[p][1],b,release_b),'set')
	charMapSet(p, 'h_c', tw.bitResult(tw.h_att[p][1],c,release_c),'set')
	charMapSet(p, 'h_d', tw.bitResult(tw.h_att[p][1],d,release_d),'set')
	charMapSet(p, 'r_x', tw.bitResult(tw.r_att[p][1],x,release_x),'set')
	charMapSet(p, 'r_y', tw.bitResult(tw.r_att[p][1],y,release_y),'set')
	charMapSet(p, 'r_z', tw.bitResult(tw.r_att[p][1],z,release_z),'set')
	charMapSet(p, 'r_w', tw.bitResult(tw.r_att[p][1],w,release_w),'set')
	charMapSet(p, 'r_a', tw.bitResult(tw.r_att[p][1],a,release_a),'set')
	charMapSet(p, 'r_b', tw.bitResult(tw.r_att[p][1],b,release_b),'set')
	charMapSet(p, 'r_c', tw.bitResult(tw.r_att[p][1],c,release_c),'set')
	charMapSet(p, 'r_d', tw.bitResult(tw.r_att[p][1],d,release_d),'set')
	charMapSet(p, 's',   tw.bitResult(tw.p_att[p][1],s,release_Start),'set')
	charMapSet(p, 'h_s', tw.bitResult(tw.h_att[p][1],s,release_Start),'set')
	charMapSet(p, 'r_s', tw.bitResult(tw.r_att[p][1],s,release_Start),'set')

	charMapSet(p, 'xy', tw.bitResult2(tw.bitResult(tw.p_att[p][1],x,release_x),tw.bitResult(tw.p_att[p][1],y,release_y)) ,'set')
	charMapSet(p, 'yz', tw.bitResult2(tw.bitResult(tw.p_att[p][1],y,release_y),tw.bitResult(tw.p_att[p][1],z,release_z)) ,'set')
	charMapSet(p, 'xz', tw.bitResult2(tw.bitResult(tw.p_att[p][1],x,release_x),tw.bitResult(tw.p_att[p][1],z,release_z)) ,'set')
	charMapSet(p, 'ab', tw.bitResult2(tw.bitResult(tw.p_att[p][1],a,release_a),tw.bitResult(tw.p_att[p][1],b,release_b)),'set')
	charMapSet(p, 'bc', tw.bitResult2(tw.bitResult(tw.p_att[p][1],b,release_b),tw.bitResult(tw.p_att[p][1],c,release_c)),'set')
	charMapSet(p, 'ac', tw.bitResult2(tw.bitResult(tw.p_att[p][1],a,release_a),tw.bitResult(tw.p_att[p][1],c,release_c)),'set')
	charMapSet(p, 'xa', tw.bitResult2(tw.bitResult(tw.p_att[p][1],x,release_x),tw.bitResult(tw.p_att[p][1],a,release_a)),'set')
	charMapSet(p, 'yb', tw.bitResult2(tw.bitResult(tw.p_att[p][1],y,release_y),tw.bitResult(tw.p_att[p][1],b,release_b)),'set')
	charMapSet(p, 'bc', tw.bitResult2(tw.bitResult(tw.p_att[p][1],b,release_b),tw.bitResult(tw.p_att[p][1],c,release_c)),'set')
	charMapSet(p, 'zc', tw.bitResult2(tw.bitResult(tw.p_att[p][1],z,release_z),tw.bitResult(tw.p_att[p][1],c,release_c)),'set')
	charMapSet(p, 'cd', tw.bitResult2(tw.bitResult(tw.p_att[p][1],c,release_c),tw.bitResult(tw.p_att[p][1],d,release_d)),'set')
	charMapSet(p, 'zw', tw.bitResult2(tw.bitResult(tw.p_att[p][1],z,release_z),tw.bitResult(tw.p_att[p][1],w,release_w)),'set')
	charMapSet(p, 'wd', tw.bitResult2(tw.bitResult(tw.p_att[p][1],w,release_w),tw.bitResult(tw.p_att[p][1],d,release_d)),'set')
end

function tw.stopRun(p)
	cmd_Activef[p]=false
	cmd_Activeb[p]=false
	--this is dirty, but effective to prevent any command with 66/44 or FF/BB in it explicitly causing issues and pissing me off.
	local fcommands={'i623','i236236','i24862486','i84268426','i632146','i6246','i641236','i236236','i23623','i4123641236','i1632143','i4646','i646'}
	local bcommands={'i421','i214214','i26842684','i86248624','i412364','i4264','i463214','i214214','i21421','i6321463214','i3412361','i6464','i464'}

	for  k, v in pairs(fcommands) do
		if tw.specialbuffer[p][v].b_t >(Bit6*2) then
			--print(v)
			cmd_Activef[p]=true
		end
	end
	for  k, v in pairs(bcommands) do
		if tw.specialbuffer[p][v].b_t >(Bit6*2) then
			cmd_Activeb[p]=true
		end
	end
end


function tw.chargeDir(p,dir,l)
	if (dir[1] ==4 or (l>1 and (dir[2]==5 or dir[3]==6))) and map('tw_B_ChargeReady')>0  then
		return true
	end

	if (dir[1] ==8 or (l>1 and (dir[2]==9 or dir[3]==10))) and map('tw_F_ChargeReady')>0   then
		return true
	end

	if dir[1] ==10 and map('tw_F_ChargeReady')>0 and map('tw_D_ChargeReady')>0 then
		return true
	end

	if (dir[1] ==2 or (l>1 and (dir[2]==6 or dir[3]==10))) and map('tw_D_ChargeReady')>0    then
		return true
	end

	if dir[1] ==6 and map('tw_B_ChargeReady')>0 and map('tw_D_ChargeReady')>0   then
		return true
	end

	return false
end

function tw.checkCorners(p,v,i,im)
	if v==down and (tw.BitAND(tw.p_dir[p][1],p_AllBits)==down or tw.BitAND(tw.p_dir[p][1],p_AllBits)==down+right or tw.BitAND(tw.p_dir[p][1],p_AllBits)==down+left ) then 
		return true
	end

	if v==left and (tw.BitAND(tw.p_dir[p][1],p_AllBits)==left or (tw.BitAND(tw.p_dir[p][1],p_AllBits)==down+left and i<im) or tw.BitAND(tw.p_dir[p][1],p_AllBits)==up+left ) then 
		return true
	end

	if v==right and (tw.BitAND(tw.p_dir[p][1],p_AllBits)==right or (tw.BitAND(tw.p_dir[p][1],p_AllBits)==down+right and i<im) or tw.BitAND(tw.p_dir[p][1],p_AllBits)==up+right ) then 
		return true
	end

	if v==up and (tw.BitAND(tw.p_dir[p][1],p_AllBits)==up or tw.BitAND(tw.p_dir[p][1],p_AllBits)==up+right or tw.BitAND(tw.p_dir[p][1],p_AllBits)==up+left ) then 
		return true
	end

	return false
end

--checks bit value and handles logic accordingly
function tw.validateBit(p,i,v)
	local input_type = tw.specialbuffer[p][i].input_types[v]
	local input = tw.specialbuffer[p][i].inputs[v]

	--a bit greater than 0 means direction
	if input > 0 then
		local res =false
		local res2=false
		player(p) 
		if math.floor(tw.specialbuffer[p][i].b_t/Bit6)==0 then
			local res2=false
			local check_all_buffers = (tw.BitAND(input, p_AllBits) > 0 and tw.BitAND(input, r_AllBits) > 0)

			-- check old style
			if check_all_buffers then
				res = ((tw.BitAND(tw.r_dir[p][1],r_AllBits) == input) or (tw.BitAND(tw.p_dir[p][1],p_AllBits) == input) or (tw.BitAND(tw.h_dir[p][1],p_AllBits) == input) or res2) and (tw.specialbuffer[p][i].charge==nil or map('tw_charge_partition')==1 or (tw.chargeDir(p,tw.specialbuffer[p][i].dir,#tw.specialbuffer[p][i].dir)))

				--leniency on D,U/B,F charges
				return res 
			else
				return tw.handleInputLogic(p, tw.h_dir[p][1], tw.p_dir[p][1], tw.r_dir[p][1], input, input_type, i, false)
			end
		else
			res = tw.handleInputLogic(p, tw.h_dir[p][1], tw.p_dir[p][1], tw.r_dir[p][1], input, input_type, i, false)

			--if charge directions are defined, allow input to use corners of directions.
			if tw.specialbuffer[p][i].dir~=nil and #tw.specialbuffer[p][i].dir>1 or tw.specialbuffer[p][i].rot~=nil  then
				res2 = tw.checkCorners(p,input,v,#tw.specialbuffer[p][i].inputs)
			end

			return res or res2
		end
	-- button input
	else
		--if v > 1 then print('input = ' .. i .. ', v = ' .. tostring(v)) end
		return tw.handleInputLogic(p, tw.h_att[p][1], tw.p_att[p][1], tw.r_att[p][1], input*-1, input_type, i, true)
	end
end

function tw.handleInputLogic(p, h_buf, p_buf, r_buf, input, input_type, k, is_button)
	local res = false
	-- Release
	if input_type == release then
		res = is_button and (tw.BitAND(r_buf, (input > release_d and math.floor(input/x) or input)) > 0) or (tw.BitAND(r_buf, (input > release_Right and math.floor(input/up) or input)) > 0)
	-- Hold
	elseif input_type == hold then
		res = is_button and (tw.BitAND(h_buf, input) > 0) or (tw.BitAND(h_buf, p_AllBits) == input)
	-- Multidirectional
	elseif input_type == multidirectional and not is_button then
		-- We have directions defined
		if tw.specialbuffer[p][k].dir ~= nil and #tw.specialbuffer[p][k].dir > 0 then
			res = (tw.BitAND(h_buf,p_AllBits) == (tw.specialbuffer[p][k].dir[1]*16) or tw.BitAND(h_buf,p_AllBits) == (tw.specialbuffer[p][k].dir[2]*16) or tw.BitAND(h_buf,p_AllBits) == (tw.specialbuffer[p][k].dir[3]*16)) 
		-- Default: assume any direction is fine
		else
			res = (tw.BitAND(h_buf, input) > 0)
		end
	-- Press
	else
		res = is_button and (tw.BitAND(p_buf, p_AllBits_att) == input) or (tw.BitAND(p_buf, p_AllBits) == input)
	end
	return res
end

function tw.checkRotation(p,i)
	--destroy opposite direction by this point.
	if tw.specialbuffer[p]['i62486248'].b_t > tw.specialbuffer[p]['i68426842'].b_t then
		tw.specialbuffer[p]['i68426842'].b_t=0
	end
	if tw.specialbuffer[p]['i62486248'].b_t < tw.specialbuffer[p]['i68426842'].b_t then
		tw.specialbuffer[p]['i62486248'].b_t=0
	end

	if tw.specialbuffer[p]['i24862486'].b_t > tw.specialbuffer[p]['i26842684'].b_t then
		tw.specialbuffer[p]['i26842684'].b_t=0
	end
	if tw.specialbuffer[p]['i24862486'].b_t < tw.specialbuffer[p]['i26842684'].b_t then
		tw.specialbuffer[p]['i24862486'].b_t=0
	end

	if tw.specialbuffer[p]['i48624862'].b_t > tw.specialbuffer[p]['i42684268'].b_t then
		tw.specialbuffer[p]['i42684268'].b_t=0
	end
	if tw.specialbuffer[p]['i48624862'].b_t < tw.specialbuffer[p]['i42684268'].b_t then
		tw.specialbuffer[p]['i48624862'].b_t=0
	end

	if tw.specialbuffer[p]['i86248624'].b_t > tw.specialbuffer[p]['i84268426'].b_t then
		tw.specialbuffer[p]['i84268426'].b_t=0
	end
	if tw.specialbuffer[p]['i86248624'].b_t < tw.specialbuffer[p]['i84268426'].b_t then
		tw.specialbuffer[p]['i86248624'].b_t=0
	end

	if tw.specialbuffer[p]['i6248'].b_t > tw.specialbuffer[p]['i6842'].b_t then
		tw.specialbuffer[p]['i6842'].b_t=0
	end
	if tw.specialbuffer[p]['i6248'].b_t < tw.specialbuffer[p]['i6842'].b_t then
		tw.specialbuffer[p]['i6248'].b_t=0
	end

	if tw.specialbuffer[p]['i2486'].b_t > tw.specialbuffer[p]['i2684'].b_t then
		tw.specialbuffer[p]['i2684'].b_t=0
	end
	if tw.specialbuffer[p]['i2486'].b_t < tw.specialbuffer[p]['i2684'].b_t then
		tw.specialbuffer[p]['i2486'].b_t=0
	end

	if tw.specialbuffer[p]['i4862'].b_t > tw.specialbuffer[p]['i4268'].b_t then
		tw.specialbuffer[p]['i4268'].b_t=0
	end
	if tw.specialbuffer[p]['i4862'].b_t < tw.specialbuffer[p]['i4268'].b_t then
		tw.specialbuffer[p]['i4862'].b_t=0
	end

	if tw.specialbuffer[p]['i8624'].b_t > tw.specialbuffer[p]['i8426'].b_t then
		tw.specialbuffer[p]['i8426'].b_t=0
	end
	if tw.specialbuffer[p]['i8624'].b_t < tw.specialbuffer[p]['i8426'].b_t then
		tw.specialbuffer[p]['i8624'].b_t=0
	end

	if (math.floor(tw.specialbuffer[p]['i62486248'].b_t/Bit6)==8 and math.floor(tw.specialbuffer[p]['i24862486'].b_t/Bit6)<8 and math.floor(tw.specialbuffer[p]['i86248624'].b_t/Bit6)<8 and math.floor(tw.specialbuffer[p]['i48624862'].b_t/Bit6)<8) or (math.floor(tw.specialbuffer[p]['i68426842'].b_t/Bit6)==8 and math.floor(tw.specialbuffer[p]['i26842684'].b_t/Bit6)<8 and math.floor(tw.specialbuffer[p]['i42684268'].b_t/Bit6)<8 and math.floor(tw.specialbuffer[p]['i84268426'].b_t/Bit6)<8) then
		rotset[p]=6
	end
	if (math.floor(tw.specialbuffer[p]['i24862486'].b_t/Bit6)==8 and math.floor(tw.specialbuffer[p]['i62486248'].b_t/Bit6)<8 and math.floor(tw.specialbuffer[p]['i86248624'].b_t/Bit6)<8 and math.floor(tw.specialbuffer[p]['i48624862'].b_t/Bit6)<8) or (math.floor(tw.specialbuffer[p]['i26842684'].b_t/Bit6)==8 and math.floor(tw.specialbuffer[p]['i68426842'].b_t/Bit6)<8 and math.floor(tw.specialbuffer[p]['i42684268'].b_t/Bit6)<8 and math.floor(tw.specialbuffer[p]['i84268426'].b_t/Bit6)<8) then
		rotset[p]=2
	end
	if (math.floor(tw.specialbuffer[p]['i86248624'].b_t/Bit6)==8 and math.floor(tw.specialbuffer[p]['i24862486'].b_t/Bit6)<8 and math.floor(tw.specialbuffer[p]['i62486248'].b_t/Bit6)<8 and math.floor(tw.specialbuffer[p]['i48624862'].b_t/Bit6)<8) or (math.floor(tw.specialbuffer[p]['i84268426'].b_t/Bit6)==8 and math.floor(tw.specialbuffer[p]['i26842684'].b_t/Bit6)<8 and math.floor(tw.specialbuffer[p]['i42684268'].b_t/Bit6)<8 and math.floor(tw.specialbuffer[p]['i68426842'].b_t/Bit6)<8) then
		rotset[p]=8
	end
	if (math.floor(tw.specialbuffer[p]['i48624862'].b_t/Bit6)==8 and math.floor(tw.specialbuffer[p]['i24862486'].b_t/Bit6)<8 and math.floor(tw.specialbuffer[p]['i86248624'].b_t/Bit6)<8 and math.floor(tw.specialbuffer[p]['i62486248'].b_t/Bit6)<8) or (math.floor(tw.specialbuffer[p]['i42684268'].b_t/Bit6)==8 and math.floor(tw.specialbuffer[p]['i26842684'].b_t/Bit6)<8 and math.floor(tw.specialbuffer[p]['i68426842'].b_t/Bit6)<8 and math.floor(tw.specialbuffer[p]['i84268426'].b_t/Bit6)<8) then
		rotset[p]=4
	end

	if (math.floor(tw.specialbuffer[p]['i6248'].b_t/Bit6)==4 and math.floor(tw.specialbuffer[p]['i2486'].b_t/Bit6)<4 and math.floor(tw.specialbuffer[p]['i8624'].b_t/Bit6)<4 and math.floor(tw.specialbuffer[p]['i4862'].b_t/Bit6)<4) or (math.floor(tw.specialbuffer[p]['i6842'].b_t/Bit6)==4 and math.floor(tw.specialbuffer[p]['i2684'].b_t/Bit6)<4 and math.floor(tw.specialbuffer[p]['i4268'].b_t/Bit6)<4 and math.floor(tw.specialbuffer[p]['i8426'].b_t/Bit6)<4) then
		rotset[p]=6
	end
	if (math.floor(tw.specialbuffer[p]['i2486'].b_t/Bit6)==4 and math.floor(tw.specialbuffer[p]['i6248'].b_t/Bit6)<4 and math.floor(tw.specialbuffer[p]['i8624'].b_t/Bit6)<4 and math.floor(tw.specialbuffer[p]['i4862'].b_t/Bit6)<4) or (math.floor(tw.specialbuffer[p]['i2684'].b_t/Bit6)==4 and math.floor(tw.specialbuffer[p]['i6842'].b_t/Bit6)<4 and math.floor(tw.specialbuffer[p]['i4268'].b_t/Bit6)<4 and math.floor(tw.specialbuffer[p]['i8426'].b_t/Bit6)<4) then
		rotset[p]=2
	end
	if (math.floor(tw.specialbuffer[p]['i8624'].b_t/Bit6)==4 and math.floor(tw.specialbuffer[p]['i2486'].b_t/Bit6)<4 and math.floor(tw.specialbuffer[p]['i6248'].b_t/Bit6)<4 and math.floor(tw.specialbuffer[p]['i4862'].b_t/Bit6)<4) or (math.floor(tw.specialbuffer[p]['i8426'].b_t/Bit6)==4 and math.floor(tw.specialbuffer[p]['i2684'].b_t/Bit6)<4 and math.floor(tw.specialbuffer[p]['i4268'].b_t/Bit6)<4 and math.floor(tw.specialbuffer[p]['i6842'].b_t/Bit6)<4) then
		rotset[p]=8
	end
	if (math.floor(tw.specialbuffer[p]['i4862'].b_t/Bit6)==4 and math.floor(tw.specialbuffer[p]['i2486'].b_t/Bit6)<4 and math.floor(tw.specialbuffer[p]['i8624'].b_t/Bit6)<4 and math.floor(tw.specialbuffer[p]['i6248'].b_t/Bit6)<4) or (math.floor(tw.specialbuffer[p]['i4268'].b_t/Bit6)==4 and math.floor(tw.specialbuffer[p]['i2684'].b_t/Bit6)<4 and math.floor(tw.specialbuffer[p]['i6842'].b_t/Bit6)<4 and math.floor(tw.specialbuffer[p]['i8426'].b_t/Bit6)<4) then
		rotset[p]=4
	end
end

function tw.checkRun(p)
	--do this prevent doubled detection on the same frame, which can happen because i fucked up somewhere probably
	local threshold = 8
	local dt1 = tw.defaults[p].dash_times[1]
	local dt2 = tw.defaults[p].dash_times[2]

	for i=1,2 do
		if i==1 then
			if  tw.specialbuffer[p]['i66'].b_t < dt1 and tw.validateBit(p,'i66',i) and cmd_Activef[p]==false then
				tw.specialbuffer[p]['i66'].b_t = dt1 + Bit6
				tw.specialbuffer[p]['i66'].snk_t = 30
			end
			if  tw.specialbuffer[p]['i44'].b_t < dt1 and tw.validateBit(p,'i44',i)and cmd_Activeb[p]==false then
				tw.specialbuffer[p]['i44'].b_t = dt1 + Bit6
				tw.specialbuffer[p]['i44'].snk_t = 30
			end
		else
			if  math.floor(tw.specialbuffer[p]['i66'].b_t/Bit6) == 1 and tw.specialbuffer[p]['i66'].b_t<(Bit6+threshold) and tw.validateBit(p,'i66',i) and cmd_Activef[p]==false then
				tw.specialbuffer[p]['i66'].b_t = dt2 + (Bit6*2)
			end
			if  math.floor(tw.specialbuffer[p]['i44'].b_t/Bit6) == 1 and tw.specialbuffer[p]['i44'].b_t<(Bit6+threshold) and tw.validateBit(p,'i44',i) and cmd_Activeb[p]==false then
				tw.specialbuffer[p]['i44'].b_t = dt2 + (Bit6*2)
			end
		end
	end

	--reset if down
	if tw.BitAND(tw.p_dir[p][1],down)>0 then
		tw.specialbuffer[p]['i44'].b_t=0
		tw.specialbuffer[p]['i66'].b_t=0
	end
end

function tw.checkSpecials(p,input,snk)

	if  tw.specialbuffer[p][input].snk_t > 0 then
		tw.specialbuffer[p][input].snk_t=tw.specialbuffer[p][input].snk_t-1
	end

	-- Only decrement if tw_Assert_NoBufferTimeDec is not set
	if tw.specialbuffer[p][input].b_t > 0 and map('tw_Assert_NoBufferTimeDec') == 0 then
		--Dec
		tw.specialbuffer[p][input].b_t = tw.BitOR(tw.BitXOR(tw.specialbuffer[p][input].b_t,tw.BitAND(tw.specialbuffer[p][input].b_t,15)), tw.BitAND(tw.specialbuffer[p][input].b_t,15)-1)
	end

	for i=1,#tw.specialbuffer[p][input].inputs do
		local tt = type(tw.specialbuffer[p][input].tt) == 'table' and tw.specialbuffer[p][input].tt[i] or tw.specialbuffer[p][input].tt
		-- Run the function if tt is a function type
		if type(tt) == 'function' then tt = tt(p) end
		if tt > 0 then
			--prevent same frame set for multiple same inputs
			local threshold = tt-1
			if i==1 then
				--sequence contains inputs
				if tw.specialbuffer[p][input].b_t <= tt and tw.validateBit(p,input,i) then
					if snk then
						tw.specialbuffer[p][input].b_t = 15 + Bit6
						tw.specialbuffer[p][input].snk_t = 40
					else
						tw.specialbuffer[p][input].b_t = tt + Bit6
					end
					if tw.specialbuffer[p][input].rot ~= nil then
						tw.checkRotation(p,input)
					end
				end
			else
				local input_type = tw.specialbuffer[p][input].input_types[i]
				local curr_step = math.floor(tw.specialbuffer[p][input].b_t/Bit6)
				local bit_validated = tw.validateBit(p,input,i)
				local curr_buf_time = tw.specialbuffer[p][input].b_t
				--sequence contains inputs
				if ((curr_step == (i-1) and bit_validated) and (curr_buf_time<=(Bit6+threshold) or #tw.specialbuffer[p][input].inputs>2)) or (curr_step==i and (curr_buf_time <= ((Bit6*i)+threshold)) and input_type == multidirectional and bit_validated) then
					tw.specialbuffer[p][input].b_t = tt + (Bit6*i)
					if snk then
						tw.specialbuffer[p][input].b_t = 15 + (Bit6*i)
					end
					if tw.specialbuffer[p][input].rot ~= nil then
						tw.checkRotation(p,input)
					end
				end
			end
		-- Break if tt <= 0
		else break end
	end

	if tw.specialbuffer[p][input].b_t > 0 and (tw.BitAND(tw.specialbuffer[p][input].b_t,r_AllBits)==0 or (tw.specialbuffer[p][input].snk_t==0 and snk)) then
		tw.specialbuffer[p][input].b_t = 0
	end

	local curr_seq_num = math.floor(tw.specialbuffer[p][input].b_t/Bit6)

	if (curr_seq_num == #tw.specialbuffer[p][input].inputs and curr_seq_num > 0) then
		if tw.specialbuffer[p][input].rot ~= nil and rotset[p] == tw.specialbuffer[p][input].rot then
			charMapSet(p, tw.specialbuffer[p][input].name, 1,'set')
		elseif tw.specialbuffer[p][input].rot == nil then
			charMapSet(p, tw.specialbuffer[p][input].name, 1,'set')
		end

	else
		if tw.specialbuffer[p][input].rot ~= nil and rotset[p] == tw.specialbuffer[p][input].rot then
			charMapSet(p, tw.specialbuffer[p][input].name, 0,'set')
		elseif tw.specialbuffer[p][input].rot == nil then
			charMapSet(p, tw.specialbuffer[p][input].name, 0,'set')
		end
	end

end


function tw.checkHHS(p)
	local btn6 =  tw.defaults[p].btn6
	local mashpct =  tw.defaults[p].MashPCt
	local mashct = tw.defaults[p].MashCt

	if mashtimer[p]>0 then
		mashtimer[p]=mashtimer[p]-1
	else
		hhsp[p]=0
	end

	if mashtimerk[p]>0 then
		mashtimerk[p]=mashtimerk[p]-1
	else
		hhsk[p]=0
	end
	--i cant be bothered to use my named vars so sue me. Don't touch this shit anyway!
	if (tw.BitAND(tw.m_att[p],3) ==Bit1 or tw.BitAND(tw.m_att[p],3)==Bit2 or tw.BitAND(tw.m_att[p],3)   == Bit1+Bit2) or ((tw.BitAND(tw.m_att[p],7)  ==Bit3 or tw.BitAND(tw.m_att[p],7)  ==Bit1+Bit3 or tw.BitAND(tw.m_att[p],7)  ==Bit3+Bit2 or tw.BitAND(tw.m_att[p],7)  ==Bit3+Bit1+Bit2) and btn6==1) then
	hhsp[p]=hhsp[p]+1
		mashtimer[p] = mashpct
	end

	if (tw.BitAND(tw.m_att[p],48)==Bit5 or tw.BitAND(tw.m_att[p],48)==Bit6 or tw.BitAND(tw.m_att[p],48) == Bit5+Bit6) or ((tw.BitAND(tw.m_att[p],112)==Bit7 or tw.BitAND(tw.m_att[p],112)==Bit5+Bit7 or tw.BitAND(tw.m_att[p],112)==Bit7+Bit6 or tw.BitAND(tw.m_att[p],112)==Bit5+Bit6+Bit7) and btn6==1) then
	hhsk[p]=hhsk[p]+1
		mashtimerk[p] = mashpct
	end

	if mashtimer[p] > 0  and hhsp[p] > mashct then
		charMapSet(p, 'tw_hhsp',  1,'set')
	else
		charMapSet(p, 'tw_hhsp',  0,'set')
	end

	if mashtimerk[p] > 0  and hhsk[p] > mashct then
		charMapSet(p, 'tw_hhsk',  1,'set')
	else
		charMapSet(p, 'tw_hhsk',  0,'set')
	end

end

function tw.resetAlikeBuffers(p, command_name)
	if tw.debug then print('resetting alike buffers for commandName = ' .. command_name) end
	for k,v in pairs(tw.specialbuffer[p]) do
		if v.name == command_name then
			-- Iterate over all alike input keys
			for i,k2 in ipairs(tw.specialbuffer[p][k].alike_inputs) do
				-- Zero out the buffer
				tw.specialbuffer[p][k2].b_t = 0
			end
			break
		end
	end

end

-- Discovers all buffers that have a common substring of 3 consecutive inputs in another buffer
function tw.findAlikeBuffers(p, command_key)
	tw.specialbuffer[p][command_key].alike_inputs = {}
	for i=1,#tw.specialbuffer[p][command_key].inputs-2 do
		local subStr = {unpack(tw.specialbuffer[p][command_key].inputs, i, i+2)}
		if tw.table_length(subStr) == 3 then
			for k,v in pairs(tw.specialbuffer[p]) do
				-- Don't include ourselves, duh
				if k ~= command_key then
					for j=1,#v.inputs-2 do
						local specialSubstr = {unpack(tw.specialbuffer[p][k].inputs, j, j+2)}
						if tw.table_length(specialSubstr) == 3 and tw.is_table_equal(subStr, specialSubstr, true) then
							-- Add to list
							table.insert(tw.specialbuffer[p][command_key].alike_inputs, 1, k)
							break
						end
					end
				end
			end
		end
	end
	if tw.debug then print(serializeTable(tw.specialbuffer[p][command_key].alike_inputs, string.format('tw.specialbuffer[%d][%s].alike_inputs', p, command_key))) end
end

function tw.is_table_equal(o1, o2, ignore_mt)
    if o1 == o2 then return true end
    local o1Type = type(o1)
    local o2Type = type(o2)
    if o1Type ~= o2Type then return false end
    if o1Type ~= 'table' then return false end

    if not ignore_mt then
        local mt1 = getmetatable(o1)
        if mt1 and mt1.__eq then
            --compare using built in method
            return o1 == o2
        end
    end

    local keySet = {}

    for key1, value1 in pairs(o1) do
        local value2 = o2[key1]
        if value2 == nil or tw.is_table_equal(value1, value2, ignore_mt) == false then
            return false
        end
        keySet[key1] = true
    end

    for key2, _ in pairs(o2) do
        if not keySet[key2] then return false end
    end
    return true
end
tw.sntimer=45

tw.specials={
	i62486248  ={name ='f720',b_t=0,snk_t=0,tt={9,9,9,9,9,9,9,8},inputs={right,down,left,up,right,down,left,up},input_types={hold,press,press,press,press,press,press,press},snkonly=0,rot=6},
	i24862486  ={name ='f720',b_t=0,snk_t=0,tt={9,9,9,9,9,9,9,8},inputs={down,left,up,right,down,left,up,up},input_types={hold,press,press,press,press,press,press,press},snkonly=0,rot=2},
	i48624862  ={name ='f720',b_t=0,snk_t=0,tt={9,9,9,9,9,9,9,8},inputs={left,up,right,down,left,up,right,down},input_types={hold,press,press,press,press,press,press,press},snkonly=0,rot=4},
	i86248624  ={name ='f720',b_t=0,snk_t=0,tt={9,9,9,9,9,9,9,8},inputs={up,right,down,left,up,right,down,down},input_types={hold,press,press,press,press,press,press,press},snkonly=0,rot=8},
	i68426842  ={name ='r720',b_t=0,snk_t=0,tt={9,9,9,9,9,9,9,8},inputs={right,up,left, down,right,up,left,down},input_types={hold,press,press,press,press,press,press,press},snkonly=0,rot=6},
	i26842684  ={name ='r720',b_t=0,snk_t=0,tt={9,9,9,9,9,9,9,8},inputs={down,right,up, left,down,right,up,up},input_types={hold,press,press,press,press,press,press,press},snkonly=0,rot=2},
	i42684268  ={name ='r720',b_t=0,snk_t=0,tt={9,9,9,9,9,9,9,8},inputs={left,down,right,up,left,down,right,up},input_types={hold,press,press,press,press,press,press,press},snkonly=0,rot=4},
	i84268426  ={name ='r720',b_t=0,snk_t=0,tt={9,9,9,9,9,9,9,8},inputs={up,left,down,right,up,left,down,down},input_types={hold,press,press,press,press,press,press,press},snkonly=0,rot=8},
	i632146    ={name ='hcbf',b_t=0,snk_t=0,tt=9,inputs={right,right+down,down,down+left,left,right},input_types={hold,press,press,press,press,press},snkonly=-1},
	i6246      ={name ='hcbf',b_t=0,snk_t=0,tt=9,inputs={right,down,left,right},input_types={hold,press,press,press},snkonly=1},
	i412364    ={name ='hcfb',b_t=0,snk_t=0,tt=9,inputs={left,left+down,down,down+right,right,left},input_types={hold,press,press,press,press,press},snkonly=-1},
	i4264      ={name ='hcfb',b_t=0,snk_t=0,tt=9,inputs={left,down,right,left},input_types={hold,press,press,press},snkonly=1},
	i641236    ={name ='Fhcf',b_t=0,snk_t=0,tt=9,inputs={right,left,left+down,down,down+right,right},input_types={hold,press,press,press,press,press},snkonly=-1},
	i6426      ={name ='Fhcf',b_t=0,snk_t=0,tt=9,inputs={right,left,down,right},input_types={hold,press,press,press},snkonly=1},
	i463214    ={name ='Bhcb',b_t=0,snk_t=0,tt=9,inputs={left,left+down,down,down+right,right,left},input_types={hold,press,press,press,press,press},snkonly=-1},
	i4624      ={name ='Bhcb',b_t=0,snk_t=0,tt=9,inputs={left,down,right,left},input_types={hold,press,press,press},snkonly=1},
	i21421     ={name ='qcbqc',b_t=0,snk_t=0,tt=9,inputs={down,down+left,left,down,down+left},input_types={hold,press,press,press,press},snkonly=0},
	i23623     ={name ='qcfqc',b_t=0,snk_t=0,tt=9,inputs={down,down+right,right,down,down+right},input_types={hold,press,press,press,press},snkonly=0},
	i236236    ={name ='qcfx2',b_t=0,snk_t=0,tt=9,inputs={down,down+right,right,down,down+right,right},input_types={hold,press,press,press,press,press},snkonly=0},
	i214214    ={name ='qcbx2',b_t=0,snk_t=0,tt=9,inputs={down,down+left,left,down,down+left,left},input_types={hold,press,press,press,press,press},snkonly=0},
	i2624      ={name ='qcfhcb',b_t=0,snk_t=0,tt=9,inputs={down,right,down,left},input_types={hold,press,press,press},snkonly=1},
	i23632     ={name ='qcfhcb',b_t=0,snk_t=0,tt={9,9,9,9,9,8},inputs={down,down+right,right,down+right,down,down+left},input_types={hold,press,press,press,press,press},snkonly=-1},
	i2426      ={name ='qcbhcf',b_t=0,snk_t=0,tt=9,inputs={down,left,down,right},input_types={hold,press,press,press},snkonly=1},
	i21412     ={name ='qcbhcf',b_t=0,snk_t=0,tt={9,9,9,9,9,8},inputs={down,down+left,left,down+left,down,down+right},input_types={hold,press,press,press,press,press},snkonly=-1},
	i6321463214={name ='hcbx2',b_t=0,snk_t=0,tt=9,inputs={right,down,left,right,down,left},input_types={hold,press,press,press,press,press},snkonly=0},
	i4123641236={name ='hcfx2',b_t=0,snk_t=0,tt=9,inputs={left,down,right,left,down,right},input_types={hold,press,press,press,press,press},snkonly=0},
	i1632143   ={name ='pretz',b_t=0,snk_t=0,tt=9,inputs={left+down,right,right+down,down,down+left,left,down+right},input_types={hold,press,press,press,press,press,press},snkonly=0},
	i3412361   ={name ='rpretz',b_t=0,snk_t=0,tt=9,inputs={right+down,left,left+down,down,down+right,right,down+left},input_types={hold,press,press,press,press,press,press},snkonly=0},
	r_1319     ={name ='jkf',b_t=0,snk_t=0,tt=9,inputs={left+down,down+right,down+left,up+right},input_types={hold,press,press,press},snkonly=0,charge=true,dir={6}},
	r_3137     ={name ='rjkf',b_t=0,snk_t=0,tt=9,inputs={right+down,down+left,down+right,up+left},input_types={hold,press,press,press},snkonly=0,charge=true,dir={10}},
	i6464      ={name ='fbfb',b_t=0,snk_t=0,tt=9,inputs={right,left,right,left},input_types={multidirectional,press,press,press},snkonly=0,charge=true,dir={8,9,10}},
	i4646      ={name ='bfbf',b_t=0,snk_t=0,tt=9,inputs={left,right,left,right},input_types={multidirectional,press,press,press},snkonly=0,charge=true,dir={ 4,5,6}},
	--any input with buttons included are negative
	xx6az      ={name ='SGS6',b_t=0,snk_t=0,tt=9,inputs={x*-1,x*-1,right,a*-1,z*-1},input_types={release,press,press,press,press},snkonly=0},
	xx4az      ={name ='RSGS6',b_t=0,snk_t=0,tt=9,inputs={x*-1,x*-1,left,a*-1,z*-1},input_types={release,press,press,press,press},snkonly=0},
	xx6ay      ={name ='SGS4',b_t=0,snk_t=0,tt=9,inputs={x*-1,x*-1,right,a*-1,y*-1},input_types={release,press,press,press,press},snkonly=0},
	xx4ay      ={name ='RSGS4',b_t=0,snk_t=0,tt=9,inputs={x*-1,x*-1,left,a*-1,y*-1},input_types={release,press,press,press,press},snkonly=0},
	i6248      ={name ='f360',b_t=0,snk_t=0,tt=9,inputs={right,down,left,up},input_types={hold,press,press,press},snkonly=0,rot=6},
	i2486      ={name ='f360',b_t=0,snk_t=0,tt=9,inputs={down,left,up,up},input_types={hold,press,press,press},snkonly=0,rot=2},
	i4862      ={name ='f360',b_t=0,snk_t=0,tt=9,inputs={left,up,right,down},input_types={hold,press,press,press},snkonly=0,rot=4},
	i8624      ={name ='f360',b_t=0,snk_t=0,tt={9,9,9,8},inputs={up,right,down,down},input_types={hold,press,press,press},snkonly=0,rot=8},
	i6842      ={name ='r360',b_t=0,snk_t=0,tt={9,9,9,8},inputs={right,up,left,down},input_types={hold,press,press,press},snkonly=0,rot=6},
	i2684      ={name ='r360',b_t=0,snk_t=0,tt={9,9,9,8},inputs={down,right,up,up},input_types={hold,press,press,press},snkonly=0,rot=2},
	i4268      ={name ='r360',b_t=0,snk_t=0,tt={9,9,9,8},inputs={left,down,right,up},input_types={hold,press,press,press},snkonly=0,rot=4},
	i8426      ={name ='r360',b_t=0,snk_t=0,tt={9,9,9,8},inputs={up,left,down,down},input_types={hold,press,press,press},snkonly=0,rot=8},
	i623       ={name ='dp',b_t=0,snk_t=0,tt=9,inputs={right,down,down+right},input_types={hold,press,press},snkonly=0},
	i421       ={name ='rdp',b_t=0,snk_t=0,tt=9,inputs={left,down,down+left},input_types={hold,press,press},snkonly=0},
	i624       ={name ='hcb',b_t=0,snk_t=0,tt=9,inputs={right,down,left},input_types={hold,press,press},snkonly=0},
	i426       ={name ='hcf',b_t=0,snk_t=0,tt=9,inputs={left,down,right},input_types={hold,press,press},snkonly=0},
	i63214     ={name ='shcb',b_t=0,snk_t=0,tt=9,inputs={right,right+down,down,left+down,left},input_types={hold,press,press,press,press},snkonly=0},
	i61236     ={name ='shcf',b_t=0,snk_t=0,tt=9,inputs={left,left+down,down,right+down,right},input_types={hold,press,press,press,press},snkonly=0},
	i12369     ={name ='tgk',b_t=0,snk_t=0,tt=9,inputs={down+left,down,down+right,right,right+up},input_types={hold,press,press,press,press},snkonly=0},
	i32147     ={name ='rtgk',b_t=0,snk_t=0,tt=9,inputs={down+right,down,down+left,left,left+up},input_types={hold,press,press,press,press},snkonly=0},
	i236       ={name ='qcf',b_t=0,snk_t=0,tt=9,inputs={down,down+right,right},input_types={hold,press,press},snkonly=-1},
	i214       ={name ='qcb',b_t=0,snk_t=0,tt=9,inputs={down,down+left,left},input_types={hold,press,press},snkonly=-1},
	i26        ={name ='qcf',b_t=0,snk_t=0,tt=9,inputs={down,right},input_types={hold,press},snkonly=1},
	i24        ={name ='qcb',b_t=0,snk_t=0,tt=9,inputs={down,left},input_types={hold,press},snkonly=1},
	i632       ={name ='qcd',b_t=0,snk_t=0,tt=9,inputs={right,down+right,down},input_types={hold,press,press},snkonly=0},
	i412       ={name ='rqcd',b_t=0,snk_t=0,tt=9,inputs={left,down+left,down},input_types={hold,press,press},snkonly=0},
	i263       ={name ='mib',b_t=0,snk_t=0,tt=9,inputs={down,right,down+right},input_types={hold,press,press},snkonly=0},
	i241       ={name ='rmib',b_t=0,snk_t=0,tt=9,inputs={down,left,down+left},input_types={hold,press,press},snkonly=0},
	i646       ={name ='fbf',b_t=0,snk_t=0,tt=9,inputs={right,left,right},input_types={hold,press,press},snkonly=0},
	i464       ={name ='bfb',b_t=0,snk_t=0,tt=9,inputs={left,right,left},input_types={hold,press,press},snkonly=0},
	t64        ={name ='tbf',b_t=0,snk_t=0,tt=9,inputs={right,left},input_types={hold,press},snkonly=0},
	t46        ={name ='tfb',b_t=0,snk_t=0,tt=9,inputs={left,right},input_types={hold,press},snkonly=0},
	i64        ={name ='fb',b_t=0,snk_t=0,tt=9,inputs={right,left},input_types={hold,press},snkonly=0,charge=true,dir={8,9,10}},
	i46        ={name ='bf',b_t=0,snk_t=0,tt=9,inputs={left,right},input_types={hold,press},snkonly=0,charge=true,dir={4,5,6}},
	l66        ={name ='lff',b_t=0,snk_t=0,tt=9,inputs={right,right},input_types={hold,press},snkonly=0},
	l44        ={name ='lbb',b_t=0,snk_t=0,tt=9,inputs={left,left},input_types={hold,press},snkonly=0},
	i66        ={name ='ff',b_t=0,snk_t=0,tt=9,inputs={release_Right,right},input_types={release,press},snkonly=0},
	i44        ={name ='bb',b_t=0,snk_t=0,tt=9,inputs={release_Left,left},input_types={release,press},snkonly=0},
	i28        ={name ='cdu',b_t=0,snk_t=0,tt=9,inputs={down,up},input_types={hold,press},snkonly=0,charge=true,dir={2,6,10}},
}

hook.add("loop", "tw", tw.start)
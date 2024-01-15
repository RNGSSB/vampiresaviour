--#region BASIC FUNCTIONS

-- Deep copies a table
--@return a new deep copy of the provided table
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

--Determines if we can move at all (for basics)
--@return boolean
function canMove(p)
	player(p)
	local stateNo = stateno() -- so we're not calling it 6000 times
	return ctrl() or (stateNo==100 and animelemtime(2) > 1) or
	stateNo==101
end

--Determines if we can move at all (for specials)
--@return boolean
function canMoveSpecial(p)
	player(p)
	local stateNo = stateno() -- so we're not calling it 6000 times
	return ctrl() or (stateNo==100 and animelemtime(2) > 1) or
	stateNo==101 or stateNo==40  or (stateNo==52 and anim()==47 and time() >= 2)
end

--Determines if we can whiff cancel
--@return boolean
function canWhiffCancel(p)
	player(p)
	local canMove = canMoveSpecial(p)
	local stateNo = stateno() -- so we're not calling it 6000 times
	return canMove or time() < 4 and ((stateNo >= 200 and stateNo <= 299) or (stateNo >= 400 and stateNo <= 499))
end

--#region Cancels

-- Define special cancel states and their first inactive frames here.
-- The attack will no longer be able to cancel once animelemtime(inactive_frame) >= 0
--
-- Fields:
--stateNo - the stateNo the cancel is legal from.
--inactive_frame - the number of the first animelem after the last animelem of the first hitting attack box.
--                 A function(p) that always returns an int indicating the frame value can also be supplied
--                 here to provide conditional logic (such as handling proximity normals in the same state).
--limiter - boolean limiter function, functions the same way as the stateNo table below.
local cancelTable = {
	ground = {},
	air = {}
}

local cancel_states = {
	special_cancels = deepcopy(cancelTable),
	super_cancels = deepcopy(cancelTable),
	renda_states = {}
}

player_cancels = {
	deepcopy(cancel_states),
	deepcopy(cancel_states),
	deepcopy(cancel_states),
	deepcopy(cancel_states)
}
--#endregion

-- Checks cancel tables
--@return boolean
function checkCancels(p, t, stateNo)
	local can_cancel = false

	-- Don't do anything if the table is nil
	if t ~= nil then
		local is_air = statetype() == 'A'
		local cancel_table = is_air and t.air or t.ground

		-- Again, don't do anything if the table is nil
		if cancel_table ~= nil then
			for _,v in ipairs(cancel_table) do
				local f = nil
				if v.inactive_frame ~= nil then
					-- If it's a function, run it
					if type(v.inactive_frame) == 'function' then
						f = v.inactive_frame(p)
					-- Otherwise, it's a raw frame
					else
						f = v.inactive_frame
					end
				end
				if stateNo == v.stateNo and (not f or animelemtime(f) < 0) and
				(not v.limiter or v.limiter(p) == true) then
					can_cancel = true
					break
				end
			end
		end
	end
	return can_cancel
end

-- Special cancel function
--@return boolean
function canSpecialCancel(p)
	player(p)
	local canWC = canWhiffCancel(p)
	local canSC = canWC or checkCancels(p, player_cancels[p].special_cancels, stateno())
	return canSC
end

-- Super cancel function
--@return boolean
function canSuperCancel(p)
	player(p)
	local canSC = canSpecialCancel(p)
	return canSC or checkCancels(p, player_cancels[p].super_cancels, stateno())
end

-- Determines if we can perform a Full Power technique
--@return boolean
function fpSkillLimiter(p)
	player(p)
	if power() >= 1000 then
		-- Not holding down and we can special cancel?
		return map('h_Dn')==0 and canSuperCancel(p)
	end
	return false
end

-- Determines if we can perform a Lvl.2 super
--@return boolean
function lvl2SuperLimiter(p)
	player(p)
	if power() >= 2000 then
		-- We can super cancel?
		return canSuperCancel(p)
	end
	return false
end

-- Determines if we can perform a Full Power super (Lvl. 3)
--@return boolean
function fpSuperLimiter(p)
	player(p)
	if power() >= 3000 then
		-- We can super cancel?
		return canSuperCancel(p)
	end
	return false
end

-- shit in Lua works exactly like you'd expect, so we can use this
-- to make some reasonable predictions
--@return integer
function predictState(p)
	-- Default implementation to prevent crashing
	return -1
end

-- Power limiter function.
--@return boolean
function powerLimiter(p)
	player(p)
	if power() >= 1000 then
		-- Can we super cancel?
		return canSuperCancel(p)
	end
	return false
end

-- Determines if a Hunter chain is possible
--@return boolean
function canChain(p)
	player(p)
	local target_state_no = predictState(p)
	local stateNo = stateno()
	local can_move = canMove(p)
	if can_move then return true end
	-- Don't chain specials or anything like that
	if stateNo < 800 and stateNo ~= 300 then
		if target_state_no > -1 then
			-- Make sure we can only chain states [200,299], [400,499], and [600,699]
			if target_state_no < 700 and (math.floor(target_state_no/100)%2) == 0  then
				-- Get the target stateNo info
				local trgt_state_mod = target_state_no%100
				-- Get the current stateNo info
				local curr_state_mod = stateNo%100
				local is_ascending = false

				-- Strength must be rising as a whole
				if trgt_state_mod >= 50 and trgt_state_mod <= 69 then
					is_ascending = (curr_state_mod >= 0 and curr_state_mod <= 49)
				elseif trgt_state_mod >= 40 and trgt_state_mod <= 49 then
					is_ascending = (curr_state_mod >= 0 and curr_state_mod <= 19) or (curr_state_mod >= 30 and curr_state_mod <= 39)
				elseif trgt_state_mod >= 30 and trgt_state_mod <= 39 then
					is_ascending = (curr_state_mod >= 0 and curr_state_mod <= 9)
				elseif trgt_state_mod >= 20 and trgt_state_mod <= 29 then
					is_ascending = (curr_state_mod >= 0 and curr_state_mod <= 19) or (curr_state_mod >= 30 and curr_state_mod <= 49)
				elseif trgt_state_mod >= 10 and trgt_state_mod <= 19 then
					is_ascending = (curr_state_mod >= 0 and curr_state_mod <= 9) or (curr_state_mod >= 30 and curr_state_mod <= 39)
				end

				local move_contact = movecontact() == 1
				local is_throw = hitdefattr():match('T') ~= nil

				if is_throw then return false end

				if is_ascending then
					return move_contact
				else
					return stateNo == target_state_no and trgt_state_mod < 10 and move_contact
				end
			end
		end
	end
	return false
end

-- for determining renda cancels
--@return boolean
function canRenda(p)
	player(p)
	local target_state_no = predictState(p)
	local stateNo = stateno()
	local can_move = canMove(p)

	-- Just return true if we can already move
	if can_move then return true end

	-- Compare them all
	for _,trgt_state in ipairs(player_cancels[p].renda_states) do
		if target_state_no==trgt_state then
			for _,curr_state in ipairs(player_cancels[p].renda_states) do
				if stateNo==curr_state then return time() > 3 end
			end
		end
	end
	return false
end
--#endregion
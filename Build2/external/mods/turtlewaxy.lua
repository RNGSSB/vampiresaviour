tw.extraspecials = {
	--if you need to define your own specials, this is the place to do it.
	--the following parameters are accepted:
	--
	--name - this will name the map sent to the character to be checked
	--
	--b_t - required, always 0
	--
	--snk_t - required, always 0
	--
	--tt - time in frames for each input defined in inputs{}. Do not set higher than 31 or the command won't work.
	--     This can either be a table of values such as tt={9,9,9,8} or a single value such as tt=15. If a single value is
	--     specified, then TW will use that same time for all inputs in the command, otherwise the length of the tt table
	--     must match the number of elements in inputs exactly or the script may error. A function that takes an integer, p
	--     (the player index) as its only argument may also be specified for each input, but the function must return an
	--     integer value.
	--
	--input_types - required, denotes the input type, must be the same length as inputs, allows the following values:
	--              tw.press, tw.hold, tw.release, and tw.multidirectional (multitidirectional is for directional inputs only)
	--
	--inputs = allows the following values assuming the character is facing right:
	--
	--if the input involves pressing or holding: tw.up, tw.down, tw.left, tw.right,tw.x,tw.y,tw.z,tw.w,tw.a,tw.b,tw.c,tw.d
	--if the input involves releasing: tw.release_up,tw.release_down,tw.release_left,tw.release_right,tw.release_x,tw.release_y,tw.release_z,tw.release_w,tw.release_a,tw.release_b,tw.release_c,tw.release_d
	--you can combine them if you want to check diagonal inputs IE DF,DB,UF,UB
	--		this is an example of DB,DF,DB,UF
	--		inputname={name ='rjkf',b_t=0,snk_t=0,tt=15,inputs={tw.right+tw.down,tw.down+tw.left,tw.down+tw.right,tw.up+tw.left},input_types={tw.hold,tw.press,tw.press,tw.press},snkonly=0,charge=true,dir={10}}
    --
	--snkonly - if set to 1, this input will only be checked if Buffer_Snk is set to 1.
	--
	--charge - if set to true, it will be given leniency as a charge motion allowing DB and UB to be checked as well if the input is B. Example below:
	--
	--	i46={name ='bf',b_t=0,snk_t=0,tt=15,inputs={tw.release_left,tw.right},input_types={tw.release,tw.press},snkonly=0,charge=true,dir={4,5,6}},
	--
	--dir - if the input is a charge, it will check this set of values in addition to the first input defined on the input{} set:
	--		1 - U,2 - D,4 - B,8 - F,5 - UB,9 - UF,6 - DB,10 - DF
	i2 = { name = 'longjump', b_t = 0, snk_t = 0, tt = 9, inputs = { tw.down }, input_types = { tw.press }, snkonly = 0 },
	i61 = { name = 'fdb', b_t = 0, snk_t = 0, tt = 15, inputs = { tw.right, tw.left + tw.down }, input_types = { tw.multidirectional, tw.press }, snkonly = 0, charge = true, dir = { 8, 9, 10 } },
	i43 = { name = 'bdf', b_t = 0, snk_t = 0, tt = 15, inputs = { tw.left, tw.right + tw.down }, input_types = { tw.multidirectional, tw.press }, snkonly = 0, charge = true, dir = { 4, 5, 6 } },
	iMshz = { name = 'mash_z', b_t = 0, snk_t = 0, tt = 10, inputs = { tw.z * -1, tw.z * -1, tw.z * -1 }, input_types = { tw.press, tw.press, tw.press }, snkonly = 0 },
	i22 = { name = 'dd', b_t = 0, snk_t = 0, tt = 12, inputs = { tw.down, tw.down }, input_types = { tw.press, tw.press }, snkonly = 0 },
}

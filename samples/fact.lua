--[====[
	Sample program in Lua language
	Computes factorial
--]====]

x = tonumber(io.read()) -- Input an integer
if 0 < x then -- Don't compute if x <= 0
	fact = 1
	repeat
		fact = fact * x
		x = x - 1
	until x == 0
	io.write(fact, "\n") -- Output factorial of x
end

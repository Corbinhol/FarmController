local component = require("component");




farmWidth = 4;
farmHeight = 5;

local farmX;
function init()
	--Create the table
	farmX = {};
	for i = 0, farmWidth, 1 do
		local farmY = {};
		for t = 0, farmHeight, 1 do --In Each FarmX Slot, Put FarmY Slots.
			farmY[t] = t;
		end
		farmX[i] = farmY;
	end
end
print("Version .1");
local component = require("component");

print("Version .1");


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

init();
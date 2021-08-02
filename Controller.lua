os.execute("clear");

local component = require("component");
local redstoneList = component.list("redstone");
local serialization = require("serialization");
local network = component.modem
local event = require("event");
local filesystem = component.filesystem;

local running = true;

local farmWidth = 4;
local farmHeight = 5;

local addressFile = "addresses.dat";
local addressFileBackup = "addresses_back.dat";

local farmGrid = {};

local ver = "0.0.1";
serverPort = 63;
function file_exists(name)
	local f=io.open(name,"r")
	if f~=nil then io.close(f) return true else return false end
end


function getRedstoneAddress()
	for it, comp in pairs(redstoneList) do
		compont = component.proxy(it);
		for z = 0, 5, 1 do
			if compont.getInput(z) > 0 then
				return it;
			end
		end
	end
	return false;
end


function waitUntilEnter()
	local userInput = io.read()
end

function saveTable(input, file)
	local console = io.stdout;
	local serInput = serialization.serialize(input);
	local fileOut = io.open(file, "w");
	local t = io.output(fileOut);
	io.write(serInput);
	io.close(fileOut);
	io.flush();
	io.stdout = console;
	print("Successful");
	return true;
end

function loadTable(file)
	local fileIn = io.open(file, "r");
	io.input(fileIn);
	local serialIn = io.read();
	io.close(fileIn)
	return serialization.unserialize(serialIn);
end

function init()
local farmX = {};
local file = io.open(addressFile, "w");
	print("Starting Cailibration Process");
	for i = 1, farmWidth, 1 do --Set Each X Coordinate
		local farmY = {};
		for t = 1, farmHeight, 1 do --Set Each Y Coordinate
			local farm = {};
			local test = false;
			
			while test == false do
				print("Please Turn Redstone Signal On, and Press enter");
				print("[" .. i .. "," .. t .. "]");
				waitUntilEnter();
				farm["redstoneAddress"] = getRedstoneAddress();
				farm["redstoneStatus"] = true;
				if farm["redstoneAddress"] == false then
					print("ERROR. No Redstone Signal Found! Going Back.");
				else 
					test = true;
				end
			end
			farmY[t] = farm;
			print("Redstone Address Set To " .. farmY[t]["redstoneAddress"]);
			print("--------------------------------------------------------");
		end
		farmX[i] = farmY;
	end
	local output = serialization.serialize(farmX);
	
	io.output(file);
	io.write(output);
	io.close(file);
	print("Farm Successfully Calibrated!");
end

function load_server()
	print("Version: " .. ver);
	print("Starting Server...");
	print("Loading Farm Data");
	farmGrid = loadTable(addressFile);
	if farmGrid ~= nil then print("Farm Data Successfully Loaded");
	else print("Error Loading Farm Data, Stopping Server"); return false; end
	print("Opening Port " .. serverPort);
	portStat = network.open(serverPort);
	if portStat == false then
		print("Error Opening Port " .. serverPort .. ". Stopping Server");
		return false;
	else
		print("Successfully Opened " .. serverPort .. "!");
	end
	print("Setting Farming Stations");
	for i = 1, farmWidth, 1 do
		for t=1,farmHeight,1 do
			local currentFarm = farmGrid[i][t];
			--local currentIO = component.proxy(currentFarm["redstoneAddress"];
			if currentFarm["redstoneStatus"] == true then
				setRedstoneSignal(i, t, 0);
			else
				setRedstoneSignal(i, t, 15);
			end
		end
	end
	print("Server Successfully Initiated!");
	--print(farmGrid[1][1]["redstoneAddress"]);
	event.listen("interrupted", shutdown);
end

function setRedstoneSignal(x, y, signal)
	redAddress = farmGrid[tonumber(x)][tonumber(y)]["redstoneAddress"];
	local redstoneIO = component.proxy(redAddress);
	redstoneIO.setOutput(2, signal);
	farmGrid[tonumber(x)][tonumber(x)]["redstoneStatus"] = false;
	
	return signal;
end

function shutdown()
	print("Shutting Down Server!");
	network.close(serverPort);
	print("Closed port " .. serverPort);
	print("Creating Backup File Just in case.");
	os.execute("del " .. addressFileBackup);
	os.execute("copy " .. addressFile .. " " .. addressFileBackup);
	os.execute("del " .. addressFile);
	print("Saving Current Configuration...");
	local t = saveTable(farmGrid, addressFile);
	print("Auto Running All Farms");
	for i=1, farmWidth, 1 do
		for t=1, farmHeight, 1 do
			setRedstoneSignal(i, t, 0);
		end
	end
	print("All Farms Enabled!");
	running = false;
	return true;
end

function run_command(command, messageDecoded)
	if command == "disableFarm" then --Disable Farm Command
		local x = messageDecoded[2];
		local y = messageDecoded[3];
		setRedstoneSignal(x, y, 15) return "Disabled [" .. x .. "," .. y .. "]!";
	
	elseif command == "enableFarm" then --Enable Farm Command
		local x = messageDecoded[2];
		local y = messageDecoded[3];
		setRedstoneSignal(x, y, 0) return "Enabled [" .. x .. "," .. y .. "]!";
	
	elseif command == "shutdown" then shutdown() return "Shutting Down Server" 

	
	
	end;
	return "Command Not Found";
end

if file_exists(addressFile) == true then load_server() else init() local loadStat = load_server() end;

if loadStat == false then running = false end

while running == true do
	if running == false then break; end
	print(running);
	print("------------------------");
	print("Waiting For Command...");
	_, _, from, port, _, message = event.pull("modem_message");
	local messageDecoded = serialization.unserialize(message);
	print("Messaged Recieved From " .. from .. ":" .. messageDecoded[1]);
	output = run_command(messageDecoded[1], messageDecoded)
	print(output);
	if output ~= nil then network.send(from, port, output); end;
	messageDecoded = nil;
	_, _, from, port, _, message = nil;
	output = = nil;
	if running == false then break; end
end
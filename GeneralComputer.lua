--Requires:
--Chatbox
--Player Detector

local textFunctions = require("utilities/textFunctions")
local det = peripheral.find("playerDetector")
local chatBox = peripheral.find("chatBox")
local chatBoxName = "General"

chatFunctions = {

	privateMessage = function(text, player)
		local chatMessage = {
			{text = "(Private) ", color = "gray", italic = true},
		}
		chatMessage[2] = text
		chatMessage = textutils.serializeJSON(chatMessage)
		chatBox.sendFormattedMessageToPlayer(chatMessage, player, chatBoxName)
	end

}

functions = {

	ping = function(commands)

		local desiredName = commands[2]
		local registerCaps = commands[3]

		if registerCaps == nil or string.lower(registerCaps) ~= "true" then registerCaps = "false" end

		--No player given
		if desiredName == nil or desiredName == "" then
			chatFunctions.privateMessage({text = "Enter an player username.", color = "red", bold = true}, commands[1])
			return
		end

		local name = ""
		local players = det.getOnlinePlayers()

		if registerCaps == "false" then
			desiredName = string.lower(desiredName)
		end

		for i,v in pairs(players) do
			local compareName = v
			if registerCaps == "false" then 
				compareName = string.lower(v) 
			end
			if string.find(compareName, desiredName) then
				if name == "" or string.len(v) < string.len(name) then
					name = v
				end
			end	
		end

		local table = det.getPlayerPos(name)
		local user = det.getPlayerPos(commands[1])

		if table.x == nil then
			chatFunctions.privateMessage({text = "Invalid username or player is in another dimension.", color = "red", bold = true}, commands[1])
			return
		end

		local distance = math.sqrt((table.x - user.x)^2 + (table.y - user.y)^2 + (table.z - user.z)^2)
		
		chatFunctions.privateMessage({text = "\n" .. name .. ": " .. table.x .. ", " .. table.y .. ", " .. table.z .. "\nDistance: " .. textFunctions.round(distance) .. " Blocks", color = "white", bold = true, italic = false}, commands[1])

	end,

	radar = function(commands)

		local players = det.getPlayersInRange(300)
		local displayedPlayers = ""

		for i,v in pairs(players) do
			if commands[2] == "true" or (v ~= "EnchantedAlchemy" and v ~= "garbloni" and v ~= "LogHammm") then
				displayedPlayers = displayedPlayers .. v .. "\n"
			end
		end

		if displayedPlayers ~= "" then
			chatFunctions.privateMessage({text = "Players within 300 blocks of detector:\n" .. displayedPlayers, color = "white", bold = false, italic = false}, commands[1])
		else
			chatFunctions.privateMessage({text = "No players within 300 blocks of detector.", color = "white", bold = false, italic = false}, commands[1])
		end
		

	end,

	help = function(commands)

		local chatMessage = {}

		if commands[2] ~= "general" then

			chatMessage = {
				{text = "Type \"$help\" followed by one of the following terms to see more info:\n", color = "white"},
				{text = "general\n", color = "white"}, {text = "See info on general commands.\n", color = "yellow"},
				{text = "inv\n", color = "white"}, {text = "See info on inventory manager commands, if you are connected to one.\n", color = "yellow"},
			}

		elseif commands[2] == nil or commands[2] == "" or commands[2] == " "

			chatMessage = {
				{text = "command | ", color = "white"}, {text = "required args.", color = "aqua"}, {text = " | ", color = "white"}, {text = "optional args.\n", color = "yellow"},
				{text = "$ping | ", color = "white"}, {text = "username", color = "aqua"}, {text = " | ", color = "white"}, {text = "registersCapslock\n", color = "yellow"}, {text = "Display the given player's username. Not caps sensitive unless registersCapslock is true.\n", color = "gray"},
				{text = "$radar | ", color = "white"}, {text = "includeFaction\n", color = "yellow"}, {text = "Displays players within 300 blocks of the computer. Does not include Penumbra unless includeFaction is true.\n", color = "gray"},
			}

		end

		chatMessage = textutils.serializeJSON(chatMessage)
		chatBox.sendFormattedMessageToPlayer(chatMessage, commands[1], chatBoxName)

	end

}

while true do

	local event, user, message, uuid, isHidden = os.pullEvent("chat")
	if isHidden and user == "EnchantedAlchemy" or user == "garbloni" or user == "LogHammm" then

		local commands = {}
		
		for s in string.gmatch(message, "[%w:_]+") do
			commands[#commands+1] = s
		end
		
		local mainCommand = commands[1]
		table.remove(commands,1)

		table.insert(commands, 1, user)
		
		if functions[mainCommand] ~= nil then
			functions[mainCommand](commands)
		end
		
	end

end

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
		
		chatFunctions.privateMessage({text = name .. ": " .. table.x .. ", " .. table.y .. ", " .. table.z .. "\nDistance: " .. textFunctions.round(distance) .. " Blocks", color = "white", bold = true, italic = false}, commands[1])

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

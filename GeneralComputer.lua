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
			if commands[2] == "true" or (v ~= "EnchantedAlchemy" and v ~= "garbloni" and v ~= "LogHammm" and v ~= "ToomtHunger") then
				displayedPlayers = displayedPlayers .. v .. "\n"
			end
		end

		if displayedPlayers ~= "" then
			chatFunctions.privateMessage({text = "Players within 300 blocks of detector:\n" .. displayedPlayers, color = "white", bold = false, italic = false}, commands[1])
		else
			chatFunctions.privateMessage({text = "No players within 300 blocks of detector.", color = "white", bold = false, italic = false}, commands[1])
		end
		

	end,

	nearby = function(commands)

		local testRange = 300
		local numNearby = 0

		local player = commands[1]
		local playerInfo = det.getPlayerPos(player)

		local chatMessage = {
			{text = "(Private) ", color = "gray", italic = true}
		}

		for i,v in pairs(det.getOnlinePlayers()) do
			if v ~= player then

				local otherInfo = det.getPlayerPos(v)
				if otherInfo.x ~= nil then  --insure players in other dimensions won't be counted

					local distance = math.sqrt((otherInfo.x - playerInfo.x)^2 + (otherInfo.y - playerInfo.y)^2 + (otherInfo.z - playerInfo.z)^2)

					if distance <= testRange then

						numNearby = numNearby + 1

						print(v)

						chatMessage[#chatMessage + 1] = {text = v..": "..otherInfo.x..", "..otherInfo.y..", "..otherInfo.z.." | Distance: "..distance, color = "white", bold = false, italic = false}

					end

				end

			end
		end

		print(#chatMessage)

		if numNearby > 0 then
			chatMessage[2] = {text = "Players within 300 blocks of you:\n", color = "white", italic = false}
		else
			chatMessage[2] = {text = "No players within 300 blocks of you.", color = "white", italic = false}
		end
		

		chatMessage = textutils.serializeJSON(chatMessage)
		chatBox.sendFormattedMessageToPlayer(chatMessage, player, chatBoxName)

	end,

	announce = function(commands)

		local text = commands
		table.remove(text, 1)
		local textString = ""
		for i,v in pairs(text) do
			textString = textString .. v .. " "
		end

		local chatMessage = {
			{text = textString, color = "dark_purple", bold = true, italic = false}
		}
		chatMessage = textutils.serializeJSON(chatMessage)
		chatBox.sendFormattedMessage(chatMessage, "Penumbra Research Team", "[]", "")

	end,

	help = function(commands)

		local chatMessage = {}

		if commands[2] == nil or commands[2] == "" or commands[2] == " " then

			chatMessage = {
				{text = "Type \"$help\" followed by one of the following terms to see more info:\n", color = "white"},
				{text = "general\n", color = "yellow"}, {text = "See info on general commands.\n", color = "gray"},
				{text = "inv\n", color = "yellow"}, {text = "See info on inventory manager commands.\n", color = "gray"},
			}

		elseif commands[2] == "general" then

			chatMessage = {
				{text = "command | ", color = "white"}, {text = "required args.", color = "aqua"}, {text = " | ", color = "white"}, {text = "optional args.\n", color = "yellow"},
				{text = "$ping | ", color = "white"}, {text = "username", color = "aqua"}, {text = " | ", color = "white"}, {text = "registersCapslock\n", color = "yellow"}, {text = "Display the given player's username. Not caps sensitive unless registersCapslock is true.\n", color = "gray"},
				{text = "$radar | ", color = "white"}, {text = "includeFaction\n", color = "yellow"}, {text = "Displays players within 300 blocks of the computer. Does not include Penumbra unless includeFaction is true.\n", color = "gray"},
				{text = "$announce | ", color = "white"}, {text = "text\n", color = "aqua"}, {text = "Announces a message as the Penumbra Rearch Team.\n", color = "gray"},
			}

		elseif commands[2] == "inv" then

			chatMessage = {
				{text = "command | ", color = "white"}, {text = "required args.", color = "aqua"}, {text = " | ", color = "white"}, {text = "optional args.\n", color = "yellow"},
				{text = "$take | ", color = "white"}, {text = "mod:item_name", color = "aqua"}, {text = " | ", color = "white"}, {text = "quantity\n", color = "yellow"}, {text = "Takes one (or given amount) of the given item if it is in storage.\n", color = "gray"},
				{text = "$store | ", color = "white"}, {text = "quantity\n", color = "yellow"}, {text = "Puts held stack (or given amount) of items in storage.\n", color = "gray"},
				{text = "$del | ", color = "white"}, {text = "quantity\n", color = "yellow"}, {text = "DELETES held stack (or given amount) of items.\n", color = "gray"},
				{text = "$list\n", color = "white"}, {text = "Lists all items in storage\n", color = "gray"}
			}

		end

		chatMessage = textutils.serializeJSON(chatMessage)
		chatBox.sendFormattedMessageToPlayer(chatMessage, commands[1], chatBoxName)

	end

}

while true do

	local event, user, message, uuid, isHidden = os.pullEvent("chat")
	if isHidden and user == "EnchantedAlchemy" or user == "garbloni" or user == "LogHammm" or user == "ToomtHunger" then

		local commands = {}
		
		for s in string.gmatch(message, "[%w%p:_]+") do
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

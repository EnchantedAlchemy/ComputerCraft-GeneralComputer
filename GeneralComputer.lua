local textFunctions = require("utilities/textFunctions")
local det = peripheral.find("playerDetector")
local chatBox = peripheral.find("chatBox")
local chatBoxName = "Ping"

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

		local name = commands[2]

		--No player given
		if name == nil or name == "" then
			chatFunctions.privateMessage({text = "Enter an player username.", color = "red", bold = true}, commands[1])
			return
		end

		local table = det.getPlayerPos(name)
		local user = det.getPlayerPos(commands[1])

		if table.x == nil then
			chatFunctions.privateMessage({text = "Invalid username or player is in another dimension.", color = "red", bold = true}, commands[1])
			return
		end
		
		chatFunctions.privateMessage({text = commands[2] .. ": " .. table.x .. ", " .. table.y .. ", " .. table.z, color = "white", bold = true}, commands[1])
		chatFunctions.privateMessage({text = "Distance: " .. math.sqrt((table.x - user.x)^2 + (table.y - user.y)^2 + (table.z - user.z)^2) .. " Blocks", color = "white", bold = true}, commands[1])

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

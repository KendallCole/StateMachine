local DebugCommands = {}
local TextChatService = game:GetService("TextChatService")
local StateMachine: any = require(script.Parent.Parent:WaitForChild("StateMachine"))
local commands
commands = {
	["/ls"] = function()
		for k, _ in commands do
			print(k)
		end
	end, 
	["/add"] = function(...) 
		local args = {...}
		
		local accum = 0
		
		for _, v in args do
			if tonumber(v) then
				accum += tonumber(v)
			end
		end
		print("sum: ".. accum)
	end,
    ["/states"] = function()
        print(StateMachine:GetStates())
    end,
    ["/heap"] = function()
        print(StateMachine:GetHeap())
    end,
    ["/addstate"] = function(_, StateName, Duration, Override)
        StateMachine:AddState(StateName, tonumber(Duration), Override)
    end
	
}
TextChatService.SendingMessage:Connect(function(msg)
	local message = string.split(msg.Text, " ")
    local command = commands[string.lower(message[1])]
	if command then
		command(table.unpack(message))
	end
end)

return DebugCommands
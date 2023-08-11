local Types = require(script.Parent:WaitForChild("StateMachine").Types) 
local DebugCommands = require(script.DebugCommands)

type StateMachine = Types.StateMachine

local StateMachine = require(script.Parent:WaitForChild("StateMachine")) :: StateMachine
local Enums = StateMachine.States.Enums 
StateMachine.OnStateAdded:Connect(function(AddedStateName: string)
    print("[ADDED]: "..AddedStateName)
end)
StateMachine.OnStateRemoving:Connect(function(AddedStateName: string)
    print("[REMOVED]: "..AddedStateName)
end)
StateMachine:AddState(Enums.ExampleState, 5)
task.wait(3)
StateMachine:RemoveState(Enums.ExampleState)
StateMachine:RemoveState(Enums.ExampleState)
StateMachine:AddState(Enums.BlockerState)
StateMachine:AddState(Enums.ExampleState)
StateMachine:AddState(Enums.ExampleState)
task.wait(3)
StateMachine:RemoveState(Enums.BlockerState)
StateMachine:RemoveState(Enums.ExampleState)
StateMachine:AddState(Enums.ExampleState2,5)
StateMachine:AddState(Enums.StateThatGetsRemovedBySomeoneElse, 5)
StateMachine:Reset()

--     StateMachine:AddState(Enums.ExampleState, 5)
--     task.wait(1)
--     StateMachine:RemoveState(Enums.ExampleState)
--     task.wait(1)
--     StateMachine:AddState("ExampleState1", 5)
--     task.wait(2)


--     StateMachine:AddState("ExampleState2", 7, true)
--     StateMachine:AddState("ExampleState3", 6)
--     StateMachine:AddState("ExampleState4", 5)

-- StateMachine:AddState("ExampleState1", 5)
-- StateMachine:AddState("ExampleState2", 4)
-- StateMachine:AddState("ExampleState3", 3)
-- StateMachine:AddState("ExampleState4", 2)
-- StateMachine:AddState("ExampleState5", 1)
-- StateMachine:AddState("ExampleState6", 0)
--print("Currently in the ExampleState: ", StateMachine:HasState(Enums.ExampleState))
--StateMachine:Reset()
--print("Do I still have the ExampleState: ", StateMachine:HasState(Enums.ExampleState))

--!strict

local States = {}
local Types = require(script.Parent.Types)
type State = Types.State

--Pseudo-enums? Allows for easier auto complete :) 
States.Enums = {
    ["ExampleState"] = "ExampleState",
    ["ExampleState2"] = "ExampleState2",
    ["ExampleState3"] = "ExampleState3",
    ["BlockerState"] = "BlockerState",
    ["StateThatGetsRemovedBySomeoneElse"] = "StateThatGetsRemovedBySomeoneElse"
}

States.BlockerState = {
    Blockers = {},    -- State will not activate if any of these states are currently active
    Bans = {States.Enums.ExampleState},      -- States that are not allowed while in the current state
    Prerequisites = {},      --  These states must be present for it to start 
    Removes = {},   --  Removes these states upon start
    OnEnter = function()        
        print("My enter function works!")
    end,
    
    OnExit = function()
        print("My exit function works!")
    end,

    OnReinvoked = function()
        print("My reinvoked function works!") 
    end,

    WhileActive = function()
        -- while true do
        --     print("I am currently in my blocker state")
        --    -- task.wait(0.1)
        -- end
    end
} :: State

States.ExampleState = {
    Blockers = {},
    Bans = {},    
    Prerequisites = {},
    Removes = {States.Enums.StateThatGetsRemovedBySomeoneElse}, 
    OnEnter = function()        
        print("My enter function works!")
    end,
    
    OnExit = function()
        print("My exit function works!")
        end,

        OnReinvoked = function()
        print("My reinvoked function works!") 
        end,

  
} :: State

States.StateThatGetsRemovedBySomeoneElse = {
    Blockers = {},  
    Prerequisites = {}, 
    Bans = {},      
    Removes = {},   
    
    OnEnter = function()        
        print("My enter function works!")
    end,
    
    OnExit = function()
        print("My exit function works!")
    end,

    OnReinvoked = function()
        print("My reinvoked function works!") 
    end,

} :: State

States.ExampleState1 = table.clone(States.ExampleState)
States.ExampleState2 = table.clone(States.ExampleState)
States.ExampleState3 = table.clone(States.ExampleState)
States.ExampleState4 = table.clone(States.ExampleState)
States.ExampleState5 = table.clone(States.ExampleState)
States.ExampleState6 = table.clone(States.ExampleState)
States.ExampleState7 = table.clone(States.ExampleState)

return table.freeze(States)
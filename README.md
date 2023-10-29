# Non Deterministic State Machine

## Events 
### OnStateAdded 
```lua
StateMachine.OnStateAdded -> (StateName: string)
```
Fires when a new state has been added to the StateMachine’s active states.
***
### OnStateRemoving
```lua
StateMachine.OnStateRemoving -> (StateName: string)
```
Fires when a state has been removed from the StateMachine’s active states
***
### OnStateReinvolked
```lua
StateMachine.OnStateReinvolked -> (StateName: string)
```
Fires when an already active state has been added to the StateMachine’s active states.

## Methods 
### AddState()
```lua
StateMachine:AddState(StateName: string): boolean
```
Attempts to add a given state to the StateMachine’s active states for an infinite duration. 

Returns ```true``` if done successfully, returns ```false``` if the given state is banned, blocked, missing a prerequisites or if the StateMachine is locked. 

```lua
StateMachine:AddState(StateName: string, duration): boolean
```
Attempts to add a given state to the StateMachine’s active states, but with a specified duration. If the given state is already active, the new provided duration will be added on top of the current duration. 

```lua
StateMachine:AddState(StateName: string, duration: number?, overrideQueuedDuration: boolean?): boolean
```
Attempts to add a given state to the StateMachine’s active states. If passed with ```overrideQueuedDuration = true```, the new provided duration will replace the state’s current duration if it is already active. 

***
### RemoveState()
```lua
StateMachine:RemoveState(StateName: string)
```
Attempts to remove a given state from the StateMachine’s active states. 
Will return false if the StateMachine is currently locked.  

***
### HasState()
```lua
StateMachine:HasState(StateName: string): boolean
```
Returns ```true``` is the provided state is currently in the StateMachines’s active list, returns ```false``` otherwise. 

***
### AddBan()
```lua
StateMachine:AddBan(StateName: string): boolean
```
Increments the provided state’s ban number. Returns ```true``` if the operation is successful, ```false``` if the state is already banned using this method, DNE, or if the StateMachine is locked. 

Note: States can be banned using this method, or banned by other states. Any state with more than 1 ban cannot be accessed.

***
### GetBannedStates()
```lua
StateMachine:GetBannedStates(): {[StateName]: number}
```
Returns a dictionary with the keys being the banned state’s name, and the value being the number of entities banning the current state.

***
### RemoveBan()
```lua
StateMachine:RemoveBan(StateName: string): boolean
```
Removes the provided state from the StateMachine’s ban list. Returns ```true``` if the operation is successful, ```false``` if the state is already banned, DNE, or if the StateMachine is locked.

***
### GetTimeUntilExpiration()
```lua
StateMachine:GetTimeUntilExpiration(StateName): number?
```
Returns the time (in seconds) until the provided state expires. Returns nil if the state is not currently active.

***
### SetLocked()
```lua
StateMachine:SetLocked(state: boolean)
```
Locks the StateMachine if ```true``` is passed, unlocks the StateMachine if ```false``` is passed.

***
### IsLocked()
```lua
StateMachine.IsLocked(): boolean
```
Returns ```true``` if the StateMachine is locked, returns false otherwise. 

***
### GetStates()

```lua
StateMachine:GetStates(): {[StateName]: ActiveState}
```
Returns a dictionary of all currently active states with the state name being the key, and the state’s active thread as the value.

***
### Reset()
```lua
StateMachine:Reset()
```
Iterates through all currently active states and removes them. 



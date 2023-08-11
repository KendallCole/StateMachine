--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Heap = require(ReplicatedStorage:WaitForChild("DataStructures"):WaitForChild("Heap"))
local Types = require(script.Types)
type StateName = Types.StateName
type State = Types.State
type StateMachine = Types.StateMachine

local StateMachine = {} :: StateMachine

local function Init()
    StateMachine._BannedStates = {}
    StateMachine._ActiveStates = {} 
    StateMachine.States = require(script.States) :: any
    local function unpackDict(Dict: {any: any}): (any, any) -- Is there a more elegant to get a dict's keys in lua?
        for k, v in pairs(Dict) do
            return k, v
        end
        return 
    end
    local function CompareExperationTime(a: any, b: any) -- Comparitor func used for the heap
        local aName, aTimestamp = unpackDict(a)
        local bName, bTimestamp = unpackDict(b)
        assert(type(aTimestamp)=='number', ("Issue with extracting timestamp from state "..aName))
        assert(type(bTimestamp)=='number', ("Issue with extracting timestamp from state "..bName))
       
        --Always send states with -1 to the bottom of the heap
        if aTimestamp < 0 then
            return true
        end
        if bTimestamp < 0 then
            return false
        end

        if aTimestamp > bTimestamp then
            return true
        else
            return false
        end
    end
    local ActiveStatesHeap: {} = Heap.new(CompareExperationTime)

    local StateAdded: BindableEvent = Instance.new("BindableEvent")
    local StateRemoved: BindableEvent = Instance.new("BindableEvent")

    StateMachine._ActiveStatesHeap = ActiveStatesHeap :: any --@TODO type heap

    StateMachine._StateAdded = StateAdded :: BindableEvent
    StateMachine.OnStateAdded = StateAdded.Event

    StateMachine._StateRemoved = StateRemoved
    StateMachine.OnStateRemoving = StateRemoved.Event 
    --STRATEGY:
    -- 1) Using a min heap (for positive numbers only, ignores -1 for infinity) to see if the current task has expired
    -- 2) If the task has expired, ensure that it is Removed
    task.spawn(function()
        while true do

           
            if StateMachine._ActiveStatesHeap:Size() > 0 then
                local NextExpiredState = StateMachine._ActiveStatesHeap:Peek()
                --print(NextExpiredState)
                local StateName, ExperationTimestamp = unpackDict(NextExpiredState)
                
                if StateMachine._ActiveStates and StateMachine._ActiveStates[StateName] == nil then
                    warn(("State "..StateName.. " no longer exist in _ActiveStates, popping from heap!"))
                    StateMachine._ActiveStatesHeap:Pop()
                    continue
                end
                if ExperationTimestamp < 0 then 
                    RunService.RenderStepped:Wait()
                    continue 
                end
                
                local TimeTillExpired = ExperationTimestamp - tick()
                
                --print(StateName,"expires in", ExperationTimestamp - tick())
                if TimeTillExpired <= 0 then
                    StateMachine._ActiveStatesHeap:Pop()
                    StateMachine:RemoveState(StateName)
                end
            end

            RunService.RenderStepped:Wait()
        end
    end)
end

function StateMachine:AddState(StateName: string, duration: number?, overrideQueuedDuration: boolean?): boolean

    --duration = duration or -1
    local DEFAULT_DURATION = -1
    overrideQueuedDuration = overrideQueuedDuration or false
    duration = (duration or DEFAULT_DURATION)
    assert(type(duration)=='number', "Duration could not be converted to number") -- Helps scilence LSP!
    assert((duration == -1 or duration > 0), "[ERROR] Desired state duration must be <0 OR set to '-1' (aka infinity)")
    
    if self.States[StateName] then
        --Ensure the state isn't blocked
        print(self._BannedStates)
        if self._BannedStates[StateName] and self._BannedStates[StateName] > 0 then
            warn(("Can't enter "..StateName.. " [state is currently banned]"))
            return false
        end
        
        --Ensure prereqs are present
        for _, PrerequisiteName: StateName in ipairs(self.States[StateName].Prerequisites) do
            if self._ActiveStates[PrerequisiteName] == nil then
                warn(("Can't enter "..StateName.. " [missing prereq "..PrerequisiteName.."]"))
                return false
            end
        end


        --Enter or re-involk
        if self._ActiveStates[StateName] ~= nil then
            self.States[StateName].OnReinvoked()

            --Search heap for our state, update the index if found
            for i, heapEntry in StateMachine._ActiveStatesHeap do
                if type(heapEntry) == 'table' and heapEntry[StateName] ~= nil then
                    if overrideQueuedDuration then
                        if duration < 0 then
                            self._ActiveStatesHeap:UpdateIndex(i, {[StateName] = duration}) -- "-1" aka infinite time
                        else
                            self._ActiveStatesHeap:UpdateIndex(i, {[StateName] = tick() + duration})
                        end
                    else
                        
                        local curDuration = self._ActiveStatesHeap[i][StateName] 
                        if curDuration < 0 then
                            warn("Cant add time to -1 duration task")
                        else
                            if duration < 0 then
                                -- Change to "-1" for infinite time in state
                                self._ActiveStatesHeap:UpdateIndex(i, {[StateName] = duration})
                            else

                                self._ActiveStatesHeap:UpdateIndex(i, {[StateName] = curDuration+ duration})
                            end
                        end
                        print("Add to current duration")
                    end                
                    break --Only do once, exit loop! 
                end

            end
           
        else
            self.States[StateName].OnEnter()
            local ExperationTimestamp = if duration >= 0 then tick() + duration else DEFAULT_DURATION
            self._ActiveStates[StateName] = {
                Alive = true
            } :: Types.ActiveState
            StateMachine._ActiveStatesHeap:Insert(
                {[StateName] = ExperationTimestamp} 
                )

            if self.States[StateName].WhileActive ~= nil then
                local NewThread = task.spawn(function()
                    self.States[StateName].WhileActive()
                end)           
                self._ActiveStates[StateName].ActiveTask = NewThread
            end
            self._StateAdded:Fire(StateName)
        end

        --Set bans        
        for _, BanStateName in ipairs(self.States[StateName].Bans) do
            self._BannedStates[BanStateName] = (self._BannedStates[BanStateName] or 0) + 1
        end
    
        --Remove other states
        for _, RemoveName in ipairs(self.States[StateName].Removes) do
            if self._ActiveStates[RemoveName] then
                self:RemoveState(RemoveName)
                print("Auto removed state", RemoveName)
            end
        end
        

        return true
    else
        warn(("Can't enter '"..tostring(StateName).."' [State not found]"))
    end

    return false
end

function StateMachine:RemoveState(StateName: string)
    if self.States[StateName] then
        if self._ActiveStates[StateName] ~= nil then
            if #self.States[StateName].Bans > 0 then
                for _, BanStateName in ipairs(self.States[StateName].Bans) do
                    self._BannedStates[BanStateName] = (self._BannedStates[BanStateName] or 0) - 1
                    if self._BannedStates[BanStateName] < 1 then
                        self._BannedStates[BanStateName] = nil
                    end
                end
            end
            
            if type(self._ActiveStates[StateName].ActiveTask) == 'thread' then
                task.cancel(self._ActiveStates[StateName].ActiveTask)
            end
            self._ActiveStates[StateName] = nil
            self.States[StateName].OnExit()
            self._StateRemoved:Fire(StateName)

            --Search heap and float entry to the top to avoid a stale heap removal
            for i, heapEntry in StateMachine._ActiveStatesHeap do
                if type(heapEntry) == 'table' and heapEntry[StateName] ~= nil then
                    print("Force floating to top")
                    self._ActiveStatesHeap:UpdateIndex(i, {[StateName] = 0})
                    break
                end
            end
        else
            warn(("Can't exit '"..StateName.."' [state not currently active]"))   
        end
    else    
        error(("Can't exit '"..StateName.."' [DNE]"))
    end
end

function StateMachine:HasState(StateName: string): boolean
    return not (self._ActiveStates[StateName] == nil)
end

function StateMachine:GetTimeUntilExpiration(StateName): number?
    if self:HasState(StateName) then
        print(StateMachine._ActiveStatesHeap)
        for i, heapEntry in StateMachine._ActiveStatesHeap do
            if type(heapEntry) == 'table' and heapEntry[StateName] ~= nil then
                return heapEntry[StateName] - tick()
            end
        end
    else
        warn(("State "..StateName.." Not found, returning nil"))
    end
    
    return nil
end

function StateMachine:GetStates()
	return self._ActiveStates
end

function StateMachine:GetHeap()
	return self._ActiveStatesHeap
end

function StateMachine:GetBannedStates()
    return self._BannedStates
end

function StateMachine:Reset()
    for StateName, _ in pairs(self._ActiveStates) do
        self:RemoveState(StateName)
    end
    warn("States reset")
end

Init()
return StateMachine



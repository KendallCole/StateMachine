export type ActiveState = {
    ActiveTask: thread, 
    Alive: boolean
}
export type StateName = string
export type State = {
    Blockers: {StateName},
    Bans: {StateName},
    Removes: {StateName},
    Prerequisites: {StateName},
    OnEnter: () -> (),
    OnExit: () -> (),
    OnReinvoked: () -> (),
    WhileActive: () -> (),
} 
export type StateMachine = {
    States: {
        Enums: {[any]: StateName},
        [StateName]: State     
    },
    _ActiveStatesHeap: any,
    _ActiveStatesUpdates: any, -- {[StateName]: number} Linter not liking this, giving up for now
    _StateAdded: any, --BindableEvent 
    _StateRemoved: any, --BindableEvent 
    _BannedStates: {[StateName]: number},
    _ActiveStates: {[StateName]: ActiveState},
    --Signals
    OnStateRemoving: RBXScriptSignal | any,
    OnStateAdded: RBXScriptSignal | any, 
    --Methods    
    AddState: (StateMachine, StateName, number?, boolean?) -> (),
    RemoveState: (StateMachine, StateName) -> (),
    
    HasState: (StateMachine, StateName) -> boolean,
    Reset: (StateMachine) -> (),
    GetStates: (StateMachine) -> {[StateName]: ActiveState},
    GetHeap: (StateMachine) -> {any},
    GetBannedStates:  (StateMachine) -> {[StateName]: number},
    GetTimeUntilExpiration: (StateMachine, StateName) -> number?
}

return nil
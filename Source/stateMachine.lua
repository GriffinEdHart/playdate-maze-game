
class('StateMachine').extends()

function StateMachine:init(initialState)
    self.states = {}
    self.currentStateName = initialState
    self.currentState = nil
end

function StateMachine:addState(name, state)
    self.states[name] = state
end

function StateMachine:changeState(stateName)
    if self.currentState then
        if self.currentState.exit then
            self.currentState.exit()
        end
    end

    self.currentStateName = stateName
    self.currentState = self.states[stateName]

    if not self.currentState then
        error("State '" .. stateName .. "' does not exist")
    end

    if self.currentState.enter then
        self.currentState:enter()
    end
end

function StateMachine:update(dt)
    if self.currentState and self.currentState.update then
        self.currentState:update(dt)
    end
end

function StateMachine:getCurrentState()
    return self.currentStateName
end


require 'class';

stateHandler = class:new()

function stateHandler:init(states)
  self.states = states
  self.currentState = states[1]
  self.previousState = nil
end
--------------------------------------------------------------------- plugs into main.lua
function stateHandler:draw(dt)

end

function stateHandler:update(dt)
  
end
-----------------------------------------------------------------------------------------
function stateHandler:changeState(new)
  if (new ~= self.currentState) then
    self.previousState = self.currentState
  end
    self.currentState = new
    currentlySelected = camera
end
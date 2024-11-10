local ReplicatedStorage = game:GetService("ReplicatedStorage")
export type MachineState = "Empty" | "In Progress" | "Complete"
export type ObjectState = MachineState
export type ObjectCategory = "Decoration" | "Amenity" 

local ToolData = require(ReplicatedStorage.Data.ToolData)
type LaundryState = ToolData.LaundryState

export type Object = {
    name: string,
    currentLevel: number,
    maxLevel: number,
    cost: number,
    cycleTime: number,
    timeRemaining: number,
    assetName: string,
    model: Model?,
    category : ObjectCategory?
}

export type InteractableObject = Object&{
    state: ObjectState,
    expectedLaundryState : LaundryState,
    nextState : LaundryState,
    prompt: ProximityPrompt?,
    tool : ToolData.ToolInfo?,
}

return {}

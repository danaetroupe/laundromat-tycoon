local ReplicatedStorage = game:GetService("ReplicatedStorage")
export type MachineState = "Empty" | "In Progress" | "Complete"
export type ShelfState = "Empty" | "Full" | "Unfilled"
export type ObjectState = MachineState | ShelfState
export type ObjectCategory = "Decoration" | "Amenity" 

local ToolData = require(ReplicatedStorage.Data.ToolData)
type LaundryState = ToolData.LaundryState
type ToolInfo = ToolData.ToolInfo

export type Object = {
    name: string,
    currentLevel: number,
    maxLevel: number,
    cost: number,
    timeRemaining: number,
    assetName: string,
    model: Model?,
    category : ObjectCategory?
}

export type InteractableObject = Object&{
    state: MachineState,
    expectedLaundryState : LaundryState,
    cycleTime: number,
    nextState : LaundryState,
    prompt: ProximityPrompt?,
    tool : ToolData.ToolInfo?,
}

export type Storage = Object&{
    state : ShelfState,
    addPrompt : ProximityPrompt?,
    takePrompt : ProximityPrompt?,
    spots : {{
        tool : ToolInfo,
        part : Part
    }},
    spotCount : number
}

return {}

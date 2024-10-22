export type MachineState = "Empty" | "In Progress" | "Complete"
export type ObjectState = MachineState

export type Object = {
    name: string,
    currentLevel: number,
    maxLevel: number,
    cost: number,
    cycleTime: number,
    timeRemaining: number,
    assetName: string,
    model: Model?,
}

export type InteractableObject = Object&{
    state: ObjectState,
    prompt: ProximityPrompt?
}

return {}

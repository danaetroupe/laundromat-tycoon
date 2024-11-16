local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILabs = require(ReplicatedStorage.Packages.UILabs)

return {
    controls = {
        Speed = UILabs.Number(5),
        Space = UILabs.Number(3),
        Amenities = UILabs.Number(0),
        Cleanliness = UILabs.Number(5),
        Decorations = UILabs.Number(0)
    },
    render = function(props : UILabs.GenericProps): () -> ()
        local frame = Instance.new("Frame")
        frame.Parent = props.target
        frame.Size = UDim2.fromScale(0.5, 0.5)
        frame.AnchorPoint = Vector2.new(0.5,0.5)
        frame.Position = UDim2.fromScale(0.5,0.5)
    
        return function(): ()
            frame:Destroy()
        end
    end
}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Default = require(script.Parent.Parent)
local UILabs = require(ReplicatedStorage.Packages.UILabs)

return {
    controls = {
        Amount = UILabs.Number(0),
    },
    render = function(props : UILabs.GenericProps)
        local frame = Default.createButtons(script:GetChildren())
        frame.Parent = props.target
    
        local MoneyValue = Instance.new("IntValue")
        MoneyValue.Value = props.controls.Amount
        props.subscribe(function(_values, info)
            UILabs.ListenControl(info.Amount, function(newVal)
                MoneyValue.Value = newVal
            end)
        end)

        local coins = Default.createCoinDisplay(MoneyValue)
        coins.Parent = props.target

        -- Set buttons to greyed out
        Default.changeActive(frame, false)
        Default.changeActive(frame, true, "Build")

        return function()
            frame:Destroy()
            MoneyValue:Destroy()
            coins:Destroy()
        end
    end
}

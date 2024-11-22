local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILabs = require(ReplicatedStorage.Packages.UILabs)

local LoadingScreen = require(script.Parent)

return {
    controls = {
    },
    render = function(props : UILabs.GenericProps)
        local screen = LoadingScreen.Show()
        screen.Parent = props.target

        local buttonFrame, _button = LoadingScreen.ShowButtons()
        buttonFrame.Parent = props.target

        return function()
           screen:Destroy()
           buttonFrame:Destroy()
        end
    end
}
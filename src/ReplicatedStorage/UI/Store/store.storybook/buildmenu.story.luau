local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UILabs = require(ReplicatedStorage.Packages.UILabs)

local Store = require(script.Parent.Parent)

return {
    controls = {
        isBuilding = UILabs.Boolean(true),
        PlayerMoney = UILabs.Number(250)
    },
    render = function(props : UILabs.GenericProps)
        local buildStore = Store.createMenu(props.controls.PlayerMoney)
        buildStore.Parent = props.target

        local keybinds = Store.createBuildKeybinds()
        keybinds.Parent = props.target

        props.subscribe(function(_values, info)
            UILabs.ListenControl(info.PlayerMoney, function(newValue)
                Store.updateIconValues(buildStore, newValue)
            end)

            UILabs.ListenControl(info.isBuilding, function(newValue)
                Store.toggle(buildStore, newValue)
                Store.toggleKeybinds(keybinds,  not newValue)
            end)
        end)

        return function()
           buildStore:Destroy()
        end
    end
}
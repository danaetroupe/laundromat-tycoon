local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Tutorial = require(script.Parent)
local UILabs = require(ReplicatedStorage.Packages.UILabs)

local function show(props : UILabs.GenericProps)
    local Text = Instance.new("StringValue")
    Text.Value = "Welcome to Laundromat Tycoon!"

    local panel = Tutorial.CreatePanel(Text)
    panel.Parent = props.target

    local _unsubscribe = props.subscribe(function(_values, infos)
        local info = infos.Text
        if info.__new ~= info.__old then
            Text.Value = info.__new
        end
    end)

    return function()
        panel:Destroy()
        Text:Destroy()
    end
end

return {
    controls = {
        Text = UILabs.String("")
    },
    render = show
}
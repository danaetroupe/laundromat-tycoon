local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local UILabs = require(ReplicatedStorage.Packages.UILabs)
local Messages = require(script.Parent)

local function show(props : UILabs.GenericProps)
    local message = Messages.createMessage("This is a test.")
    message.Parent = props.target

    local unsubscribe = props.subscribe(function(values, infos)
        local info = infos.Visible
        if info.__new ~= info.__old then
            local transparency = if values.Visible then 0 else 1
            Messages.fade(message, transparency)
        end
    end)

    return function()
        message:Destroy()
    end
end

return {
    controls = {
        Visible = UILabs.Boolean(true)
    },
    render = show
}
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Objects = require(ReplicatedStorage.Data.ObjectData.Objects)
local PlaceObject = require(script.PlaceObject)

local Store = {}


-- Clear UI page for reset
local function clear(panel : Frame)
    for _, icon in panel:GetChildren() do
        if icon:IsA("ImageButton") then
            icon:Destroy()
        end
    end
end

-- Displays store
function Store.show(frame : Frame, icon : ImageButton)
    clear(frame)
    for _, objectName in Objects.GetObjectNames() do
        local button = icon:Clone()
        button.Parent = frame
        --[[
        todo: implement image
        local image = objects.GetProperty(objectName, "image")
        button.Image =  if image then image else button.Image
        ]]
        button.Top.Text = Objects.GetProperty(objectName, "name")
        local cost = Objects.GetProperty(objectName, "cost")
        button.Display.Text = if cost then "$"..cost else "$ERR"
        PlaceObject.Init(button, objectName, frame)
     end
end

-- Quit object placement and end interactions
function Store.hide()
    PlaceObject.quit()
end

return Store
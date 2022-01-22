--[[

THIS SCRIPT IS MADE BY ReelPlum.
You're free to use this minimap for whatever you want. I don't need any credit, but feel free to do so, if you want to.

SETTINGS ARE A CHILD OF THIS SCRIPT. IT'S CONVENIENTLY NAMED "SETTINGS". 

--]]




local Minimap = {}

local Settings = require(script:WaitForChild("Settings"))
local TagController = require(script:WaitForChild("Internal"):WaitForChild("TagController"))

local CollectionService = game:GetService("CollectionService")

local events = script:WaitForChild("Internal"):WaitForChild("Events")
	local updateEvent = events:WaitForChild("Update")


function Minimap:Toggle()
	Settings["Technical"]["Visible"] = not Settings["Technical"]["Visible"]
	
	updateEvent:Fire()
end

function Minimap:Resize(newSize: UDim2)
	if not newSize then
		error("No size was given...")
	end
	
	Settings["Gui"]["mapSize"] = newSize
	
	updateEvent:Fire()
end

function Minimap:Reposition(newPosition: UDim2, newAnchorPoint: Vector2)
	if not newPosition then
		newPosition = Settings["Gui"]["mapPosition"]
	end
	
	if not newAnchorPoint then
		newAnchorPoint = Settings["Gui"]["anchorPoint"]
	end

	Settings["Gui"]["mapPosition"] = newPosition
	Settings["Gui"]["anchorPoint"] = newAnchorPoint

	updateEvent:Fire()
end

function Minimap:AddBlip(obj: BasePart, tagName: string)
	if obj then
		if tostring("tagName") and obj:IsA("BasePart") then
			if TagController:findTag(tagName) then
				CollectionService:AddTag(obj, tagName)
			end
		else
			error("The tag or object is not correct! Check if they're a string and basepart.")
		end
	else
		error("Got no object")
	end
end

function Minimap:RemoveBlip(obj: Instance)
	if obj then
		for _, tag in pairs(CollectionService:GetTags(obj)) do
			if TagController:findTag(tag) then
				CollectionService:RemoveTag(obj, tag)
			end
		end
		
	else
		error("Got no object")
	end
end

function Minimap:ChangeRoundness(newRoundness: UDim)
	if newRoundness then
		if typeof(newRoundness) == "UDim" then
			Settings["Gui"]["mapCornerRoundness"] = newRoundness
			Settings["Gui"]["borderCornerRoundness"] = newRoundness

			updateEvent:Fire()
		end
	end
end

function Minimap:ChangeMap(newMapId: number)
	if newMapId then
		if tonumber(newMapId) then
			Settings["Map"]["mapId"] = newMapId
			
			updateEvent:Fire()
		else
			error("Given map id is not a number")
		end
	else
		error("Got no map id")
	end
end

function Minimap:ChangeMapCenter(newMapCenter: Vector3)
	if newMapCenter then
		if typeof(newMapCenter) == "Vector3" then
			Settings["Map"]["mapCenter"] = newMapCenter
			
			updateEvent:Fire()
		else
			error("Given map center is not a Vector3")
		end
	else
		error("Got no Vector3")
	end
end
return Minimap

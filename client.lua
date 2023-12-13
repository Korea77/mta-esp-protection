--[[
    AUTHOR: KOREA
    
    WORKS ONLY FOR PLAYERS (IT MAY NOT WORKING FOR PLAYERS THAT ARE IN VEHICLE)
    ALSO YOU CAN OPTIMIZE IT BY CREATING 2 TABLES:
        PLAYERS IN 300 RANGE
        PLAYERS > 300 RANGE
        
]]

local pedBodyAttachmennts = {}

local function doesElementHaveBlip(element)
	local attachments = getAttachedElements(element)
	for i = 1, #attachments do
		if getElementType(attachments[i]) == 'blip' then
			return true
		end
	end
	return false
end

local function passSomeBodys(element, x, y, z)
	if doesElementHaveBlip(element) then
		return true
	end
	local bodyParts = pedBodyAttachmennts[element] or {[1] = element}
	for i,v in pairs(bodyParts) do
		local x1, y1, z1 = getElementPosition(v)
		if isLineOfSightClear(x, y, z, x1, y1, z1, true, false, false, true, false, true, true, element) then
			return true
		end
	end
	return false
end

local function duplicateRecordsByX(t, refcords)
	local newT = {}
	for i = 1, refcords do
		for i, v in pairs(t) do
			newT[#newT + 1] = v
		end
	end
	return newT
end
local elementThatWasStreamedIn = {}
local elementBackToStream = {}
local passForSomeMS = {}

addEventHandler("onClientRender", root, function()
	local players = getElementsByType("player")
	local x, y, z = getCameraMatrix(localPlayer)
	for i = 1, #players do
		local player = players[i]
		
		if player ~= localPlayer then

			local x1, y1, z1 = getElementPosition(player)
			if getDistanceBetweenPoints3D(x1, y1, z1, x, y, z) <= 300 then
				setElementStreamable(player, false) -- always streamed it to prevent spam with onClientElementStreamIn
				elementThatWasStreamedIn[player] = getTickCount() + 500
				if (passForSomeMS[player] or 0) > getTickCount() or not passSomeBodys(player, x, y, z) then
					setElementPosition(player, -6000, -6000, z1,true)
                    if (passForSomeMS[player] or 0) < getTickCount()  then
                        passForSomeMS[player] = getTickCount() + 50
                    end
					if not elementBackToStream[player] then elementBackToStream[player] = true end
					-- playersToUpdate[#playersToUpdate + 1] = {v, 'body' }
				elseif elementBackToStream[player] then
					elementBackToStream[player] = nil
					setElementPosition(player, x1, y1, z1, true)
				end
			else
				if elementThatWasStreamedIn[player] then
					if elementThatWasStreamedIn[player] < getTickCount() then
						setElementStreamable(player, true)
						elementThatWasStreamedIn[player] = nil
					end
				else
					setElementStreamable(player, true)
				end
				setElementPosition(player, -6000, -6000, z1, true)
				if not elementBackToStream[player] then elementBackToStream[player] = true end
			end
		end
	end
end)

local function createBodyAttachments(player)
    if pedBodyAttachmennts[player] then return end
    pedBodyAttachmennts[player] = {}
    pedBodyAttachmennts[player]['head'] = createColSphere(0, 0, 0.9, 0.1)
    pedBodyAttachmennts[player]['body'] = createColSphere(0, 0, 0, 0.1)
    pedBodyAttachmennts[player]['-x'] = createColSphere(-0.5, 0, 0, 0.1)
    pedBodyAttachmennts[player]['x'] = createColSphere(0.5, 0, 0, 0.1)
    pedBodyAttachmennts[player]['y'] = createColSphere(0, 0.5, 0, 0.1)
    pedBodyAttachmennts[player]['-y'] = createColSphere(0, -0.5, 0, 0.1)
    pedBodyAttachmennts[player]['torso'] = createColSphere(0, 0, 0.4, 0.1)
    pedBodyAttachmennts[player]['lokieto'] = createColSphere(0.3, 0, 0.4, 0.1)
    for i, vv in pairs(pedBodyAttachmennts[player]) do
        local x, y, z = getElementPosition(vv)
        attachElements(vv, player, x, y, z)
    end

end

local function removeBodyAttachments(player)
    if pedBodyAttachmennts[player] then
        for i, v in pairs(pedBodyAttachmennts[player]) do
            if isElement(v) then destroyElement(v) end
        end
        pedBodyAttachmennts[player] = {}
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()

    for i, v in pairs(getElementsByType("player")) do
        if v ~= localPlayer then
            createBodyAttachments(v)
        end
    end

end)

addEventHandler("onClientPlayerJoin", root, function()
    createBodyAttachments(source)
end)

addEventHandler("onClientPlayerQuit", root, function()
    removeBodyAttachments(source)
end)


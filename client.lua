--  ___         _    ___  _____   __
-- / __| ___ __| |_ |   \| __\ \ / /
-- \__ \/ -_|_-< ' \| |) | _| \ V / 
-- |___/\___/__/_||_|___/|___| \_/  

-- Code by sesh#5567
-- https://github.com/seshborges
-- any problem just call me :)

function dxDrawTextOnElement(TheElement,text,height,distance,R,G,B,alpha,size,font,...)
	local x, y, z = getElementPosition(TheElement)
	local x2, y2, z2 = getCameraMatrix()
	local distance = distance or 20
	local height = height or 1

	if (isLineOfSightClear(x, y, z+2, x2, y2, z2, ...)) then
		local sx, sy = getScreenFromWorldPosition(x, y, z+height)
		if(sx) and (sy) then
			local distanceBetweenPoints = getDistanceBetweenPoints3D(x, y, z, x2, y2, z2)
			if(distanceBetweenPoints < distance) then
				dxDrawText(text, sx+2, sy+2, sx, sy, tocolor(R or 255, G or 255, B or 255, alpha or 255), (size or 1)-(distanceBetweenPoints / distance), font or 'arial', 'center', 'center', false, false, false, true)
			end
		end
	end
end

function isPedAiming(thePedToCheck)
	if isElement(thePedToCheck) then
		if getElementType(thePedToCheck) == "player" or getElementType(thePedToCheck) == "ped" then
			if getPedTask(thePedToCheck, "secondary", 0) == "TASK_SIMPLE_USE_GUN" or isPedDoingGangDriveby(thePedToCheck) then
				return true
			end
		end
	end
	return false
end

setElementData(localPlayer, 'loja.iRobbedTheStore', false)

addEventHandler('onClientPlayerTarget', getRootElement(),
  function (target)
    
  if not target then return end

  if not tostring(getElementType(target)) == 'ped' then
    return
  end

	if not config['ativar roubos'] then return end

	if not isPedAiming(localPlayer) then return end

	if not getElementData(target, 'loja.atendente') then return end

  if getElementData(localPlayer, 'loja.iRobbedTheStore') then
    return
  end

	triggerServerEvent('shop.tryRob', localPlayer, localPlayer, target)

  end
)

function cancelPedDamage()
	cancelEvent()
end
addEventHandler ('onClientPedDamage', getRootElement(), cancelPedDamage )

addEventHandler('onClientRender', getRootElement(),
  function ()
		for i, ped in ipairs(getElementsByType('ped')) do
			if getElementData(ped, 'loja.atendente') then
				dxDrawTextOnElement(ped,
					config.messages['comprar algo no ped'], 
					config.estiloDoTexto.height, 
					config.estiloDoTexto.distance, 
					config.estiloDoTexto.colorR, 
					config.estiloDoTexto.colorG, 
					config.estiloDoTexto.colorB, 
					255, 
					1.3,
					config.estiloDoTexto.font,
					false
				)
			end
		end
  end
)

function dxDrawRoundedRectangle(x, y, width, height, radius, color, postGUI, subPixelPositioning)
  dxDrawRectangle(x+radius, y+radius, width-(radius*2), height-(radius*2), color, postGUI, subPixelPositioning)
  dxDrawCircle(x+radius, y+radius, radius, 180, 270, color, color, 16, 1, postGUI)
  dxDrawCircle(x+radius, (y+height)-radius, radius, 90, 180, color, color, 16, 1, postGUI)
  dxDrawCircle((x+width)-radius, (y+height)-radius, radius, 0, 90, color, color, 16, 1, postGUI)
  dxDrawCircle((x+width)-radius, y+radius, radius, 270, 360, color, color, 16, 1, postGUI)
  dxDrawRectangle(x, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
  dxDrawRectangle(x+radius, y+height-radius, width-(radius*2), radius, color, postGUI, subPixelPositioning)
  dxDrawRectangle(x+width-radius, y+radius, radius, height-(radius*2), color, postGUI, subPixelPositioning)
  dxDrawRectangle(x+radius, y, width-(radius*2), radius, color, postGUI, subPixelPositioning)
end

local screenW, screenH = guiGetScreenSize()
local x, y = (screenW/1368), (screenH/768)

function createDxAndTimer(open)
  theTimers = setTimer(function() removeEventHandler('onClientRender', root, dxLoadingRobbing) end, config["tempo para assaltar uma loja"] + 2000, 1)
  addEventHandler('onClientRender', root, dxLoadingRobbing)
end
addEvent('createDxAndTimer', true)
addEventHandler('createDxAndTimer', localPlayer, createDxAndTimer)

function dxLoadingRobbing()
  if isTimer(theTimers) then
    remaining, executesRemaining, timeInterval = getTimerDetails(theTimers)
    if remaining <= (config["tempo para assaltar uma loja"] / 14) then return end
    dxDrawRoundedRectangle(x*1130, y*700, x*170, y*20, 10, tocolor(0, 0, 0, 111), false)
    -- dxDrawRoundedRectangle(x*1132.5, y*702.5, x*165/config["tempo para assaltar uma loja"]*remaining, y*15, 10, tocolor(255, 0, 0, 111), false)
    dxDrawRoundedRectangle(x*1132.5, y*702.5, x*165/(config["tempo para assaltar uma loja"]+2000)*remaining, y*15, 10, tocolor(255, 0, 0, 111), false)
  end
end

function closeDraw()
  if not isTimer(theTimers) then return end
  killTimer(theTimers)
  removeEventHandler('onClientRender', root, dxLoadingRobbing)
end
addEvent('closeDraw', true)
addEventHandler('closeDraw', localPlayer, closeDraw)
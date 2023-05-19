--  ___         _    ___  _____   __
-- / __| ___ __| |_ |   \| __\ \ / /
-- \__ \/ -_|_-< ' \| |) | _| \ V / 
-- |___/\___/__/_||_|___/|___| \_/  

-- Code by sesh#5567
-- https://github.com/seshborges
-- any problem just call me :)

local ped = {}
local secondPed = {}
local markEnter = {}
local markLeave = {}
local blip = {}
local shopMark = {}
local timeToRobbery = config['tempo para assaltar uma loja']
local shop = config.shops;

for i=1, #shop do

  ped[i] = createPed(shop[i]['skin do atendente'], shop[i].ped[1], shop[i].ped[2], shop[i].ped[3], shop[i].ped[4])
  setElementInterior(ped[i], shop[i].ped[5])
	setElementData(ped[i], 'loja.atendente', true)

  markLeave[i] = createMarker(shop[i].markLeave[1], shop[i].markLeave[2], shop[i].markLeave[3]-1, config.marker['tipo de marcador'], config.marker['tamanho do marcador'], 9, 59, 215, config.marker['opacidade do marcador'])
  setElementInterior(markLeave[i], shop[i].ped[5])

  markEnter[i] = createMarker(shop[i].markEnter[1], shop[i].markEnter[2], shop[i].markEnter[3]-1, config.marker['tipo de marcador'], config.marker['tamanho do marcador'], 9, 59, 215, config.marker['opacidade do marcador'])
  blip[i] = createBlipAttachedTo(markEnter[i], shop[i].blipIconId)

	shopMark[i] = createMarker(shop[i].ped[1], shop[i].ped[2], shop[i].ped[3]-1, 'cylinder', 3, 255, 255, 0, 0)
	setElementInterior(shopMark[i], shop[i].ped[5])
	setElementData(shopMark[i], 'loja.shopMark', true)

  if #shop[i].secondPed > 0 then
    secondPed[i] = createPed(shop[i]['skin do atendente'], shop[i].secondPed[1], shop[i].secondPed[2], shop[i].secondPed[3])
    setElementInterior(secondPed[i], shop[i].ped[5])
    setTimer(setElementFrozen, 100, 1, secondPed[i], true)
    setTimer(setPedAnimation, 200, 1, secondPed[i], 'SHOP', 'SHP_Serve_Idle')
  end

end

function markerHit(source, matchingDimension)
  if getElementType(source) == 'player' and not (isPedInVehicle(source)) then
      for i=1, #shop do
        if isElementWithinMarker(source, markEnter[i]) then
          if shop[i].robbery == true then 
            return exports['Notice']:addNotification(source, shop[i]['mensagem quando o jogador tentar entrar na loja e ela foi assaltada'], 'error') 
          end
          setElementInterior(source, shop[i].ped[5])
          setElementPosition(source, shop[i].markLeave[1], shop[i].markLeave[2] + 2, shop[i].markLeave[3])
          setElementData(source, 'loja.id', shop[i].shopId)
          return
        end
        if isElementWithinMarker(source, markLeave[i]) then
          setElementInterior(source, 0)
          setElementPosition(source, shop[i].teleportLeave[1], shop[i].teleportLeave[2], shop[i].teleportLeave[3])
          setElementRotation(source, 0, 0, shop[i].teleportLeave[4])
          setElementData(source, 'loja.id', false)
          playerIsRobbingAndLeaveShop(source)
          return
        end
      end
  end
end
addEventHandler('onMarkerHit', getRootElement(), markerHit)

function tryRobberyShop(source, target)

  if not config['ativar roubos'] then return end

  setPedAnimations(target, true)

  setElementData(target, 'loja.atendente', false)
  setElementData(source, 'loja.iRobbedTheStore', true)

  local getIdOfShop = getElementData(source, 'loja.id')
  config.shops[getIdOfShop].robbery = true

  setTimer(setPedAnimation, 1500, 1, secondPed[getIdOfShop], 'shop', 'SHP_Rob_HandsUp')

  exports['Notice']:addNotification(source, 'Espere o funcionario entregar o dinheiro.', 'info') 

  setTimer(allowShop, config['delay para realizar outro assalto'], 1, getIdOfShop, target)
  setTimer(allowClientRobbery, config['delay para realizar outro assalto'], 1, source)
  setTimer(robberySuccesful, config['tempo para assaltar uma loja'], 1, source)
  setTimer(callPolice, config['tempo para assaltar uma loja']/4, 1, source, getIdOfShop)

  triggerClientEvent(source, 'createDxAndTimer', source, true)

end
addEvent('shop.tryRob', true)
addEventHandler('shop.tryRob', root, tryRobberyShop)

function allowShop(getIdOfShop, target)
  config.shops[getIdOfShop].robbery = false
  setPedAnimation(target)
  setPedAnimation(secondPed[getIdOfShop], 'SHOP', 'SHP_Serve_Idle')
  setElementData(target, 'loja.atendente', true)
end

function callPolice(source, getIdOfShop)
  exports['Notice']:addNotification(source, 'A Policia foi alertada', 'warning') 
  local mx, my, mz = getElementPosition(markEnter[getIdOfShop])
  local getMarkVictimPosition = { mx, my, mz }
  local getAllPlayers = getElementsByType('player')
  for i, player in ipairs(getAllPlayers) do
    if getElementData(player, 'loja.iRobbedTheStore') then return end
    for i, acl in ipairs(config['acl que irá receber o chamado de roubo']) do
      local playerAccount = getAccountName(getPlayerAccount(player))
      if isObjectInACLGroup( 'user.'..playerAccount, aclGetGroup(acl) ) then
        exports['Notice']:addNotification(player, 'Uma ocorrência de assalto a loja foi feita em '.. getZoneName(getMarkVictimPosition[1], getMarkVictimPosition[2], getMarkVictimPosition[3], false), 'info') 
      end
    end
  end
end

function allowClientRobbery(source)
  setElementData(source, 'loja.iRobbedTheStore', false)
end

function onPlayerQuitRemoveMoney(quitType, reason, responsible)
  removeElementData(source, 'loja.id')
end
addEventHandler('onPlayerQuit', root, onPlayerQuitRemoveMoney)

function playerIsRobbingAndLeaveShop(source)
  if getElementData(source, 'loja.iRobbedTheStore') then
    triggerClientEvent(source, 'closeDraw', source)
  end
end

function robberySuccesful(source)
  if not getElementData(source, 'loja.id') then
    return
  end
  givePlayerMoney(source, 2000)
  setElementData(source, 'loja.imRobbing', false)
  exports['Notice']:addNotification(source, 'O funcionario te entregou todo dinheiro disponível em caixa', 'success') 
end

function setPedAnimations(target, var)
  if not var then
      setPedAnimation(target, '', '')
    return
  end

  setElementFrozen(target, true)
  setTimer(setPedAnimation, 300, 1, target, 'shop', 'SHP_Rob_React')
  setTimer(setPedAnimation, 2600, 1, target, 'shop', 'SHP_Rob_HandsUp')
  setTimer(setPedAnimation, 3200, 1, target, 'shop', 'SHP_Rob_GiveCash')
  setTimer(setPedAnimation, timeToRobbery, 1, target, 'shop', 'SHP_Rob_HandsUp')
  setTimer(setPedAnimation, timeToRobbery*1.5, 1, target, 'ped', 'DUCK_cower')
end

function buySomething()
  
end
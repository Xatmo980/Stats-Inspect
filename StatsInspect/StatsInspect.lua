local config = {}
local GuI = 44332210
local ActivatePlayer = {}


ActivatePlayer.ResurrectPlayer = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then	
		tes3mp.Resurrect(tonumber(pid), 0)
		local HealthBase = tes3mp.GetHealthBase(pid)
		local P = (HealthBase * 50) / 100
		tes3mp.SetHealthCurrent(pid, P)
		tes3mp.SendStatsDynamic(pid)
	end
end

ActivatePlayer.Res = function(pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
		Players[pid]:Resurrect()
	end
end

ActivatePlayer.InspectPlayer = function(eventStatus, pid, cellDescription, objects, players)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then	
		local PlayerPid
		for _, object in pairs(players) do
			PlayerPid = object.pid
		end	
		if Players[PlayerPid] ~= nil and Players[PlayerPid]:IsLoggedIn() then		
			Players[pid].data.targetPid = PlayerPid	
			Players[PlayerPid].data.targetPid = pid	
                        local player = Players[PlayerPid]	
			local IsAlive = tes3mp.GetHealthCurrent(PlayerPid)	
			if IsAlive ~= 0 then
                           local MajN = {}
                           local MinN = {}
                           local MaBase = {}
                           local MiBase = {}
	                   local LvL = player.data.stats.level
                           local Progress = player.data.stats.levelProgress
                           local cHP = math.floor(player.data.stats.healthCurrent)
                           local bHP = math.floor(player.data.stats.healthBase)
                                 for i=0,4 do
                                     MajN[i] = tes3mp.GetSkillName(tes3mp.GetClassMajorSkill(PlayerPid, i))
                                     MaBase[i] = tes3mp.GetSkillBase(PlayerPid, tes3mp.GetClassMajorSkill(PlayerPid, i))
                                     MinN[i] = tes3mp.GetSkillName(tes3mp.GetClassMinorSkill(PlayerPid, i))
                                     MiBase[i] = tes3mp.GetSkillBase(PlayerPid, tes3mp.GetClassMinorSkill(PlayerPid, i))
                                 end
                           local StatsList = "Level " .. LvL .. "\n" .. "Level Progress " .. Progress .. "\n" .. "HP " .. cHP .. "/" .. bHP .. "\n\n" .. "[MajorSkills]" .. "\n" .. MajN[0] .. "(" .. MaBase[0] .. ")" .. "\n" .. MajN[1] .. "(" .. MaBase[1] .. ")" .. "\n" .. MajN[2] .. "(" .. MaBase[2] .. ")" .. "\n" .. MajN[3] .. "(" .. MaBase[3] .. ")" .. "\n" .. MajN[4] .. "(" .. MaBase[4] .. ")" .. "\n\n" .. "[MinorSkills]" .. "\n" .. MinN[0] .. "(" .. MiBase[0] .. ")" ..  "\n" .. MinN[1].. "(" .. MiBase[1] .. ")" .. "\n" .. MinN[2].. "(" .. MiBase[2] .. ")" .. "\n" .. MinN[3].. "(" .. MiBase[3] .. ")" .. "\n" .. MinN[4] .. "(" .. MiBase[4] .. ")"
                           tes3mp.CustomMessageBox(pid, GuI, StatsList, "Ok")
                        else
			   Players[pid].currentCustomMenu = "resurrect player"
			   menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)		
                          -- tes3mp.CustomMessageBox(pid, GuI, "This Dude is Dead Bro", "Ok")
                        end

		end
	end
end

ActivatePlayer.ResurrectCheck = function(eventStatus, pid)
	ActivatePlayer.ResurrectProcess(pid)
	return customEventHooks.makeEventStatus(false,false)	
end	

ActivatePlayer.ResurrectProcess = function(pid)	
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then	
		if DragonDoor then
			DragonDoor.OnPlayerConnect(true, pid)
		end	
		local currentResurrectType
		if config.respawnAtImperialShrine == true then
			if config.respawnAtTribunalTemple == true then
				if math.random() > 0.5 then
					currentResurrectType = enumerations.resurrect.IMPERIAL_SHRINE
				else
					currentResurrectType = enumerations.resurrect.TRIBUNAL_TEMPLE
				end
			else
				currentResurrectType = enumerations.resurrect.IMPERIAL_SHRINE
			end
		elseif config.respawnAtTribunalTemple == true then
			currentResurrectType = enumerations.resurrect.TRIBUNAL_TEMPLE
		elseif config.defaultRespawnCell ~= nil then
			currentResurrectType = enumerations.resurrect.REGULAR
			tes3mp.SetCell(pid, config.defaultRespawnCell)
			tes3mp.SendCell(pid)
			if config.defaultRespawnPos ~= nil and config.defaultRespawnRot ~= nil then
				tes3mp.SetPos(pid, config.defaultRespawnPos[1], config.defaultRespawnPos[2], config.defaultRespawnPos[3])
				tes3mp.SetRot(pid, config.defaultRespawnRot[1], config.defaultRespawnRot[2])
				tes3mp.SendPos(pid)
			end
		end
		local message = "You have been revived"
		if currentResurrectType == enumerations.resurrect.IMPERIAL_SHRINE then
			message = message .. " at the nearest shrine"
		elseif currentResurrectType == enumerations.resurrect.TRIBUNAL_TEMPLE then
			message = message .. " to the nearest temple"
		end
		message = message .. ".\n"
		if Players[pid].data.shapeshift.isWerewolf == true then
			Players[pid]:SetWerewolfState(false)
		end
		contentFixer.UnequipDeadlyItems(pid)
		tes3mp.Resurrect(pid, currentResurrectType)
		tes3mp.SendMessage(pid, message, false)
	end
end

ActivatePlayer.OnDeathTime = function(eventStatus, pid)
	if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then 
		return customEventHooks.makeEventStatus(false,true)
	end
end

ActivatePlayer.DeathTimeExpiration = function(eventStatus, pid)
	if eventStatus.validCustomHandlers then
		if Players[pid] ~= nil and Players[pid]:IsLoggedIn() then
			  Players[pid].currentCustomMenu = "resurrect"
			  menuHelper.DisplayMenu(pid, Players[pid].currentCustomMenu)		
	        end
	end
end

customEventHooks.registerHandler("OnObjectActivate", ActivatePlayer.InspectPlayer)
customEventHooks.registerValidator("OnPlayerResurrect", ActivatePlayer.ResurrectCheck)
customEventHooks.registerHandler("OnDeathTimeExpiration", ActivatePlayer.DeathTimeExpiration)
customEventHooks.registerValidator("OnDeathTimeExpiration", ActivatePlayer.OnDeathTime)
customCommandHooks.registerCommand("resurrect", ActivatePlayer.Res)

return ActivatePlayer

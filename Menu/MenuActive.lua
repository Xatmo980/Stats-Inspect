local GoldCost = 500 -- The amount of gold you want to charge for Resurrection

Menus["resurrect player"] = {
    text = color.White.."Do you want to "..color.Gold..
    "help\n"..color.White.."this person? it will cost you " .. GoldCost .. " gold",
    buttons = {						
        { caption = "Patch them up.",
            destinations = {
                         menuHelper.destinations.setDefault("You lack the Gold"),
                         menuHelper.destinations.setConditional("Success",
                         {
                          menuHelper.conditions.requireItem("gold_001", GoldCost)
                         },
                         {
                          menuHelper.effects.removeItem("gold_001", GoldCost),
	                      menuHelper.effects.runGlobalFunction("ActivatePlayer", "ResurrectPlayer", 
			            {menuHelper.variables.currentPlayerDataVariable("targetPid")})
                        })
            }
        },			
        { caption = "Leave them there.", destinations = nil }
    }
}

Menus["resurrect"] = {
    text = color.Red .. "You are unconcious.\n" .. color.White .. "You can wait for another player\nor respawn at the nearest temple.",
    buttons = {						
        { caption = "Respawn",
            destinations = {menuHelper.destinations.setDefault(nil,
            { 
				menuHelper.effects.runGlobalFunction(nil, "OnPlayerSendMessage",
					{menuHelper.variables.currentPid(), "/resurrect"})
                })
            }
        },			
        { caption = "Wait", destinations = nil }
    }
}

Menus["You lack the Gold"] = {
    text = "You lack the required Gold.",
    buttons = {
        { caption = "Ok", destinations = nil }
    }
}

Menus["Success"] = {
    text = GoldCost .. " Gold has been taken and they have been resurrected.",
    buttons = {
        { caption = "Ok", destinations = nil }
    }
}

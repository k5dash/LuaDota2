local failSwitch= {}

failSwitch.optionEnable = Menu.AddOption({ "Utility","failSwitch"}, "Enable", "Stop ultimate if no enemy in radius")
failSwitch.optionKey = Menu.AddKeyOption({ "Utility","failSwitch"}, "Force Cast Key",Enum.ButtonCode.KEY_P)

failSwitch.ultiRadius = {enigma_black_hole = 420, magnataur_reverse_polarity = 410}

function failSwitch.OnUpdate()
	if not Menu.IsEnabled(failSwitch.optionEnable) then return true end
	if not Menu.IsKeyDown(failSwitch.optionKey) then return end

	local myHero = Heroes.GetLocal()
	local name = NPC.GetUnitName(myHero)
	local mousePos = Input.GetWorldCursorPos()

	if not (name == "npc_dota_hero_enigma" or name == "npc_dota_hero_magnataur") then return end
	local myMana = NPC.GetMana(myHero)
	local ulti = NPC.GetAbilityByIndex(myHero, 3)
	Log.Write(Ability.GetName(ulti))
	if ulti ~= nil and Ability.IsCastable(ulti, myMana) then
		if name == "npc_dota_hero_enigma" then
        	Ability.CastPosition(ulti, mousePos)
        else 
        	Ability.CastNoTarget(ulti)
        end
    end
end


function failSwitch.OnPrepareUnitOrders(orders)
    if not Menu.IsEnabled(failSwitch.optionEnable) then return true end
    if not orders.ability then return true end
    if not (orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION or orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET) then return true end
    local abilityName = Ability.GetName(orders.ability)
    if not ( abilityName == "enigma_black_hole" or abilityName == "magnataur_reverse_polarity") then return true end
	local myHero = Heroes.GetLocal()
	local mousePos = Input.GetWorldCursorPos()
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)

    if abilityName == "magnataur_reverse_polarity" then
    	mousePos =  NPC.GetAbsOrigin(myHero)
    end 
    if NPC.IsPositionInRange(enemy, mousePos, failSwitch.ultiRadius[abilityName], 0) then return true end
    return false
end

return failSwitch
local failSwitch= {}

failSwitch.optionEnable = Menu.AddOption({ "Utility","Fail Switch"}, "Enable", "Stop ultimate if no enemy in radius")
failSwitch.optionKey = Menu.AddKeyOption({ "Utility","Fail Switch"}, "Force Cast Key",Enum.ButtonCode.KEY_P)

failSwitch.ultiRadius = {enigma_black_hole = 420, magnataur_reverse_polarity = 410, faceless_void_chronosphere = 425}

function failSwitch.OnUpdate()
	if not Menu.IsEnabled(failSwitch.optionEnable) then return true end
	if not Menu.IsKeyDown(failSwitch.optionKey) then return end

	local myHero = Heroes.GetLocal()
	
	local mousePos = Input.GetWorldCursorPos()

	local myMana = NPC.GetMana(myHero)
	local ulti = NPC.GetAbilityByIndex(myHero, 3)
	if ulti ~= nil and Ability.IsCastable(ulti, myMana) then
		local name =Ability.GetName(ulti)
		Log.Write(name)
		if name == "enigma_black_hole" or name == "faceless_void_chronosphere" then
        	Ability.CastPosition(ulti, mousePos)
        elseif name == "magnataur_reverse_polarity" then
        	Ability.CastNoTarget(ulti)
        end
    end
end


function failSwitch.OnPrepareUnitOrders(orders)
    if not Menu.IsEnabled(failSwitch.optionEnable) then return true end
    if not orders.ability then return true end
    if not (orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION or orders.order == Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_NO_TARGET) then return true end
    local abilityName = Ability.GetName(orders.ability)
    if not ( abilityName == "enigma_black_hole" or abilityName == "magnataur_reverse_polarity" or abilityName == "faceless_void_chronosphere") then return true end
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
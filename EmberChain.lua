local ember= {}

ember.optionEnable = Menu.AddOption({ "Hero Specific","Ember"}, "Enabled", "Auto Chain")
ember.optionKey = Menu.AddKeyOption({ "Hero Specific","Ember"}, "Key", Enum.ButtonCode.KEY_P)

-- this will be set later (only once) inside of OnUpdate.
ember.chainsRadius = 0

function ember.OnUpdate()
	if not Menu.IsEnabled(ember.optionEnable) then return end
	if not Menu.IsKeyDown(ember.optionKey) then return end
    
	local myHero = Heroes.GetLocal()

	if NPC.GetUnitName(myHero) ~= "npc_dota_hero_ember_spirit" then return end

	local punch = NPC.GetAbilityByIndex(myHero, 1)
	local fist = NPC.GetAbilityByIndex(myHero, 0)

	local mousePos = Input.GetWorldCursorPos()
    local myMana = NPC.GetMana(myHero)

    if punch ~= nil and Ability.IsCastable(punch, myMana) then
	    Ability.CastPosition(punch, mousePos)
    end

    if fist == nil or not Ability.IsCastable(fist, myMana) then return end

    -- since ember spirit's chains ability doesn't increase in radius each level, just get it once here.
    -- there would be no point in doing it every tick!
    if ember.chainsRadius == 0 then
        ember.chainsRadius = Ability.GetLevelSpecialValueFor(fist, "radius")
    end

    -- get the nearest enemy to cursor.
	local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)

    -- chains doesnt seem to use the hull radius.
    if enemy ~= nil and NPC.IsPositionInRange(myHero, NPC.GetAbsOrigin(enemy), ember.chainsRadius, 0) then
    	Ability.CastNoTarget(fist)
    end
end

return ember
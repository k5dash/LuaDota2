local ember= {}

ember.optionEnable = Menu.AddOption({ "Hero Specific","Ember"}, "Enabled", "Auto Chain")
ember.optionFistAndChain = Menu.AddKeyOption({ "Hero Specific","Ember"}, "Fist Chain Key", Enum.ButtonCode.KEY_P)
ember.optionDashKey = Menu.AddKeyOption({ "Hero Specific","Ember"}, "3xUltimate Key", Enum.ButtonCode.KEY_P)
ember.optionVeil = Menu.AddOption({ "Hero Specific","Ember"}, "Use Veil", "")

-- this will be set later (only once) inside of OnUpdate.
ember.chainsRadius = 0

function ember.OnUpdate()
    if not Menu.IsEnabled(ember.optionEnable) then return end
    fistAndChain()
    dash()
end

function fistAndChain()
    if not Menu.IsKeyDown(ember.optionFistAndChain) then return end

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
    if enemy ~= nil and NPC.IsPositionInRange(myHero, NPC.GetAbsOrigin(enemy), 100, 0) then
        Ability.CastNoTarget(fist)
        if Menu.IsEnabled(ember.optionVeil) then
            local veil = NPC.GetItem( myHero, "item_veil_of_discord", true)
            if veil ~= nil and Ability.IsCastable(veil, myMana) then 
                Ability.CastPosition(veil, mousePos)
            end
        end
    end
end

function dash()
    if not Menu.IsKeyDown(ember.optionDashKey) then return end
    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_ember_spirit" then return end

    local putRen = NPC.GetAbilityByIndex(myHero, 4)
    local dash = NPC.GetAbilityByIndex(myHero, 3)

    local mousePos = Input.GetWorldCursorPos()
    local myMana = NPC.GetMana(myHero)

    if putRen ~= nil and Ability.IsCastable(putRen, myMana) then
        Ability.CastPosition(putRen, mousePos)
        Ability.CastPosition(putRen, mousePos)
        Ability.CastPosition(putRen, mousePos)
    end

    if dash == nil or not Ability.IsCastable(dash, myMana) then return end
    Ability.CastPosition(dash, mousePos)
end

return ember
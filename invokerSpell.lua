local invoker= {}

invoker.optionEnable = Menu.AddOption({ "Hero Specific","Invoker", "One Key Spell"}, "Enabled", "Auto Chain")
invoker.optionColdSnap = Menu.AddKeyOption({ "Hero Specific","Invoker", "One Key Spell"}, "Cold Snap", Enum.ButtonCode.KEY_Y)
invoker.optionGhostWalk = Menu.AddKeyOption({ "Hero Specific","Invoker", "One Key Spell"}, "Ghost Walk", Enum.ButtonCode.KEY_V)
invoker.optionIceWall = Menu.AddKeyOption({ "Hero Specific","Invoker", "One Key Spell"}, "Ice Wall", Enum.ButtonCode.KEY_G)
invoker.optionEMP = Menu.AddKeyOption({ "Hero Specific","Invoker", "One Key Spell"}, "EMP", Enum.ButtonCode.KEY_C)
invoker.optionTornado = Menu.AddKeyOption({ "Hero Specific","Invoker", "One Key Spell"}, "Tornado", Enum.ButtonCode.KEY_X)
invoker.optionAlacrity = Menu.AddKeyOption({ "Hero Specific","Invoker", "One Key Spell"}, "Alacrity", Enum.ButtonCode.KEY_Z)
invoker.optionSS = Menu.AddKeyOption({ "Hero Specific","Invoker", "One Key Spell"}, "Sun Strike", Enum.ButtonCode.KEY_T)
invoker.optionForgeSpirit = Menu.AddKeyOption({ "Hero Specific","Invoker", "One Key Spell"}, "Forge Spirit", Enum.ButtonCode.KEY_4)
invoker.optionChaos = Menu.AddKeyOption({ "Hero Specific","Invoker", "One Key Spell"}, "Chaos Meteor", Enum.ButtonCode.KEY_5)
invoker.optionBlast = Menu.AddKeyOption({ "Hero Specific","Invoker", "One Key Spell"}, "Deafening Blast", Enum.ButtonCode.KEY_B)
function invoker.OnUpdate()
    if not Menu.IsEnabled(invoker.optionEnable) then return end
    local myHero = Heroes.GetLocal()
    if myHero == nill then return end 
    
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_invoker" then return end
    local Q = NPC.GetAbilityByIndex(myHero, 0)
    local W = NPC.GetAbilityByIndex(myHero, 1)
    local E = NPC.GetAbilityByIndex(myHero, 2)
    local R = NPC.GetAbilityByIndex(myHero, 5)
    local myMana = NPC.GetMana(myHero)
    if Menu.IsKeyDownOnce(invoker.optionColdSnap) and Q and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then 
        Ability.CastNoTarget(Q)
        Ability.CastNoTarget(Q)
        Ability.CastNoTarget(Q)
        Ability.CastNoTarget(R) 
        return        
    end 
    if Menu.IsKeyDownOnce(invoker.optionGhostWalk) and Q and W and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then 
        Ability.CastNoTarget(Q)
        Ability.CastNoTarget(Q)
        Ability.CastNoTarget(W)
        Ability.CastNoTarget(R)
        Ability.CastNoTarget(W)
        Ability.CastNoTarget(W)
        return        
    end 
    if Menu.IsKeyDownOnce(invoker.optionIceWall) and Q and E and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then 
        Ability.CastNoTarget(Q)
        Ability.CastNoTarget(Q)
        Ability.CastNoTarget(E)
        Ability.CastNoTarget(R) 
        return        
    end 
    if Menu.IsKeyDownOnce(invoker.optionEMP) and W and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then 
        Ability.CastNoTarget(W)
        Ability.CastNoTarget(W)
        Ability.CastNoTarget(W)
        Ability.CastNoTarget(R) 
        return        
    end 
    if Menu.IsKeyDownOnce(invoker.optionTornado) and W and Q and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then 
        Ability.CastNoTarget(W)
        Ability.CastNoTarget(W)
        Ability.CastNoTarget(Q)
        Ability.CastNoTarget(R) 
        return        
    end 
    if Menu.IsKeyDownOnce(invoker.optionAlacrity) and W and E and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then 
        Ability.CastNoTarget(W)
        Ability.CastNoTarget(W)
        Ability.CastNoTarget(E)
        Ability.CastNoTarget(R) 
        return        
    end 
    if Menu.IsKeyDownOnce(invoker.optionSS) and E and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then 
        Ability.CastNoTarget(E)
        Ability.CastNoTarget(E)
        Ability.CastNoTarget(E)
        Ability.CastNoTarget(R) 
        return        
    end 
    if Menu.IsKeyDownOnce(invoker.optionForgeSpirit) and E and Q and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then 
        Ability.CastNoTarget(E)
        Ability.CastNoTarget(E)
        Ability.CastNoTarget(Q)
        Ability.CastNoTarget(R) 
        return        
    end 
    if Menu.IsKeyDownOnce(invoker.optionChaos) and E and W and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then 
        Ability.CastNoTarget(E)
        Ability.CastNoTarget(E)
        Ability.CastNoTarget(W)
        Ability.CastNoTarget(R) 
        return        
    end 
    if Menu.IsKeyDownOnce(invoker.optionBlast) and E and W and Q and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then 
        Ability.CastNoTarget(Q)
        Ability.CastNoTarget(E)
        Ability.CastNoTarget(W)
        Ability.CastNoTarget(R) 
        return        
    end 
end

return invoker
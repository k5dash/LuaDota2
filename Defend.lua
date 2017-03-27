local defend= {}

defend.optionEnable = Menu.AddOption({ "Utility", "Defend"}, "Enable", "defend")
--defend.fontSize = Menu.AddOption({ "Awareness", "Show defend Count"}, "Font Size", "", 20, 50, 10)
defend.optionDaggerEnable = Menu.AddOption({ "Utility","Defend"}, "Use Dagger","")
defend.optionHurricanEnable = Menu.AddOption({ "Utility","Defend"}, "Use Hurirrican","")
defend.optionEmber = Menu.AddOption({ "Utility","Defend"}, "Ember Ultimate","")
defend.optionRadius = Menu.AddOption({ "Utility","Defend"}, "Defend Radius","",100,1500,100)
defend.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)

function defend.OnUpdate()
    if not Menu.IsEnabled(defend.optionEnable) then return end
    local myHero = Heroes.GetLocal()
    local myTeam = Entity.GetTeamNum(myHero)
    if myHero == nill then return end
 -- Log.Write(NPC.GetAbsOrigin(myHero):GetX().." X")
 -- Log.Write(NPC.GetAbsOrigin(myHero):GetY().." Y")
 -- Log.Write(NPC.GetAbsOrigin(myHero):GetZ().." Z")
 -- Log.Write(Entity.GetTeamNum(myHero).."teamNum")
    local myDagger = NPC.GetItem(myHero,"item_blink")
    local hurrican = NPC.GetItem(myHero,"item_hurricane_pike")
    for i= 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        local sameTeam = Entity.GetTeamNum(enemy) == myTeam
        if not sameTeam and not NPC.IsDormant(enemy) and Entity.GetHealth(enemy) > 0 then
            local dagger = NPC.GetItem(enemy,"item_blink")
            if dagger and NPC.IsEntityInRange(myHero, enemy, Menu.GetValue(defend.optionRadius)) and Ability.GetCooldownLength(dagger) > 4 and Ability.SecondsSinceLastUse(dagger)<=1 and Ability.SecondsSinceLastUse(dagger)>0 then
            	local myMana = NPC.GetMana(myHero)
            	if NPC.GetUnitName(myHero) == "npc_dota_hero_ember_spirit" and Menu.IsEnabled(defend.optionEmber) then
            		local ultimate = NPC.GetAbilityByIndex(myHero, 3)
            		if Ability.IsCastable(ultimate, myMana) then 
            			-- local modifiers = NPC.GetModifiers(myHero)
            			-- for i = 1, #modifiers do
            			-- 	Log.Write(Modifier.GetName(modifiers[i]))
            			-- end 
            			local remnant = NPC.GetModifier(myHero, "modifier_ember_spirit_fire_remnant_charge_counter")
            			if remnant then
            				local count = Modifier.GetStackCount(remnant)
            				if count <3 then 
            					Ability.CastPosition(ultimate, Entity.GetAbsOrigin(myHero))
            				end 
            			end 
            		end 
                elseif Menu.IsEnabled(defend.optionDaggerEnable) and myDagger and Ability.IsReady(myDagger) then              
                    defend.useDagger(myHero, myDagger,defend.GetFountainPosition(myTeam))
                end

                if Menu.IsEnabled(defend.optionHurricanEnable) and hurrican and Ability.IsCastable(hurrican, myMana) then
                    Ability.CastTarget(hurrican, enemy)
                end 
            end 
        end 
    end 
end

function defend.useDagger(myHero, dagger, vector)
    if dagger == nill or not Ability.IsReady(dagger) then return end 
    local dir = vector - NPC.GetAbsOrigin(myHero)
    dir:SetZ(0)
    dir:Normalize()
    dir:Scale(1199)
    local destination = NPC.GetAbsOrigin(myHero) + dir
    Ability.CastPosition(dagger, vector)
end

function defend.GetFountainPosition(teamNum)
    for i = 1, NPCs.Count() do 
        local npc = NPCs.Get(i)

        if Entity.GetTeamNum(npc) == teamNum and NPC.IsStructure(npc) then
            local name = NPC.GetUnitName(npc)
            if name ~= nil and name == "dota_fountain" then
                return NPC.GetAbsOrigin(npc)
            end
        end
    end
end

return defend
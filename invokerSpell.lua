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
invoker.optionStop = Menu.AddKeyOption({ "Hero Specific","Invoker", "One Key Spell"}, "Stop Combo", Enum.ButtonCode.KEY_7)
invoker.optionOrchid_ColdSnap = Menu.AddKeyOption({ "Hero Specific","Invoker", "One Key Spell"}, "Orchid Cold Snap Alacrity", Enum.ButtonCode.KEY_N)
invoker.optionTornado_EMP= Menu.AddKeyOption({ "Hero Specific","Invoker", "One Key Spell"}, "Tornado EMP", Enum.ButtonCode.KEY_K)
invoker.optionEul_Sunstrike_Chaos_Blast= Menu.AddKeyOption({ "Hero Specific","Invoker", "One Key Spell"}, "Eul Sunstrike Chaos Blast", Enum.ButtonCode.KEY_L)
invoker.optionRefresher= Menu.AddKeyOption({ "Hero Specific","Invoker", "One Key Spell"}, "Refresher Combo", Enum.ButtonCode.KEY_J)
invoker.castQueue ={}
invoker.nextTick = 0
invoker.TornadoCD = {0.8, 1.1,1.4,1.7, 2.0,2.3,2.6,2.9}

        -- local element = invoker.castQueue[1]
        -- table.remove(invoker.castQueue, 1)
        -- local delay = element[1]
        -- local ability = element[2]
        -- local position = element[3]
        -- local onlyUseIfChanneling = element[4]
        -- local target = element[5]
        -- local heroWithRequiredBuff = element[6]
        -- local requiredBuff = element[7]
        -- local repeatHero = element[8]
        -- local repeatUntilBuff = element[9]
        -- local distanceLimit =elemtn[10]
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
     if Menu.IsKeyDownOnce(invoker.optionColdSnap) then 
        invoker.coldSnapInstant(Q,W,E,R, myMana)
        return        
    end 

    if Menu.IsKeyDownOnce(invoker.optionGhostWalk) then 
        invoker.ghostWalkInstant(Q,W,E,R, myMana) 
        return        
    end 
    if Menu.IsKeyDownOnce(invoker.optionIceWall) then 
        invoker.iceWallInstant(Q,W,E,R, myMana) 
        return        
    end 
    if Menu.IsKeyDownOnce(invoker.optionEMP) then 
        invoker.EMPInstant(Q,W,E,R, myMana) 
        return       
    end 
    if Menu.IsKeyDownOnce(invoker.optionTornado) then 
        invoker.tornadoInstant(Q,W,E,R, myMana) 
        return        
    end 
    if Menu.IsKeyDownOnce(invoker.optionAlacrity) then 
        invoker.alacrityInstant(Q,W,E,R, myMana) 
        return        
    end 
    if Menu.IsKeyDownOnce(invoker.optionSS) then 
        invoker.SSInstant(Q,W,E,R, myMana) 
        return        
    end 
    if Menu.IsKeyDownOnce(invoker.optionForgeSpirit) then 
        invoker.forgeSpiritInstant(Q,W,E,R, myMana) 
        return        
    end 
    if Menu.IsKeyDownOnce(invoker.optionChaos) then 
        invoker.chaosInstant(Q,W,E,R, myMana) 
        return        
    end 
    if Menu.IsKeyDownOnce(invoker.optionBlast) then 
        invoker.blastInstant(Q,W,E,R, myMana) 
        return        
    end 

    if Menu.IsKeyDownOnce(invoker.optionStop) then 
        invoker.castQueue ={}
        return
    end 
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local modifiers = NPC.GetModifiers(enemy)
    -- for i,v in ipairs(modifiers) do
    --     Log.Write(Modifier.GetName(v))
    -- end 
    if Menu.IsKeyDownOnce(invoker.optionOrchid_ColdSnap) then 
        local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
        if enemy == nil then return end  
        local orchid = NPC.GetItem(myHero,"item_orchid")
        if orchid then
            invoker.repeatInsert(0.001, orchid, nil, nil, enemy, 5)
        end 
        local blood = NPC.GetItem(myHero,"item_bloodthorn")
        if blood then
            invoker.repeatInsert(0.001, blood, nil, nil, enemy, 5)
        end 
        local coldSnap = invoker.skillInSlot(myHero, "invoker_cold_snap")
        if coldSnap then
            invoker.repeatInsert(0.001, coldSnap, nil, nil, enemy, 5)
        end
        local alacrity = invoker.skillInSlot(myHero, "invoker_alacrity")
        --Log.Write(Ability.GetName(alacrity))
        if not alacrity then
            invoker.alacrity(Q,W,E,R, myMana,0.01)
        end
        alacrity = NPC.GetAbility(myHero,"invoker_alacrity")
        invoker.repeatInsert(0.01, alacrity, nil, nil, myHero, 5)
        invoker.repeatInsert(0, W, nil, nil, nil, 3)
        table.insert(invoker.castQueue,{0, "Attack", nil, nil, enemy})
        return
    end 

    if Menu.IsKeyDownOnce(invoker.optionRefresher) then
        local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
        if enemy == nil then return end
        local tornado = invoker.skillInSlot(myHero, "invoker_tornado")
        local EMP = invoker.skillInSlot(myHero, "invoker_emp")
        if not EMP or not tornado then return end 
        local level = Ability.GetLevel(Q)
        local delay = invoker.TornadoCD[level]
        local enemyPos = NPC.GetAbsOrigin(enemy)
        local myPos = NPC.GetAbsOrigin(myHero)
        local distance = enemyPos - myPos
        distance = distance:Length2D()
        if distance > 700 then return end 
        local time = distance/1000
        --Log.Write(delay+time)

        local angle = Entity.GetRotation(myHero)
        -- local angleOffset = Angle(0, 45, 0)
        -- angle:SetYaw(angle:GetYaw() + angleOffset:GetYaw())
        local x,y,z = angle:GetVectors()
        local direction = x + y + z
        local turnRate = NPC.GetTurnRate(myHero)
        local iToEnemy = enemyPos - myPos
        local iToEnemyAngle = iToEnemy:ToAngle()
        local turnTime = math.abs(iToEnemyAngle:GetYaw() - angle:GetYaw())/(turnRate*2000)
        table.insert(invoker.castQueue,{0, E, nil, nil, nil})
        table.insert(invoker.castQueue,{0, E, nil, nil, nil})
        table.insert(invoker.castQueue,{turnTime, E, nil, nil, nil})
        table.insert(invoker.castQueue,{0.2, tornado, NPC.GetAbsOrigin(enemy), nil, nil})
        for i= 1,4 do
            invoker.chaos(Q,W,E,R, myMana,0.05) 
        end 
        invoker.chaos(Q,W,E,R, myMana,delay+time+0.2-2.9-0.1)
        table.insert(invoker.castQueue,{delay+time-2, EMP, NPC.GetAbsOrigin(enemy), nil, enemy})

        local chaos = NPC.GetAbility(myHero,"invoker_chaos_meteor")
        invoker.repeatInsert(0.1, chaos, enemyPos, nil, enemy, 5, enemy, "modifier_invoker_tornado")
        for i= 1,5 do
                invoker.blast(Q,W,E,R, myMana,0.05,enemy, "modifier_invoker_tornado") 
        end 
         table.insert(invoker.castQueue,{delay+time-distance/500-2.1, W, nil, nil, nil})
        local blast = NPC.GetAbility(myHero,"invoker_deafening_blast")
        local orchid = NPC.GetItem(myHero,"item_orchid")
        local blood = NPC.GetItem(myHero,"item_bloodthorn")
        local shivas = NPC.GetItem(myHero,"item_shivas_guard")
        if shivas then 
            invoker.repeatInsert(0.001, shivas, nil, nil, nil, 5,enemy, "modifier_invoker_tornado")
        end 
        local candidateItem = orchid
        if blood then 
            candidateItem = blood
        end 
        if candidateItem then
            invoker.repeatInsertMore({0.001,0,0.001}, {blast,candidateItem,blast}, {enemyPos,nil,enemyPos}, {nil,nil,nil}, {enemy,enemy,enemy}, 5,{enemy,nil,enemy}, {"modifier_invoker_tornado",nil,"modifier_invoker_chaos_meteor_burn"})
        else
            invoker.repeatInsert(0.001, blast, enemyPos, nil, enemy, 10,enemy, "modifier_invoker_tornado")
        end  

        local refresher = NPC.GetItem(myHero, "item_refresher") 
        if not refresher then return end
        invoker.repeatInsert(0.001, refresher, nil, nil, nil, 5,enemy, "modifier_invoker_deafening_blast_knockback")
        invoker.repeatInsert(0.001, chaos, enemyPos, nil, enemy, 5,enemy, "modifier_invoker_deafening_blast_disarm")
        invoker.repeatInsert(0.001, blast, enemyPos, nil, enemy, 5,enemy, "modifier_invoker_deafening_blast_disarm")
        if shivas then 
            invoker.repeatInsert(0.001, shivas, nil, nil, nil, 5,enemy, "modifier_invoker_deafening_blast_knockback")
        end 
        if candidateItem then
            invoker.repeatInsert(0.001, candidateItem, nil, nil, enemy, 5,enemy, "modifier_invoker_deafening_blast_disarm")
        end
        for i= 1,4 do
            invoker.EMP(Q,W,E,R, myMana,0.001,enemy, "modifier_invoker_deafening_blast_disarm") 
        end 
        invoker.repeatInsert(0.001, EMP, enemyPos, nil, enemy, 5,enemy, "modifier_invoker_deafening_blast_disarm")
        table.insert(invoker.castQueue,{0, "Attack", nil, nil, enemy})

        return
    end 
    if Menu.IsKeyDownOnce(invoker.optionTornado_EMP) then 
        local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
        if enemy == nil then return end  

        local tornado = invoker.skillInSlot(myHero, "invoker_tornado")
        local EMP = invoker.skillInSlot(myHero, "invoker_emp")
        if tornado and EMP then
            local level = Ability.GetLevel(Q)
            local delay = invoker.TornadoCD[level]
            local enemyPos = NPC.GetAbsOrigin(enemy)
            local myPos = NPC.GetAbsOrigin(myHero)
            local distance = enemyPos - myPos
            distance = distance:Length2D()
            local time = distance/1000
            --Log.Write(delay+time)
            if 2.9< delay + time +0.2 then
                table.insert(invoker.castQueue,{delay+time+0.2-2.9, tornado, NPC.GetAbsOrigin(enemy), nil, nil})
                table.insert(invoker.castQueue,{0.1, EMP, NPC.GetAbsOrigin(enemy), nil, enemy})
            else 
                table.insert(invoker.castQueue,{2.9-delay-time-0.2, EMP, NPC.GetAbsOrigin(enemy), nil, nil})
                table.insert(invoker.castQueue,{0.1, tornado, NPC.GetAbsOrigin(enemy), nil, enemy})
            end 

            local orchid = NPC.GetItem(myHero,"item_orchid")
            local blood = NPC.GetItem(myHero,"item_bloodthorn")

            for i= 1,5 do
                invoker.coldSnap(Q,W,E,R, myMana,0.01)
            end 
            invoker.repeatInsert(0.01, W, nil,nil, nil, 3)
            local coldSnap = NPC.GetAbility(myHero,"invoker_cold_snap")
            if orchid or blood then
                if blood then 
                    invoker.repeatInsertMore({0.02,0.02}, {coldSnap,blood}, {nil,nil}, {nil,nil}, {enemy, enemy}, 40,{nil,nil},{nil,nil})
                end 
                if orchid and not blood then
                    invoker.repeatInsertMore({0.02,0.02}, {coldSnap,orchid}, {nil,nil}, {nil,nil}, {enemy, enemy}, 40,{nil,nil},{nil,nil})
                end
            end 
            table.insert(invoker.castQueue,{0, W, nil, nil, enemy})
            table.insert(invoker.castQueue,{0, "Attack", nil, nil, enemy})
        end
        return
    end

    if Menu.IsKeyDownOnce(invoker.optionEul_Sunstrike_Chaos_Blast) then 
        local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
        if enemy == nil then return end  
        local eul = NPC.GetItem(myHero, "item_cyclone",true)
        if eul == nil then return end 
        local sunstrike = invoker.skillInSlot(myHero, "invoker_sun_strike")
        local chaos = invoker.skillInSlot(myHero, "invoker_chaos_meteor")
        local enemyPos = Entity.GetAbsOrigin(enemy)
        local myPos = Entity.GetAbsOrigin(myHero)
        local distance = enemyPos - myPos
        local distance = distance:Length2D()
        local time = distance/1100

        if sunstrike and chaos and distance<575 then
            table.insert(invoker.castQueue,{2.5-1.7+0.1, eul, nil, nil, enemy,nil, nil, nil, nil, 575})
            table.insert(invoker.castQueue,{0.3, sunstrike, Entity.GetAbsOrigin(enemy), nil, nil})
            table.insert(invoker.castQueue,{1.2-time, chaos, Entity.GetAbsOrigin(enemy), nil, nil})
            invoker.blast(Q,W,E,R, myMana,0.2)
            local blast = NPC.GetAbility(myHero,"invoker_deafening_blast")
            table.insert(invoker.castQueue,{0, blast, NPC.GetAbsOrigin(enemy), nil, nil})
        end
        return
    end

    if os.clock() < invoker.nextTick then return end 
    local myHero = Heroes.GetLocal()
    invoker.processCastQueue(myHero)
    if #invoker.castQueue ~= 0 then return end 
end

function invoker.skillInSlot(myHero, skillName)
    for i = 3,4 do
        local skill = NPC.GetAbilityByIndex(myHero,i)
        if Ability.GetName(skill) == skillName then
            return skill
        end 
    end 

    return nil
end

function invoker.repeatInsert(repeatDuration, ability, position, onlyUseIfChanneling, target, num, hero, modifier)
    for i= 1, num do
        table.insert(invoker.castQueue,{repeatDuration, ability, position, onlyUseIfChanneling, target, hero, modifier})
    end 
end

function invoker.repeatInsertMore(repeatDurationSet, abilitySet, positionSet, onlyUseIfChannelingSet, targetSet, num, heroSet, modifierSet)
    for i= 1, num do
        for j = 1, #abilitySet do
            table.insert(invoker.castQueue,{repeatDurationSet[j], abilitySet[j], positionSet[j], onlyUseIfChannelingSet[j], targetSet[j], heroSet[j],modifierSet[j]})
        end 
    end 
end

function invoker.processCastQueue(myHero)
    for i = 1, #invoker.castQueue do
        local element = invoker.castQueue[1]
        local delay = element[1]
        local ability = element[2]
        local position = element[3]
        local onlyUseIfChanneling = element[4]
        local target = element[5]
        local heroWithrequiredBuff = element[6]
        local requiredBuff = element[7]
        local repeatHero = element[8]
        local repeatUntil = element[9]
        local distanceLimit = element[10]
        if heroWithrequiredBuff and requiredBuff then
            local hasBuff = NPC.HasModifier(heroWithrequiredBuff, requiredBuff)
            if not hasBuff then 
                table.remove(invoker.castQueue, 1)
                return
            end 
        end 

        if type(ability) == "string" then
            if ability =="Attack" then 
                Player.PrepareUnitOrders(Players.GetLocal(), 4, target, Vector(0,0,0), target, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero)
                table.remove(invoker.castQueue, 1)
                return
            elseif ability =="move" then
                Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, target, position, target, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero)
                table.remove(invoker.castQueue, 1)
                return
            end
            ability = NPC.GetItem(myHero, ability, true)
        end 

        local myMana = NPC.GetMana(myHero)
        if ability and Ability.IsCastable(ability,myMana) and Ability.IsReady(ability) then
            if onlyUseIfChanneling and not NPC.IsChannellingAbility(myHero) then return end 
            if position == nil and target == nil then 
                Ability.CastNoTarget(ability)
            elseif position == nil and target then
                Ability.CastTarget(ability, target)
            elseif position and target then
                position = Entity.GetAbsOrigin(target)
                Ability.CastPosition(ability, position)
            else
                Ability.CastPosition(ability, position)
            end 
            local totalLatency = (NetChannel.GetAvgLatency(Enum.Flow.FLOW_INCOMING) + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING)) * 2
            invoker.nextTick = os.clock() + delay + totalLatency
            --Log.Write(ultimateHelper.nextTick)
        end 
        if repeatHero and repeatUntil then
            local hasBuff = NPC.HasModifier(repeatHero, repeatUntil)
            if not hasBuff then 
                local totalLatency = (NetChannel.GetAvgLatency(Enum.Flow.FLOW_INCOMING) + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING)) * 2
                invoker.nextTick = os.clock() + delay + totalLatency
                --Log.Write(invoker.nextTick)
                return
            end 
        end
        table.remove(invoker.castQueue, 1)
        return
    end 
end


function invoker.coldSnap(Q,W,E,R, myMana,delay,hero,modifier) 
    if Q and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        table.insert(invoker.castQueue,{0, Q, nil, nil, nil})
        table.insert(invoker.castQueue,{0, Q, nil, nil, nil})
        table.insert(invoker.castQueue,{0, Q, nil, nil, nil})
        table.insert(invoker.castQueue,{delay, R, nil, nil, nil,hero, modifier})
    end 
end 

function invoker.ghostWalk(Q,W,E,R, myMana,delay) 
    if Q and W and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        table.insert(invoker.castQueue,{0, Q, nil, nil, nil})
        table.insert(invoker.castQueue,{0, Q, nil, nil, nil})
        table.insert(invoker.castQueue,{0, W, nil, nil, nil})
        table.insert(invoker.castQueue,{0, R, nil, nil, nil})
        table.insert(invoker.castQueue,{0, W, nil, nil, nil})
        table.insert(invoker.castQueue,{delay, W, nil, nil, nil})
    end 
end 

function invoker.iceWall(Q,W,E,R, myMana,delay) 
    if Q and E and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        table.insert(invoker.castQueue,{0, Q, nil, nil, nil})
        table.insert(invoker.castQueue,{0, Q, nil, nil, nil})
        table.insert(invoker.castQueue,{0, E, nil, nil, nil})
        table.insert(invoker.castQueue,{delay, R, nil, nil, nil})
    end 
end 

function invoker.EMP(Q,W,E,R, myMana,delay,hero,modifier) 
    if W and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        table.insert(invoker.castQueue,{0, W, nil, nil, nil})
        table.insert(invoker.castQueue,{0, W, nil, nil, nil})
        table.insert(invoker.castQueue,{0, W, nil, nil, nil})
        table.insert(invoker.castQueue,{delay, R, nil, nil, nil,hero,modifier})
    end 
end 

function invoker.tornado(Q,W,E,R, myMana,delay) 
    if W and Q and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        table.insert(invoker.castQueue,{0, W, nil, nil, nil})
        table.insert(invoker.castQueue,{0, W, nil, nil, nil})
        table.insert(invoker.castQueue,{0, Q, nil, nil, nil})
        table.insert(invoker.castQueue,{delay, R, nil, nil, nil})
    end 
end 

function invoker.alacrity(Q,W,E,R, myMana,delay) 
    if W and E and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        table.insert(invoker.castQueue,{0.01, W, nil, nil, nil})
        table.insert(invoker.castQueue,{0.01, W, nil, nil, nil})
        table.insert(invoker.castQueue,{0.01, E, nil, nil, nil})
        table.insert(invoker.castQueue,{delay, R, nil, nil, nil})
    end 
end 

function invoker.SS(Q,W,E,R, myMana,delay) 
    if E and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        table.insert(invoker.castQueue,{0, E, nil, nil, nil})
        table.insert(invoker.castQueue,{0, E, nil, nil, nil})
        table.insert(invoker.castQueue,{0, E, nil, nil, nil})
        table.insert(invoker.castQueue,{delay, R, nil, nil, nil})
    end 
end 

function invoker.forgeSpirit(Q,W,E,R, myMana,delay) 
    if E and Q and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        table.insert(invoker.castQueue,{0, E, nil, nil, nil})
        table.insert(invoker.castQueue,{0, E, nil, nil, nil})
        table.insert(invoker.castQueue,{0, Q, nil, nil, nil})
        table.insert(invoker.castQueue,{delay, R, nil, nil, nil})
    end 
end 

function invoker.chaos(Q,W,E,R, myMana,delay,hero,modifier) 
    if E and W and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        table.insert(invoker.castQueue,{0, E, nil, nil, nil})
        table.insert(invoker.castQueue,{0, E, nil, nil, nil})
        table.insert(invoker.castQueue,{0, W, nil, nil, nil})
        table.insert(invoker.castQueue,{delay, R, nil, nil, nil,hero, modifier})
    end 
end 

function invoker.blast(Q,W,E,R, myMana,delay,hero, modifier) 
    if E and W and Q and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        table.insert(invoker.castQueue,{0, Q, nil, nil, nil})
        table.insert(invoker.castQueue,{0, E, nil, nil, nil})
        table.insert(invoker.castQueue,{0, W, nil, nil, nil})
        table.insert(invoker.castQueue,{delay, R, nil, nil,nil, hero, modifier})
    end 
end 




function invoker.coldSnapInstant(Q,W,E,R, myMana,delay,hero,modifier) 
    if Q and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        Ability.CastNoTarget(Q,myMana)
        Ability.CastNoTarget(Q,myMana)
        Ability.CastNoTarget(Q,myMana)
        Ability.CastNoTarget(R,myMana)
    end 
end 

function invoker.ghostWalkInstant(Q,W,E,R, myMana,delay) 
    if Q and W and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        Ability.CastNoTarget(Q,myMana)
        Ability.CastNoTarget(Q,myMana)
        Ability.CastNoTarget(W,myMana)
        Ability.CastNoTarget(R,myMana)
        Ability.CastNoTarget(W,myMana)
        Ability.CastNoTarget(W,myMana)
    end 
end 

function invoker.iceWallInstant(Q,W,E,R, myMana,delay) 
    if Q and E and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        Ability.CastNoTarget(Q,myMana)
        Ability.CastNoTarget(Q,myMana)
        Ability.CastNoTarget(E,myMana)
        Ability.CastNoTarget(R,myMana)
    end 
end 

function invoker.EMPInstant(Q,W,E,R, myMana,delay,hero,modifier) 
    if W and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        Ability.CastNoTarget(W,myMana)
        Ability.CastNoTarget(W,myMana)
        Ability.CastNoTarget(W,myMana)
        Ability.CastNoTarget(R,myMana)
    end 
end 

function invoker.tornadoInstant(Q,W,E,R, myMana,delay) 
    if W and Q and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        Ability.CastNoTarget(W,myMana)
        Ability.CastNoTarget(W,myMana)
        Ability.CastNoTarget(Q,myMana)
        Ability.CastNoTarget(R,myMana)
    end 
end 

function invoker.alacrityInstant(Q,W,E,R, myMana,delay) 
    if W and E and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        Ability.CastNoTarget(W,myMana)
        Ability.CastNoTarget(W,myMana)
        Ability.CastNoTarget(E,myMana)
        Ability.CastNoTarget(R,myMana)
    end 
end 

function invoker.SSInstant(Q,W,E,R, myMana,delay) 
    if E and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        Ability.CastNoTarget(E,myMana)
        Ability.CastNoTarget(E,myMana)
        Ability.CastNoTarget(E,myMana)
        Ability.CastNoTarget(R,myMana)
    end 
end 

function invoker.forgeSpiritInstant(Q,W,E,R, myMana,delay) 
    if E and Q and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        Ability.CastNoTarget(E,myMana)
        Ability.CastNoTarget(E,myMana)
        Ability.CastNoTarget(Q,myMana)
        Ability.CastNoTarget(R,myMana)
    end 
end 

function invoker.chaosInstant(Q,W,E,R, myMana,delay,hero,modifier) 
    if E and W and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        Ability.CastNoTarget(E,myMana)
        Ability.CastNoTarget(E,myMana)
        Ability.CastNoTarget(W,myMana)
        Ability.CastNoTarget(R,myMana)
    end 
end 

function invoker.blastInstant(Q,W,E,R, myMana,delay,hero, modifier) 
    if E and W and Q and Ability.IsCastable(R, myMana) and Ability.IsReady(R) then
        Ability.CastNoTarget(Q,myMana)
        Ability.CastNoTarget(W,myMana)
        Ability.CastNoTarget(E,myMana)
        Ability.CastNoTarget(R,myMana)
    end 
end 

return invoker
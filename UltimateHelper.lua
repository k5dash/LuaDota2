local ultimateHelper= {}

ultimateHelper.optionEnable = Menu.AddOption({ "Utility","Black Hole Helper"}, "Enable", "Enigama Black Hole")
ultimateHelper.optionMidNightPulseEnable = Menu.AddOption({ "Utility","Black Hole Helper"}, "MidNight Pulse", "Use Mid Night Pulse")
ultimateHelper.option3Key = Menu.AddKeyOption({ "Utility","Black Hole Helper"}, ">=3 Men Key",Enum.ButtonCode.KEY_P)
ultimateHelper.option2Key = Menu.AddKeyOption({ "Utility","Black Hole Helper"}, "<=2 Men Key",Enum.ButtonCode.KEY_K)
ultimateHelper.optionDelay = Menu.AddOption({ "Utility", "Black Hole Helper"}, "MidNight Pulse Delay", "", 1, 8, 1)

ultimateHelper.ultiRadius = {enigma_black_hole = 420, magnataur_reverse_polarity = 410, faceless_void_chronosphere = 425}
ultimateHelper.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)
ultimateHelper.cache = {}

ultimateHelper.castQueue ={}
ultimateHelper.nextTick = 0


function ultimateHelper.OnUpdate()
    if not Menu.IsEnabled(ultimateHelper.optionEnable) then return true end
    local myHero = Heroes.GetLocal()

    if os.clock() < ultimateHelper.nextTick then return end 
    ultimateHelper.processCastQueue(myHero)
    if #ultimateHelper.castQueue ~= 0 then return end 

    if Menu.IsKeyDown(ultimateHelper.option3Key) then
        if myHero == nill then return end
        local ultimate = NPC.GetAbilityByIndex(myHero, 3)
        if ultimate == nill or not Ability.IsReady(ultimate) then return end 

        local maxCount,finalPos = ultimateHelper.findBestPostiont(myHero)

        if finalPos == nill or maxCount < 3 then return end
        --
        ultimateHelper.renderHelper(finalPos, "CT")
        --ultimateHelper.renderHelper(ccs, "CC")
        --ultimateHelper.renderHelper(mid, "MD")
        if not ultimateHelper.useItem(myHero, finalPos) then return end 
        ultimateHelper.castUltimate(myHero, finalPos) 
        return
    end 

    if Menu.IsKeyDown(ultimateHelper.option2Key) then
        if myHero == nill then return end
        local ultimate = NPC.GetAbilityByIndex(myHero, 3)
        if ultimate == nill or not Ability.IsReady(ultimate) then return end 
        local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
        if not enemy then return end 
        local enemyPos = Entity.GetAbsOrigin(enemy)
        local myPos = Entity.GetAbsOrigin(myHero)
        local vec = enemyPos-myPos
        local distance = vec:Length2D()
        if distance>1200 then return end
        local finalPos = ultimateHelper.processHeroesLessThan2(myHero, enemy)
        if not finalPos then
            finalPos = enemyPos
        end 
        if not ultimateHelper.useItem(myHero, finalPos) then return end 
        ultimateHelper.castUltimate(myHero, finalPos) 
    end
end

function ultimateHelper.processHeroesLessThan2(myHero, enemy)
    local secondEnemy = nil
    local secondDistance = 100000
    local myTeam = Entity.GetTeamNum( myHero )
    for i = 1, Heroes.Count() do
        local hero = Heroes.Get(i)
        if not NPC.IsIllusion(hero) and hero~=enemy and Entity.IsAlive(hero)then
            local sameTeam = Entity.GetTeamNum(hero) == myTeam
            if not sameTeam and not Entity.IsDormant(hero) then
                Log.Write("heyyyy")
                local enemyPos = Entity.GetAbsOrigin(hero)
                local myPos = Input.GetWorldCursorPos()
                local vec = enemyPos-myPos
                local distance = vec:Length2D()
                if distance<secondDistance then
                    secondDistance = distance
                    secondEnemy = hero
                end 
            end
        end
    end

    if secondEnemy then
        local secondEnemyPos = Entity.GetAbsOrigin(secondEnemy)
        local enemyPos = Entity.GetAbsOrigin(enemy)
        local vec = secondEnemyPos - enemyPos
        local distance = vec:Length2D()
        if distance> 420*2 then return end
        local midPoint = enemyPos + secondEnemyPos
        midPoint:SetZ(0)
        midPoint:SetX(midPoint:GetX()/2) 
        midPoint:SetY(midPoint:GetY()/2)
        local myPos = Entity.GetAbsOrigin(myHero)
        vec = myPos - midPoint
        distance = vec:Length2D()
        if distance>1200 then return end 
        return midPoint
    end 
    return nil
end


function ultimateHelper.processCastQueue(myHero)
    for i = 1, #ultimateHelper.castQueue do
        local element = ultimateHelper.castQueue[1]
        table.remove(ultimateHelper.castQueue, 1)
        local ability = element[2]
        local position = element[3]
        local onlyUseIfChanneling = element[4]
        if type(ability) == "string" then
            ability = NPC.GetItem(myHero, ability, true)
        end 
        local myMana = NPC.GetMana(myHero)
        if ability and Ability.IsCastable(ability,myMana) and Ability.IsReady(ability) then
            if onlyUseIfChanneling and not NPC.IsChannellingAbility(myHero) then return end 
            if position == null then 
                Ability.CastNoTarget(ability)
            else 
                Ability.CastPosition(ability, position)
            end
            local totalLatency = (NetChannel.GetAvgLatency(Enum.Flow.FLOW_INCOMING) + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING)) * 2
            ultimateHelper.nextTick = os.clock() + element[1] + totalLatency
            --Log.Write(ultimateHelper.nextTick)
            return
        end 
    end 
end

function ultimateHelper.findBestPostiont(myHero)
    local enemies = NPC.GetHeroesInRadius(myHero, 1500, Enum.TeamType.TEAM_ENEMY)
    local count = 0;
    local point = {}
    for i, enemy in ipairs(enemies) do
        count = count + 1;
        point[i] = NPC.GetAbsOrigin(enemy)
        --Log.Write(NPC.GetUnitName(enemy)..":  "..point[i]:GetX()..","..point[i]:GetY())
    end
    if count<3 then return end

    local maxCount = 0;
    local finalPos = nill
    for i = 1, count do
        for j = i+1, count do
            for k = j+1, count do
                --Log.Write(point[i]:GetX().."  "..i)
                --Log.Write(point[j]:GetX().."  "..j)
                --Log.Write(point[k]:GetX().."  "..k)
                ultimateHelper.processHeroes(myHero,point[i],point[j],point[k])
                local tempPos = ultimateHelper.cache["pos"]
                local tempCount = ultimateHelper.cache["count"]
                if tempCount> maxCount then 
                    maxCount = tempCount
                    finalPos = tempPos
                end
            end
        end
    end 
    return maxCount, finalPos
end

function ultimateHelper.useItem(myHero, finalPos)
    local myMana = NPC.GetMana(myHero)
    local dagger = NPC.GetItem(myHero, "item_blink", true) 
    if dagger == nill or Ability.GetCooldownTimeLeft(dagger)>0 then 
        return false 
    end 

    local bkb = NPC.GetItem(myHero, "item_black_king_bar", true) 
    if bkb ~= nill then
        table.insert(ultimateHelper.castQueue,{0, bkb,})
    end
    local shivas = NPC.GetItem(myHero, "item_shivas_guard", true)
    if shivas ~= nill and Ability.IsCastable(shivas, myMana)then
        table.insert(ultimateHelper.castQueue,{0, shivas})
    end
    local ultimate = NPC.GetAbilityByIndex(myHero, 3)
    if dagger ~= nill and ultimate~= nill and Ability.IsCastable(ultimate, myMana) and Ability.IsReady(dagger) and Ability.IsReady(ultimate) then
        if NPC.IsPositionInRange(myHero, finalPos, 1200, 0) then
            table.insert(ultimateHelper.castQueue,{0, dagger, finalPos})
        else
            local dir = finalPos - NPC.GetAbsOrigin(myHero)
            dir:SetZ(0)
            dir:Normalize()
            dir:Scale(1199)
            local destination = NPC.GetAbsOrigin(myHero) + dir

            table.insert(ultimateHelper.castQueue,{0, dagger, destination})
        end 
    end 
    return true

end 

function ultimateHelper.processHeroes(myHero, hero1Pos, hero2Pos, hero3Pos)

    -- get circumcenter of the 3 points
    local centroid = ultimateHelper.centroid(hero1Pos, hero2Pos, hero3Pos)
    local ccs = ultimateHelper.circumCenter(hero1Pos, hero2Pos, hero3Pos)
    local mid = ultimateHelper.furthestMidPoint(hero1Pos, hero2Pos, hero3Pos)

    local centroidHeroCount = ultimateHelper.validateCenter(centroid,myHero)
    local ccsHeroCount = ultimateHelper.validateCenter(ccs,myHero)
    local midCount = ultimateHelper.validateCenter(mid,myHero)

    --Log.Write(centroidHeroCount)
    --Log.Write(ccsHeroCount)
    --Log.Write(midCount)


    if centroidHeroCount < 3 and ccsHeroCount < 3 and midCount < 3 then
       --Log.Write(centroidHeroCount)
        ultimateHelper.cache["pos"] = nill
        ultimateHelper.cache["count"] = 0
        --Logs.Write(result["count"])
        return r
    end
    if centroidHeroCount >= ccsHeroCount and centroidHeroCount >= midCount then 
        --Log.Write(centroidHeroCount)
        ultimateHelper.cache["pos"] = centroid
        --Logs.Write(centroidHeroCount)
        ultimateHelper.cache["count"] = centroidHeroCount
        return
    end
    if ccsHeroCount >= centroidHeroCount and ccsHeroCount >= midCount then 
        --Log.Write(centroidHeroCount)
        ultimateHelper.cache["pos"] = ccs
        ultimateHelper.cache["count"] = ccsHeroCount
        --Logs.Write(result["count"])
        return
    end
    ultimateHelper.cache["pos"] = mid
    ultimateHelper.cache["count"] = midCount
    return result
    --ultimateHelper.castUltimate(myHero, ccs) 
end

function ultimateHelper.furthestMidPoint(a, b, c)
    local distanceAB = a:Distance(b)
    local distanceAC = a:Distance(c)
    local distanceBC = b:Distance(c)

    distanceAB = distanceAB:Length()
    distanceAC = distanceAC:Length()
    distanceBC = distanceBC:Length()

    if distanceAB >= distanceAC and distanceAB>= distanceBC then 
        local result = a + b
        result:SetX(result:GetX()/2)
        result:SetY(result:GetY()/2)  
        result:SetZ(0)
        return result
    end 

    if distanceAC >= distanceAB and distanceAC>= distanceBC then 
        local result = a + c
        result:SetX(result:GetX()/2)
        result:SetY(result:GetY()/2)  
        result:SetZ(0)
        return result
    end 

    local result = b + c
    result:SetX(result:GetX()/2)
    result:SetY(result:GetY()/2)  
    result:SetZ(0)
    return result
end

function ultimateHelper.circumCenter(a, b, c)
    a:SetZ(0)
    b:SetZ(0)
    c:SetZ(0)
    
    local xa = a:GetX()
    local ya = a:GetY()
    local xb = b:GetX()
    local yb = b:GetY()
    local xc = c:GetX()
    local yc = c:GetY()

    local delta = 2*(xa-xb)*(yc-yb) - 2*(ya-yb)*(xc-xb)
    local deltaX = (yc-yb)*(xa*xa + ya*ya - xb*xb - yb*yb) - (ya-yb)*(xc*xc + yc*yc - xb*xb - yb*yb)
    local deltaY = (xa-xb)*(xc*xc + yc*yc - xb*xb - yb*yb) - (xc-xb)*(xa*xa + ya*ya - xb*xb - yb*yb) 

    local resultX = deltaX/delta
    local resultY = deltaY/delta
    return Vector(resultX, resultY, 0)
end

function ultimateHelper.castUltimate(myHero, pos)
    local myMana = NPC.GetMana(myHero)
    local ulti = NPC.GetAbilityByIndex(myHero, 3)

    local midNightPulse = NPC.GetAbilityByIndex(myHero, 2)
    if midNightPulse ~= nil and Ability.IsCastable(midNightPulse, myMana) and Menu.IsEnabled(ultimateHelper.optionMidNightPulseEnable) then
        local delay = Menu.GetValue(ultimateHelper.optionDelay)/10.0
        table.insert(ultimateHelper.castQueue,{delay, midNightPulse, pos})
    end

    if ulti ~= nil and Ability.IsCastable(ulti, myMana) then
        local name =Ability.GetName(ulti)
        if name == "enigma_black_hole" or name == "faceless_void_chronosphere" then
            table.insert(ultimateHelper.castQueue,{4.1, ulti, pos})
        elseif name == "magnataur_reverse_polarity" then
            table.insert(ultimateHelper.castQueue,{0, ulti})
        end
    end

    myMana = NPC.GetMana(myHero)
    local refresher = NPC.GetItem(myHero, "item_refresher")
    if refresher == nill then return end 

    if myMana >= Ability.GetManaCost(midNightPulse) + Ability.GetManaCost(ulti) + Ability.GetManaCost(refresher) then
        table.insert(ultimateHelper.castQueue,{0.1, refresher, nill, true})
        return
    end  
end 

function ultimateHelper.centroid(a, b, c )
    local result = a + b + c
    result:SetX(result:GetX()/3)
    result:SetY(result:GetY()/3)
    result:SetZ(0)
    return result
end

function ultimateHelper.renderHelper(pos, text)
    local x, y, visible = Renderer.WorldToScreen(pos)
    if visible then
        Renderer.SetDrawColor(255, 255, 0, 255)
        Renderer.DrawTextCentered(ultimateHelper.font, x, y, text, 1)
    end
end

function ultimateHelper.validateCenter(center, myHero)
    local numOfEnemyInRadius = 0
    local myTeam = Entity.GetTeamNum( myHero )

    for i = 1, Heroes.Count() do
        local hero = Heroes.Get(i)
        if not NPC.IsIllusion(hero) then
            local sameTeam = Entity.GetTeamNum(hero) == myTeam
            if not sameTeam then
                if NPC.IsPositionInRange(hero, center, 420, 0) then 
                    numOfEnemyInRadius = numOfEnemyInRadius + 1
                end
            end
        end
    end
    
    return numOfEnemyInRadius
end 

return ultimateHelper
local ultimateHelper= {}

ultimateHelper.optionEnable = Menu.AddOption({ "Utility","Black Hole Helper"}, "Enable", "Stop ultimate if no enemy in radius")
ultimateHelper.optionKey = Menu.AddKeyOption({ "Utility","Black Hole Helper"}, "Key",Enum.ButtonCode.KEY_P)

ultimateHelper.ultiRadius = {enigma_black_hole = 420, magnataur_reverse_polarity = 410, faceless_void_chronosphere = 425}
ultimateHelper.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)
ultimateHelper.cache = {}
function ultimateHelper.OnUpdate()
	if not Menu.IsEnabled(ultimateHelper.optionEnable) then return true end
    if not Menu.IsKeyDown(ultimateHelper.optionKey) then return end

	local myHero = Heroes.GetLocal()
	if myHero == nill then return end

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

    ultimateHelper.renderHelper(finalPos, "CT")
    --ultimateHelper.renderHelper(ccs, "CC")
    --ultimateHelper.renderHelper(mid, "MD")
    if finalPos == nill or maxCount < 3 then return end
    ultimateHelper.castUltimate(myHero, finalPos)
    
end

function ultimateHelper.processHeroes(myHero, hero1Pos, hero2Pos, hero3Pos)

    -- get circumcenter of the 3 points
    local centroid = ultimateHelper.centroid(hero1Pos, hero2Pos, hero3Pos)
    local ccs = ultimateHelper.circumCenter(hero1Pos, hero2Pos, hero3Pos)
    local mid = ultimateHelper.furthestMidPoint(hero1Pos, hero2Pos, hero3Pos)

    local centroidHeroCount = ultimateHelper.validateCenter(centroid,myHero)
    local ccsHeroCount = ultimateHelper.validateCenter(ccs,myHero)
    local midCount = ultimateHelper.validateCenter(mid,myHero)

    Log.Write(centroidHeroCount)
    Log.Write(ccsHeroCount)
    Log.Write(midCount)


    if centroidHeroCount < 3 and ccsHeroCount < 3 and midCount < 3 then
        Log.Write(centroidHeroCount)
        ultimateHelper.cache["pos"] = nill
        ultimateHelper.cache["count"] = 0
        --Logs.Write(result["count"])
        return r
    end
    if centroidHeroCount >= ccsHeroCount and centroidHeroCount >= midCount then 
        Log.Write(centroidHeroCount)
        ultimateHelper.cache["pos"] = centroid
        --Logs.Write(centroidHeroCount)
        ultimateHelper.cache["count"] = centroidHeroCount
        return
    end
    if ccsHeroCount >= centroidHeroCount and ccsHeroCount >= midCount then 
        Log.Write(centroidHeroCount)
        local result ={}
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

function ultimateHelper.castUltimate(myHero, ccs)
    local myMana = NPC.GetMana(myHero)
    local ulti = NPC.GetAbilityByIndex(myHero, 3)
    local dagger = NPC.GetItem(myHero, "item_blink", true) 
    if dagger ~= nill and Ability.IsCastable(ulti, myMana) then
        Ability.CastPosition(dagger, ccs)
    end 

    if ulti ~= nil and Ability.IsCastable(ulti, myMana) then
        local name =Ability.GetName(ulti)
        Log.Write(name)
        if name == "enigma_black_hole" or name == "faceless_void_chronosphere" then
            Ability.CastPosition(ulti, ccs)
        elseif name == "magnataur_reverse_polarity" then
            Ability.CastNoTarget(ulti)
        end
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
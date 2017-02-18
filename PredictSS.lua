local predictSS= {}

predictSS.optionEnable = Menu.AddOption({ "Utility", "Skill Prediction"}, "Enable", "Predict Sunstrike")
predictSS.font = Renderer.LoadFont("Tahoma", 40, Enum.FontWeight.EXTRABOLD)
predictSS.optionSSKey = Menu.AddKeyOption({ "Utility", "Skill Prediction"}, "Cast Spell Key", Enum.ButtonCode.KEY_P)
predictSS.lastAngle = Angle(0,0,0)
--predictSS.lastTurningState = false
predictSS.direction = nill
predictSS.target = nill


function predictSS.OnUpdate()
    if not Menu.IsEnabled(predictSS.optionEnable) then return end
    local myHero = Heroes.GetLocal()
    local myTeam = Entity.GetTeamNum(myHero)
    if myHero == nill then return end
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    if enemy == nill then return end 
    --Log.Write(Ability.GetName(NPC.GetAbilityByIndex(myHero, 1)))
    local sunstrike = NPC.GetAbility(myHero, "invoker_sun_strike")
    local torrent = NPC.GetAbility(myHero, "kunkka_torrent")
    local arrow = NPC.GetAbility(myHero, "mirana_arrow")
    if sunstrike then 
        predictSS.processHero(enemy, 2.0)
    end 

    if torrent then 
        predictSS.processHero(enemy, 2.0)
    end 

    if arrow then 
        predictSS.processHero(enemy, 2.0)
    end 
    
    -- Log.Write(target:__tostring())

    -- local turning = false
    -- if predictSS.lastAngle:__tostring() ==  angle:__tostring() then
    --     turning = false
    --     Log.Write("stopped")
    -- else
    --     turning = true
    --     Log.Write("turning")
    -- end 
    -- predictSS.lastAngle = angle

    -- if turning and not predictSS.lastTurningState then
    --     Log.Write("Heyhey--------------------------------------------------")
    -- end 

    -- predictSS.lastTurningState = turning
    -- Log.Write(angle:__tostring())
    -- Log.Write(angle:__tostring())
    if Menu.IsKeyDownOnce(predictSS.optionSSKey) then 
        if sunstrike and Ability.IsCastable(sunstrike, NPC.GetMana(myHero)) and Ability.IsReady(sunstrike) and predictSS.direction then
            Ability.CastPosition(sunstrike, predictSS.direction)
            return 
        end 
        if torrent and Ability.IsCastable(torrent, NPC.GetMana(myHero)) and Ability.IsReady(torrent) and predictSS.direction then
            Ability.CastPosition(torrent, predictSS.direction)
            return
        end 

        if arrow and Ability.IsCastable(arrow, NPC.GetMana(myHero)) and Ability.IsReady(arrow) and predictSS.direction then
            local myPos = NPC.GetAbsOrigin(myHero)
            local enemyPos = NPC.GetAbsOrigin(enemy)
            predictSS.target = predictSS.caculateTarget(myPos,enemyPos, 857, NPC.GetMoveSpeed(enemy))
            Ability.CastPosition(arrow, predictSS.target)
            return
        end 
    end 

end

function predictSS.caculateTarget(myPos, enemyPos, mySpeed, enemySpeed)
    local direction = Vector(0,0,0)
    direction:SetX(predictSS.delta:GetX())
    direction:SetY(predictSS.delta:GetY())
    direction:Normalize()
    local vector = myPos - enemyPos
    local distance = vector:Length2D()
    local offset = -0.1/500*distance + 0.6
    --Log.Write(distance)
    return predictSS.binarySearch(0,2000, myPos, enemyPos, direction, mySpeed, enemySpeed, offset)
end 

function predictSS.binarySearch(num1, num2, myPos, enemyPos, direction, mySpeed, enemySpeed, offset) 
    local vec = Vector(0,0,0)
    vec:SetX(direction:GetX())
    vec:SetY(direction:GetY())
    local mid = (num1 + num2)/2
    vec:Scale(mid)
    --Log.Write(vec:__tostring())
    --Log.Write(predictSS.direction:__tostring())
    local target = enemyPos + vec
    --Log.Write(target:__tostring())
        local x, y = Renderer.WorldToScreen(target)
        Renderer.SetDrawColor(255, 255, 255)
        Renderer.DrawTextCenteredX(predictSS.font, x+5, y+5, "Here", 0)

    if num1 >= num2 -1 then
        return target
    end
    local myVector = target - myPos
    local enemyVector = target - enemyPos
    local myDistance = myVector:Length2D()
    local enemyDistance = enemyVector:Length2D()

    local timeEnemy = enemyDistance/enemySpeed
    local timeMe =  myDistance/mySpeed
        -- Log.Write("mid"..mid)
        -- Log.Write("enemyDistance"..enemyDistance)
        -- Log.Write("ActualMine"..myDistance/857)
        -- Log.Write("ActualEnemy"..enemyDistance/enemySpeed)
        -- Log.Write("Enemy"..timeEnemy)
        -- Log.Write("Me"..timeMe)
    if timeEnemy > timeMe + offset and timeEnemy < timeMe + offset+0.01 then

        Log.Write("got it")
        local x, y = Renderer.WorldToScreen(target)
        Renderer.SetDrawColor(255, 255, 255)
        Renderer.DrawTextCenteredX(predictSS.font, x+5, y+5, "Here", 0)
        return target
    elseif timeEnemy <= timeMe + offset then
        --Log.Write("futher")
        return predictSS.binarySearch(mid, num2, myPos, enemyPos, direction, mySpeed, enemySpeed, offset)
    else
        --Log.Write("closer")
        return predictSS.binarySearch(num1, mid, myPos, enemyPos, direction, mySpeed, enemySpeed, offset)
    end
end

function predictSS.processHero(enemy, duration)
    local speed = NPC.GetMoveSpeed(enemy)
    local angle = Entity.GetRotation(enemy)
    local angleOffset = Angle(0, 45, 0)
    angle:SetYaw(angle:GetYaw() + angleOffset:GetYaw())
    local x,y,z = angle:GetVectors()
    local direction = x + y + z
    local name = NPC.GetUnitName(enemy)
    direction:SetZ(0)
    direction:Normalize()
    direction:Scale(speed*duration)

    local origin = NPC.GetAbsOrigin(enemy)
    predictSS.delta = direction
    predictSS.direction = origin + direction
end 


function predictSS.OnDraw()
    if not Menu.IsEnabled(predictSS.optionEnable) then return end
    if predictSS.direction == nill then return end 
    local myHero = Heroes.GetLocal()
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    local myPos = NPC.GetAbsOrigin(myHero)
    local enemyPos = NPC.GetAbsOrigin(enemy)

    predictSS.renderHero(enemyPos)
    --predictSS.drawLine(myPos, enemyPos)
    -- if predictSS.target then
    --     predictSS.drawLine(myPos,predictSS.target)
    -- end 
end 

function predictSS.renderHero(enemyPos)
    local x, y = Renderer.WorldToScreen(predictSS.direction)
    Renderer.SetDrawColor(255, 255, 255)
    Renderer.DrawTextCenteredX(predictSS.font, x+5, y+5, "Here", 0)
    local a, b = Renderer.WorldToScreen(enemyPos)
    Renderer.SetDrawColor(255, 255, 255)
    Renderer.DrawLine(x, y, a, b)
end 

function predictSS.drawLine(pos1, pos2)
    local x1, y1 = Renderer.WorldToScreen(pos1)
    local x2, y2 = Renderer.WorldToScreen(pos2)
    Renderer.SetDrawColor(255, 255, 255)
    Renderer.DrawLine(x1, y1, x2, y2)
end 

return predictSS
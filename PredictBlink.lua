local predictBlink= {}

predictBlink.optionEnable = Menu.AddOption({ "Utility", "Predict Blink"}, "Enable", "Predict Blink Direction")
predictBlink.font = Renderer.LoadFont("Tahoma", 40, Enum.FontWeight.EXTRABOLD)

predictBlink.lastAngle = Angle(0,0,0)
--predictBlink.lastTurningState = false
predictBlink.direction = {}
predictBlink.antimage = nill
predictBlink.qop = nill

function predictBlink.OnUpdate()
    if not Menu.IsEnabled(predictBlink.optionEnable) then return end
    local myHero = Heroes.GetLocal()
    local myTeam = Entity.GetTeamNum(myHero)
    if myHero == nill then return end

    if predictBlink.antimage == nill and predictBlink.qop == nill then
         for i = 1, Heroes.Count() do
            local hero = Heroes.Get(i)
            local sameTeam = Entity.GetTeamNum(hero) == myTeam
            if not sameTeam and NPC.GetAbility(hero, "antimage_blink") then
                predictBlink.antimage = hero
            end
            if not sameTeam and NPC.GetAbility(hero, "queenofpain_blink")  then
                predictBlink.qop = hero
            end 
         end 
    end 

    predictBlink.processHero(predictBlink.antimage)
    predictBlink.processHero(predictBlink.qop)
    -- Log.Write(target:__tostring())

    -- local turning = false
    -- if predictBlink.lastAngle:__tostring() ==  angle:__tostring() then
    --     turning = false
    --     Log.Write("stopped")
    -- else
    --     turning = true
    --     Log.Write("turning")
    -- end 
    -- predictBlink.lastAngle = angle

    -- if turning and not predictBlink.lastTurningState then
    --     Log.Write("Heyhey--------------------------------------------------")
    -- end 

    -- predictBlink.lastTurningState = turning
    -- Log.Write(angle:__tostring())
    -- Log.Write(angle:__tostring())
end

function predictBlink.processHero(enemy)
    if enemy == nill then return end 

    local angle = Entity.GetRotation(enemy)
    local angleOffset = Angle(0, 45, 0)
    angle:SetYaw(angle:GetYaw() + angleOffset:GetYaw())
    local x,y,z = angle:GetVectors()
    local direction = x + y + z
    local name = NPC.GetUnitName(enemy)
    direction:SetZ(0)
    direction:Normalize()
    if name == NPC.GetUnitName(predictBlink.qop) then
        direction:Scale(1300)
    else 
        direction:Scale(1150)
    end 

    local origin = NPC.GetAbsOrigin(enemy)
    predictBlink.direction[name] = origin + direction
end 


function predictBlink.OnDraw()
    if not Menu.IsEnabled(predictBlink.optionEnable) then return end
    if predictBlink.direction["npc_dota_hero_queenofpain"] then 
         predictBlink.renderHero("npc_dota_hero_queenofpain")
    end 
    if predictBlink.direction["npc_dota_hero_antimage"] then 
         predictBlink.renderHero("npc_dota_hero_antimage")
    end 
end 

function predictBlink.renderHero(name)
    local x, y = Renderer.WorldToScreen(predictBlink.direction[name] )
    Renderer.SetDrawColor(255, 255, 255)
    Renderer.DrawTextCenteredX(predictBlink.font, x+5, y+5, "Here", 0)
end 

return predictBlink
local hit= {}

hit.optionEnable = Menu.AddOption({ "Awareness"}, "Show Hit Count", "Show how many hit at most to kill the enemy")
hit.font = Renderer.LoadFont("Tahoma", 25, Enum.FontWeight.EXTRABOLD)

function hit.OnDraw()
    if not Menu.IsEnabled(hit.optionEnable) then return end
    local myHero = Heroes.GetLocal()
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    getHitNumbers(myHero,enemy)
    getHitNumbers(enemy,myHero)
end

function getHitNumbers(myHero, enemy)
    if myHero == nil or enemy==nil then return end
    local trueDamage = NPC.GetDamageMultiplierVersus(myHero, enemy) * (NPC.GetTrueDamage(myHero) * NPC.GetArmorDamageMultiplier(enemy))
    local pos = NPC.GetAbsOrigin(enemy)
    local x, y, visible = Renderer.WorldToScreen(pos)
    local healthLeft = Entity.GetHealth(enemy)
    local hitCount = math.ceil(healthLeft/trueDamage)
    if visible then
        Renderer.SetDrawColor(255, 255, 0, 255)
        Renderer.DrawTextCentered(hit.font, x, y, hitCount, 1)
    end
end
return hit
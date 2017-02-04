local hit= {}

hit.optionEnable = Menu.AddOption({ "Awareness", "Show Hit Count"}, "Enable", "Show how many hit at most to kill the enemy")
hit.fontSize = Menu.AddOption({ "Awareness", "Show Hit Count"}, "Font Size", "", 20, 50, 10)
hit.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)
hit.fontSave = 30;
function hit.OnDraw()
    if not Menu.IsEnabled(hit.optionEnable) then return end
    local myHero = Heroes.GetLocal()
    local enemy = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    hit.getHitNumbers(myHero,enemy)
    hit.getHitNumbers(enemy,myHero)
    local fontNow =  Menu.GetValue(hit.fontSize)
    if (fontNow ~= fontSave) then
        hit.font = Renderer.LoadFont("Tahoma", fontNow, Enum.FontWeight.EXTRABOLD)
        fontSave = fontNow
    end 
end

function hit.getHitNumbers(myHero, enemy)
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
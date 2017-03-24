local invokerDisplay = {}

invokerDisplay.option = Menu.AddOption({ "Hero Specific", "Invoker","Invoker Display"}, "Enable", "Displays enemy hero cooldowns in an easy and intuitive way.")
invokerDisplay.boxSizeOption = Menu.AddOption({ "Hero Specific", "Invoker", "Invoker Display"}, "Cooldown Display Size", "", 21, 200, 5)
invokerDisplay.boxY = Menu.AddOption({ "Hero Specific", "Invoker","Invoker Display" }, "Y position", "Height in the screen", -500, 500, 10)
invokerDisplay.needsInit = true
invokerDisplay.spellIconPath = "resource/flash3/images/spellicons/"
invokerDisplay.cachedIcons = {}

invokerDisplay.colors = {}

function invokerDisplay.InsertColor(alias, r_, g_, b_)
    table.insert(invokerDisplay.colors, { name = alias, r = r_, g = g_, b = b_})
end

invokerDisplay.InsertColor("Green", 0, 255, 0)
invokerDisplay.InsertColor("Yellow", 234, 255, 0)
invokerDisplay.InsertColor("Red", 255, 0, 0)
invokerDisplay.InsertColor("Blue", 0, 0, 255)
invokerDisplay.InsertColor("White", 255, 255, 255)
invokerDisplay.InsertColor("Black", 0, 0, 0)

invokerDisplay.sortAbilitiesOption = Menu.AddOption({ "Hero Specific", "Invoker", "Invoker Display" }, "Sort Abilities by Name", "")

invokerDisplay.invokeOrder =
{
    invoker_sun_strike = { 2, 2, 2 },
    invoker_emp = { 1, 1, 1 },
    invoker_tornado = { 0, 1, 1 },
    invoker_alacrity = { 1, 1, 2 },
    invoker_ghost_walk = { 0, 0, 1 },
    invoker_deafening_blast = { 0, 1, 2 },
    invoker_chaos_meteor = { 1, 2, 2 },
    invoker_cold_snap = { 0, 0, 0 },
    invoker_ice_wall = { 0, 0, 2 },
    invoker_forge_spirit = { 0, 2, 2 }
}

function invokerDisplay.InvokeAbility(ability)
    if not ability then return end

    local name = Ability.GetName(ability)
    if not name then return end

    local invokeOrder = invokerDisplay.invokeOrder[name]
    if not invokeOrder then return end

    local myHero = Heroes.GetLocal()

    local invoke = NPC.GetAbility(myHero, "invoker_invoke")
    if not invoke then return end

    for i, v in ipairs(invokeOrder) do
        local orb = NPC.GetAbilityByIndex(myHero, v)

        if orb then
            Ability.CastNoTarget(orb)
        end
    end

    Ability.CastNoTarget(invoke)
end

function invokerDisplay.InitDisplay()
    invokerDisplay.boxSize = Menu.GetValue(invokerDisplay.boxSizeOption)
    invokerDisplay.innerBoxSize = invokerDisplay.boxSize - 2
    invokerDisplay.levelBoxSize = math.floor(invokerDisplay.boxSize * 0.1875)

    invokerDisplay.font = Renderer.LoadFont("Tahoma", math.floor(invokerDisplay.innerBoxSize * 0.643), Enum.FontWeight.BOLD)
end

-- callback
function invokerDisplay.OnMenuOptionChange(option, old, new)
    if option == invokerDisplay.boxSizeOption then
        invokerDisplay.InitDisplay()
    end
end

function invokerDisplay.DrawDisplay(hero)
    local pos = Entity.GetAbsOrigin(hero)
    pos:SetY(pos:GetY() - 50.0)

    local x, y, vis = Renderer.WorldToScreen(pos)
    local w, h = Renderer.GetScreenSize()
    x = w/2;
    y = h/5*3;
    y = y+Menu.GetValue(invokerDisplay.boxY)

    if not vis then return end

    local abilities = {}

    for i = 3, 15 do
        local ability = NPC.GetAbilityByIndex(hero, i)
        local name = Ability.GetName(ability)
        if ability ~= nil and Entity.IsAbility(ability) and not Ability.IsAttributes(ability) and name~="invoker_invoke" and name ~= "invoker_empty1" and name~= "invoker_empty2"then
            if Ability.GetCooldownTimeLeft(ability)==0 then
                table.insert(abilities, 1, ability)
            else 
                table.insert(abilities, #abilities+1, ability)
            end 
        end
    end

    if Menu.IsEnabled(invokerDisplay.sortAbilitiesOption) then
        table.sort(abilities, function(a, b) return Ability.GetName(a) < Ability.GetName(b) end)
    end

    local startX = x - math.floor(((#abilities) / 2) * invokerDisplay.boxSize)

    -- black background
    Renderer.SetDrawColor(0, 0, 0, 150)
    Renderer.DrawFilledRect(startX + 1, y - 1, (invokerDisplay.boxSize * #abilities) + 2, invokerDisplay.boxSize + 2)

    -- draw the actual ability squares now
    for i, ability in ipairs(abilities) do
        invokerDisplay.DrawAbilitySquare(hero, ability, startX, y, i - 1)
    end

    -- black border
    Renderer.SetDrawColor(0, 0, 0, 255)
    Renderer.DrawOutlineRect(startX + 1, y - 1, (invokerDisplay.boxSize * #abilities) + 2, invokerDisplay.boxSize + 2)
end

function invokerDisplay.DrawAbilitySquare(hero, ability, x, y, index)
    local abilityName = Ability.GetName(ability)
    local imageHandle = invokerDisplay.cachedIcons[abilityName]

    if imageHandle == nil then
        imageHandle = Renderer.LoadImage(invokerDisplay.spellIconPath .. abilityName .. ".png")
        invokerDisplay.cachedIcons[abilityName] = imageHandle
    end

    local realX = x + (index * invokerDisplay.boxSize) + 2

    local castable = Ability.IsCastable(ability, NPC.GetMana(hero), true)

    -- default colors = can cast
    local imageColor = { 255, 255, 255 }
    local outlineColor = { 0, 255 , 0 }

    if not castable then
        if Ability.GetLevel(ability) == 0 then
            imageColor = { 125, 125, 125 }
            outlineColor = { 255, 0, 0 }
        elseif Ability.GetManaCost(ability) > NPC.GetMana(hero) then
            imageColor = { 150, 150, 255 }
            outlineColor = { 0, 0, 255 }
        else
            imageColor = { 255, 150, 150 }
            outlineColor = { 255, 0, 0 }
        end
    end

    local hoveringOver = Input.IsCursorInRect(realX, y, invokerDisplay.boxSize, invokerDisplay.boxSize)

    local boxSize = invokerDisplay.boxSize

    if hoveringOver then
        boxSize = math.floor(boxSize * 1.25)
    end

    Renderer.SetDrawColor(imageColor[1], imageColor[2], imageColor[3], 255)
    Renderer.DrawImage(imageHandle, realX, y, boxSize, boxSize)

    Renderer.SetDrawColor(outlineColor[1], outlineColor[2], outlineColor[3], 255)
    Renderer.DrawOutlineRect(realX, y, boxSize, boxSize)

    local cdLength = Ability.GetCooldownLength(ability)

    if not Ability.IsReady(ability) and cdLength > 0.0 then
        local cooldownRatio = Ability.GetCooldown(ability) / cdLength
        local cooldownSize = math.floor(invokerDisplay.innerBoxSize * cooldownRatio)

        Renderer.SetDrawColor(255, 255, 255, 50)
        Renderer.DrawFilledRect(realX + 1, y + (invokerDisplay.innerBoxSize - cooldownSize) + 1, invokerDisplay.innerBoxSize, cooldownSize)

        Renderer.SetDrawColor(255, 255, 255)
        Renderer.DrawText(invokerDisplay.font, realX + 1, y, math.floor(Ability.GetCooldown(ability)), 0)
    elseif hoveringOver and Input.IsKeyDownOnce(Enum.ButtonCode.MOUSE_LEFT) then
        invokerDisplay.InvokeAbility(ability)
    end
end

function invokerDisplay.OnDraw()
    if not Menu.IsEnabled(invokerDisplay.option) then return end

    local myHero = Heroes.GetLocal()
    if NPC.GetUnitName(myHero) ~= "npc_dota_hero_invoker" then return end
    if not myHero then return end

    if invokerDisplay.needsInit then
        invokerDisplay.InitDisplay()
        invokerDisplay.needsInit = false
    end
    invokerDisplay.DrawDisplay(myHero)
    -- for i = 1, Heroes.Count() do
    --     local hero = Heroes.Get(i)
        
    --     if not Entity.IsSameTeam(myHero, hero) and not Entity.IsDormant(hero) and not NPC.IsIllusion(hero) and Entity.IsAlive(hero) then
    --         invokerDisplay.DrawDisplay(hero)
    --     end
    -- end
end

return invokerDisplay
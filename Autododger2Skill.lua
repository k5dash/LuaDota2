local AutoDodger3 = {}

AutoDodger3.option = Menu.AddOption({ "Utility", "Super Auto Dodger" }, "Skill Picker", "Displays enemy hero cooldowns in an easy and intuitive way.")
AutoDodger3.boxSizeOption = Menu.AddOption({ "Utility", "Super Auto Dodger" }, "Display Size", "", 21, 64, 1)
AutoDodger3.needsInit = true
AutoDodger3.spellIconPath = "resource/flash3/images/spellicons/"
AutoDodger3.cachedIcons = {}
AutoDodger3.w = 1920
AutoDodger3.h = 1080
AutoDodger3.colors = {}

function AutoDodger3.InsertColor(alias, r_, g_, b_)
    table.insert(AutoDodger3.colors, { name = alias, r = r_, g = g_, b = b_})
end

AutoDodger3.InsertColor("Green", 0, 255, 0)
AutoDodger3.InsertColor("Yellow", 234, 255, 0)
AutoDodger3.InsertColor("Red", 255, 0, 0)
AutoDodger3.InsertColor("Blue", 0, 0, 255)
AutoDodger3.InsertColor("White", 255, 255, 255)
AutoDodger3.InsertColor("Black", 0, 0, 0)

AutoDodger3.levelColorOption = Menu.AddOption({ "Utility", "Super Auto Dodger" }, "Level Color", "", 1, #AutoDodger3.colors, 1)

for i, v in ipairs(AutoDodger3.colors) do
    Menu.SetValueName(AutoDodger3.levelColorOption, i, v.name)
end

function AutoDodger3.InitDisplay()
    AutoDodger3.boxSize = Menu.GetValue(AutoDodger3.boxSizeOption)
    AutoDodger3.innerBoxSize = AutoDodger3.boxSize - 2
    AutoDodger3.levelBoxSize = math.floor(AutoDodger3.boxSize * 0.1875)

    AutoDodger3.font = Renderer.LoadFont("Tahoma", math.floor(AutoDodger3.innerBoxSize * 0.643), Enum.FontWeight.BOLD)
    local w, h = Renderer.GetScreenSize()
    AutoDodger3.w = math.floor(w/2)
    AutoDodger3.h = math.floor(h/2)
end

-- callback
function AutoDodger3.OnMenuOptionChange(option, old, new)
    if option == AutoDodger3.boxSizeOption then
        AutoDodger3.InitDisplay()
    end
end

function AutoDodger3.DrawDisplay(hero, x,y)

    local abilities = {}

    for i = 0, 24 do
        local ability = NPC.GetAbilityByIndex(hero, i)

        if ability ~= nil and Entity.IsAbility(ability) and not Ability.IsHidden(ability) and not Ability.IsAttributes(ability) then
            table.insert(abilities, ability)
        end
    end

    local startX = x - math.floor((#abilities / 2) * AutoDodger3.boxSize)

    -- black background
    Renderer.SetDrawColor(0, 0, 0, 150)
    Renderer.DrawFilledRect(startX + 1, y - 1, (AutoDodger3.boxSize * #abilities) + 2, AutoDodger3.boxSize + 2)

    -- draw the actual ability squares now
    for i, ability in ipairs(abilities) do
        AutoDodger3.DrawAbilitySquare(hero, ability, startX, y, i - 1)
    end

    -- black border
    Renderer.SetDrawColor(0, 0, 0, 255)
    Renderer.DrawOutlineRect(startX + 1, y - 1, (AutoDodger3.boxSize * #abilities) + 2, AutoDodger3.boxSize + 2)
end

function AutoDodger3.DrawAbilitySquare(hero, ability, x, y, index)
    local abilityName = Ability.GetName(ability)
    local imageHandle = AutoDodger3.cachedIcons[abilityName]

    if imageHandle == nil then
        imageHandle = Renderer.LoadImage(AutoDodger3.spellIconPath .. abilityName .. ".png")
        AutoDodger3.cachedIcons[abilityName] = imageHandle
    end

    local realX = x + (index * AutoDodger3.boxSize) + 2

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

    Renderer.SetDrawColor(imageColor[1], imageColor[2], imageColor[3], 255)
    Renderer.DrawImage(imageHandle, realX, y, AutoDodger3.boxSize, AutoDodger3.boxSize)

    Renderer.SetDrawColor(outlineColor[1], outlineColor[2], outlineColor[3], 255)
    Renderer.DrawOutlineRect(realX, y, AutoDodger3.boxSize, AutoDodger3.boxSize)

    local cdLength = Ability.GetCooldownLength(ability)

    if not Ability.IsReady(ability) and cdLength > 0.0 then
        local cooldownRatio = Ability.GetCooldown(ability) / cdLength
        local cooldownSize = math.floor(AutoDodger3.innerBoxSize * cooldownRatio)

        Renderer.SetDrawColor(255, 255, 255, 50)
        Renderer.DrawFilledRect(realX + 1, y + (AutoDodger3.innerBoxSize - cooldownSize) + 1, AutoDodger3.innerBoxSize, cooldownSize)

        Renderer.SetDrawColor(255, 255, 255)
        Renderer.DrawText(AutoDodger3.font, realX + 1, y, math.floor(Ability.GetCooldown(ability)), 0)
    end

    AutoDodger3.DrawAbilityLevels(ability, realX, y)
end

function AutoDodger3.DrawAbilityLevels(ability, x, y)
    local level = Ability.GetLevel(ability)

    x = x + 1
    y = ((y + AutoDodger3.boxSize) - AutoDodger3.levelBoxSize) - 1

    local color = AutoDodger3.colors[Menu.GetValue(AutoDodger3.levelColorOption)]

    for i = 1, level do
        Renderer.SetDrawColor(color.r, color.g, color.b, 255)
        Renderer.DrawFilledRect(x + ((i - 1) * AutoDodger3.levelBoxSize), y, AutoDodger3.levelBoxSize, AutoDodger3.levelBoxSize)
        
        Renderer.SetDrawColor(0, 0, 0, 255)
        Renderer.DrawOutlineRect(x + ((i - 1) * AutoDodger3.levelBoxSize), y, AutoDodger3.levelBoxSize, AutoDodger3.levelBoxSize)
    end
end

function AutoDodger3.OnDraw()
    if not Menu.IsEnabled(AutoDodger3.option) then return end

    local myHero = Heroes.GetLocal()

    if not myHero then return end

    if AutoDodger3.needsInit then
        AutoDodger3.InitDisplay()
        AutoDodger3.needsInit = false
    end

    for i = 1, Heroes.Count() do
        local hero = Heroes.Get(i)
        
        if not Entity.IsSameTeam(myHero, hero) and not NPC.IsIllusion(hero) then
            AutoDodger3.DrawDisplay(hero, AutoDodger3.w, AutoDodger3.h)
        end
    end
end

return AutoDodger3

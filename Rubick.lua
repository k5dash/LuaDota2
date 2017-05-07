local Rubick = {}

Rubick.option = Menu.AddOption({ "Hero Specific", "Rubick", "Advanced"}, "Enable", "")
Rubick.boxSizeOption = Menu.AddOption({ "Hero Specific", "Rubick","Advanced" }, "Display Size", "", 21, 64, 1)
Rubick.skillPickerOption = Menu.AddOption({ "Hero Specific", "Rubick", "Advanced"}, "Skill Picker", "")
Rubick.needsInit = true
Rubick.spellIconPath = "resource/flash3/images/spellicons/"
Rubick.cachedIcons = {}
Rubick.pickedSkills ={}
Rubick.skillOrder ={}

Rubick.colors = {}

function Rubick.InsertColor(alias, r_, g_, b_)
    table.insert(Rubick.colors, { name = alias, r = r_, g = g_, b = b_})
end

Rubick.InsertColor("Green", 0, 255, 0)
Rubick.InsertColor("Yellow", 234, 255, 0)
Rubick.InsertColor("Red", 255, 0, 0)
Rubick.InsertColor("Blue", 0, 0, 255)
Rubick.InsertColor("White", 255, 255, 255)
Rubick.InsertColor("Black", 0, 0, 0)

Rubick.levelColorOption = Menu.AddOption({  "Hero Specific", "Rubick","Advanced" }, "Display Level Color", "", 1, #Rubick.colors, 1)
Rubick.pickedSkills ={}
Rubick.skillCoolDown ={}

Rubick.TimeTick = 0

for i, v in ipairs(Rubick.colors) do
    Menu.SetValueName(Rubick.levelColorOption, i, v.name)
end

function Rubick.OnUpdate()
    if not Menu.IsEnabled(Rubick.option) then return end
    local myHero = Heroes.GetLocal()
    if not myHero then return end 
    local myName = NPC.GetUnitName(myHero)

    if myName ~="npc_dota_hero_rubick" then return end
    local myMana = NPC.GetMana(myHero)

    if Rubick.TimeTick > GameRules.GetGameTime() then return end 

    local ultimate = NPC.GetAbility(myHero, "rubick_spell_steal")

    if not ultimate or Ability.GetCooldownTimeLeft(ultimate)>0 or not Ability.IsCastable(ultimate, myMana) then return end
    local currentSkill = NPC.GetAbilityByIndex(myHero,4)
    if currentSkill and Ability.GetName(currentSkill)~="rubick_empty1" then
        Rubick.skillCoolDown[Ability.GetName(currentSkill)] = GameRules.GetGameTime() + Ability.GetCooldownTimeLeft(currentSkill)
    end 

    local target
    local skillTarget
    for i = 1, Heroes.Count() do
        local hero = Heroes.Get(i)
        if not Entity.IsSameTeam(myHero, hero) and not Entity.IsDormant(hero) and not NPC.IsIllusion(hero) and NPC.IsEntityInRange(hero, myHero, 1000+NPC.GetCastRangeBonus(myHero)) then
            local candidateTime = 99999
            local candidateSkill
            for j = 0, 24 do
                local ability = NPC.GetAbilityByIndex(hero, j)
                local abilityName
                if ability then 
                    abilityName = Ability.GetName(ability)
                end 

                if abilityName and Rubick.pickedSkills[abilityName] then
                    local length = Ability.GetCooldownLength(ability)
                    local coolDownLeft = Ability.GetCooldownTimeLeft(ability)
                    if coolDownLeft>0 and candidateTime> length- coolDownLeft then
                        candidateTime = length - coolDownLeft
                        candidateSkill = ability
                    end 
                end
            end
            local candidateOrder = Rubick.findIndex(candidateSkill)
            if candidateSkill then
                if skillTarget then
                    if Rubick.findIndex(skillTarget) > candidateOrder and (not currentSkill or currentSkill and Ability.GetName(skillTarget)~=Ability.GetName(currentSkill)) and (not Rubick.skillCoolDown[Ability.GetName(candidateSkill)] or Rubick.skillCoolDown[Ability.GetName(candidateSkill)] < GameRules.GetGameTime()) then 
                        skillTarget = candidateSkill
                        target = hero
                    end 
                else 
                    if (not currentSkill or Ability.GetName(candidateSkill)~=Ability.GetName(currentSkill)) and (not Rubick.skillCoolDown[Ability.GetName(candidateSkill)] or Rubick.skillCoolDown[Ability.GetName(candidateSkill)] < GameRules.GetGameTime()) then
                        skillTarget = candidateSkill
                        target = hero
                    end 
                end  
            end 
        end
    end

    if skillTarget and not NPC.IsChannellingAbility(myHero) then
        local candidateOrder = Rubick.findIndex(skillTarget);
        if currentSkill and Rubick.pickedSkills[Ability.GetName(currentSkill)] then
            if Rubick.findIndex(currentSkill)>candidateOrder or (Ability.GetCooldownTimeLeft(currentSkill)>8 and Rubick.findIndex(currentSkill)~=candidateOrder)then
                Ability.CastTarget(ultimate, target)
                Rubick.TimeTick = GameRules.GetGameTime() +2
            end 
        else
            Ability.CastTarget(ultimate, target)
            Rubick.TimeTick = GameRules.GetGameTime() +2
        end 
    end 
end 


function Rubick.findIndex(ability)
    for k = 1, #Rubick.skillOrder do
        if ability and Ability.GetName(Rubick.skillOrder[k]) == Ability.GetName(ability) then
            return k
        end 
    end 
end
-----------------------------------------------------------------------------------
function Rubick.InitDisplay()
    Rubick.boxSize = Menu.GetValue(Rubick.boxSizeOption)
    Rubick.innerBoxSize = Rubick.boxSize - 2
    Rubick.levelBoxSize = math.floor(Rubick.boxSize * 0.1875)

    Rubick.font = Renderer.LoadFont("Tahoma", math.floor(Rubick.innerBoxSize * 0.643), Enum.FontWeight.BOLD)
    local w, h = Renderer.GetScreenSize()
    Rubick.w = math.floor(w/2)
    Rubick.h = math.floor(h/2)
    Rubick.pickedSkills ={}
end

-- callback
function Rubick.OnMenuOptionChange(option, old, new)
    if option == Rubick.boxSizeOption then
        Rubick.InitDisplay()
    end
end


function Rubick.DrawDisplayPriorityQueue(x, y)

    local startX = x - math.floor((#Rubick.skillOrder / 2) * Rubick.boxSize)

    -- black background
    Renderer.SetDrawColor(0, 0, 0, 150)
    Renderer.DrawFilledRect(startX + 1, y - 1, (Rubick.boxSize * #Rubick.skillOrder) + 2, Rubick.boxSize + 2)
    -- draw the actual ability squares now
    for i, ability in ipairs(Rubick.skillOrder) do
        Rubick.DrawAbilitySquarePriorityQueue(ability, startX, y, i - 1)
    end

    -- black border
    Renderer.SetDrawColor(0, 0, 0, 255)
    Renderer.DrawOutlineRect(startX + 1, y - 1, (Rubick.boxSize * #Rubick.skillOrder) + 2, Rubick.boxSize + 2)
end 

function Rubick.DrawDisplay(hero, x, y)
    local pos = Entity.GetAbsOrigin(hero)
    pos:SetY(pos:GetY() - 50.0)

    local abilities = {}

    for i = 0, 24 do
        local ability = NPC.GetAbilityByIndex(hero, i)

        if ability ~= nil and Entity.IsAbility(ability) and not Ability.IsHidden(ability) and not Ability.IsAttributes(ability) then
            table.insert(abilities, ability)
        end
    end

    local startX = x - math.floor((#abilities / 2) * Rubick.boxSize)

    -- black background
    Renderer.SetDrawColor(0, 0, 0, 150)
    Renderer.DrawFilledRect(startX + 1, y - 1, (Rubick.boxSize * #abilities) + 2, Rubick.boxSize + 2)

    -- draw the actual ability squares now

    for i, ability in ipairs(abilities) do
        Rubick.DrawAbilitySquare(ability, startX, y, i - 1)
    end

    -- black border
    Renderer.SetDrawColor(0, 0, 0, 255)
    Renderer.DrawOutlineRect(startX + 1, y - 1, (Rubick.boxSize * #abilities) + 2, Rubick.boxSize + 2)
end

function Rubick.DrawAbilitySquare(ability, x, y, index)
    local abilityName = Ability.GetName(ability)
    local imageHandle = Rubick.cachedIcons[abilityName]

    if imageHandle == nil then
        imageHandle = Renderer.LoadImage(Rubick.spellIconPath .. abilityName .. ".png")
        Rubick.cachedIcons[abilityName] = imageHandle
    end

    local realX = x + (index * Rubick.boxSize) + 2

   -- local castable = Ability.IsCastable(ability, NPC.GetMana(hero), true)

    -- default colors = can cast
    local imageColor = { 255, 255, 255 }
    local outlineColor = { 0, 255 , 0 }
    local isPassive = Ability.IsPassive(ability)
    if isPassive then
            imageColor = { 125, 125, 125 }
            outlineColor = { 255, 0, 0 }
    end 

    local hoveringOver = Input.IsCursorInRect(realX, y, Rubick.boxSize, Rubick.boxSize)

    if hoveringOver and not isPassive and Input.IsKeyDownOnce(Enum.ButtonCode.MOUSE_LEFT) then
        if not Rubick.pickedSkills[abilityName] then
            table.insert(Rubick.skillOrder, ability)
        else
            for i = 1, #Rubick.skillOrder do
                if Rubick.skillOrder[i] == ability then
                    table.remove(Rubick.skillOrder,i)
                end 
            end 
        end 
        Rubick.pickedSkills[abilityName] = not Rubick.pickedSkills[abilityName] 
    end 
    -- if not castable then
    --     if Ability.GetLevel(ability) == 0 then
    --         imageColor = { 125, 125, 125 }
    --         outlineColor = { 255, 0, 0 }
    --     elseif Ability.GetManaCost(ability) > NPC.GetMana(hero) then
    --         imageColor = { 150, 150, 255 }
    --         outlineColor = { 0, 0, 255 }
    --     else
    --         imageColor = { 255, 150, 150 }
    --         outlineColor = { 255, 0, 0 }
    --     end
    -- end
    if not Rubick.pickedSkills[abilityName] then
        imageColor = { 125, 125, 125 }
        outlineColor = { 255, 0, 0 }
    end 
    if hoveringOver and not isPassive then
            imageColor = { 255, 255, 125 }
            outlineColor = { 255, 225, 255 }
    end

    Renderer.SetDrawColor(imageColor[1], imageColor[2], imageColor[3], 255)
    Renderer.DrawImage(imageHandle, realX, y, Rubick.boxSize, Rubick.boxSize)

    Renderer.SetDrawColor(outlineColor[1], outlineColor[2], outlineColor[3], 255)
    Renderer.DrawOutlineRect(realX, y, Rubick.boxSize, Rubick.boxSize)

    -- local cdLength = Ability.GetCooldownLength(ability)

    -- if not Ability.IsReady(ability) and cdLength > 0.0 then
    --     local cooldownRatio = Ability.GetCooldown(ability) / cdLength
    --     local cooldownSize = math.floor(Rubick.innerBoxSize * cooldownRatio)

    --     Renderer.SetDrawColor(255, 255, 255, 50)
    --     Renderer.DrawFilledRect(realX + 1, y + (Rubick.innerBoxSize - cooldownSize) + 1, Rubick.innerBoxSize, cooldownSize)

    --     Renderer.SetDrawColor(255, 255, 255)
    --     Renderer.DrawText(Rubick.font, realX + 1, y, math.floor(Ability.GetCooldown(ability)), 0)
    -- end

    Rubick.DrawAbilityLevels(ability, realX, y)
end

function Rubick.DrawAbilitySquarePriorityQueue(ability, x, y, index)
    local abilityName = Ability.GetName(ability)
    local imageHandle = Rubick.cachedIcons[abilityName]

    if imageHandle == nil then
        imageHandle = Renderer.LoadImage(Rubick.spellIconPath .. abilityName .. ".png")
        Rubick.cachedIcons[abilityName] = imageHandle
    end

    local realX = x + (index * Rubick.boxSize) + 2

   -- local castable = Ability.IsCastable(ability, NPC.GetMana(hero), true)

    -- default colors = can cast
    local imageColor = { 255, 255, 255 }
    local outlineColor = { 0, 255 , 0 }

    local hoveringOver = Input.IsCursorInRect(realX, y, Rubick.boxSize, Rubick.boxSize)
    if hoveringOver then
        imageColor = { 255, 255, 125 }
        outlineColor = { 255, 225, 255 }
    end
    if hoveringOver and Input.IsKeyDownOnce(Enum.ButtonCode.MOUSE_LEFT) then
        local pos = 2
        for i = 1, #Rubick.skillOrder do
            if Rubick.skillOrder[i] == ability then
                pos = i
            end 
        end 
        
        if pos ~= 1 then 
            table.remove(Rubick.skillOrder,pos)
            table.insert(Rubick.skillOrder,pos-1,ability)
        end 
    end


   

    Renderer.SetDrawColor(imageColor[1], imageColor[2], imageColor[3], 255)
    Renderer.DrawImage(imageHandle, realX, y, Rubick.boxSize, Rubick.boxSize)

    Renderer.SetDrawColor(outlineColor[1], outlineColor[2], outlineColor[3], 255)
    Renderer.DrawOutlineRect(realX, y, Rubick.boxSize, Rubick.boxSize)

    -- local cdLength = Ability.GetCooldownLength(ability)

    -- if not Ability.IsReady(ability) and cdLength > 0.0 then
    --     local cooldownRatio = Ability.GetCooldown(ability) / cdLength
    --     local cooldownSize = math.floor(Rubick.innerBoxSize * cooldownRatio)

    --     Renderer.SetDrawColor(255, 255, 255, 50)
    --     Renderer.DrawFilledRect(realX + 1, y + (Rubick.innerBoxSize - cooldownSize) + 1, Rubick.innerBoxSize, cooldownSize)

    --     Renderer.SetDrawColor(255, 255, 255)
    --     Renderer.DrawText(Rubick.font, realX + 1, y, math.floor(Ability.GetCooldown(ability)), 0)
    -- end

    Rubick.DrawAbilityLevels(ability, realX, y)
end

function Rubick.DrawAbilityLevels(ability, x, y)
    local level = Ability.GetLevel(ability)

    x = x + 1
    y = ((y + Rubick.boxSize) - Rubick.levelBoxSize) - 1

    local color = Rubick.colors[Menu.GetValue(Rubick.levelColorOption)]

    for i = 1, level do
        Renderer.SetDrawColor(color.r, color.g, color.b, 255)
        Renderer.DrawFilledRect(x + ((i - 1) * Rubick.levelBoxSize), y, Rubick.levelBoxSize, Rubick.levelBoxSize)
        
        Renderer.SetDrawColor(0, 0, 0, 255)
        Renderer.DrawOutlineRect(x + ((i - 1) * Rubick.levelBoxSize), y, Rubick.levelBoxSize, Rubick.levelBoxSize)
    end
end

function Rubick.OnDraw()
    if not Menu.IsEnabled(Rubick.option) then return end
    if not Menu.IsEnabled(Rubick.skillPickerOption) then return end

    local myHero = Heroes.GetLocal()
    if not myHero then return end 
    local myName = NPC.GetUnitName(myHero)

    if myName ~="npc_dota_hero_rubick" then return end

    if Rubick.needsInit then
        Rubick.InitDisplay()
        Rubick.needsInit = false
    end
    local enemyHeroCount = 0;
    for i = 1, Heroes.Count() do
        local hero = Heroes.Get(i)
        if not Entity.IsSameTeam(myHero, hero) and not NPC.IsIllusion(hero) then
            Rubick.DrawDisplay(hero, Rubick.w, Rubick.h - enemyHeroCount*(Rubick.boxSize+2))
            enemyHeroCount = enemyHeroCount + 1
        end
    end
    Rubick.DrawDisplayPriorityQueue(Rubick.w, Rubick.h+300)
end

return Rubick
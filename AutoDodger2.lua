local AutoDodger2 = {}

AutoDodger2.option = Menu.AddOption({"Utility", "Super Auto Dodger"}, "Enable", "Automatically dodges projectiles.")
AutoDodger2.linearOption = Menu.AddOption({"Utility", "Super Auto Dodger", "Dodge Linear Projectiles"}, "Enable", "")
AutoDodger2.impactRadiusOption = Menu.AddOption({"Utility", "Super Auto Dodger", "Dodge Linear Projectiles"}, "Impact Radius", "",100,1000,100)
AutoDodger2.disjointOption = Menu.AddOption({"Utility", "Super Auto Dodger","Dodge Disjoint"}, "Enable", "")
AutoDodger2.impactDistanceOption = Menu.AddOption({"Utility", "Super Auto Dodger","Dodge Disjoint"}, "Safe Distance offset", "",100,2000,100)
AutoDodger2.animationOption = Menu.AddOption({"Utility", "Super Auto Dodger","Dodge Animation"}, "Enable", "")
AutoDodger2.castPointOption = Menu.AddOption({"Utility", "Super Auto Dodger","Dodge Animation"}, "CastPoint Offset", "", 1,10,1 )

AutoDodger2.skillItemOption = Menu.AddOption({"Utility", "Super Auto Dodger"}, "Use Item First", "Use item first to dodge skills")
AutoDodger2.skillOption = Menu.AddOption({"Utility", "Super Auto Dodger"}, "Use Skill", "Use skill to dodge skills")
AutoDodger2.itemOption= Menu.AddOption({"Utility", "Super Auto Dodger"}, "Use Item", "Use item to dodge skills")
AutoDodger2.allItemOption = Menu.AddOption({"Utility", "Super Auto Dodger", "Item"}, "Use All Selected Items", "Use all selected items to dodge skills")
AutoDodger2.daggerOption = Menu.AddOption({"Utility", "Super Auto Dodger","Item"}, "Use Dagger", "Use Dagger to dodge skills", -1, 10, 1)
AutoDodger2.blademailOption = Menu.AddOption({"Utility", "Super Auto Dodger","Item"}, "Use BladeMail", "Use BladeMail to defend",-1, 10, 1)
AutoDodger2.ghostOption = Menu.AddOption({"Utility", "Super Auto Dodger","Item"}, "Use Ghost Scepter", "Use Ghost Scepter to defend",-1, 10, 1)
AutoDodger2.mantaOption = Menu.AddOption({"Utility", "Super Auto Dodger","Item"}, "Use Manta", "Use Manta to dodge skills",-1, 10, 1)
AutoDodger2.eulOption = Menu.AddOption({"Utility", "Super Auto Dodger","Item"}, "Use Eul", "Use Eul to dodge skills",-1, 10, 1)
AutoDodger2.lotusOption = Menu.AddOption({"Utility", "Super Auto Dodger","Item"}, "Use Lotus", "Use Lotus to dodge skills",-1, 10, 1)
AutoDodger2.sbOption = Menu.AddOption({"Utility", "Super Auto Dodger","Item"}, "Use Shadow Blade", "Use Shadow Blade to dodge skills",-1, 10, 1)
AutoDodger2.bkbOption = Menu.AddOption({"Utility", "Super Auto Dodger","Item"}, "Use BKB", "Use BKB to dodge skills",-1, 10, 1)
AutoDodger2.capeOption = Menu.AddOption({"Utility", "Super Auto Dodger","Item"}, "Use Glimmer Cape", "Use GlimmerCape to dodge skills",-1, 10, 1)

AutoDodger2.dodgeTick = 0
-- logic for specific particle effects will go here.
AutoDodger2.particleLogic = 
{
     require("AutoDodger2/PudgeLogic")--,
    -- require("AutoDodger2/LinaLogic")
}

AutoDodger2.activeProjectiles = {}
AutoDodger2.knownRanges = {}
AutoDodger2.ignoredProjectileNames = {}
AutoDodger2.ignoredProjectileHashes = {}
AutoDodger2.projectileQueue ={}
AutoDodger2.projectileQueueLength = 0.0
AutoDodger2.impactRadius = 400
AutoDodger2.canReset = true
AutoDodger2.AnimationQueue ={}
AutoDodger2.AnimationQueueLength = 0

AutoDodger2.nextDodgeTime = 0.0
AutoDodger2.nextDodgeTimeProjectile = 0.0
AutoDodger2.nextDodgeTimeAnimation = 0.0

AutoDodger2.movePos = Vector()
AutoDodger2.fountainPos = Vector()
AutoDodger2.active = false
AutoDodger2.drawPos = nil

AutoDodger2.mapFont = Renderer.LoadFont("Tahoma", 50, Enum.FontWeight.NORMAL)

AutoDodger2.skillPickerOption = Menu.AddOption({ "Utility", "Super Auto Dodger"}, "Skill Picker", "Displays enemy hero cooldowns in an easy and intuitive way.")
AutoDodger2.boxSizeOption = Menu.AddOption({ "Utility", "Super Auto Dodger","Skill Picker Setting" }, "Display Size", "", 21, 64, 1)
AutoDodger2.needsInit = true
AutoDodger2.spellIconPath = "resource/flash3/images/spellicons/"
AutoDodger2.cachedIcons = {}
AutoDodger2.w = 1920
AutoDodger2.h = 1080
AutoDodger2.colors = {}
AutoDodger2.skillSelected = {}
AutoDodger2.itemOrder = {}

function AutoDodger2.InsertColor(alias, r_, g_, b_)
    table.insert(AutoDodger2.colors, { name = alias, r = r_, g = g_, b = b_})
end
Menu.SetValueName(AutoDodger2.daggerOption, -1, 'OFF')
Menu.SetValueName(AutoDodger2.blademailOption, -1, 'OFF')
Menu.SetValueName(AutoDodger2.ghostOption, -1, 'OFF')
Menu.SetValueName(AutoDodger2.mantaOption, -1, 'OFF')
Menu.SetValueName(AutoDodger2.eulOption, -1, 'OFF')
Menu.SetValueName(AutoDodger2.lotusOption, -1, 'OFF')
Menu.SetValueName(AutoDodger2.sbOption, -1, 'OFF')
Menu.SetValueName(AutoDodger2.bkbOption, -1, 'OFF')
Menu.SetValueName(AutoDodger2.capeOption, -1, 'OFF')

function AutoDodger2.setItemOrder()
    AutoDodger2.itemOrder = {
        {Menu.GetValue(AutoDodger2.daggerOption), "item_blink"},
        {Menu.GetValue(AutoDodger2.blademailOption), "item_blade_mail"},
        {Menu.GetValue(AutoDodger2.ghostOption), "item_ghost"},
        {Menu.GetValue(AutoDodger2.mantaOption), "item_manta"},
        {Menu.GetValue(AutoDodger2.eulOption),"item_cyclone"},
        {Menu.GetValue(AutoDodger2.lotusOption),"item_lotus_orb"},
        {Menu.GetValue(AutoDodger2.sbOption),"item_invis_sword"},
        {Menu.GetValue(AutoDodger2.bkbOption),"item_black_king_bar"},
        {Menu.GetValue(AutoDodger2.capeOption),"item_glimmer_cape"}
    }
    table.sort(AutoDodger2.itemOrder, function(a, b)
        return a[1] > b[1]
    end)
    Log.Write('...........')
    for k,v in pairs(AutoDodger2.itemOrder) do
        Log.Write(v[1]..':'..v[2])
    end 
end 

AutoDodger2.InsertColor("Green", 0, 255, 0)
AutoDodger2.InsertColor("Yellow", 234, 255, 0)
AutoDodger2.InsertColor("Red", 255, 0, 0)
AutoDodger2.InsertColor("Blue", 0, 0, 255)
AutoDodger2.InsertColor("White", 255, 255, 255)
AutoDodger2.InsertColor("Black", 0, 0, 0)

AutoDodger2.levelColorOption = Menu.AddOption({ "Utility", "Super Auto Dodger","Skill Picker Setting" }, "Level Color", "", 1, #AutoDodger2.colors, 1)

for i, v in ipairs(AutoDodger2.colors) do
    Menu.SetValueName(AutoDodger2.levelColorOption, i, v.name)
end

function AutoDodger2.InitDisplay()
    AutoDodger2.boxSize = Menu.GetValue(AutoDodger2.boxSizeOption)
    AutoDodger2.innerBoxSize = AutoDodger2.boxSize - 2
    AutoDodger2.levelBoxSize = math.floor(AutoDodger2.boxSize * 0.1875)

    AutoDodger2.font = Renderer.LoadFont("Tahoma", math.floor(AutoDodger2.innerBoxSize * 0.643), Enum.FontWeight.BOLD)
    local w, h = Renderer.GetScreenSize()
    AutoDodger2.w = math.floor(w/2)
    AutoDodger2.h = math.floor(h/2)
end

-------------------------------------------------------------------------------------------------------
function AutoDodger2.OnUpdate()
    --Log.Write(AutoDodger2.nextDodgeTimeProjectile..', '..GameRules.GetGameTime())
    --Log.Write(AutoDodger2.projectileQueueLength)
    if not Menu.IsEnabled(AutoDodger2.option) then return end
    AutoDodger2.ProcessLinearProjectile()
    AutoDodger2.ProcessProjectile()
    AutoDodger2.ProcessAnimation()
    AutoDodger2.ProcessChoosingSkills()
end

--------------------------------------------------------------------------------------------------------
function AutoDodger2.DodgeLogicProjectile(key, mode)
    if Menu.GetValue(AutoDodger2.skillItemOption) then
        local dodged = AutoDodger2.DodgeLogicItem(key, mode, false) 
        AutoDodger2.DodgeLogicSkill(key, mode, dodged)
    else
        local dodged = AutoDodger2.DodgeLogicSkill(key, mode,false)
        AutoDodger2.DodgeLogicItem(key, mode, dodged) 
    end 
end 
function AutoDodger2.DodgeLogicItem(key, mode, dodged)
    if not Menu.IsEnabled(AutoDodger2.itemOption) then return false end 
    local myHero = Heroes.GetLocal()
    local eul = NPC.GetItem(myHero, "item_cyclone")
    local lotus = NPC.GetItem(myHero, "item_lotus_orb")
    local bladeMail = NPC.GetItem(myHero, "item_blade_mail")
    local manta = NPC.GetItem(myHero, "item_manta") 
    local ghost = NPC.GetItem(myHero, "item_ghost") 
    local eblade = NPC.GetItem(myHero, "item_ethereal_blade")
    local blink = NPC.GetItem(myHero, "item_blink")
    local shadowblade = NPC.GetItem(myHero, "item_invis_sword")
    local glimmerCape = NPC.GetItem(myHero, "item_glimmer_cape")
    local bkb = NPC.GetItem(myHero, "item_black_king_bar")

    local myTeam = Entity.GetTeamNum(myHero)
    local myMana = NPC.GetMana(myHero)
    local myPos = Entity.GetAbsOrigin(myHero)
    local myName = NPC.GetUnitName(myHero)
    AutoDodger2.setItemOrder()

    local dodgeAll = Menu.IsEnabled(AutoDodger2.allItemOption)

    for k,v in ipairs(AutoDodger2.itemOrder) do
        local order = v[1]
        local item = v[2]
        if order ~= -1 then 
            if (not dodged or dodgeAll) and eul and Ability.IsCastable(eul,myMana) and item == "item_cyclone" then
                    Ability.CastTarget(eul,myHero)
                    dodged = true
            end 
            if (not dodged or dodgeAll) and lotus and Ability.IsCastable(lotus,myMana) and item == "item_lotus_orb" then
                    Ability.CastTarget(lotus,myHero)
                    dodged = true
            end 
            if (not dodged or dodgeAll) and bladeMail and Ability.IsCastable(bladeMail,myMana) and item == "item_blade_mail" then
                    Ability.CastNoTarget(bladeMail)
                    dodged = true
            end
            if (not dodged or dodgeAll) and manta and Ability.IsCastable(manta,myMana) and item == "item_manta" then
                    Ability.CastNoTarget(manta)
                    dodged = true
            end
            if (not dodged or dodgeAll) and ghost and Ability.IsCastable(ghost,myMana) and item == "item_ghost" then
                    Ability.CastNoTarget(ghost)
                    dodged = true
            end 
            if (not dodged or dodgeAll) and eblade and Ability.IsCastable(eblade,myMana) and item == "item_ethereal_blade" then
                    Ability.CastTarget(eblade,myHero)
                    dodged = true
            end
            if (not dodged or dodgeAll) and blink and Ability.IsCastable(blink,myMana) and item == "item_blink" then
                    AutoDodger2.DodgeByMoveForward(myHero, 1199, blink)
                    dodged = true
            end
            if (not dodged or dodgeAll) and shadowblade and Ability.IsCastable(shadowblade,myMana) and item == "item_invis_sword" then
                    Ability.CastNoTarget(shadowblade)
                    dodged = true
            end
            if (not dodged or dodgeAll) and glimmerCape and Ability.IsCastable(glimmerCape,myMana) and item == "item_glimmer_cape" then
                    Ability.CastTarget(glimmerCape,myHero)
                    dodged = true
            end
            if (not dodged or dodgeAll) and bkb and Ability.IsCastable(bkb,myMana) and item == "item_black_king_bar" then
                    Ability.CastNoTarget(bkb)
                    dodged = true
            end
        end 
    end

  
    return dodged
end 

function AutoDodger2.DodgeLogicSkill(key, mode, dodged)
    if not Menu.IsEnabled(AutoDodger2.skillOption) then return false end
    local myHero = Heroes.GetLocal()
    local myTeam = Entity.GetTeamNum(myHero)
    local myMana = NPC.GetMana(myHero)
    local myPos = Entity.GetAbsOrigin(myHero)
    local myName = NPC.GetUnitName(myHero)
    if dodged then return end 
    if myName == "npc_dota_hero_puck" then 
        local skill = NPC.GetAbility(myHero, "puck_phase_shift")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.CastNoTarget(skill)
            AutoDodger2.dodgeTick = GameRules.GetGameTime()+1
            dodged = true
        end 
    end 
    if myName == "npc_dota_hero_bane" then 
        local skill = NPC.GetAbility(myHero, "bane_nightmare")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.CastTarget(skill,myHero)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_omniknight" then 
        local skill = NPC.GetAbility(myHero, "omniknight_repel")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.CastTarget(skill,myHero)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_shadow_demon" then 
        local skill = NPC.GetAbility(myHero, "shadow_demon_disruption")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.CastTarget(skill,myHero)
            dodged = true
        end 
    end
    
    if myName == "npc_dota_hero_obsidian_destroyer" then 
        local skill = NPC.GetAbility(myHero, "obsidian_destroyer_astral_imprisonment")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.CastTarget(skill,myHero)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_abaddon" then 
        local skill = NPC.GetAbility(myHero, "abaddon_aphotic_shield")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.CastTarget(skill,myHero)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_life_stealer" then 
        local skill = NPC.GetAbility(myHero, "life_stealer_rage")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.CastNoTarget(skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_sand_king" then 
        local skill = NPC.GetAbility(myHero, "sandking_sand_storm")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.CastNoTarget(skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_juggernaut" then 
        local skill = NPC.GetAbility(myHero, "juggernaut_blade_fury")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.CastNoTarget(skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_clinkz" then 
        local skill = NPC.GetAbility(myHero, "clinkz_wind_walk")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.CastNoTarget(skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_alchemist" then 
        local skill = NPC.GetAbility(myHero, "alchemist_chemical_rage")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.CastNoTarget(skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_nyx_assassin" then 
        local skill = NPC.GetAbility(myHero, "nyx_assassin_spiked_carapace")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.CastNoTarget(skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_slark" then 
        local skill = NPC.GetAbility(myHero, "slark_dark_pact")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.CastNoTarget(skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_bounty_hunter" then 
        local skill = NPC.GetAbility(myHero, "bounty_hunter_wind_walk")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.CastNoTarget(skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_weaver" then 
        local skill = NPC.GetAbility(myHero, "weaver_shukuchi")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.CastNoTarget(skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_medusa" then 
        local skill = NPC.GetAbility(myHero, "medusa_mana_shield")
        if skill and not NPC.HasModifier(myHero, "modifier_medusa_mana_shield") and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.Toggle(skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_templar_assassin" then 
        local skill = NPC.GetAbility(myHero, "templar_assassin_meld")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.CastNoTarget(skill)
            dodged = true
        end
        skill = NPC.GetAbility(myHero, "templar_assassin_refraction")
        if not dodged and skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.CastNoTarget(skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_morphling" then 
        local skill = NPC.GetAbility(myHero, "morphling_waveform")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then
            AutoDodger2.DodgeByMoveForward(myHero, 1000, skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_storm_spirit" then 
        local skill = NPC.GetAbility(myHero, "storm_spirit_ball_lightning")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then
            AutoDodger2.DodgeByMoveForward(myHero, 500, skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_queenofpain" then 
        local skill = NPC.GetAbility(myHero, "queenofpain_blink")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then
            AutoDodger2.DodgeByMoveForward(myHero, 1000, skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_faceless_void" then 
        local skill = NPC.GetAbility(myHero, "faceless_void_time_walk")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then
            AutoDodger2.DodgeByMoveForward(myHero, 1000, skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_phantom_lancer" then 
        local skill = NPC.GetAbility(myHero, "phantom_lancer_doppelwalk")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then
            AutoDodger2.DodgeByMoveForward(myHero, 600, skill)
            dodged = true
        end 
    end

    -- if myName == "npc_dota_hero_lone_druid" then 
    --     local skill = NPC.GetAbility(myHero, "lone_druid_true_form")
    --     if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
    --         Ability.CastNoTarget(skill)
    --         dodged = true
    --     end 
    --     skill = NPC.GetAbility(myHero, "lone_druid_true_form_druid")
    --     if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
    --         Ability.CastNoTarget(skill)
    --         dodged = true
    --     end
    -- end
    -- if myName == "npc_dota_hero_riki" then 
    --     local skill = NPC.GetAbility(myHero, "riki_blink_strike")
    --     if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
    --         AutoDodger2.DodgeByAttackNearUnits(myHero, 800, skill)
    --     end 
    -- end
    if myName ==  "npc_dota_hero_tusk" then 
        local skill = NPC.GetAbility(myHero, "tusk_snowball")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            AutoDodger2.DodgeByAttackNearUnits(myHero, 1250, skill)
        end 
    end
    if myName == "npc_dota_hero_ember_spirit" then 
        local skill = NPC.GetAbility(myHero, "ember_spirit_sleight_of_fist")
        local level = Ability.GetLevel(skill)
        local range = 700
        local fistRadius = {250,350,450,550} 
        local radius = range + fistRadius[level]

        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            local units = NPC.GetUnitsInRadius(myHero, radius, Enum.TeamType.TEAM_ENEMY)
            if #units >0 then 
                local candidate
                for i =1, #units do
                    if (NPC.IsCreep(units[i]) or NPC.IsHero(units[i]))  and Entity.IsAlive(units[i]) then
                        candidate = units[i]

                        break 
                    end  
                end 
                if candidate then 
                    local enemyPos = Entity.GetAbsOrigin(candidate)
                    local vec = enemyPos - myPos

                    local distance = vec:Length2D()

                    if distance <700 then 
                        Ability.CastPosition(skill, enemyPos)
                    else 
                        vec:Normalize()
                        local castPos = vec:Scaled(700) + myPos
                        Ability.CastPosition(skill, castPos)
                    end 
                    dodged = true
                end 
            end 
        end 
    end
    return dodged
end 
function AutoDodger2.DodgeByAttackNearUnits(myHero, radius, skill)
    local units = NPC.GetUnitsInRadius(myHero, radius, Enum.TeamType.TEAM_ENEMY)
    local dodged = false
    if #units >0 then 
        local candidate
        for i =1, #units do
            if (NPC.IsCreep(units[i]) or NPC.IsHero(units[i]))  and Entity.IsAlive(units[i]) then
                candidate = units[i]
                break 
            end  
        end 
        if candidate then 
            Ability.CastTarget(skill,candidate)
            dodged = true
        end 
    end 
    return dodged
end 

function AutoDodger2.DodgeByMoveToBase(myHero, distance, skill)
    AutoDodger2.fountainPos = AutoDodger2.GetFountainPosition(Entity.GetTeamNum(myHero))
    local myPos = Entity.GetAbsOrigin(myHero)
    local vec = AutoDodger2.fountainPos - myPos
    vec=vec:Normalized()
    vec=vec:Scaled(distance-1)
    vec = vec + myPos 
    Ability.CastPosition(skill, vec)
end 

function AutoDodger2.DodgeByMoveForward(myHero, distance, skill)
    local myPos = Entity.GetAbsOrigin(myHero)
    local angle = Entity.GetRotation(myHero)
    local angleOffset = Angle(0, 45, 0)
    angle:SetYaw(angle:GetYaw() + angleOffset:GetYaw())
    local x,y,z = angle:GetVectors()
    local direction = x + y + z
    direction = direction:Normalized()
    direction = direction:Scaled(distance)
    direction = myPos + direction
    Ability.CastPosition(skill, direction)
end        
--------------------------------------------------------------------------------------------------------
function AutoDodger2.InsertIgnoredProjectile(name)
    AutoDodger2.ignoredProjectileNames[name] = true
end

AutoDodger2.InsertIgnoredProjectile("tinker_machine")
AutoDodger2.InsertIgnoredProjectile("weaver_swarm_projectile")

function AutoDodger2.Reset()
    if not AutoDodger2.canReset then return end

    AutoDodger2.activeProjectiles = {}
    AutoDodger2.nextDodgeTime = 0.0
    AutoDodger2.canReset = false
    AutoDodger2.skillSelected ={}
    AutoDodger2.projectileQueueLength = 0
    AutoDodger2.AnimationQueueLength = 0
    AutoDodger2.projectileQueue={}
    AutoDodger2.setItemOrder()
end

function AutoDodger2.GetFountainPosition(teamNum)
    for i = 1, NPCs.Count() do 
        local npc = NPCs.Get(i)

        if Entity.GetTeamNum(npc) == teamNum and NPC.IsStructure(npc) then
            local name = NPC.GetUnitName(npc)
            if name ~= nil and name == "dota_fountain" then
                return NPC.GetAbsOrigin(npc)
            end
        end
    end
end

function AutoDodger2.GetRange(index)
    local knownRange = AutoDodger2.knownRanges[index]

    if knownRange == nil then return 2000 end

    return knownRange
end

function AutoDodger2.OnProjectile(projectile)
    if not Menu.IsEnabled(AutoDodger2.option) then return end 
    if not Menu.IsEnabled(AutoDodger2.disjointOption) then return end
    if not projectile.source or projectile.isAttack then return end
    local myHero = Heroes.GetLocal()
    local enemy = projectile.source

    if projectile.target ~= myHero then return end
    local myTeam = Entity.GetTeamNum(myHero)
    local enemyTeam = Entity.GetTeamNum(enemy)

    local sameTeam = Entity.GetTeamNum(enemy) == myTeam
    if sameTeam then return end 

    local myPos = Entity.GetAbsOrigin(myHero)
    local enemyPos = Entity.GetAbsOrigin(enemy)

    local distance = myPos - enemyPos 
    local distanceLenth = distance:Length2D() - NPC.GetHullRadius(myHero) - Menu.GetValue(AutoDodger2.impactDistanceOption)
    
    local delay = (distanceLenth/projectile.moveSpeed) 
    delay = math.max(delay, 0.001)
    Log.Write(projectile.name)
    if (AutoDodger2.projectileMap[projectile.name] and AutoDodger2.projectileMapRev[AutoDodger2.projectileMap[projectile.name].ability].selected or not AutoDodger2.projectileMap[projectile.name]) and not AutoDodger2.ignoredDisjoint[projectile.name] then 
    -- table.insert(AutoDodger2.projectileQueue, {GameRules.GetGameTime()+delay,projectile.name})
        AutoDodger2.projectileQueue[projectile.particleSystemHandle] = { 
            source = projectile.source,
            target = projectile.target,
            origin = Entity.GetAbsOrigin(projectile.source),
            moveSpeed = projectile.moveSpeed,
            index = projectile.particleSystemHandle,
            time = GameRules.GetGameTime(),
            dodgeTime = delay + GameRules.GetGameTime(),
            name = projectile.name,
        }
        AutoDodger2.projectileQueueLength = AutoDodger2.projectileQueueLength + 1
    end 
end

function AutoDodger2.OnLinearProjectileCreate(projectile)
    if not Menu.IsEnabled(AutoDodger2.option) then return end 
    if not Menu.IsEnabled(AutoDodger2.linearOption) then return end
    if not projectile.source then return end

    if Entity.IsSameTeam(Heroes.GetLocal(), projectile.source) then return end
    local shouldIgnore = AutoDodger2.ignoredProjectileHashes[projectile.particleIndex]

    if shouldIgnore == true then 
        return
    elseif shouldIgnore == nil then
        if AutoDodger2.ignoredProjectileNames[projectile.name] then
            AutoDodger2.ignoredProjectileHashes[projectile.particleIndex] = true
            return
        else
            AutoDodger2.ignoredProjectileHashes[projectile.particleIndex] = false
        end
    end

    AutoDodger2.canReset = true
    AutoDodger2.activeProjectiles[projectile.handle] = { source = projectile.source,
        origin = projectile.origin,
        velocity = projectile.velocity,
        index = projectile.particleIndex,
        time = GameRules.GetGameTime(),
        name = projectile.name
    }
end

function AutoDodger2.OnLinearProjectileDestroy(projectile)
    if not Menu.IsEnabled(AutoDodger2.option) then return end
    if not Menu.IsEnabled(AutoDodger2.linearOption) then return end
    local projectileData = AutoDodger2.activeProjectiles[projectile.handle]

    if not projectileData then return end

    local curtime = GameRules.GetGameTime()

    local t = curtime - projectileData.time
    local curPos = projectileData.origin + (projectileData.velocity:Scaled(t))

    local range = (curPos - projectileData.origin):Length2D() 
    local knownRange = AutoDodger2.knownRanges[projectileData.index]

    if knownRange == nil or knownRange < range then
        AutoDodger2.knownRanges[projectileData.index] = range
    end 

    AutoDodger2.activeProjectiles[projectile.handle] = nil
end
--------------------------------------------------------------------------------------------------
function AutoDodger2.OnUnitAnimation(animation)
    if not Menu.IsEnabled(AutoDodger2.option) then return end
    if not animation or not animation.unit then return end

    local myHero = Heroes.GetLocal()
    if not myHero or Entity.IsSameTeam(myHero, animation.unit) or not NPC.IsHero(animation.unit) then return end
    
    local sequenceName = animation.sequenceName
    local enemy = animation.unit
    local enemyName = NPC.GetUnitName(animation.unit)

    --Log.Write(animation.sequenceName.."    Animation")
    if AutoDodger2.animationMap[sequenceName] and AutoDodger2.animationMapReverse[AutoDodger2.animationMap[sequenceName].ability].selected then
        Log.Write("Yay")
        AutoDodger2.AnimationQueue[sequenceName] ={
            time = GameRules.GetGameTime()+animation.castpoint,
            sequenceName = sequenceName,
            enemy = enemy,
            enemyName = enemyName,
            castPoint = animation.castpoint
        }
        AutoDodger2.AnimationQueueLength = AutoDodger2.AnimationQueueLength + 1
    end 
end 

function AutoDodger2.OnPrepareUnitOrders(orders)
    if not Menu.IsEnabled(AutoDodger2.option) then return true end
    if GameRules.GetGameTime()>AutoDodger2.dodgeTick then return true end 
    return false
end
--------------------------------------------------------------------------------------------------
function AutoDodger2.OnParticleCreate(particle)
    --Log.Write(particle.name)
    if not Menu.IsEnabled(AutoDodger2.option) then return end
    for i, v in ipairs(AutoDodger2.particleLogic) do
        v:OnParticleCreate(particle, AutoDodger2.activeProjectiles)
    end
end

function AutoDodger2.OnParticleUpdate(particle)
    if not Menu.IsEnabled(AutoDodger2.option) then return end

    for i, v in ipairs(AutoDodger2.particleLogic) do
        v:OnParticleUpdate(particle, AutoDodger2.activeProjectiles, AutoDodger2.knownRanges)
    end
end

function AutoDodger2.OnParticleUpdateEntity(particle)
    if not Menu.IsEnabled(AutoDodger2.option) then return end

    for i, v in ipairs(AutoDodger2.particleLogic) do
        v:OnParticleUpdateEntity(particle, AutoDodger2.activeProjectiles)
    end
end

function AutoDodger2.OnParticleDestroy(particle)
    if not Menu.IsEnabled(AutoDodger2.option) then return end

    for i, v in ipairs(AutoDodger2.particleLogic) do
        v:OnParticleDestroy(particle, AutoDodger2.activeProjectiles)
    end
end
------------------------------------------------------------------------------------------------------
function AutoDodger2.ProcessProjectile()
    local min = 999999999
    local candidateKey = nil
    for k,v in pairs(AutoDodger2.projectileQueue) do  
        local myPos = Entity.GetAbsOrigin(v.target)
        local enemyPos = v.origin

        local distance = myPos - enemyPos 
        local distanceLenth = distance:Length2D() - NPC.GetHullRadius(v.target) - Menu.GetValue(AutoDodger2.impactDistanceOption)

        local delay = (distanceLenth/v.moveSpeed) 
        delay = math.max(delay, 0.00)
        AutoDodger2.projectileQueue[k].dodgeTime = delay + v.time
        if v.dodgeTime< min then 
            min = v.dodgeTime
            candidateKey=k
        end 
    end

    if min~= 999999999 then 
        AutoDodger2.nextDodgeTimeProjectile = min
    end 

    local curtime = GameRules.GetGameTime()

    if curtime< AutoDodger2.nextDodgeTimeProjectile  then return end
    if AutoDodger2.projectileQueueLength  == 0 then return end 
    local myHero = Heroes.GetLocal()
    if not Entity.IsAlive(myHero) then return end

    if candidateKey then 
        AutoDodger2.DodgeLogicProjectile(candidateKey, "projectile")
        AutoDodger2.projectileQueue[candidateKey] = nil
        AutoDodger2.projectileQueueLength = AutoDodger2.projectileQueueLength - 1
    end 
    AutoDodger2.nextDodgeTimeProjectile = min
end

function AutoDodger2.ProcessLinearProjectile()
    if not Menu.IsEnabled(AutoDodger2.linearOption) then return end

    local curtime = GameRules.GetGameTime()

    if curtime < AutoDodger2.nextDodgeTime then return end

    local myHero = Heroes.GetLocal()

    if not Entity.IsAlive(myHero) then return end

    local myPos = Entity.GetAbsOrigin(myHero)

    local movePositions = {}

    -- simulate projectiles.
    for k, v in pairs(AutoDodger2.activeProjectiles) do
        local t = curtime - v.time

        local projectileDir = v.velocity:Normalized()
        
        local curPos = v.origin + v.velocity:Scaled(t)

        local dir = (curPos - myPos)
        local impactPos = curPos + projectileDir:Scaled(dir:Length2D())
        local endPos = v.origin + projectileDir:Scaled(AutoDodger2.GetRange(v.index))

        -- do not dodge if ahead of the impact point, and do not dodge if ahead of the max range of the projectile.
        if (impactPos - curPos):Dot(projectileDir) > 0 and (endPos - impactPos):Dot(projectileDir) > 0 and NPC.IsPositionInRange(myHero, impactPos, AutoDodger2.impactRadius) then 
            if Menu.GetValue(AutoDodger2.skillItemOption) then
                local dodged = AutoDodger2.DodgeLogicItem(key, mode, false) 
                AutoDodger2.DodgeLogicSkill(key, mode, dodged)
            else
                local dodged = AutoDodger2.DodgeLogicSkill(key, mode,false)
                AutoDodger2.DodgeLogicItem(key, mode, dodged) 
            end 
        end
    end

    -- if #movePositions == 0 then
    --     AutoDodger2.active = false
    --     return
    -- end

    -- AutoDodger2.movePos = Vector()

    -- for k, v in pairs(movePositions) do
    --     AutoDodger2.movePos = AutoDodger2.movePos + v
    -- end

    -- AutoDodger2.movePos = Vector(AutoDodger2.movePos:GetX() / #movePositions, AutoDodger2.movePos:GetY() / #movePositions, myPos:GetZ())
    -- if NPC.IsChannellingAbility(myHero) then return end 
    -- Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, nil, AutoDodger2.movePos, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero, false, true)

    AutoDodger2.nextDodgeTime = GameRules.GetGameTime() + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) + 0.03
    AutoDodger2.active = true
end

function AutoDodger2.ProcessChoosingSkills()

end 

function AutoDodger2.ProcessAnimation()
    if not Menu.IsEnabled(AutoDodger2.option) then return end 
    if not Menu.IsEnabled(AutoDodger2.animationOption) then return end 
    local myHero = Heroes.GetLocal()
    if not myHero then return end 
    
    AutoDodger2.OnOtherAnimationCreation()
    --Log.Write(AutoDodger2.AnimationQueueLength)
    local min = 999999999
    local candidateKey = nil
    --Log.Write(AutoDodger2.AnimationQueueLength)
    for k,v in pairs(AutoDodger2.AnimationQueue) do
           
        local skillName = AutoDodger2.animationMap[v.sequenceName].ability
        local skill = NPC.GetAbility(v.enemy, skillName)
        if not Ability.IsInAbilityPhase(skill) then
            AutoDodger2.AnimationQueue[k]=nil
            AutoDodger2.AnimationQueueLength =AutoDodger2.AnimationQueueLength -1
        else
            if min>v.time then 
                min = v.time
                candidateKey = k
            end 
        end 
    end

    if candidateKey then 
        AutoDodger2.nextDodgeTimeAnimation = min
    end 

    local curtime = GameRules.GetGameTime()

    if curtime < AutoDodger2.nextDodgeTimeAnimation-Menu.GetValue(AutoDodger2.castPointOption)/40  then return end
    if AutoDodger2.AnimationQueueLength == 0 then return end 
    local myHero = Heroes.GetLocal()
    if not Entity.IsAlive(myHero) then return end

    
    if candidateKey and AutoDodger2.isTargetMe(myHero, AutoDodger2.AnimationQueue[candidateKey].enemy, AutoDodger2.AnimationQueue[candidateKey].sequenceName ) then
        AutoDodger2.DodgeLogicProjectile(candidateKey,"animation") 
        AutoDodger2.AnimationQueue[candidateKey] = nil
        AutoDodger2.AnimationQueueLength = AutoDodger2.AnimationQueueLength - 1
    end 
    AutoDodger2.nextDodgeTimeAnimation= min
end 

function AutoDodger2.OnOtherAnimationCreation()
    local myHero = Heroes.GetLocal()
    local myTeam = Entity.GetTeamNum(myHero)

    for i = 1, Heroes.Count() do
        local hero = Heroes.Get(i)
        if not NPC.IsIllusion(hero) then
            local sameTeam = Entity.GetTeamNum(hero) == myTeam
            if not sameTeam then
                local enemyName = NPC.GetUnitName(hero)
                if AutoDodger2.otherAnimationMapHelper[enemyName] then
                    for j =1,#AutoDodger2.otherAnimationMapHelper[enemyName] do
                        local skillName =  AutoDodger2.otherAnimationMapHelper[enemyName][j]
                        local skill = NPC.GetAbility(hero, skillName)
                        if Ability.IsInAbilityPhase(skill) and not AutoDodger2.AnimationQueue[skillName] and AutoDodger2.animationMap[skillName] and AutoDodger2.animationMap[skillName].selected then 
                            --Log.Write(skillName)
                            AutoDodger2.AnimationQueue[skillName] ={
                                time = GameRules.GetGameTime()+Ability.GetCastPoint(skill),
                                sequenceName = skillName,
                                enemy = hero,
                                enemyName = enemyName,
                                castPoint = Ability.GetCastPoint(skill)
                            }
                            AutoDodger2.AnimationQueueLength = AutoDodger2.AnimationQueueLength + 1
                        end 
                    end 
                end 
            end
        end
    end
end 

-- AutoDodger2.AnimationQueue[sequenceName] ={
--             time = GameRules.GetGameTime()+animation.castpoint,
--             sequenceName = sequenceName,
--             enemy = enemy,
--             enemyName = enemyName,
--             castPoint = animation.castpoint
--         }
function AutoDodger2.isTargetMe(myHero,enemy, sequenceName)
    local angle = Entity.GetRotation(enemy)
    local angleOffset = Angle(0, 45, 0)
    angle:SetYaw(angle:GetYaw() + angleOffset:GetYaw())
    local x,y,z = angle:GetVectors()
    local direction = x + y + z
    local name = NPC.GetUnitName(enemy)
    direction:SetZ(0)


    local skillName = AutoDodger2.animationMap[sequenceName].ability
    local skill = NPC.GetAbility(enemy, skillName)
    local level = Ability.GetLevel(skill)
    local castRange = AutoDodger2.animationMap[sequenceName].castRange[level]
    local radius = AutoDodger2.animationMap[sequenceName].radius[level]
    local origin = NPC.GetAbsOrigin(enemy)

    local pointsNum = math.floor(castRange/25) + 1
    for i = pointsNum,1,-1 do 
        direction:Normalize()
        Log.Write(25*(i-1))
        direction:Scale(25*(i-1))
        Log.Write(direction:Length2D())
        local pos = direction + origin

        if NPC.IsPositionInRange(myHero, pos, radius + NPC.GetHullRadius(myHero), 0) then 
            Log.Write("yes")
            return true 
        end
    end 
    return false
end 
        -- AutoDodger2.AnimationQueue[skillName] ={
        --     time = GameRules.GetGameTime(),
        --     sequenceName = sequenceName,
        --     enemy = enemy,
        --     enemyName = enemyName,
        --     castPoint = unit.castpoint
        -- }
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AutoDodger2.OnDraw()
    if not Engine.IsInGame() or not Menu.IsEnabled(AutoDodger2.option) then
        AutoDodger2.Reset()
        return
    end
    local myHero = Heroes.GetLocal()
    if not Menu.IsEnabled(AutoDodger2.skillPickerOption) then return end

    local myHero = Heroes.GetLocal()

    if not myHero then return end

    if AutoDodger2.needsInit then
        AutoDodger2.InitDisplay()
        AutoDodger2.needsInit = false
    end
    local EnemyCount = 0
    for i = 1, Heroes.Count() do
        local hero = Heroes.Get(i)
        
        if not Entity.IsSameTeam(myHero, hero) and not NPC.IsIllusion(hero) then
            EnemyCount = EnemyCount + 1
            AutoDodger2.DrawDisplay(hero, AutoDodger2.w, AutoDodger2.h - (EnemyCount-1)*(AutoDodger2.boxSize+2))
        end
    end

    --Log.Write(Entity.GetRotation(myHero):__tostring())
end
---------------------------------------------------------------------------------------------------------------------------------------------------------
function AutoDodger2.OnMenuOptionChange(option, old, new)
    if option == AutoDodger2.boxSizeOption then
        AutoDodger2.InitDisplay()
    elseif option == AutoDodger2.daggerOption or option == AutoDodger2.blademailOption or
           option == AutoDodger2.ghostOption or option == AutoDodger2.mantaOption or option == AutoDodger2.eulOption or 
           option == AutoDodger2.lotusOption or option == AutoDodger2.sbOption or
           option == AutoDodger2.bkbOption or option == AutoDodger2.capeOption then 
        AutoDodger2.setItemOrder()
    end 
end

function AutoDodger2.DrawDisplay(hero, x,y)

    local abilities = {}

    for i = 0, 24 do
        local ability = NPC.GetAbilityByIndex(hero, i)
        if ability ~= nil and Entity.IsAbility(ability) and not Ability.IsHidden(ability) and not Ability.IsAttributes(ability) then
            if AutoDodger2.animationMapReverse[Ability.GetName(ability)] or AutoDodger2.animationMap[Ability.GetName(ability)] or AutoDodger2.projectileMapRev[Ability.GetName(ability)]  then 
                table.insert(abilities, ability)
            end 
        end
    end

    local startX = x - math.floor((#abilities / 2) * AutoDodger2.boxSize)

    Renderer.DrawFilledRect(startX + 1, y - 1, (AutoDodger2.boxSize * #abilities) + 2, AutoDodger2.boxSize + 2)

    -- draw the actual ability squares now
    for i, ability in ipairs(abilities) do
        AutoDodger2.DrawAbilitySquare(hero, ability, startX, y, i - 1)
    end

    -- black border
    Renderer.SetDrawColor(0, 0, 0, 255)
    Renderer.DrawOutlineRect(startX + 1, y - 1, (AutoDodger2.boxSize * #abilities) + 2, AutoDodger2.boxSize + 2)
end

function AutoDodger2.DrawAbilitySquare(hero, ability, x, y, index)
    local abilityName = Ability.GetName(ability)
    local imageHandle = AutoDodger2.cachedIcons[abilityName]

    if imageHandle == nil then
        imageHandle = Renderer.LoadImage(AutoDodger2.spellIconPath .. abilityName .. ".png")
        AutoDodger2.cachedIcons[abilityName] = imageHandle
    end

    local realX = x + (index * AutoDodger2.boxSize) + 2

    -- default colors = can cast
    local imageColor = { 255, 255, 255 }
    local outlineColor = { 0, 255 , 0 }
    local hoveringOver = Input.IsCursorInRect(realX, y, AutoDodger2.boxSize, AutoDodger2.boxSize)
    if not hoveringOver then
        --if Ability.GetLevel(ability) == 0 then
            imageColor = { 125, 125, 125 }
            outlineColor = { 255, 0, 0 }
       -- elseif Ability.GetManaCost(ability) > NPC.GetMana(hero) then
            --imageColor = { 150, 150, 255 }
           -- outlineColor = { 0, 0, 255 }
        --else
            --imageColor = { 255, 150, 150 }
            --outlineColor = { 255, 0, 0 }
        --end
    end

    if hoveringOver and Input.IsKeyDownOnce(Enum.ButtonCode.MOUSE_LEFT) then
        if Menu.IsEnabled(AutoDodger2.skillPickerOption) then 
            if AutoDodger2.animationMapReverse[abilityName] then
                AutoDodger2.animationMapReverse[abilityName].selected = not AutoDodger2.animationMapReverse[abilityName].selected
            end 
            if AutoDodger2.animationMap[abilityName] then
                AutoDodger2.animationMap[abilityName].selected = not AutoDodger2.animationMap[abilityName].selected
            end 
            if AutoDodger2.projectileMapRev[abilityName] then 
                AutoDodger2.projectileMapRev[abilityName].selected = not AutoDodger2.projectileMapRev[abilityName].selected
            end 
        end 
    end

    if AutoDodger2.animationMapReverse[abilityName] and AutoDodger2.animationMapReverse[abilityName].selected or AutoDodger2.animationMap[abilityName] and AutoDodger2.animationMap[abilityName].selected or AutoDodger2.projectileMapRev[abilityName] and AutoDodger2.projectileMapRev[abilityName].selected then 
        imageColor = { 255, 255, 255 }
        outlineColor = { 0, 255 , 0 }
    end 

    Renderer.SetDrawColor(imageColor[1], imageColor[2], imageColor[3], 255)
    Renderer.DrawImage(imageHandle, realX, y, AutoDodger2.boxSize, AutoDodger2.boxSize)

    Renderer.SetDrawColor(outlineColor[1], outlineColor[2], outlineColor[3], 255)
    Renderer.DrawOutlineRect(realX, y, AutoDodger2.boxSize, AutoDodger2.boxSize)

    -- local cdLength = Ability.GetCooldownLength(ability)

    -- if not Ability.IsReady(ability) and cdLength > 0.0 then
    --     local cooldownRatio = Ability.GetCooldown(ability) / cdLength
    --     local cooldownSize = math.floor(AutoDodger2.innerBoxSize * cooldownRatio)

    --     Renderer.SetDrawColor(255, 255, 255, 50)
    --     Renderer.DrawFilledRect(realX + 1, y + (AutoDodger2.innerBoxSize - cooldownSize) + 1, AutoDodger2.innerBoxSize, cooldownSize)

    --     Renderer.SetDrawColor(255, 255, 255)
    --     Renderer.DrawText(AutoDodger2.font, realX + 1, y, math.floor(Ability.GetCooldown(ability)), 0)
    -- end

    -- AutoDodger2.DrawAbilityLevels(ability, realX, y)
end

function AutoDodger2.DrawAbilityLevels(ability, x, y)
    local level = Ability.GetLevel(ability)

    x = x + 1
    y = ((y + AutoDodger2.boxSize) - AutoDodger2.levelBoxSize) - 1

    local color = AutoDodger2.colors[Menu.GetValue(AutoDodger2.levelColorOption)]

    for i = 1, level do
        Renderer.SetDrawColor(color.r, color.g, color.b, 255)
        Renderer.DrawFilledRect(x + ((i - 1) * AutoDodger2.levelBoxSize), y, AutoDodger2.levelBoxSize, AutoDodger2.levelBoxSize)
        
        Renderer.SetDrawColor(0, 0, 0, 255)
        Renderer.DrawOutlineRect(x + ((i - 1) * AutoDodger2.levelBoxSize), y, AutoDodger2.levelBoxSize, AutoDodger2.levelBoxSize)
    end
end
-----------------------------------------------------------------------------------------------------------------------------------------------------------

AutoDodger2.animationMap ={}
AutoDodger2.animationMapReverse={}
AutoDodger2.otherAnimationMapHelper={}

AutoDodger2.animationMap['chronosphere_anim']={ability="faceless_void_chronosphere", castRange={600,600,600,600}, radius={425,425,425,425}, item={'item_blink','item_ghost','item_blade_mail','item_manta','item_cyclone'}}
AutoDodger2.animationMapReverse["faceless_void_chronosphere"]={anim='chronosphere_anim', selected=false}
AutoDodger2.animationMap['cast_time_dilation']={ability="faceless_void_time_dilation", castRange={0,0,0,0}, radius={725,725,725,725}}
AutoDodger2.animationMapReverse["faceless_void_time_dilation"]={anim='cast_time_dilation', selected=false}
AutoDodger2.animationMap['impale_anim']={ability="lion_impale", castRange={500,500,500,500}, radius={125,125,125,125}, speed=1600}
AutoDodger2.animationMapReverse["lion_impale"]={anim='impale_anim', selected=fasle}
-- AutoDodger2.animationMap['shield_storm_bolt']={ability="sven_storm_bolt", castRange={600,600,600,600}, radius={125,125,125,125}}
-- AutoDodger2.animationMapReverse["sven_storm_bolt"]={anim='shield_storm_bolt', selected=fasle}
AutoDodger2.animationMap['cast_purification_anim']={ability="omniknight_purification", castRange={600,600,600,600}, radius={125,125,125,125}}
AutoDodger2.animationMapReverse["omniknight_purification"]={anim='cast_purification_anim', selected=fasle}
AutoDodger2.animationMap['cast4_primal_roar_anim']={ability="beastmaster_primal_roar", castRange={600,600,600,600}, radius={0,0,0,0}}
AutoDodger2.animationMapReverse["beastmaster_primal_roar"]={anim='cast4_primal_roar_anim', selected=fasle}
AutoDodger2.animationMap['legion_commander_duel_anim']={ability="legion_commander_duel", castRange={150,150,150,150}, radius={0,0,0,0}}
AutoDodger2.animationMapReverse["legion_commander_duel"]={anim='legion_commander_duel_anim', selected=fasle}
-- AutoDodger2.animationMap['cast1_hellfire_blast']={ability="skeleton_king_hellfire_blast", castRange={525,525,525,525}, radius={0,0,0,0}}
-- AutoDodger2.animationMapReverse["skeleton_king_hellfire_blast"]={anim='cast1_hellfire_blast', selected=fasle}
AutoDodger2.animationMap['cast_hoofstomp_anim']={ability="centaur_hoof_stomp", castRange={0,0,0,0}, radius={315,315,315,315}}
AutoDodger2.animationMapReverse["centaur_hoof_stomp"]={anim='cast_hoofstomp_anim', selected=fasle}
AutoDodger2.animationMap['fissure_anim']={ability="earthshaker_fissure", castRange={1350,1350,1350,1350}, radius={225,225,225,225}}
AutoDodger2.animationMapReverse["earthshaker_fissure"]={anim='fissure_anim', selected=fasle}
AutoDodger2.animationMap['crush_anim']={ability="slardar_slithereen_crush", castRange={0,0,0,0}, radius={350,350,350,350}}
AutoDodger2.animationMapReverse["slardar_slithereen_crush"]={anim='crush_anim', selected=fasle}
AutoDodger2.animationMap['amp_anim']={ability="slardar_amplify_damage", castRange={700,700,700,700}, radius={0,0,0,0}}
AutoDodger2.animationMapReverse["slardar_amplify_damage"]={anim='amp_anim', selected=fasle}
AutoDodger2.animationMap['cast_doom_anim']={ability="doom_bringer_doom", castRange={550,550,550,550}, radius={0,0,0,0}}
AutoDodger2.animationMapReverse["doom_bringer_doom"]={anim='cast_doom_anim', selected=fasle}
-- AutoDodger2.animationMap['chaosbolt_anim']={ability="chaos_knight_chaos_bolt", castRange={500,500,500,500}, radius={0,0,0,0}}
-- AutoDodger2.animationMapReverse["chaos_knight_chaos_bolt"]={anim='chaosbolt_anim', selected=fasle}
AutoDodger2.animationMap['ultimate_anim']={ability="spirit_breaker_nether_strike", castRange={700,700,700,700}, radius={0,0,0,0}}
AutoDodger2.animationMapReverse["spirit_breaker_nether_strike"]={anim='ultimate_anim', selected=fasle}
AutoDodger2.animationMap['Thunderclap_anim']={ability="brewmaster_thunder_clap", castRange={0,0,0,0}, radius={400,400,400,400}}
AutoDodger2.animationMapReverse["brewmaster_thunder_clap"]={anim='Thunderclap_anim', selected=fasle}
AutoDodger2.animationMap['polarity_anim']={ability="magnataur_reverse_polarity", castRange={0,0,0,0}, radius={410,410,410,410}}
AutoDodger2.animationMapReverse["magnataur_reverse_polarity"]={anim='polarity_anim', selected=fasle}
AutoDodger2.animationMap['shockWave_anim']={ability="magnataur_shockwave", castRange={1150,1150,1150,1150}, radius={150,150,150,150}, speed=1050}
AutoDodger2.animationMapReverse["magnataur_shockwave"]={anim='shockWave_anim', selected=fasle}
AutoDodger2.animationMap['waveform_launch_anim']={ability="morphling_waveform", castRange={1000,1000,1000,1000}, radius={200,200,200,200},speed=1250}
AutoDodger2.animationMapReverse["morphling_waveform"]={anim='waveform_launch_anim', selected=fasle}
AutoDodger2.animationMap['attack_omni_cast']={ability="juggernaut_omni_slash", castRange={350,350,350,350}, radius={50,50,50,50}}
AutoDodger2.animationMapReverse["juggernaut_omni_slash"]={anim='attack_omni_cast', selected=fasle}
AutoDodger2.animationMap['cast4_sirenSong_anim']={ability="naga_siren_song_of_the_siren", castRange={0,0,0,0}, radius={1250,1250,1250,1250}}
AutoDodger2.animationMapReverse["naga_siren_song_of_the_siren"]={anim='cast4_sirenSong_anim', selected=fasle}
AutoDodger2.animationMap['cast6_requiem_anim']={ability="nevermore_requiem", castRange={0,0,0,0}, radius={1425,1425,1425,1425}}
AutoDodger2.animationMapReverse["nevermore_requiem"]={anim='cast6_requiem_anim', selected=fasle}
AutoDodger2.animationMap['cast_savage_roar']={ability="lone_druid_savage_roar", castRange={0,0,0,0}, radius={325,325,325,325}}
AutoDodger2.animationMapReverse["lone_druid_savage_roar"]={anim='cast_savage_roar', selected=fasle}
AutoDodger2.animationMap['sunder']={ability="terrorblade_sunder", castRange={550,550,550,550}, radius={50,50,50,50}}
AutoDodger2.animationMapReverse["terrorblade_sunder"]={anim='sunder', selected=fasle}
AutoDodger2.animationMap['basher_cast4_mana_void_anim']={ability="antimage_mana_void", castRange={600,600,600,600}, radius={50,50,50,50}}
AutoDodger2.animationMapReverse["antimage_mana_void"]={anim='basher_cast4_manma_void_anim', selected=fasle}
AutoDodger2.animationMap['laser_anim']={ability="tinker_laser", castRange={650,650,650,650}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["tinker_laser"]={anim='laser_anim', selected=fasle}
AutoDodger2.animationMapReverse[""]={anim='laser_anim', selected=fasle}
AutoDodger2.animationMap['zeus_lightning_cast2_arcana']={ability="zuus_lightning_bolt", castRange={700,700,700,700}, radius={50,50,50,50}}
AutoDodger2.animationMapReverse["zuus_lightning_bolt"]={anim='zeus_lightning_cast2_arcana', selected=fasle}
AutoDodger2.animationMap['cast04_winters_curse_flying_low_anim']={ability="winter_wyvern_winters_curse", castRange={800,800,800,800}, radius={500,500,500,500}}
AutoDodger2.animationMapReverse["winter_wyvern_winters_curse"]={anim='cast04_winters_curse_flying_low_anim', selected=fasle}
AutoDodger2.animationMap['staff_split_earth_anim']={ability="leshrac_split_earth", castRange={750,750,750,750}, radius={150,175,200,225}}
AutoDodger2.animationMapReverse["leshrac_split_earth"]={anim='staff_split_earth_anim', selected=fasle}
AutoDodger2.animationMap['rubick_cast_fadebolt_anim']={ability="rubick_fade_bolt", castRange={800,800,800,800}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["rubick_fade_bolt"]={anim='rubick_cast_fadebolt_anim', selected=fasle}
AutoDodger2.animationMap['staff_lightning_storm_anim']={ability="leshrac_lightning_storm", castRange={800,800,800,800}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["leshrac_lightning_storm"]={anim='staff_lightning_storm_anim', selected=fasle}
AutoDodger2.animationMap['cast_channel_shackles_anim']={ability="shadow_shaman_shackles", castRange={400,400,400,400}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["shadow_shaman_shackles"]={anim='cast_channel_shackles_anim', selected=fasle}
AutoDodger2.animationMap['cast_ether_shock_anim']={ability="shadow_shaman_ether_shock", castRange={600,600,600,600}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["shadow_shaman_ether_shock"]={anim='cast_ether_shock_anim', selected=fasle}
AutoDodger2.animationMap['frost_nova_anim']={ability="lich_frost_nova", castRange={600,600,600,600}, radius={200,200,200,200}}
AutoDodger2.animationMapReverse["lich_frost_nova"]={anim='frost_nova_anim', selected=fasle}
AutoDodger2.animationMap['chain_frost_anim']={ability="lich_chain_frost", castRange={750,750,750,750}, radius={15,15,15,15}}
AutoDodger2.animationMapReverse["lich_chain_frost"]={anim='chain_frost_anim', selected=fasle}
AutoDodger2.animationMap['cast1_carrionSwarm']={ability="death_prophet_carrion_swarm", castRange={810,810,810,810}, radius={200,200,200,200}}
AutoDodger2.animationMapReverse["death_prophet_carrion_swarm"]={anim='cast1_carrionSwarm', selected=fasle}
AutoDodger2.animationMap['cast2_silence_anim']={ability="death_prophet_silence", castRange={900,900,900,900}, radius={425,425,425,425}}
AutoDodger2.animationMapReverse["death_prophet_silence"]={anim='cast2_silence_anim', selected=fasle}
AutoDodger2.animationMap['cast_ulti_anim']={ability="obsidian_destroyer_sanity_eclipse", castRange={700,700,700,700}, radius={375,475,575,575}}
AutoDodger2.animationMapReverse["obsidian_destroyer_sanity_eclipse"]={anim='cast_ulti_anim', selected=fasle}
AutoDodger2.animationMap['frostbite_anim']={ability="crystal_maiden_frostbite", castRange={525,525,525,525}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["crystal_maiden_frostbite"]={anim='frostbite_anim', selected=fasle}
AutoDodger2.animationMap['nova_anim']={ability="crystal_maiden_crystal_nova", castRange={700,700,700,700}, radius={425,425,425,425}}
AutoDodger2.animationMapReverse["crystal_maiden_crystal_nova"]={anim='nova_anim', selected=fasle}
AutoDodger2.animationMap['cast_LW_anim']={ability="silencer_last_word", castRange={900,900,900,900}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["silencer_last_word"]={anim='cast_LW_anim', selected=fasle}
AutoDodger2.animationMap['warlock_cast2_shadow_word_anim']={ability="warlock_shadow_word", castRange={525,600,675,750}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["warlock_shadow_word"]={anim='warlock_cast2_shadow_word_anim', selected=fasle}
AutoDodger2.animationMap['warlock_cast4_rain_chaos_anim']={ability="warlock_rain_of_chaos", castRange={1200,1200,1200,1200}, radius={600,600,600,600}}
AutoDodger2.animationMapReverse["warlock_rain_of_chaos"]={anim='warlock_cast4_rain_chaos_anim', selected=fasle}
AutoDodger2.animationMap['earthshock_anim']={ability="ursa_earthshock", castRange={0,0,0,0}, radius={385,385,385,385}}
AutoDodger2.animationMapReverse["ursa_earthshock"]={anim='earthshock_anim', selected=fasle}
AutoDodger2.animationMap['queen_sonicwave_anim']={ability="queenofpain_sonic_wave", castRange={900,900,900,900}, radius={450,450,450,450}}
AutoDodger2.animationMapReverse["queenofpain_sonic_wave"]={anim='queen_sonicwave_anim', selected=fasle}
AutoDodger2.animationMap['cast3_Purifying_Flames_anim']={ability="oracle_purifying_flames", castRange={800,800,800,800}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["oracle_purifying_flames"]={anim='cast3_Purifying_Flames_anim', selected=fasle}
AutoDodger2.animationMap['cast_ult_anim']={ability="necrolyte_reapers_scythe", castRange={600,600,600,600}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["necrolyte_reapers_scythe"]={anim='cast_ult_anim', selected=fasle}
AutoDodger2.animationMap['fiends_grip_cast_anim']={ability="bane_fiends_grip", castRange={600,600,600,600}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["bane_fiends_grip"]={anim='fiends_grip_cast_anim', selected=fasle}
AutoDodger2.animationMap['brain_sap_anim']={ability="bane_brain_sap", castRange={600,600,600,600}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["bane_brain_sap"]={anim='brain_sap_anim', selected=fasle}
AutoDodger2.animationMap['nightmare_anim']={ability="bane_nightmare", castRange={500,550,600,650}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["bane_nightmare"]={anim='nightmare_anim', selected=fasle}
AutoDodger2.animationMap['dragon_slave_anim']={ability="lina_dragon_slave", castRange={1075,1075,1075,1075}, radius={275,275,275,275}}
AutoDodger2.animationMapReverse["lina_dragon_slave"]={anim='dragon_slave_anim', selected=fasle}
AutoDodger2.animationMap['light_strike_array_lhand_anim']={ability="lina_light_strike_array", castRange={625,625,625,625}, radius={225,225,225,225}}
AutoDodger2.animationMapReverse["lina_light_strike_array"]={anim='light_strike_array_lhand_anim', selected=fasle}
AutoDodger2.animationMap['laguna_blade_anim']={ability="lina_laguna_blade", castRange={600,600,600,600}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["lina_laguna_blade"]={anim='laguna_blade_anim', selected=fasle}
AutoDodger2.animationMap['finger_anim']={ability="lion_finger_of_death", castRange={900,900,900,900}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["lion_finger_of_death"]={anim='finger_anim', selected=fasle}
AutoDodger2.animationMap['lasso_start_anim']={ability="batrider_flaming_lasso", castRange={100,100,100,100}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["batrider_flaming_lasso"]={anim='lasso_start_anim', selected=fasle}
AutoDodger2.animationMap['cast1_malefice_anim']={ability="enigma_malefice", castRange={600,600,600,600}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["enigma_malefice"]={anim='cast1_malefice_anim', selected=fasle}
AutoDodger2.animationMap['cast4_black_hole_anim']={ability="enigma_black_hole", castRange={275,275,275,275}, radius={420,420,420,420}}
AutoDodger2.animationMapReverse["enigma_black_hole"]={anim='cast4_black_hole_anim', selected=fasle}
AutoDodger2.animationMap['cast1_penitence_anim']={ability="chen_penitence", castRange={800,800,800,800}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["chen_penitence"]={anim='cast1_penitence_anim', selected=fasle}
AutoDodger2.animationMap['cast2_testoffaith_anim']={ability="chen_test_of_faith", castRange={600,600,600,600}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["chen_test_of_faith"]={anim='cast2_testoffaith_anim', selected=fasle}
AutoDodger2.animationMap['cast1_fireblast_anim']={ability="ogre_magi_fireblast", castRange={475,475,475,475}, radius={50,50,50,50}}
AutoDodger2.animationMapReverse["ogre_magi_fireblast"]={anim='cast1_fireblast_anim', selected=fasle}
AutoDodger2.animationMap['cast1_fireblast_withUltiSceptre_anim']={ability="ogre_magi_unrefined_fireblast", castRange={475,475,475,475}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["ogre_magi_unrefined_fireblast"]={anim='cast1_fireblast_withUltiSceptre_anim', selected=fasle}
AutoDodger2.animationMap['enchant_anim']={ability="enchantress_enchant", castRange={700,700,700,700}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["enchantress_enchant"]={anim='enchant_anim', selected=fasle}
AutoDodger2.animationMap['vacuum_anim']={ability="dark_seer_vacuum", castRange={500,500,500,500}, radius={250,350,450,550}}
AutoDodger2.animationMapReverse["dark_seer_vacuum"]={anim='vacuum_anim', selected=fasle}
AutoDodger2.animationMap['cast4_rupture_anim']={ability="bloodseeker_rupture", castRange={1000,1000,1000,1000}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["bloodseeker_rupture"]={anim='cast4_rupture_anim', selected=fasle}
AutoDodger2.animationMap['cast_doubledgec_anim']={ability="centaur_double_edge", castRange={150,150,150,150}, radius={190,190,190,190}}
AutoDodger2.animationMapReverse["centaur_double_edge"]={anim='cast_doubledgec_anim', selected=fasle}
AutoDodger2.animationMap['pudge_dismember_start']={ability="pudge_dismember", castRange={160,160,160,160}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["pudge_dismember"]={anim='pudge_dismember_start', selected=fasle}
AutoDodger2.animationMap['x_mark_anim']={ability="kunkka_x_marks_the_spot", castRange={400,600,800,1000}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["kunkka_x_marks_the_spot"]={anim='x_mark_anim', selected=fasle}
AutoDodger2.animationMap['cast_void_nihility_anim']={ability="night_stalker_void", castRange={525,525,525,525}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["night_stalker_void"]={anim='cast_void_nihility_anim', selected=fasle}
AutoDodger2.animationMap['cast_cripplingfear_anim']={ability="night_stalker_crippling_fear", castRange={500,500,500,500}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["night_stalker_crippling_fear"]={anim='cast_cripplingfear_anim', selected=fasle}
AutoDodger2.animationMap['cast1_starfall']={ability="mirana_starfall", castRange={0,0,0,0}, radius={650,650,650,650}}
AutoDodger2.animationMapReverse["mirana_starfall"]={anim='cast1_starfall', selected=fasle}
AutoDodger2.animationMap['poof_digger_alt_anim']={ability="meepo_poof", castRange={0,0,0,0}, radius={375,375,375,375}}
AutoDodger2.animationMapReverse["meepo_poof"]={anim='poof_digger_alt_anim', selected=fasle}
AutoDodger2.animationMap['zeus_lightning_thundergods_wrath_arcana']={ability="zuus_thundergods_wrath", castRange={0,0,0,0}, radius={7000,7000,7000,7000}}
AutoDodger2.animationMapReverse["zuus_thundergods_wrath"]={anim='zeus_lightning_thundergods_wrath_arcana', selected=fasle}
AutoDodger2.animationMap['life drain_anim']={ability="pugna_life_drain", castRange={900,1050,1200,1200}, radius={50,50,50,50}}
AutoDodger2.animationMapReverse["pugna_life_drain"]={anim='life drain_anim', selected=fasle}
AutoDodger2.animationMap['bonkers_paralyzing_cask_anim']={ability="witch_doctor_paralyzing_cask", castRange={700,700,700,700}, radius={25,25,25,25}}
AutoDodger2.animationMapReverse["witch_doctor_paralyzing_cask"]={anim='life bonkers_paralyzing_cask_anim', selected=fasle}
AutoDodger2.animationMap['cast5_coil_anim']={ability="puck_dream_coil", castRange={750,750,750,750}, radius={375,375,375,375}}
AutoDodger2.animationMapReverse["puck_dream_coil"]={anim='cast5_coil_anim', selected=fasle}
AutoDodger2.animationMap['mana_burn_anim']={ability="nyx_assassin_mana_burn", castRange={750,750,750,750}, radius={375,375,375,375}}
AutoDodger2.animationMapReverse["nyx_assassin_mana_burn"]={anim='mana_burn_anim', selected=fasle}

AutoDodger2.animationMap['axe_berserkers_call']={ability="axe_berserkers_call",castRange={0,0,0,0}, radius={300,300,300,300}, selected=false}
AutoDodger2.animationMap['axe_culling_blade']={ability="axe_culling_blade",castRange={150,150,150,150}, radius={25,25,25,25},selected=false}
AutoDodger2.animationMap['axe_battle_hunger']={ability="axe_battle_hunger",castRange={750,750,750,750}, radius={25,25,25,25},selected=false}
AutoDodger2.otherAnimationMapHelper['npc_dota_hero_axe']={'axe_berserkers_call','axe_battle_hunger','axe_culling_blade'}
AutoDodger2.animationMap['undying_decay'] ={ability="undying_decay", castRange={650,650,650,650}, radius={325,325,325,325}, selected=false}
AutoDodger2.otherAnimationMapHelper['npc_dota_hero_undying']={'undying_decay'}
AutoDodger2.animationMap['chaos_knight_reality_rift']={ability="chaos_knight_reality_rift",castRange={550,600,650,700}, radius={0,0,0,0},selected=false}
AutoDodger2.otherAnimationMapHelper['npc_dota_hero_chaos_knight']={'chaos_knight_reality_rift'}
AutoDodger2.animationMap['nevermore_shadowraze1']={ability="nevermore_shadowraze1",castRange={200,200,200,200}, radius={250,250,250,250},selected=false}
AutoDodger2.animationMap['nevermore_shadowraze2']={ability="nevermore_shadowraze2",castRange={450,450,450,450}, radius={250,250,250,250},selected=false}
AutoDodger2.animationMap['nevermore_shadowraze3']={ability="nevermore_shadowraze3",castRange={700,700,700,700}, radius={250,250,250,250},selected=false}
AutoDodger2.otherAnimationMapHelper["npc_dota_hero_nevermore"]={'nevermore_shadowraze1','nevermore_shadowraze2','nevermore_shadowraze3'}
AutoDodger2.animationMap['bane_enfeeble']={ability="bane_enfeeble",castRange={1000,1000,1000,1000}, radius={25,25,25,25},selected=false}
AutoDodger2.otherAnimationMapHelper['npc_dota_hero_bane']={'bane_enfeeble'}
AutoDodger2.animationMap['huskar_life_break']={ability="huskar_life_break",castRange={550,550,550,550}, radius={25,25,25,25},selected=false}
AutoDodger2.otherAnimationMapHelper['npc_dota_hero_huskar']={'huskar_life_break'}
-- AutoDodger2.animationMap['tusk_walrus_punch']={ability="tusk_walrus_punch",castRange={150,150,150,150}, radius={25,25,25,25},selected=false}
-- AutoDodger2.otherAnimationMapHelper['npc_dota_hero_tusk']={'tusk_walrus_punch'}
AutoDodger2.animationMap['razor_static_link']={ability="razor_static_link",castRange={600,600,600,600}, radius={25,25,25,25},selected=false}
AutoDodger2.otherAnimationMapHelper['npc_dota_hero_razor']={'razor_static_link'}
AutoDodger2.animationMap['drow_ranger_wave_of_silence']={ability="drow_ranger_wave_of_silence",castRange={900,900,900,900}, radius={250,250,250,250},selected=false}
AutoDodger2.otherAnimationMapHelper['npc_dota_hero_drow_ranger']={'drow_ranger_wave_of_silence'}
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------

AutoDodger2.projectileMap = {}
AutoDodger2.projectileMapRev = {}

AutoDodger2.projectileMap['abaddon_death_coil'] = {ability='abaddon_death_coil'}  
AutoDodger2.projectileMapRev['abaddon_death_coil'] = {selected=true}
AutoDodger2.projectileMap['skeletonking_hellfireblast'] = {ability='skeleton_king_hellfire_blast'}  
AutoDodger2.projectileMapRev['skeleton_king_hellfire_blast'] = {selected=true}
AutoDodger2.projectileMap['UNKNKOWN_PARTICLE'] = {ability='tusk_snowball'}  
AutoDodger2.projectileMapRev['tusk_snowball'] = {selected=true}
AutoDodger2.projectileMap['sven_spell_storm_bolt'] = {ability='sven_storm_bolt'}  
AutoDodger2.projectileMapRev['sven_storm_bolt'] = {selected=true}
AutoDodger2.projectileMap['chaos_knight_chaos_bolt'] = {ability='chaos_knight_chaos_bolt'}  
AutoDodger2.projectileMapRev['chaos_knight_chaos_bolt'] = {selected=true}
AutoDodger2.projectileMap['tidehunter_gush'] = {ability='tidehunter_gush'}  
AutoDodger2.projectileMapRev['tidehunter_gush'] = {selected=true}
AutoDodger2.projectileMap['alchemist_unstable_concoction_projectile'] = {ability='alchemist_unstable_concoction'}  
AutoDodger2.projectileMapRev['alchemist_unstable_concoction'] = {selected=true}
AutoDodger2.projectileMap['brewmaster_drunken_haze'] = {ability='brewmaster_drunken_haze'}  
AutoDodger2.projectileMapRev['brewmaster_drunken_haze'] = {selected=true}
AutoDodger2.projectileMap['bristleback_viscous_nasal_goo'] = {ability='bristleback_viscous_nasal_goo'} 
AutoDodger2.projectileMapRev['bristleback_viscous_nasal_goo'] = {selected=true}
AutoDodger2.projectileMap['vengeful_magic_missle'] = {ability='vengefulspirit_magic_missile'} 
AutoDodger2.projectileMapRev['vengefulspirit_magic_missile'] = {selected=true}
AutoDodger2.projectileMap['siren_net_projectile'] = {ability='naga_siren_ensnare'} 
AutoDodger2.projectileMapRev['naga_siren_ensnare'] = {selected=true}
AutoDodger2.projectileMap['phantom_assassin_stifling_dagger'] = {ability='phantom_assassin_stifling_dagger'} 
AutoDodger2.projectileMapRev['phantom_assassin_stifling_dagger'] = {selected=true}
AutoDodger2.projectileMap['phantomlancer_spiritlance_projectile'] = {ability='phantom_lancer_spirit_lance'} 
AutoDodger2.projectileMapRev['phantom_lancer_spirit_lance'] = {selected=true}
AutoDodger2.projectileMap['spectre_spectral_dagger_tracking'] = {ability='spectre_spectral_dagger'} 
AutoDodger2.projectileMapRev['spectre_spectral_dagger'] = {selected=true}
AutoDodger2.projectileMap['sniper_assassinate'] = {ability='sniper_assassinate'} 
AutoDodger2.projectileMapRev['sniper_assassinate'] = {selected=true}
AutoDodger2.projectileMap['medusa_mystic_snake_projectile_initial'] = {ability='medusa_mystic_snake'} 
AutoDodger2.projectileMapRev['medusa_mystic_snake'] = {selected=true}
AutoDodger2.projectileMap['broodmother_web_cast'] = {ability='broodmother_spawn_spiderlings'} 
AutoDodger2.projectileMapRev['broodmother_spawn_spiderlings'] = {selected=true}
AutoDodger2.projectileMap['bounty_hunter_suriken_toss'] = {ability='bounty_hunter_shuriken_toss'} 
AutoDodger2.projectileMapRev['bounty_hunter_shuriken_toss'] = {selected=true}
AutoDodger2.projectileMap['tinker_missile'] = {ability='tinker_heat_seeking_missile'} 
AutoDodger2.projectileMapRev['tinker_heat_seeking_missile'] = {selected=true}
AutoDodger2.projectileMap['skywrath_mage_arcane_bolt'] = {ability='skywrath_mage_arcane_bolt'} 
AutoDodger2.projectileMapRev['skywrath_mage_arcane_bolt'] = {selected=true}
AutoDodger2.projectileMap['skywrath_mage_concussive_shot'] = {ability='skywrath_mage_concussive_shot'} 
AutoDodger2.projectileMapRev['skywrath_mage_concussive_shot'] = {selected=true}
AutoDodger2.projectileMap['dazzle_poison_touch'] = {ability='dazzle_poison_touch'} 
AutoDodger2.projectileMapRev['dazzle_poison_touch'] = {selected=true}
AutoDodger2.projectileMap['queen_scream_of_pain'] = {ability='queenofpain_scream_of_pain'} 
AutoDodger2.projectileMapRev['queenofpain_scream_of_pain'] = {selected=true}
AutoDodger2.projectileMap['queen_shadow_strike'] = {ability='queenofpain_shadow_strike'} 
AutoDodger2.projectileMapRev['queenofpain_shadow_strike'] = {selected=true}
AutoDodger2.projectileMap['necrolyte_pulse_enemy'] = {ability='necrolyte_death_pulse'} 
AutoDodger2.projectileMapRev['necrolyte_death_pulse'] = {selected=true}
AutoDodger2.projectileMap['oracle_fortune_prj'] = {ability='oracle_fortunes_end'} 
AutoDodger2.projectileMapRev['oracle_fortunes_end'] = {selected=true}
AutoDodger2.projectileMap['visage_soul_assumption_bolt'] = {ability='visage_soul_assumption'} 
AutoDodger2.projectileMapRev['visage_soul_assumption'] = {selected=true}
AutoDodger2.projectileMap['windrunner_shackleshot'] = {ability='windrunner_shackleshot'} 
AutoDodger2.projectileMapRev['windrunner_shackleshot'] = {selected=true}
AutoDodger2.projectileMap['orge_magi_ignite'] = {ability='ogre_magi_ignite'} 
AutoDodger2.projectileMapRev['ogre_magi_ignite'] = {selected=true}

AutoDodger2.ignoredDisjoint={}
AutoDodger2.ignoredDisjoint['tinker_laser'] = true
return AutoDodger2
local AutoDodger2 = {}

AutoDodger2.option = Menu.AddOption({"Utility", "Super Auto Dodger"}, "Auto Dodger", "Automatically dodges projectiles.")
AutoDodger2.impactRadiusOption = Menu.AddOption({"Utility", "Super Auto Dodger"}, "Impact Radius", "",100,1000,100)
AutoDodger2.impactDistanceOption = Menu.AddOption({"Utility", "Super Auto Dodger"}, "Safe Distance offset", "",100,2000,100)
-- logic for specific particle effects will go here.
AutoDodger2.optionKey = Menu.AddKeyOption({ "Utility","Super Auto Dodger"}, "Choose Skills to Disable",Enum.ButtonCode.KEY_Z)
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
AutoDodger2.queueLength = 0.0
AutoDodger2.impactRadius = 400
AutoDodger2.canReset = true

AutoDodger2.nextDodgeTime = 0.0
AutoDodger2.nextDodgeTimeProjectile = 0.0
AutoDodger2.movePos = Vector()
AutoDodger2.fountainPos = Vector()
AutoDodger2.active = false

AutoDodger2.mapFont = Renderer.LoadFont("Tahoma", 50, Enum.FontWeight.NORMAL)

AutoDodger2.skillOption = Menu.AddOption({ "Utility", "Super Auto Dodger", "Skill Picker"}, "Enable", "Displays enemy hero cooldowns in an easy and intuitive way.")
AutoDodger2.boxSizeOption = Menu.AddOption({ "Utility", "Super Auto Dodger", "Skill Picker" }, "Display Size", "", 21, 64, 1)
AutoDodger2.needsInit = true
AutoDodger2.spellIconPath = "resource/flash3/images/spellicons/"
AutoDodger2.cachedIcons = {}
AutoDodger2.w = 1920
AutoDodger2.h = 1080
AutoDodger2.colors = {}
AutoDodger2.skillSelected = {}

function AutoDodger2.InsertColor(alias, r_, g_, b_)
    table.insert(AutoDodger2.colors, { name = alias, r = r_, g = g_, b = b_})
end

AutoDodger2.InsertColor("Green", 0, 255, 0)
AutoDodger2.InsertColor("Yellow", 234, 255, 0)
AutoDodger2.InsertColor("Red", 255, 0, 0)
AutoDodger2.InsertColor("Blue", 0, 0, 255)
AutoDodger2.InsertColor("White", 255, 255, 255)
AutoDodger2.InsertColor("Black", 0, 0, 0)

AutoDodger2.levelColorOption = Menu.AddOption({ "Utility", "Super Auto Dodger","Skill Picker" }, "Level Color", "", 1, #AutoDodger2.colors, 1)

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
    --Log.Write(AutoDodger2.queueLength)
    if not Menu.IsEnabled(AutoDodger2.option) then return end
    AutoDodger2.ProcessLinearProjectile()
    AutoDodger2.ProcessProjectile()
    AutoDodger2.ProcessChoosingSkills()
end

--------------------------------------------------------------------------------------------------------
function AutoDodger2.DodgeLogicProjectile()
    local myHero = Heroes.GetLocal()
    local dodged = false
    local eul = NPC.GetItem(myHero, "item_cyclone")
    local lotus = NPC.GetItem(myHero, "item_lotus_orb")
    local bladeMail = NPC.GetItem(myHero, "item_blade_mail")
    local manta = NPC.GetItem(myHero, "item_manta") 

    local myTeam = Entity.GetTeamNum(myHero)
    local myMana = NPC.GetMana(myHero)
    local myPos = Entity.GetAbsOrigin(myHero)
    local myName = NPC.GetUnitName(myHero)

    if myName == "npc_dota_hero_puck" then 
        local skill = NPC.GetAbility(myHero, "puck_phase_shift")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then 
            Ability.CastNoTarget(skill)
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
            AutoDodger2.DodgeByMoveToForward(myHero, 1000, skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_storm_spirit" then 
        local skill = NPC.GetAbility(myHero, "storm_spirit_ball_lightning")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then
            AutoDodger2.DodgeByMoveForward(myHero, 200, skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_queenofpain" then 
        local skill = NPC.GetAbility(myHero, "queenofpain_blink")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then
            AutoDodger2.DodgeByMoveToForward(myHero, 1000, skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_faceless_void" then 
        local skill = NPC.GetAbility(myHero, "faceless_void_time_walk")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then
            AutoDodger2.DodgeByMoveToForward(myHero, 1000, skill)
            dodged = true
        end 
    end
    if myName == "npc_dota_hero_phantom_lancer" then 
        local skill = NPC.GetAbility(myHero, "phantom_lancer_doppelwalk")
        if skill and Ability.IsReady(skill) and Ability.IsCastable(skill,myMana) then
            AutoDodger2.DodgeByMoveToForward(myHero, 600, skill)
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

    if not dodged and eul and Ability.IsCastable(eul,myMana)  then
            Ability.CastTarget(eul,myHero)
            dodged = true
    end 
    if not dodged and lotus and Ability.IsCastable(lotus,myMana)  then
            Ability.CastTarget(lotus,myHero)
            dodged = true
    end 
    if not dodged and manta and Ability.IsCastable(manta,myMana)  then
            Ability.CastNoTarget(manta)
            dodged = true
    end 
    if not dodged and bladeMail and Ability.IsCastable(bladeMail,myMana)  then
            Ability.CastNoTarget(bladeMail)
            dodged = true
    end

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
    AutoDodger2.queueLength = 0
    AutoDodger2.projectileQueue={}
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
    AutoDodger2.queueLength = AutoDodger2.queueLength + 1
end

function AutoDodger2.OnLinearProjectileCreate(projectile)
    if not Menu.IsEnabled(AutoDodger2.option) then return end
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
function AutoDodger2.OnParticleCreate(particle)
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
    for k,v in pairs(AutoDodger2.projectileQueue) do  
        local myPos = Entity.GetAbsOrigin(v.target)
        local enemyPos = v.origin

        local distance = myPos - enemyPos 
        local distanceLenth = distance:Length2D() - NPC.GetHullRadius(v.target) - Menu.GetValue(AutoDodger2.impactDistanceOption)

        local delay = (distanceLenth/v.moveSpeed) 
        delay = math.max(delay, 0.00)
        AutoDodger2.projectileQueue[k].dodgeTime = delay + v.time
        Log.Write(delay)
        min = math.min(v.dodgeTime, min)
    end

    if min~= 999999999 then 
        AutoDodger2.nextDodgeTimeProjectile = min
    end 

    local curtime = GameRules.GetGameTime()

    if curtime< AutoDodger2.nextDodgeTimeProjectile  then return end
    if AutoDodger2.queueLength  == 0 then return end 
    local myHero = Heroes.GetLocal()
    if not Entity.IsAlive(myHero) then return end

    local minimum = 9999999999
    local candidateKey = nil
    for k,v in pairs(AutoDodger2.projectileQueue) do 
        if v.dodgeTime < minimum then 
            minimum = v.dodgeTime
            candidateKey = k
        end 
    end  
    if candidateKey then 
        AutoDodger2.projectileQueue[candidateKey] = nil
        AutoDodger2.queueLength = AutoDodger2.queueLength - 1
    end 
    AutoDodger2.DodgeLogicProjectile()
    AutoDodger2.nextDodgeTimeProjectile = minimum
    table.remove(AutoDodger2.projectileQueue,minimumI)
end

function AutoDodger2.ProcessLinearProjectile()
    local curtime = GameRules.GetGameTime()

    if curtime < AutoDodger2.nextDodgeTime then return end

    local myHero = Heroes.GetLocal()

    if not Entity.IsAlive(myHero) then return end

    local myPos = Entity.GetAbsOrigin(myHero)

    local movePositions = {}
    AutoDodger2.impactRadius = Menu.GetValue(AutoDodger2.impactRadiusOption)

    -- simulate projectiles.
    for k, v in pairs(AutoDodger2.activeProjectiles) do
        local t = curtime - v.time
        local projectileDir = v.velocity:Normalized()
        -- local curPos = v.origin + v.velocity:Scaled(t)
        -- local dir = (curPos - myPos)
        -- local impactPos = curPos + projectileDir:Scaled(dir:Length2D())
        -- local endPos = v.origin + projectileDir:Scaled(1225)

        local distance = myPos - v.origin
        local projection = distance:Project(projectileDir)
        local closestPoint = projection + v.origin

        -- local x, y, onScreen = Renderer.WorldToScreen(closestPoint)
        -- Renderer.DrawTextCentered(AutoDodger2.mapFont, x, y, "Here", 1)
        -- do not dodge if ahead of the impact point, and do not dodge if ahead of the max range of the projectile.
        -- if (impactPos - curPos):Dot(projectileDir) > 0 and (endPos - impactPos):Dot(projectileDir) > 0 and NPC.IsPositionInRange(myHero, impactPos, AutoDodger2.impactRadius) then 
        --     local impactDir = (myPos - impactPos):Normalized()

        --     table.insert(movePositions, impactPos + impactDir:Scaled(AutoDodger2.impactRadius + NPC.GetHullRadius(myHero) + 10))
        -- end
        local range = 1500
        if v.name and v.range then
            range = v.range +200
        end 

        local impactRadius = AutoDodger2.impactRadius
        if v.impactRadius then 
            impactRadius = v.impactRadius
        end 

         if projection:Length2D()<=range and NPC.IsPositionInRange(myHero, closestPoint, impactRadius) then 
             local impactDir = (myPos - closestPoint):Normalized()
             local myAngle = Entity.GetRotation(myHero)
             local moveDir = impactDir:ToAngle()
             table.insert(movePositions, myPos + impactDir:Scaled(AutoDodger2.impactRadius+NPC.GetHullRadius(myHero)))
         end

    end

    if #movePositions == 0 then
        AutoDodger2.active = false
        return
    end

    AutoDodger2.movePos = Vector()

    for k, v in pairs(movePositions) do
        AutoDodger2.movePos = AutoDodger2.movePos + v
    end

    AutoDodger2.movePos = Vector(AutoDodger2.movePos:GetX() / #movePositions, AutoDodger2.movePos:GetY() / #movePositions, myPos:GetZ())
    Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_POSITION, nil, AutoDodger2.movePos, nil, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero, false, true)

    AutoDodger2.nextDodgeTime = GameRules.GetGameTime() + NetChannel.GetAvgLatency(Enum.Flow.FLOW_OUTGOING) + 0.2
    AutoDodger2.active = true
end 

function AutoDodger2.ProcessChoosingSkills()
    if not Menu.IsKeyDownOnce(AutoDodger2.optionKey) then return end 
    Log.Write("hey")
end 
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function AutoDodger2.OnDraw()
    if not Engine.IsInGame() or not Menu.IsEnabled(AutoDodger2.option) then
        AutoDodger2.Reset()
        return
    end
    local myHero = Heroes.GetLocal()
    if not Menu.IsEnabled(AutoDodger2.skillOption) then return end

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
            AutoDodger2.DrawDisplay(hero, AutoDodger2.w, AutoDodger2.h - (EnemyCount-1)*AutoDodger2.boxSize)
        end
    end
    --Log.Write(Entity.GetRotation(myHero):__tostring())
end
---------------------------------------------------------------------------------------------------------------------------------------------------------
function AutoDodger2.OnMenuOptionChange(option, old, new)
    if option == AutoDodger2.boxSizeOption then
        AutoDodger2.InitDisplay()
    end
end

function AutoDodger2.DrawDisplay(hero, x,y)

    local abilities = {}

    for i = 0, 24 do
        local ability = NPC.GetAbilityByIndex(hero, i)

        if ability ~= nil and Entity.IsAbility(ability) and not Ability.IsHidden(ability) and not Ability.IsAttributes(ability) then
            table.insert(abilities, ability)
        end
    end

    local startX = x - math.floor((#abilities / 2) * AutoDodger2.boxSize)

    -- black background
    Renderer.SetDrawColor(0, 0, 0, 150)
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
        Log.Write(abilityName)
        AutoDodger2.skillSelected[abilityName] = not AutoDodger2.skillSelected[abilityName]
    end

    if  AutoDodger2.skillSelected[abilityName] == true then 
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

AutoDodger2.skillMap = {}
AutoDodger2.skillMap["pudge_meathook"] = {{"pudge_meat_hook"}, {1000,1100,1200,1300}}

return AutoDodger2
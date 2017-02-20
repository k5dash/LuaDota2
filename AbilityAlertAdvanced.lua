local AbilityAlert2 = {}

AbilityAlert2.option = Menu.AddOption({ "Awareness" }, "Ability Alert Advanced", "Alerts you when certain abilities are used.")
AbilityAlert2.font = Renderer.LoadFont("Tahoma", 22, Enum.FontWeight.EXTRABOLD)
AbilityAlert2.mapFont = Renderer.LoadFont("Tahoma", 16, Enum.FontWeight.NORMAL)

-- current active alerts.
AbilityAlert2.alerts = {}
AbilityAlert2.mapOrigin = {x=-7000, y=7000}

AbilityAlert2.ambiguous =
{
    {  
        name = "nyx_assassin_vendetta_start",
        msg = " has used Vendetta",
        ability = "nyx_assassin_vendetta",
        duration = 15,
        unique = true
    },
    {
        name = "smoke_of_deceit",
        shortName = "smoke",
        msg = "Smoke of Deceit has been used",
        ability ="",
        duration = 35,
        unique = false
    },
    -- {
    --     name = "blink_dagger_start",
    --     shortName = "dagger",
    --     msg = "dagger",
    --     ability ="",
    --     duration = 4,
    --     unique = false
    -- },
    {  
        name = "queen_blink_start",
        msg ='',
        ability = "queenofpain_blink",
        duration = 4,
        unique = true
    },
    {  
        name = "bounty_hunter_windwalk",
        msg ='bounty is invisiable',
        ability = "bounty_hunter_wind_walk",
        duration = 4,
        unique = true
    },
    {  
        name = "antimage_blink_start",
        msg ='',
        ability = "antimage_blink",
        duration = 4,
        unique = true
    },
    {  
        name = "invoker_ice_wall",
        msg ='',
        ability = "invoker_ice_wall",
        duration = 4,
        unique = true
    },
    {  
        name = "invoker_emp",
        msg ='',
        ability = "invoker_emp",
        duration = 4,
        unique = true
    },
    {  
        name = "legion_commander_odds",
        msg ='',
        ability = "legion_commander_overwhelming_odds",
        duration = 4,
        unique = true
    },
    {  
        name = "roshan_spawn",
        msg ='Roshan respawned',
        ability = "",
        duration = 4,
        unique = true
    },
    {  
        name = "roshan_slam",
        shortName = "rosh",
        msg ='Roshan is under attack',
        ability = "",
        duration = 4,
        unique = true
    },
    {  
        name = "tiny_avalanche",
        msg ='',
        ability = "tiny_avalanche",
        duration = 4,
        unique = true
    },
    {  
        name = "tiny_toss",
        msg ='',
        ability = "tiny_toss",
        duration = 4,
        unique = true
    },
    {  
        name = "earthshaker_fissure",
        msg ='',
        ability = "earthshaker_fissure",
        duration = 4,
        unique = true
    },
    {  
        name = "shredder_tree_dmg",
        msg ='',
        ability = "shredder_timber_chain",
        duration = 4,
        unique = true
    },
    {  
        name = "shredder_chakram_stay",
        msg ='',
        ability = "shredder_chakram",
        duration = 4,
        unique = true
    },
    {  
        name = "shredder_chakram_return",
        msg ='',
        ability = "shredder_chakram",
        duration = 4,
        unique = true
    },
    {  
        name = "sandking_burrowstrike",
        msg ='',
        ability = "sandking_burrowstrike",
        duration = 4,
        unique = true
    },
    {  
        name = "sandking_sandstorm",
        msg ='',
        ability = "sandking_sand_storm",
        duration = 10,
        unique = true
    },
    {  
        name = "alchemist_unstable_concoction_timer",
        msg ='Alchemist has started unstable ',
        ability = "alchemist_unstable_concoction",
        duration = 10,
        unique = true
    },
    {  
        name = "alchemist_acid_spray",
        msg ='',
        ability = "alchemist_acid_spray",
        duration = 10,
        unique = true
    },
    {  
        name = "clinkz_windwalk",
        msg ='clinkz is invisble',
        ability = "clinkz_wind_walk",
        duration = 35,
        unique = true
    },
    -- {  
    --     name = "razor_plasmafield",
    --     msg ='',
    --     ability = "razor_plasma_field",
    --     duration = 4,
    --     unique = true
    -- }
    -- {  
    --     name = "venomancer_ward_cast",
    --     msg ='',
    --     ability = "venomancer_plague_ward",
    --     duration = 4,
    --     unique = true
    -- },
    {  
        name = "meepo_poof_end",
        msg ='',
        ability = "meepo_poof",
        duration = 4,
        unique = true
    },
    -- {  
    --     name = "slark_dark_pact_pulses",
    --     msg ='',
    --     ability = "slark_dark_pact",
    --     duration = 4,
    --     unique = true
    -- },
    {  
        name = "slark_pounce_start",
        msg ='',
        ability = "slark_pounce",
        duration = 4,
        unique = true
    },
    {  
        name = "ember_spirit_sleight_of_fist_cast",
        msg ='',
        ability = "ember_spirit_sleight_of_fist",
        duration = 4,
        unique = true
    },
    -- {  
    --     name = "zuus_arc_lightning_head",
    --     msg ='',
    --     ability = "zuus_arc_lightning",
    --     duration = 4,
    --     unique = true
    -- }
    -- {  
    --     name = "zuus_lighting_bolt_start",
    --     msg ='',
    --     ability = "zuus_lighting_bolt",
    --     duration = 4,
    --     unique = true
    -- }
    {  
        name = "lina_spell_light_strike_array",
        msg ='',
        ability = "lina_light_strike_array",
        duration = 4,
        unique = true
    },
    {  
        name = "leshrac_split_earth",
        msg ='',
        ability = "leshrac_split_earth",
        duration = 4,
        unique = true
    },
    {  
        name = "disruptor_kineticfield_formation",
        msg ='',
        ability = "disruptor_kinetic_field",
        duration = 4,
        unique = true
    },
    {  
        name = "jakiro_ice_path",
        msg ='',
        ability = "jakiro_ice_path",
        duration = 4,
        unique = true
    },
    {  
        name = "jakiro_dual_breath_ice",
        msg ='',
        ability = "jakiro_dual_breath",
        duration = 4,
        unique = true
    },
    {  
        name = "maiden_crystal_nova",
        msg ='',
        ability = "crystal_maiden_crystal_nova",
        duration = 4,
        unique = true
    },
    {  
        name = "phantom_assassin_phantom_strike_start",
        msg ='',
        ability = "phantom_assassin_phantom_strike",
        duration = 4,
        unique = true
    },
    {  
        name = "phantom_assassin_phantom_strike_end",
        msg ='',
        ability = "phantom_assassin_phantom_strike",
        duration = 4,
        unique = true
    }
}

AbilityAlert2.teamSpecific = 
{
    -- unique because this particle gets created for every enemy team hero.
    {  
        name = "mirana_moonlight_recipient",
        msg = "Mirana has used her ult",
        duration = 15,
        unique = true
    }
}

-- Returns true if an alert was created, false otherwise.
function AbilityAlert2.InsertAmbiguous(particle)
    for i, enemyAbility in ipairs(AbilityAlert2.ambiguous) do
        if particle.name == enemyAbility.name then
            local enemy = nill
            for i = 1, Heroes.Count() do
                local hero = Heroes.Get(i)
                if not NPC.IsIllusion(hero) then
                    local sameTeam = Entity.GetTeamNum(hero) == myTeam
                    if not sameTeam and NPC.GetAbility(hero, enemyAbility.ability) then
                        enemy = hero
                    end
                end
            end
            local newAlert = {
                index = particle.index,
                name = enemyAbility.name,
                msg = enemyAbility.msg,
                endTime = os.clock() + enemyAbility.duration,
                shortName = enemyAbility.shortName
            }
            if enemy then
                newAlert['enemy'] = NPC.GetUnitName(enemy)
                newAlert['msg'] = NPC.GetUnitName(enemy)..enemyAbility.msg
            end 

            table.insert(AbilityAlert2.alerts, newAlert)

            return true
        end
    end

    return false
end

-- Returns true if an alert was created (or an existing one was extended), false otherwise.
function AbilityAlert2.InsertTeamSpecific(particle)
    local myHero = Heroes.GetLocal()

    if particle.entity == nil then return end
    if Entity.GetTeamNum(particle.entity) == Entity.GetTeamNum(myHero) then return end

    for i, enemyAbility in ipairs(AbilityAlert2.teamSpecific) do
        if particle.name == enemyAbility.name then
            local newAlert = {
                index = particle.index,
                name = enemyAbility.name,
                msg = enemyAbility.msg,
                endTime = os.clock() + enemyAbility.duration,
                shortName = enemyAbility.shortName
            }

            if not enemyAbility.unique then
                table.insert(AbilityAlert2.alerts, newAlert)
                
                return true
            else 
                -- Look for an existing alert.
                for k, alert in ipairs(AbilityAlert2.alerts) do
                    if alert.msg == newAlert.msg then
                        alert.endTime = newAlert.endTime -- Just extend the existing time.

                        return true
                    end
                end

                -- Insert the new alert.
                table.insert(AbilityAlert2.alerts, newAlert)

                return true
            end
        end
    end

    return false
end

--
-- Callbacks
--
function AbilityAlert2.OnParticleCreate(particle)
    Log.Write(particle.name .. ",=")

    if not Menu.IsEnabled(AbilityAlert2.option) then return end

    if not AbilityAlert2.InsertAmbiguous(particle) then
        AbilityAlert2.InsertTeamSpecific(particle)
    end
end

function AbilityAlert2.OnParticleUpdate(particle)
    Log.Write("position"..particle.position:__tostring())
    if particle.controlPoint ~= 0 then return end

    for k, alert in ipairs(AbilityAlert2.alerts) do
        if particle.index == alert.index then
            alert.position = particle.position
        end
    end
end

function AbilityAlert2.OnDraw()
    for i, alert in ipairs(AbilityAlert2.alerts) do
        local timeLeft = alert.endTime - os.clock()

        if timeLeft < 0 then
            table.remove(AbilityAlert2.alerts, i)
        else
            -- Fade out the last 5 seconds of the alert.
            local alpha = 255 * math.min(timeLeft / 5, 1)

            -- Some really obnoxious color to grab your attention.
            Renderer.SetDrawColor(255, 0, 255, math.floor(alpha))

            local w, h = Renderer.GetScreenSize()

            Renderer.DrawTextCentered(AbilityAlert2.font, w / 2, h / 2 + (i - 1) * 22, alert.msg, 1)

            if alert.position then 
                local x, y, onScreen = Renderer.WorldToScreen(alert.position)

                if onScreen then
                    Renderer.DrawTextCentered(AbilityAlert2.mapFont, x, y, alert.name, 1)
                    --Renderer.DrawFilledRect(x - 5, y - 5, 10, 10)
                end
                if alert.enemy then
                    AbilityAlert2.drawPosition(alert.position, AbilityAlert2.Heroes[alert.enemy])
                else
                    AbilityAlert2.drawPosition(alert.position, alert.shortName)
                end 
            end
        end
    end
end

-- function AbilityAlert2.OnEntityCreate(ent)
--     Log.Write(NPC.GetAbsOrigin(ent):__tostring())
-- end 

-- function AbilityAlert2.OnUnitAnimation(animation)

--     Log.Write(NPC.GetAbsOrigin(animation.unit):__tostring())
-- end 

function AbilityAlert2.drawPosition(pos,enemyName)
    local w, h = Renderer.GetScreenSize()
    local x0 =AbilityAlert2.mapOrigin['x']
    local y0 =AbilityAlert2.mapOrigin['y']

    local ratio = 14000/300
    local x = pos:GetX()
    local y = pos:GetY()

    local newX = math.floor((x -x0)/ratio)
    local newY = math.floor((y -y0)/ratio)
    --Log.Write('x'..newX)
    --Log.Write('y'..newY)
    Renderer.SetDrawColor(0, 255, 127)
    Renderer.DrawTextCentered(AbilityAlert2.font, 15+newX, (h-315-newY) , enemyName, 1)
end

AbilityAlert2.Heroes ={
    npc_dota_hero_queenofpain ="qop",
    npc_dota_hero_nyx_assassin ="nyx",
    npc_dota_hero_bounty_hunter="bh",
    npc_dota_hero_antimage="am",
    npc_dota_hero_invoker="invo",
    npc_dota_hero_legion_commander="lc",
    npc_dota_hero_rattletrap="clock",
    npc_dota_hero_life_stealer="naix",
    npc_dota_hero_tiny="tiny",
    npc_dota_hero_earthshaker="es",
    npc_dota_hero_shredder="timb",
    npc_dota_hero_centaur="cent",
    npc_dota_hero_sand_king="sk",
    npc_dota_hero_alchemist="alch",
    npc_dota_hero_clinkz="clinkz",
    npc_dota_hero_razor='raze',
    npc_dota_hero_venomancer="venon",
    npc_dota_hero_meepo = "meepo",
    npc_dota_hero_slark = "slark",
    npc_dota_hero_ember_spirit = "ember",
    npc_dota_hero_zuus = "zeus",
    npc_dota_hero_lina = "lina",
    npc_dota_hero_leshrac = "lesh",
    npc_dota_hero_disruptor = "disr",
    npc_dota_hero_jakiro = "jakiro",
    npc_dota_hero_crystal_maiden = "cm",
    npc_dota_hero_phantom_assassin = "pa"
}
return AbilityAlert2

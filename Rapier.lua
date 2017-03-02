local rapier= {}

rapier.optionEnable = Menu.AddOption({ "Utility", "Rapier"}, "Enable", "Using Rapier without losing it")
rapier.optionKey = Menu.AddKeyOption({ "Utility","Rapier"}, "Key", Enum.ButtonCode.KEY_P)
--rapier.fontSize = Menu.AddOption({ "Awareness", "Show rapier Count"}, "Font Size", "", 20, 50, 10)
rapier.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)
rapier.nextTick = 0
rapier.isChanneling = false
rapier.sniperTickStart = 0
rapier.sniperTickEnd = 0
rapier.sniperTickMid = 0
function rapier.OnUpdate()
    if not Menu.IsEnabled(rapier.optionEnable) then return end
    local myHero = Heroes.GetLocal()
    if myHero == nill then return end

    local rapierItem = NPC.GetItem(myHero,"item_rapier",false)
    if rapierItem and not NPC.IsAttacking(myHero) and os.clock() > rapier.nextTick and not rapier.isChanneling then
        Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_DISASSEMBLE_ITEM, rapierItem, Vector(0,0,0), rapierItem, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, rapierItem)
    end
    local snip = NPC.GetAbility(myHero,"sniper_assassinate")
    if rapier.sniperTickMid<os.clock() and rapier.sniperTickEnd>os.clock() then
        local ghost = NPC.GetItem(myHero, "item_ghost")
        if ghost and Ability.IsReady(ghost, 0)then 
            Ability.CastNoTarget(ghost)
            return
        end
        local myMana = NPC.GetMana(myHero)
        local eul = NPC.GetItem(myHero, "item_cyclone")
        if eul and NPC.GetMana(myHero) then
            Ability.CastTarget(eul, myHero)
        end
        return
    end 
    if rapier.sniperTickStart<os.clock() and rapier.sniperTickEnd>os.clock() then
        Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION, snip, Input.GetWorldCursorPos(), snip, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, snip)
        return
    end 

    if rapier.sniperTickEnd< os.clock() then
        rapier.isChanneling = false
    end

    if not Menu.IsKeyDown(rapier.optionKey) then return end
    local target = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    if target == nill then return end 
    rapier.combine(myHero)
    Player.PrepareUnitOrders(Players.GetLocal(), 4, target, Vector(0,0,0), target, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero)
end

function rapier.OnPrepareUnitOrders(orders)
    if not Menu.IsEnabled(rapier.optionEnable) then return true end
    local myHero = Heroes.GetLocal()
    if orders.order == 5 and Ability.GetName(orders.ability) == "sniper_assassinate" then
        rapier.isChanneling = true
        rapier.combine(myHero)
        rapier.sniperTickStart = os.clock()+0.01
        rapier.sniperTickMid = os.clock() + 2.02
        rapier.sniperTickEnd = os.clock()+ 3.5
        return false
    end 
    if orders.order ~= 4 and orders.order ~=3 then return true end
    rapier.combine(myHero)
    return true
end

function rapier.combine(myHero)
    local blade = NPC.GetItem(myHero,"item_demon_edge",false)
    local relic = NPC.GetItem(myHero,"item_relic",false)
    if Entity.GetHealth(myHero)/Entity.GetMaxHealth(myHero) < 0.2 then return end 
    if blade and relic and not NPC.IsAttacking(myHero) then
        Player.PrepareUnitOrders(Players.GetLocal(), 32, blade, Vector(0,0,0), blade, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, blade)
        Player.PrepareUnitOrders(Players.GetLocal(), 32, relic, Vector(0,0,0), relic, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, relic)
        rapier.nextTick = os.clock() + NPC.GetAttackTime(myHero)/2
    end
end

return rapier


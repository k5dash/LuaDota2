local rapier= {}

rapier.optionEnable = Menu.AddOption({ "Utility", "Rapier"}, "Enable", "Using Rapier without losing it")
rapier.optionKey = Menu.AddKeyOption({ "Utility","Rapier"}, "Key", Enum.ButtonCode.KEY_P)
--rapier.fontSize = Menu.AddOption({ "Awareness", "Show rapier Count"}, "Font Size", "", 20, 50, 10)
rapier.font = Renderer.LoadFont("Tahoma", 30, Enum.FontWeight.EXTRABOLD)
rapier.nextTick = 0
function rapier.OnUpdate()
    if not Menu.IsEnabled(rapier.optionEnable) then return end
    local myHero = Heroes.GetLocal()
    if myHero == nill then return end
    
    local rapierItem = NPC.GetItem(myHero,"item_rapier",false)
    if rapierItem and not NPC.IsAttacking(myHero) and os.clock() > rapier.nextTick then
        Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_DISASSEMBLE_ITEM, rapierItem, Vector(0,0,0), rapierItem, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, rapierItem)
    end
    if not Menu.IsKeyDown(rapier.optionKey) then return end
    local target = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    if target == nill then return end 
    rapier.combine(myHero)
    Player.PrepareUnitOrders(Players.GetLocal(), 4, target, Vector(0,0,0), target, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, myHero)
end

function rapier.OnPrepareUnitOrders(orders)
    Log.Write(orders.order)
    if orders.order ~= 4 and orders.order ~=3 then return true end
    local myHero = Heroes.GetLocal()
    if myHero == nill then return end
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
        rapier.nextTick = os.clock() + 0.2
    end
end

return rapier
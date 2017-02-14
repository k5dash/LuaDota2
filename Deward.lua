local deward = {}

deward.optionEnable = Menu.AddOption({ "Utility", "Deward"}, "Enable", "Deward")
deward.optionMark = Menu.AddKeyOption({ "Utility","Deward"}, "Mark Key", Enum.ButtonCode.KEY_P)
deward.optionClear = Menu.AddKeyOption({ "Utility","Deward"}, "Clear Key", Enum.ButtonCode.KEY_P)
deward.font = Renderer.LoadFont("Tahoma", 28, Enum.FontWeight.EXTRABOLD)
deward.nextTick = 0
deward.points = {}
deward.pointsCount = 0
deward.alert =""
deward.alertTick = 0
deward.wardPosition = nill

function deward.OnUpdate()
    if not Menu.IsEnabled(deward.optionEnable) then return end
    local myHero = Heroes.GetLocal()
    local myTeam = Entity.GetTeamNum(myHero)
    if myHero == nill then return end
    if deward.pointsCount == 3 and deward.wardPosition == nill then
        deward.wardPosition = deward.circumCenter(deward.points[1].pos, deward.points[2].pos, deward.points[3].pos)
    end 

    if Menu.IsKeyDown(deward.optionMark) and os.clock()>deward.nextTick then
        if deward.pointsCount == 3 then
            deward.alertTick = os.clock() + 3
            return 
        end 
        local pos = NPC.GetAbsOrigin(myHero)
        
        local newPoint = {
                pos = pos
        }

        table.insert(deward.points, newPoint)
        deward.pointsCount = deward.pointsCount + 1
        deward.nextTick = os.clock()+ 0.5
        return 
    end 
    if Menu.IsKeyDown(deward.optionClear)then
        deward.points = {}
        deward.pointsCount = 0
        deward.wardPosition = nill
    end 
end

function deward.OnDraw()
    if not Menu.IsEnabled(deward.optionEnable) then return end
    if os.clock() < deward.alertTick then 
        local w, h = Renderer.GetScreenSize()
        Renderer.DrawTextCentered(deward.font, w / 2, h / 2 , "You need to clear Points first.", 1)
    end 
    for i, point in ipairs(deward.points) do
        local x, y, visible = Renderer.WorldToScreen(point.pos)
        if visible then
            Renderer.SetDrawColor(255, 0, 255, 255)
            Renderer.DrawTextCentered(deward.font, x, y, "X", 1)
        end 
    end 

    if deward.wardPosition then
        local x, y, visible = Renderer.WorldToScreen(deward.wardPosition)
        if visible then
            --Renderer.SetDrawColor(255, 0, 255, 255)
            Renderer.DrawTextCentered(deward.font, x, y, 'WARD', 1)
        end 
    end 
end 

function deward.circumCenter(a, b, c)
    a:SetZ(0)
    b:SetZ(0)
    c:SetZ(0)
    
    local xa = a:GetX()
    local ya = a:GetY()
    local xb = b:GetX()
    local yb = b:GetY()
    local xc = c:GetX()
    local yc = c:GetY()

    local delta = 2*(xa-xb)*(yc-yb) - 2*(ya-yb)*(xc-xb)
    local deltaX = (yc-yb)*(xa*xa + ya*ya - xb*xb - yb*yb) - (ya-yb)*(xc*xc + yc*yc - xb*xb - yb*yb)
    local deltaY = (xa-xb)*(xc*xc + yc*yc - xb*xb - yb*yb) - (xc-xb)*(xa*xa + ya*ya - xb*xb - yb*yb) 

    local resultX = deltaX/delta
    local resultY = deltaY/delta
    return Vector(resultX, resultY, 0)
end

return deward
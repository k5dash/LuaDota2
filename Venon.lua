-- Author: paroxysm
-- Version: 3
-- Updated: 05.02.2017
local venom = {}

venom.optionEnable = Menu.AddOption({ "Hero Specific","Venomancer" }, "Enabled", "")
venom.optionKey = Menu.AddKeyOption({ "Hero Specific","Venomancer" }, "Attack Hero", Enum.ButtonCode.KEY_F)
venom.optionUnitKey = Menu.AddKeyOption({ "Hero Specific","Venomancer" }, "Attack Unit", Enum.ButtonCode.KEY_F)

venom.font = Renderer.LoadFont("Tahoma", 50, Enum.FontWeight.EXTRABOLD)
venom.tick = 0
venom.target = nil

function venom.OnUpdate()
	if not Menu.IsEnabled(venom.optionEnable) then return end
	local myHero = Heroes.GetLocal()
    if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_venomancer" then return end

	if Menu.IsKeyDown(venom.optionKey) then
		venom.attackHero()
		return
	end
	if Menu.IsKeyDown(venom.optionUnitKey) then
		venom.attackUnit()
		return
	end
end

function venom.attackHero()
	if venom.tick >  GameRules.GetGameTime() then return end 
	local myHero = Heroes.GetLocal()
	local target = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
	venom.target = target
	venom.tick = GameRules.GetGameTime() +0.2
	for i= 1, NPCs.Count() do
		local entity = NPCs.Get(i)
		if entity then 
			local name = NPC.GetUnitName(entity)
			if name  and target and string.match(name, "npc_dota_venomancer_plague") then
				Player.AttackTarget(Players.GetLocal(), entity, target) 
			end 
		end 
	end
end

function venom.attackUnit()
	if venom.tick >  GameRules.GetGameTime() then return end 
	local myHero = Heroes.GetLocal()
	local target = Input.GetNearestUnitToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_BOTH)
	venom.target = target
	venom.tick = GameRules.GetGameTime() +0.2
	for i= 1, NPCs.Count() do
		local entity = NPCs.Get(i)
		if entity and Entity.IsAlive(entity) then 
			local name = NPC.GetUnitName(entity)
			if name  and target and string.match(name, "npc_dota_venomancer_plague") then
				Player.AttackTarget(Players.GetLocal(), entity, target) 
			end 
		end 
	end
end

function venom.OnDraw()
	if not Menu.IsEnabled(venom.optionEnable) then return end
	if not venom.target then return end 

	if Menu.IsKeyDown(venom.optionUnitKey) or Menu.IsKeyDown(venom.optionKey) then
		local x, y, vis = Renderer.WorldToScreen(Entity.GetAbsOrigin(venom.target))
		Renderer.DrawTextCentered(venom.font, x, y, "X", 1)
	end
	
end

return venom
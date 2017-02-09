local BrewMasterHelper= {}
BrewMasterHelper.optionEnable = Menu.AddOption({ "Hero Specific","Brew Master"}, "Enable", "Brew Master Help Scrip")
BrewMasterHelper.optionStunKey = Menu.AddKeyOption({ "Hero Specific","Brew Master"}, "Earth Stun", Enum.ButtonCode.KEY_P)
BrewMasterHelper.optionEulKey = Menu.AddKeyOption({ "Hero Specific","Brew Master"}, "Storm Eul", Enum.ButtonCode.KEY_P)
BrewMasterHelper.optionDiffuseKey = Menu.AddKeyOption({ "Hero Specific","Brew Master"}, "Storm Diffuse", Enum.ButtonCode.KEY_P)

BrewMasterHelper.cache = {}
BrewMasterHelper.Pandas ={}
BrewMasterHelper.ultimateLast = {16, 18, 20}
BrewMasterHelper.nextTick = 0

function BrewMasterHelper.OnUpdate()
	if not Menu.IsEnabled(BrewMasterHelper.optionEnable) then return end
	--if not Menu.IsKeyDown(BrewMasterHelper.optionKey) then return end
	local myHero = Heroes.GetLocal()
	if myHero == nill then return end 
	local ultimate = NPC.GetAbilityByIndex(myHero, 3)
	if ultimate == nill or Ability.GetCooldownTimeLeft(ultimate) == 0 then return end

	if BrewMasterHelper.Pandas["fire"] == nill then 
		for i= 1, NPCs.Count() do
			local entity = NPCs.Get(i)
			local name = NPC.GetUnitName(entity)
			if  Entity.GetOwner(entity) == myHero then 
				if name == "npc_dota_brewmaster_fire_1" or name == "npc_dota_brewmaster_fire_2" or name == "npc_dota_brewmaster_fire_3" then 
					BrewMasterHelper.Pandas["fire"] = entity
				end 
				if name == "npc_dota_brewmaster_storm_1" or name == "npc_dota_brewmaster_storm_2" or name == "npc_dota_brewmaster_storm_3" then 
					BrewMasterHelper.Pandas["storm"] = entity
				end 
				if name == "npc_dota_brewmaster_earth_1" or name == "npc_dota_brewmaster_earth_2" or name == "npc_dota_brewmaster_earth_3" then 
					BrewMasterHelper.Pandas["earth"] = entity
				end 
			end 
		end
	end 

	if BrewMasterHelper.Pandas["fire"] == nill then return end 
	if Menu.IsKeyDown(BrewMasterHelper.optionStunKey) then
		local earth = BrewMasterHelper.Pandas["earth"]
		if earth~=nill then 
			local stun = NPC.GetAbilityByIndex(earth, 0)
			Log.Write(Ability.GetName(stun))
			local target = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
			Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TARGET, target, Vector(0,0,0), stun, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, earth)
		end 
	end 

	if Menu.IsKeyDown(BrewMasterHelper.optionEulKey) then
		local storm = BrewMasterHelper.Pandas["storm"]
		if storm~=nill then 
			local eul = NPC.GetAbilityByIndex(storm, 1)
			Log.Write(Ability.GetName(eul))
			local target = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
			Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_TARGET, target, Vector(0,0,0), eul, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, storm)
		end 
	end 

	if Menu.IsKeyDown(BrewMasterHelper.optionDiffuseKey) then
		local storm = BrewMasterHelper.Pandas["storm"]
		if storm~=nill then 
			local diffuse = NPC.GetAbilityByIndex(storm, 0)
			Log.Write(Ability.GetName(diffuse))
			local target = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
			Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_CAST_POSITION, target, NPC.GetAbsOrigin(target), diffuse, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, storm)
		end 
	end 
end

return BrewMasterHelper
local ArcHelper= {}
ArcHelper.optionEnable = Menu.AddOption({ "Hero Specific","Arc Warden"}, "Enable", "Arc Warden Help Scrip")
ArcHelper.optionKey = Menu.AddKeyOption({ "Hero Specific","Arc Warden"}, "Clone Combo", Enum.ButtonCode.KEY_P)
ArcHelper.optionMainKey = Menu.AddKeyOption({ "Hero Specific","Arc Warden"}, "Main Hero Combo", Enum.ButtonCode.KEY_P)
ArcHelper.pushKey = Menu.AddKeyOption({ "Hero Specific","Arc Warden"}, "Clone Push", Enum.ButtonCode.KEY_P)

ArcHelper.cache = {}

ArcHelper.clone = nil
ArcHelper.cloneAttacking = false
ArcHelper.clonePushing =  false
ArcHelper.cloneAttackingTarget = nil
ArcHelper.cloneTick = 0
ArcHelper.clonePushTick = 0
ArcHelper.font = Renderer.LoadFont("Tahoma", 50, Enum.FontWeight.EXTRABOLD)

ArcHelper.mainTick = 0
function ArcHelper.init()
	ArcHelper.clone = nil
	ArcHelper.cloneAttacking = false
	ArcHelper.clonePushing =  false
	ArcHelper.cloneAttackingTarget = nil
	ArcHelper.cloneTick = 0
end

function ArcHelper.OnUpdate()
	if not Menu.IsEnabled(ArcHelper.optionEnable) then return end
	--if not Menu.IsKeyDown(ArcHelper.optionKey) then return end
	local myHero = Heroes.GetLocal()
	if myHero == nill then return end 
	local myName = NPC.GetUnitName(myHero)
	if myName ~= "npc_dota_hero_arc_warden" then return end 

	if Menu.IsKeyDown(ArcHelper.optionMainKey) then
		if GameRules.GetGameTime() > ArcHelper.mainTick then 
			ArcHelper.mainAttack()
		end 
	end 


	local ultimate = NPC.GetAbilityByIndex(myHero,3)
	if Menu.IsKeyDownOnce(ArcHelper.optionKey) then
		--
		if Ability.IsReady(ultimate) then
			ArcHelper.cloneAttacking = true
			ArcHelper.clonePushing = false
			Ability.CastNoTarget(ultimate)
		else 
			ArcHelper.cloneAttacking = not ArcHelper.cloneAttacking
			if not ArcHelper.cloneAttacking then
				ArcHelper.cloneAttackingTarget = nil
			end 
		end
	end 

	if Menu.IsKeyDownOnce(ArcHelper.pushKey) then
		if Ability.IsReady(ultimate) then
			ArcHelper.clonePushing = true
			Ability.CastNoTarget(ultimate)
		else 
			ArcHelper.cloneAttacking = not ArcHelper.cloneAttacking
		end
	end 

	if ArcHelper.clone == nil and ultimate and Ability.GetLevel(ultimate)>0 then
		for i= 1, NPCs.Count() do
			local entity = NPCs.Get(i)
			if entity and NPC.IsEntityInRange(myHero, entity, 200) then 
				local name = NPC.GetUnitName(entity)
				if name == "npc_dota_hero_arc_warden" and myHero~= entity then
					ArcHelper.clone = entity
				end 
			end 
		end
		return
	end

	if not Entity.IsAlive(ArcHelper.clone) and not Ability.IsReady(ultimate) then 
		ArcHelper.cloneAttacking = false
		ArcHelper.cloneAttackingTarget = nil
		return
	end

	if ArcHelper.clone and Entity.IsAlive(ArcHelper.clone) then 
		ArcHelper.useMidas(ArcHelper.clone)
	end 
	ArcHelper.clonePush()
	ArcHelper.cloneAttack()
end

function ArcHelper.autoDefend(myHero)
	if not myHero then return end
    local myTeam = Entity.GetTeamNum(myHero)
    local mainHero = Heroes.GetLocal()

    local orchid = NPC.GetItem(myHero,"item_orchid")
    local bloodthorn = NPC.GetItem(myHero,"item_bloodthorn")
    local hex = NPC.GetItem(myHero, "item_sheepstick")
    if not orchid and not bloodthorn and not hex then return end 
    for i= 1, Heroes.Count() do
        local enemy = Heroes.Get(i)
        local sameTeam = Entity.GetTeamNum(enemy) == myTeam
        if not sameTeam and not NPC.IsDormant(enemy) and Entity.GetHealth(enemy) > 0 then
            local dagger = NPC.GetItem(enemy,"item_blink")
            if dagger and NPC.IsEntityInRange(myHero, enemy, 800) and Ability.GetCooldownLength(dagger) > 4 and Ability.SecondsSinceLastUse(dagger)<=1 and Ability.SecondsSinceLastUse(dagger)>0 then
        	    local orchid_main = NPC.GetItem(mainHero,"item_orchid")
			    local bloodthorn_main = NPC.GetItem(mainHero,"item_bloodthorn")
			    local hex_main = NPC.GetItem(mainHero, "item_sheepstick")
            	 if not NPC.IsSilenced(enemy) then 
            	 	if NPC.IsEntityInRange(myHero, mainHero,1000) and NPC.IsEntityInRange(mainHero,enemy, 1000) then
            	 		if (not orchid or not Ability.IsReady(orchid_main)) and (not bloodthorn or not Ability.IsReady(bloodthorn_main)) and (not hex or not Ability.IsReady(hex_main)) then
            	 			if hex and Ability.IsReady(hex) then
		                    	Ability.CastTarget(hex, enemy)
		                    return
			                end
			                if bloodthorn and Ability.IsReady(bloodthorn) then
			                    Ability.CastTarget(bloodthorn, enemy)
			                    return
			                end
			                if orchid and Ability.IsReady(orchid) then
			                    Ability.CastTarget(orchid, enemy)
			                    return
			                end
            	 		end 
            	 	else 
            	 		if hex and Ability.IsReady(hex) then
	                    	Ability.CastTarget(hex, enemy)
	                    return
		                end
		                if bloodthorn and Ability.IsReady(bloodthorn) then
		                    Ability.CastTarget(bloodthorn, enemy)
		                    return
		                end
		                if orchid and Ability.IsReady(orchid) then
		                    Ability.CastTarget(orchid, enemy)
		                    return
		                end
            	 	end
	            end  
            end 
        end 
    end 
end

function ArcHelper.mainAttack()
	local myHero = Heroes.GetLocal()
	local flux = NPC.GetAbilityByIndex(myHero, 0)
	local magnetic = NPC.GetAbilityByIndex(myHero, 1)
	local spark = NPC.GetAbilityByIndex(myHero, 2)
	local orchid = NPC.GetItem(myHero,"item_orchid")
	local bloodthorn = NPC.GetItem(myHero,"item_bloodthorn")
	local mjollnir = NPC.GetItem(myHero,"item_mjollnir")
	local hex = NPC.GetItem(myHero,"item_sheepstick")

	local target = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
	local mousePos = Input.GetWorldCursorPos()

	if not NPC.IsPositionInRange(target, mousePos, 2000) then
		target = nil
	end 
	if target then
			if NPC.IsLinkensProtected(target) then
				if Ability.IsReady(flux) then
					ArcHelper.cloneTick = GameRules.GetGameTime() + 0.1
					Ability.CastTarget(flux,target)
					return
				end 
			end 
			if hex and Ability.IsReady(hex) and not NPC.HasModifier(target, "modifier_sheepstick_debuff") and not NPC.IsStunned(target) then
				Ability.CastTarget(hex,target)
				return
			end 
			if bloodthorn and Ability.IsReady(bloodthorn) and not NPC.IsSilenced(target) then
				if ArcHelper.clone and Entity.IsAlive(ArcHelper) and NPC.IsEntityInRange(myHero, target, 1000) and NPC.IsEntityInRange(myHero, ArcHelper.clone, 1000) then
					local clone_bloodthorn = NPC.GetItem(ArcHelper.clone, "item_bloodthorn")
					if not Ability.IsReady(clone_bloodthorn) then
						Ability.CastTarget(bloodthorn,target)
					end  
				else 
					Ability.CastTarget(bloodthorn,target)
				end 
			end 
			if orchid and Ability.IsReady(orchid) and not NPC.IsSilenced(target) then
				Ability.CastTarget(orchid,target)
			end 
			if mjollnir and Ability.IsReady(mjollnir) then
				Ability.CastTarget(mjollnir,myHero)
			end 
			if Ability.IsReady(flux) then
				ArcHelper.mainTick = GameRules.GetGameTime() + 0.1
				Ability.CastTarget(flux,target)
				return
			end 
			if Ability.IsReady(spark) then
				ArcHelper.mainTick = GameRules.GetGameTime() + 0.1
				Ability.CastPosition(spark,ArcHelper.PredictPosition(target))
				return
			end

			local clone_magnetic = nil
			if ArcHelper.clone then
				clone_magnetic = NPC.GetAbilityByIndex(ArcHelper.clone, 1)
			end

			if Ability.IsReady(magnetic) and not NPC.HasModifier(myHero, "modifier_arc_warden_magnetic_field") and NPC.IsEntityInRange(myHero, target, 625) and (not ArcHelper.clone or ArcHelper.clone and clone_magnetic and not Ability.IsInAbilityPhase(clone_magnetic)) then
				ArcHelper.mainTick = GameRules.GetGameTime() + 0.1
				local pos = Entity.GetAbsOrigin(myHero)
				if ArcHelper.clone and Entity.IsAlive(ArcHelper.clone) and NPC.IsEntityInRange(myHero, ArcHelper.clone, 270*2)  then
					local clone_magnetic_2 = NPC.GetAbilityByIndex(ArcHelper.clone, 1)
					if Ability.GetCooldownLength(clone_magnetic_2)-Ability.GetCooldownTimeLeft(clone_magnetic_2)<=1  then return end 
					pos = (Entity.GetAbsOrigin(ArcHelper.clone) + Entity.GetAbsOrigin(myHero))
					pos:SetX(pos:GetX()/2)
					pos:SetY(pos:GetY()/2)
					pos:SetZ(pos:GetZ()/2)
				end 
				Ability.CastPosition(magnetic,pos)
				return
			end 
			Player.AttackTarget(Players.GetLocal(), myHero, target) 
			ArcHelper.mainTick = GameRules.GetGameTime() + NPC.GetAttackTime(myHero)
		end 
end

function ArcHelper.GetClosestLaneCreepsToMouse()
	local max_distance = 9999999
	local candidate = nil
	local mousePos = Input.GetWorldCursorPos()
	for i= 1, NPCs.Count() do
		local entity = NPCs.Get(i)
		if entity and NPC.IsLaneCreep(entity) and NPC.IsRanged(entity) then 
			local creepPos = Entity.GetAbsOrigin(entity)
			local dist = creepPos -  mousePos
			local len = dist:Length2D()
			if len<max_distance then
				max_distance = len
				candidate = entity
			end
		end 
	end
	return candidate
end 

function ArcHelper.clonePush()
	if not Entity.IsAlive(ArcHelper.clone) then return end 
	if not ArcHelper.clonePushing then return end 
	if GameRules.GetGameTime() < ArcHelper.clonePushTick then return end 
	local myHero = Heroes.GetLocal()
	local bot = NPC.GetItem(ArcHelper.clone, "item_travel_boots")
	ArcHelper.clonePushTick = GameRules.GetGameTime() + 3
	local creep = nil
	if bot and Ability.IsReady(bot) then
		creep = ArcHelper.GetClosestLaneCreepsToMouse()
	end 
	
	if bot and Ability.IsReady(bot) and creep then
		Ability.CastPosition(bot, Entity.GetAbsOrigin(creep))
	end 
end 

function ArcHelper.cloneAttack()
	if not Entity.IsAlive(ArcHelper.clone) then return end 
	ArcHelper.autoDefend(ArcHelper.clone)

	if GameRules.GetGameTime() < ArcHelper.cloneTick then return end 
	local myHero = Heroes.GetLocal()
	local flux = NPC.GetAbilityByIndex(ArcHelper.clone, 0)
	local magnetic = NPC.GetAbilityByIndex(ArcHelper.clone, 1)
	local spark = NPC.GetAbilityByIndex(ArcHelper.clone, 2)
	local orchid = NPC.GetItem(ArcHelper.clone,"item_orchid")
	local bloodthorn = NPC.GetItem(ArcHelper.clone,"item_bloodthorn")
	local mjollnir = NPC.GetItem(ArcHelper.clone,"item_mjollnir")
	local hex = NPC.GetItem(ArcHelper.clone,"item_sheepstick")
	local dagger = NPC.GetItem(ArcHelper.clone,"item_blink")
	local shadowblade = NPC.GetItem(ArcHelper.clone,"item_invis_sword")
	local silver_edge = NPC.GetItem(ArcHelper.clone,"item_silver_edge")
	local invisible_candidate_blade = shadowblade
	if silver_edge then
		invisible_candidate_blade = silver_edge
	end

	if ArcHelper.cloneAttacking then 		
		if not Entity.IsAlive(ArcHelper.cloneAttackingTarget) or not NPC.IsEntityInRange(ArcHelper.cloneAttackingTarget, ArcHelper.clone, 2500) then
			ArcHelper.cloneAttackingTarget = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
			if not NPC.IsEntityInRange(ArcHelper.cloneAttackingTarget, ArcHelper.clone, 2500) then
				ArcHelper.cloneAttackingTarget =  nil
			end 
		end 
		if ArcHelper.cloneAttackingTarget then
			if dagger and Ability.IsReady(dagger) then
				if NPC.IsEntityInRange(ArcHelper.clone,ArcHelper.cloneAttackingTarget, 1500) then 
					ArcHelper.useDagger(ArcHelper.clone, dagger, Entity.GetAbsOrigin(ArcHelper.cloneAttackingTarget))
				else 
					Player.AttackTarget(Players.GetLocal(), ArcHelper.clone, ArcHelper.cloneAttackingTarget)
					ArcHelper.cloneTick = GameRules.GetGameTime() + 0.1
				end 
				return
			end 

			if invisible_candidate_blade and Ability.IsReady(invisible_candidate_blade) then
					Ability.CastNoTarget(invisible_candidate_blade)
				return
			end 

			if NPC.IsLinkensProtected(ArcHelper.cloneAttackingTarget) then
				if Ability.IsReady(flux) then
					ArcHelper.cloneTick = GameRules.GetGameTime() + 0.1
					Ability.CastTarget(flux,ArcHelper.cloneAttackingTarget)
					return
				end 
			end 
			if NPC.HasModifier(ArcHelper.clone,"modifier_item_silver_edge_windwalk") or NPC.HasModifier(ArcHelper.clone,"modifier_item_invisibility_edge_windwalk") then 
				if NPC.IsEntityInRange(ArcHelper.cloneAttackingTarget, ArcHelper.clone, 300) then
					Player.AttackTarget(Players.GetLocal(), ArcHelper.clone, ArcHelper.cloneAttackingTarget) 
					ArcHelper.cloneTick = GameRules.GetGameTime() + 0.1
					return
				else 
					Player.PrepareUnitOrders(Players.GetLocal(), Enum.UnitOrder.DOTA_UNIT_ORDER_MOVE_TO_TARGET, ArcHelper.cloneAttackingTarget, Vector(), ability, Enum.PlayerOrderIssuer.DOTA_ORDER_ISSUER_PASSED_UNIT_ONLY, ArcHelper.clone, queue, trues)
					ArcHelper.cloneTick = GameRules.GetGameTime() + 0.1
				end 
				return 
			end 

			if hex and Ability.IsReady(hex) and not NPC.HasModifier(ArcHelper.cloneAttackingTarget, "modifier_sheepstick_debuff") and not NPC.IsStunned(ArcHelper.cloneAttackingTarget) then
				Ability.CastTarget(hex,ArcHelper.cloneAttackingTarget)
				return
			end 
			if bloodthorn and Ability.IsReady(bloodthorn) and not NPC.IsSilenced(ArcHelper.cloneAttackingTarget) then
				Ability.CastTarget(bloodthorn,ArcHelper.cloneAttackingTarget)
			end 
			if orchid and Ability.IsReady(orchid) and not NPC.IsSilenced(ArcHelper.cloneAttackingTarget) then
				Ability.CastTarget(orchid,ArcHelper.cloneAttackingTarget)
			end 
			if mjollnir and Ability.IsReady(mjollnir) then
				ArcHelper.cloneTick = GameRules.GetGameTime() + 0.1
				Ability.CastTarget(mjollnir,ArcHelper.clone)
				return
			end 
			if Ability.IsReady(flux) then
				ArcHelper.cloneTick = GameRules.GetGameTime() + 0.1
				Ability.CastTarget(flux,ArcHelper.cloneAttackingTarget)
				return
			end 
			if Ability.IsReady(spark) then
				ArcHelper.cloneTick = GameRules.GetGameTime() + 0.1
				Ability.CastPosition(spark,ArcHelper.PredictPosition(ArcHelper.cloneAttackingTarget))
				return
			end

			local main_magnetic = nil
			if myHero then
				main_magnetic = NPC.GetAbilityByIndex(myHero, 1)
			end

			if Ability.IsReady(magnetic) and not NPC.HasModifier(ArcHelper.clone, "modifier_arc_warden_magnetic_field") and NPC.IsEntityInRange(ArcHelper.cloneAttackingTarget, ArcHelper.clone, 625) and not Ability.IsInAbilityPhase(main_magnetic) then
				ArcHelper.cloneTick = GameRules.GetGameTime() + 0.1
				local pos = Entity.GetAbsOrigin(ArcHelper.clone)
				if NPC.IsEntityInRange(myHero, ArcHelper.clone, 270*2) then
					pos = (Entity.GetAbsOrigin(ArcHelper.clone) + Entity.GetAbsOrigin(myHero))
					pos:SetX(pos:GetX()/2)
					pos:SetY(pos:GetY()/2)
					pos:SetZ(pos:GetZ()/2)
				end 
				Ability.CastPosition(magnetic,pos)
				return
			end 
			Player.AttackTarget(Players.GetLocal(), ArcHelper.clone, ArcHelper.cloneAttackingTarget) 
			ArcHelper.cloneTick = GameRules.GetGameTime() + NPC.GetAttackTime(myHero)/2
		end 
	end 
end

function ArcHelper.OnDraw()
	if not Menu.IsEnabled(ArcHelper.optionEnable) then return end
	if not Engine.IsInGame() then
		ArcHelper.init()
		return 
	end 
	-- local myHero = Heroes.GetLocal()
	-- local modifiers = NPC.GetModifiers(myHero)
	-- for i = 1,#modifiers do
	-- 	local name = Modifier.GetName(modifiers[i])
	-- 	Log.Write(name)
	-- end
	ArcHelper.DrawCloneMidasMsg()
	ArcHelper.DrawCloneSwitchMsg()
end 

function ArcHelper.useDagger(myHero, dagger, vector)
    if dagger == nill or not Ability.IsReady(dagger) then return end 
    local dir = vector - NPC.GetAbsOrigin(myHero)
    dir:SetZ(0)
    dir:Normalize()
    dir:Scale(1199)

    local destination = NPC.GetAbsOrigin(myHero) + dir
    Ability.CastPosition(dagger, vector)
end

function ArcHelper.useMidas(myHero)
	local midas = NPC.GetItem(myHero, "item_hand_of_midas")
	if not midas then return end 
	for i= 1, NPCs.Count() do
		local entity = NPCs.Get(i) 
		if entity and not Entity.IsSameTeam(myHero, entity) and (NPC.IsCreep(entity) or NPC.IsLaneCreep(entity) or NPC.IsNeutral(entity)) and NPC.IsEntityInRange(myHero, entity, 600) then
			if Ability.IsReady(midas) then
				Ability.CastTarget(midas, entity)
				return
			end 
		end 
	end
end

function ArcHelper.DrawCloneMidasMsg()
	if not ArcHelper.clone then return end 
	local midas = NPC.GetItem(ArcHelper.clone,	"item_hand_of_midas")
	if not midas then return end
	local w, h = Renderer.GetScreenSize()
	--Renderer.SetDrawColor(255, 255, 255)
	Renderer.DrawTextCentered(ArcHelper.font, w-200, 100, "Midas:"..math.floor(Ability.GetCooldownTimeLeft(midas)), 1)
end 

function ArcHelper.DrawCloneSwitchMsg()
	if not ArcHelper.clone then return end 
	if not Entity.IsAlive(ArcHelper.clone) then return end 
	local w, h = Renderer.GetScreenSize()
	Renderer.SetDrawColor(255, 0, 255)
	if ArcHelper.cloneAttacking then
		Renderer.DrawTextCentered(ArcHelper.font, w / 2, h / 2 + 300, "ON", 1)
	else 
		Renderer.DrawTextCentered(ArcHelper.font, w / 2, h / 2 + 300, "OFF", 1)
	end
end 


function ArcHelper.PredictPosition(enemy)
	if NPC.IsRunning(enemy) then
		return ArcHelper.processHero(enemy, 2.3)
	end 
	
	return NPC.GetAbsOrigin(enemy)
end 

function ArcHelper.processHero(enemy, duration)
    local speed = NPC.GetMoveSpeed(enemy)
    local angle = Entity.GetRotation(enemy)
    local angleOffset = Angle(0, 45, 0)
    angle:SetYaw(angle:GetYaw() + angleOffset:GetYaw())
    local x,y,z = angle:GetVectors()
    local direction = x + y + z
    local name = NPC.GetUnitName(enemy)
    direction:SetZ(0)
    direction:Normalize()
    direction:Scale(speed*duration)

    local origin = NPC.GetAbsOrigin(enemy)
    return origin + direction
end 
return ArcHelper
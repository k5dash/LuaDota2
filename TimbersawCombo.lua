local Timber = {}

Timber.optionEnable = Menu.AddOption({"Hero Specific", "Timbersaw"}, "Enable",  "Combo")
Timber.chainKey = Menu.AddKeyOption({"Hero Specific", "Timbersaw"}, "Chain Key", Enum.ButtonCode.KEY_Z)
Timber.ultimateKey = Menu.AddKeyOption({"Hero Specific", "Timbersaw"}, "Ultimate Key", Enum.ButtonCode.KEY_F)
Timber.cache= {}
Timber.font = Renderer.LoadFont("Tahoma", 50, Enum.FontWeight.EXTRABOLD)
Timber.whirlingTick = 9999999
Timber.mainTick = 0;
Timber.rotationMap = {}
Timber.counterMap = {}
Timber.chainLength = {850,1050,1250,1450}
Timber.ultimateDamage = {100,140,180}

Timber.target = nil

function Timber.OnUpdate()
    if not Menu.IsEnabled(Timber.optionEnable) then return true end
    local myHero = Heroes.GetLocal()
    if not myHero then return end 

    local myName = NPC.GetUnitName(myHero)
	local vec = Entity.GetAngVelocity(myHero):Length2D()
	-- if vec ~=0 then
	-- 	Log.Write(vec)
	-- end 

	if myName ~= "npc_dota_hero_shredder" then return end

	Timber.buildRotationMap(myHero)

  	local whirling = NPC.GetAbilityByIndex(myHero, 0)
  	local chain = NPC.GetAbilityByIndex(myHero, 1)
	local chakram = NPC.GetAbility(myHero, "shredder_chakram")
	local chakramReturn = NPC.GetAbility(myHero, "shredder_return_chakram")
	local chakramAgha = NPC.GetAbility(myHero, "shredder_chakram_2")
	local chakramAghaReturn = NPC.GetAbility(myHero, "shredder_return_chakram_2")

	local myPos = Entity.GetAbsOrigin(myHero)

	if whirling and not Ability.IsReady(whirling) then
		Timber.whirlingTick = 9999999
	end 

    if Menu.IsKeyDown(Timber.chainKey) then 
    	local tree = Input.GetNearestTreeToCursor(true)
    	local enemies = NPC.GetHeroesInRadius(myHero, 1000, Enum.TeamType.TEAM_ENEMY)

    	if Ability.IsReady(chain) then
    		Ability.CastPosition(chain, Entity.GetAbsOrigin(tree))
    		return
    	end 
    	local enemy = nil
    	if #enemies >=1 then
    		enemy = enemies[1]
    	end 
    	if enemy then
    		local enemyPos = Entity.GetAbsOrigin(enemy)
	    	if NPC.IsEntityInRange(myHero, enemy, 300) and Ability.IsReady(whirling) then
	    		if GameRules.GetGameTime() >= Timber.whirlingTick then 
	    			Ability.CastNoTarget(whirling)
	    			Timber.whirlingTick = 9999999
	    		end 
	    	end
	    	if Ability.IsReady(chakram) and not Ability.IsHidden(chakram) then
    			Ability.CastPosition(chakram,Timber.caculateTarget(myHero, enemy, myPos, enemyPos, 900, NPC.GetMoveSpeed(enemy)))
    		end 
	    else 
	    	local enemy_creep = NPC.GetUnitsInRadius(myHero, 300, Enum.TeamType.TEAM_ENEMY)
	    	if #enemy_creep>1 and GameRules.GetGameTime() >= Timber.whirlingTick then
	    		Ability.CastNoTarget(whirling)
	    		Timber.whirlingTick = 9999999
	    	end 
	    end 
    end
    
    if Menu.IsKeyDownOnce(Timber.ultimateKey) then
    	Timber.target = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    	return
    end 
    if Menu.IsKeyDown(Timber.ultimateKey) then
    	Log.Write("hey")
    	
    	if Timber.target and not Entity.IsAlive(Timber.target) then 
    		Timber.target = Input.GetNearestHeroToCursor(Entity.GetTeamNum(myHero), Enum.TeamType.TEAM_ENEMY)
    	end 
    	local enemy = Timber.target
    	local tree = Input.GetNearestTreeToCursor(true)
    	if enemy then
    		tree = Timber.GetAvailableTree(enemy)
    	end 

    	if enemy then
    		local enemyPos = Entity.GetAbsOrigin(enemy)
	    	if NPC.IsEntityInRange(myHero, enemy, 300) and Ability.IsReady(whirling) then
	    		if GameRules.GetGameTime() >= Timber.whirlingTick then 
	    			Ability.CastNoTarget(whirling)
	    			Timber.whirlingTick = 9999999
	    		end 

	    	end 
	    	if Ability.IsReady(chakram) and not Ability.IsHidden(chakram) then
	    		if Entity.GetAngVelocity(enemy):Length2D() < Timber.rotationMap[NPC.GetUnitName(enemy)] *0.7 then
	    			Ability.CastPosition(chakram,Timber.caculateTarget(myHero, enemy, myPos, enemyPos, 900, NPC.GetMoveSpeed(enemy)))
	    		end
	    	end
	    	if Ability.IsHidden(chakram) then
	    		if  NPC.HasModifier(enemy, "modifier_shredder_chakram_debuff") then
		    		local damage = Timber.ultimateDamage[Ability.GetLevel(chakram)]
		    		if damage>= Entity.GetHealth(enemy) then
		    			Ability.CastNoTarget(chakramReturn)
		    		end 
	    		end 
	    		Log.Write(Ability.GetCooldownTimeLeft(chakram))
	    		if not Timber.anyHeroIsUnderUltimate(myHero) and Ability.GetCooldownTimeLeft(chakram) == 0 then
	    			Ability.CastNoTarget(chakramReturn)
	    		end 
	    	end
	    end 

    	if Ability.IsReady(chain) and tree then
    		Ability.CastPosition(chain, Entity.GetAbsOrigin(tree))
    		return
    	end 
    end 
end

function Timber.GetAvailableTree(enemy)
	local myHero = Heroes.GetLocal()
	local myPos = Entity.GetAbsOrigin(myHero)
	local enemyPos = Entity.GetAbsOrigin(enemy)
	local dist = enemyPos -  myPos
	local len = dist:Length2D()
	dist:Normalize()
	for i = len, 1500, 100 do 
		dist:Scale(i)
		local dest = myPos + dist
		local trees = Trees.InRadius(dest, 300, true) 
		if #trees >= 1 then
			return trees[1]
		end 
		dist:Normalize()
	end 
end 

function Timber.anyHeroIsUnderUltimate(myHero)
	for i= 1, Heroes.Count() do
		local hero = Heroes.Get(i)
		if not Entity.IsSameTeam(myHero, hero) then
			if NPC.HasModifier(hero, "modifier_shredder_chakram_debuff") then
				return true
			end 
		end 
	end
end

function Timber.buildRotationMap(myHero)
	for i= 1, Heroes.Count() do
		local hero = Heroes.Get(i)
		if not Entity.IsSameTeam(myHero, hero) then
			local name = NPC.GetUnitName(hero)
			local vec = Entity.GetAngVelocity(hero):Length2D()

			if not Timber.rotationMap[name] or vec > Timber.rotationMap[name] then
				Timber.rotationMap[name] = vec
			end 
		end 
	end
end 

function Timber.caculateTarget(myHero, enemy, myPos, enemyPos, mySpeed, enemySpeed)
    local direction = Timber.processHero(enemy)
    local vector = myPos - enemyPos
    local distance = vector:Length2D()
    local offset = -0.1/500*distance + 1
    if NPC.IsRunning(enemy) then
    	return Timber.binarySearch(0,2000, myPos, enemyPos, direction, mySpeed, enemySpeed, offset)
    else 
    	return Entity.GetAbsOrigin(enemy)
    end
end 

function Timber.binarySearch(num1, num2, myPos, enemyPos, direction, mySpeed, enemySpeed, offset) 
    local vec = Vector(0,0,0)
    vec:SetX(direction:GetX())
    vec:SetY(direction:GetY())
    local mid = (num1 + num2)/2
    vec:Scale(mid)
    local target = enemyPos + vec
    if num1 >= num2 -1 then
        return target
    end
    local myVector = target - myPos
    local enemyVector = target - enemyPos
    local myDistance = myVector:Length2D()
    local enemyDistance = enemyVector:Length2D()

    local timeEnemy = enemyDistance/enemySpeed
    local timeMe =  myDistance/mySpeed
    if timeEnemy > timeMe + offset and timeEnemy < timeMe + offset+0.01 then
        return target
    elseif timeEnemy <= timeMe + offset then
        return Timber.binarySearch(mid, num2, myPos, enemyPos, direction, mySpeed, enemySpeed, offset)
    else
        return Timber.binarySearch(num1, mid, myPos, enemyPos, direction, mySpeed, enemySpeed, offset)
    end
end

function Timber.processHero(enemy)
    local speed = NPC.GetMoveSpeed(enemy)
    local angle = Entity.GetRotation(enemy)
    local angleOffset = Angle(0, 45, 0)
    angle:SetYaw(angle:GetYaw() + angleOffset:GetYaw())
    local x,y,z = angle:GetVectors()
    local direction = x + y + z
    local name = NPC.GetUnitName(enemy)
    direction:SetZ(0)
    direction:Normalize()
    return direction
end 

function Timber.OnDraw()
	if not Menu.IsEnabled(Timber.optionEnable) then return true end
	local myHero = Heroes.GetLocal()
	if not myHero or NPC.GetUnitName(myHero) ~= "npc_dota_hero_shredder" then return end

	if Timber.target then
		Renderer.SetDrawColor(255, 0, 255)
		local x, y, vis = Renderer.WorldToScreen(Entity.GetAbsOrigin(Timber.target))
	 	Renderer.DrawTextCentered(Timber.font, x, y, "Target", 1)
	end 
	-- local trees = Entity.GetTreesInRadius(myHero, 1000, true) 
	-- for i = 1, #trees do
	-- 	local x, y, vis = Renderer.WorldToScreen(Entity.GetAbsOrigin(trees[i]))
	-- 	Renderer.DrawTextCentered(Timber.font, x, y, "X", 1)
	-- end 
end

function Timber.OnLinearProjectileCreate(projectile)
	
end

function Timber.OnParticleCreate(particle)
 	if particle.name == "shredder_timber_chain_tree" then
 		Log.Write("yeah")
 		Timber.whirlingTick = GameRules.GetGameTime();
 	end 
 end 
return Timber
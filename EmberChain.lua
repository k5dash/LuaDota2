local ember= {}

ember.optionEnable = Menu.AddOption({ "Hero Specific","Ember"}, "Enabled", "Auto Chain")
ember.optionKey = Menu.AddKeyOption({ "Hero Specific","Ember"}, "Key", Enum.ButtonCode.KEY_P)

function ember.OnUpdate()
	if not Menu.IsEnabled(ember.optionEnable) then return end
	if not Menu.IsKeyDown(ember.optionKey) then return end
	local myHero = Heroes.GetLocal()
	if NPC.GetUnitName(myHero)~="npc_dota_hero_ember_spirit" then return end

	local punch = NPC.GetAbilityByIndex(myHero, 1)
	local fist = NPC.GetAbilityByIndex(myHero, 0)
	local mousePos = Input.GetWorldCursorPos()
	Ability.CastPosition(punch, mousePos)
	local enemy = getCloseEnemy(mousePos,myHero) 
	local enemyPos = NPC.GetAbsOrigin(enemy)
	local myPos = NPC.GetAbsOrigin(myHero)
	local distance = myPos:Distance(enemyPos);
          distance =  distance:Length2DSqr()
    Log.Write(distance)
    if (distance<6000) then
    	Ability.CastNoTarget(fist)
    end
end

function getCloseEnemy(mousePos, myHero)
	local target;
	local minDistance = 1000000;
	for i = 1, Heroes.Count() do
		local hero = Heroes.Get(i)
		local myTeam = Entity.GetTeamNum(myHero)
        local sameTeam = Entity.GetTeamNum(hero) == myTeam
          if not sameTeam and not NPC.IsDormant(hero) and Entity.GetHealth(hero) > 0 then
            local enemyPos = NPC.GetAbsOrigin(hero)
            local distance = mousePos:Distance(enemyPos);
            distance =  distance:Length2DSqr()
            if distance < minDistance then
            	target = hero;
            	minDistance = distance
            end
        end
	end
	return target
end

return ember
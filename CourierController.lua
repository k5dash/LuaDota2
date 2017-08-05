local CourierController = {}

CourierController.optionEnable = Menu.AddOption({"Utility", "Courier"}, "Enable",  "Combo")
CourierController.optionKey = Menu.AddKeyOption({"Utility", "Courier"}, "Key", Enum.ButtonCode.KEY_F)

CourierController.courierArray= {}
CourierController.tick = 0
CourierController.messageTick = 0
CourierController.playerHeroMap = {}
CourierController.heroesPlayerMap= {}
CourierController.mutedHeroes = {}
CourierController.mutedHeroesLength = 0
CourierController.forceTranfer = {}

CourierController.oldMutedHeroesLengh = 1000

CourierController.font = Renderer.LoadFont("Arial", 30, Enum.FontWeight.EXTRABOLD)
CourierController.players = {}


function CourierController.OnUpdate()
    if not Menu.IsEnabled(CourierController.optionEnable) then return true end

    CourierController.getPlayerHeroMap()
    CourierController.findCourier()

    if Menu.IsKeyDown(CourierController.optionKey) then
    	local pos = Input.GetWorldCursorPos()
    	for i = 1,#CourierController.courierArray do
    		CourierController.forceTranfer = {}
    		local courier = CourierController.courierArray[i]
    		NPC.MoveTo(courier, pos,false,false) 
    	end 
    	return
    end 
    CourierController.controlCourier()
end

function CourierController.findCourier()
	if GameRules.GetGameTime() < CourierController.tick then return end 
	local myHero = Heroes.GetLocal()

	CourierController.courierArray = {}
	for i= 1, NPCs.Count() do
		local entity = NPCs.Get(i) 
		if entity and Entity.IsSameTeam(myHero, entity) and NPC.GetUnitName(entity) == "npc_dota_courier" and Entity.IsAlive(entity) then
			table.insert(CourierController.courierArray, entity)
		end 
	end
	CourierController.getMutedHeroes()
	CourierController.tick = GameRules.GetGameTime() + 1
end

function CourierController.controlCourier()
	local myHero = Heroes.GetLocal()
	for i = 1,#CourierController.courierArray do
		local courier = CourierController.courierArray[i]
		if courier then
			local state = Courier.GetCourierState(courier)
			local courierEnt = Courier.GetCourierStateEntity(courier)
			local transfer = NPC.GetAbility(courier, "courier_take_stash_and_transfer_items")
			local goBase = NPC.GetAbilityByIndex(courier, 0)

			if state == Enum.CourierState.COURIER_STATE_DELIVERING_ITEMS and courierEnt == myHero then
				CourierController.forceTranfer[courier] = true
			end 
			if CourierController.forceTranfer[courier] == true then
				if NPC.IsEntityInRange(myHero, courier, 600) then
					CourierController.forceTranfer[courier] = false
				else 
					if Entity.IsAlive(myHero) then
						Ability.CastNoTarget(transfer)
					else 
						CourierController.forceTranfer[courier] = false
					end 
				end
			end
			if courierEnt and Entity.IsHero(courierEnt) and CourierController.mutedHeroes[NPC.GetUnitName(courierEnt)] and not CourierController.forceTranfer[courier] then
        		Ability.CastNoTarget(goBase)
		    end
		end
	end 
end

function CourierController.getPlayerHeroMap()
	if CourierController.players[0] then return end 
	local myHero = Heroes.GetLocal()
	if GameRules.GetServerGameState()~=5 then return end
	for i = 0,10 do
		if CourierController.players[i] then
			Menu.RemoveOption(CourierController.players[i])
			CourierController.players[i] = nil
		end
	end 

	for i= 1, Heroes.Count() do
		local entity = Heroes.Get(i) 
		if entity and Entity.IsSameTeam(myHero, entity)then
			local owner = Entity.GetOwner(entity)
			CourierController.playerHeroMap[Player.GetPlayerID(owner)] = NPC.GetUnitName(entity)
			CourierController.heroesPlayerMap[NPC.GetUnitName(entity)] = Player.GetPlayerID(owner)

			if not CourierController.players[Player.GetPlayerID(owner)] then
				--Log.Write(Player.GetPlayerID(owner)..":"..NPC.GetUnitName(entity))
				CourierController.players[Player.GetPlayerID(owner)] = Menu.AddOption({"Hero Specific", "Courier"}, string.upper(string.sub(NPC.GetUnitName(entity),15)),  "Lock Courier Usage")
			end
		end 
	end

end

function CourierController.getMutedHeroes()
	CourierController.mutedHeroes ={}
	CourierController.mutedHeroesLength = 0
	local myHero = Heroes.GetLocal()
	for i= 1, NPCs.Count() do
		local entity = NPCs.Get(i) 
		if entity and Entity.IsHero(entity) and Entity.IsSameTeam(myHero, entity) then
			local owner = Entity.GetOwner(entity)
			local ownerID = Hero.GetPlayerID(entity)
			if Player.IsMuted(owner) or (CourierController.players[ownerID] and Menu.IsEnabled(CourierController.players[ownerID])) then
				CourierController.mutedHeroes[NPC.GetUnitName(entity)] = true
				CourierController.mutedHeroesLength = CourierController.mutedHeroesLength +1
			end
		end 
	end
	if CourierController.oldMutedHeroesLengh ~= CourierController.mutedHeroesLength then
		CourierController.messageTick = GameRules.GetGameTime() + 10
		CourierController.oldMutedHeroesLengh = CourierController.mutedHeroesLength
	end 
end

function CourierController.OnGameStart()
	CourierController.courierArray= {}
	CourierController.tick = 0
	CourierController.messageTick = 0
	CourierController.playerHeroMap = {}
	CourierController.heroesPlayerMap= {}
	CourierController.mutedHeroes = {}
	CourierController.oldMutedHeroesLengh = 1000
	CourierController.players = {}
end

function CourierController.OnDraw()
	if not Menu.IsEnabled(CourierController.optionEnable) then return end

	if GameRules.GetGameMode() == -1 then
		for i= 0, 10 do
			if CourierController.players[i] then
				Log.Write("removed")
				Menu.RemoveOption(CourierController.players[i])
				CourierController.players[i] = nil
			end 
		end
	end 

	if CourierController.messageTick < GameRules.GetGameTime() or not Engine.IsInGame() then return end
	local message = ""
	for key,value in pairs(CourierController.mutedHeroes) do 
		message= message..string.upper(string.sub(key,15))..", "
	end 
	local w, h = Renderer.GetScreenSize()
	Renderer.SetDrawColor(255, 0, 255)

	if CourierController.mutedHeroesLength == 0 then 
		Renderer.DrawTextCentered(CourierController.font, w / 2, h / 2, "No players are muted", 1)
	else
		Renderer.DrawTextCentered(CourierController.font, w / 2, h / 2, message.." muted", 1)
	end 

end
return CourierController
local autoBottle = {}

autoBottle.optionEnable = Menu.AddOption({ "Utility" }, "Auto Bottle", "Auto Bottle when you on your base. Script by Rednelss")

function autoBottle.OnUpdate()
	if not Menu.IsEnabled(autoBottle.optionEnable) then return end
	local myHero = Heroes.GetLocal()
	if not NPC.HasModifier(myHero, "modifier_fountain_aura_buff") then return end
	if Entity.GetHealth(myHero) >= Entity.GetMaxHealth(myHero) and NPC.GetMana(myHero) >= NPC.GetMaxMana(myHero) then return end
	
	local bottle = NPC.GetItem(myHero, "item_bottle", true)
	if bottle == nill or not Ability.IsReady(bottle) or NPC.HasModifier(myHero, "modifier_bottle_regeneration") or NPC.IsChannellingAbility(myHero) then return end 			
	Ability.CastNoTarget(bottle)
end

return autoBottle
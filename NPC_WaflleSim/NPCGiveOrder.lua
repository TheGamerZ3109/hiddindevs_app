local module = {}

function module.giveRandomOrder(npc)
	local toppings = game.ReplicatedStorage.Resources.Assets.Objects.Toppings:GetChildren()
	local randomNum = math.random(1, #toppings)

	local ranTopping = toppings[randomNum]
	
	local order
	
	order = {
		ranTopping.Name
	}
	
	require(script.Parent.Parent.Resturant.OrderHandler).makeOrder(order, npc)
end

return module

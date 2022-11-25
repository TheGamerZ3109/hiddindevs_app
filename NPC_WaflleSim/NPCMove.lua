local goals = workspace.PlrResturant.NPCGoals:GetChildren()

local numGoals = #goals

local module = {}

function module.moveToRandomCashReg(npc : Model, goal : BasePart)
	local goalReached = false
	
	local humanoid = npc:FindFirstChild("Humanoid")
	
	if not humanoid then return end
	
	if goal.Parent:FindFirstChild("CurrentlyUsing") then npc:Destroy() return end
	
	local string = Instance.new("StringValue")
	string.Name = "CurrentlyUsing"
	string.Parent = goal.Parent
	
	humanoid:MoveTo(goal.Position)
	
	while not goalReached do
		if not humanoid and humanoid.Parent then
			break
		end
		
		if humanoid.WalkToPoint ~= goal then
			break
		end
		
		humanoid:MoveTo(goal.Position)
		task.wait(6)
	end
	
	humanoid.MoveToFinished:Connect(function()
		if not goalReached then
			goalReached = true
			
			
			require(script.Parent.NPCGiveOrder).giveRandomOrder(npc)
			
			task.wait(.5)
			
			require(script.Parent.NPCSeat).seat(npc, goal.Parent)
			
		end
	end)
end

return module
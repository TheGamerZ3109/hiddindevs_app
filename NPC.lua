-- im not gonna line in the actual game this is all in a ton of modules, but you guys said it all had to be in 1 
-- script, so here it is

local plrResturant = game.Workspace.PlrResturant
local orderMenu = plrResturant.OrderMenu

local mainui = orderMenu.OrdersGui.MainFrame
local template = mainui.Templates.WaffleOrderTemplate

local canStartOrder = mainui.Parent.CanStartOrder

local updatePlrGui = require(game.ReplicatedStorage.Resources.SharedModules.UpdatePlrGui)

local npcAssets = game.ReplicatedStorage.Resources.Assets.NPCAssets
local hair = npcAssets.Hairs:GetChildren()
local shirts = npcAssets.Shirts:GetChildren()
local pants = npcAssets.Pants:GetChildren()

local numHairs = #hair
local numShirts = #shirts
local numPants = #pants

local plrResturant = game.Workspace.PlrResturant
local tables = plrResturant.Tables
local regs = plrResturant.Registers

local waitTime = game.ServerStorage.GlobalAmounts.NPCWaitTime
waitTime.Value = math.random(1, 7)

local defaultNPC = npcAssets.DefaultNPC

local numSeats = 2 -- current am of available seats

function startOrder(plr, code)
	if not mainui:FindFirstChild(tostring(code)) then return end -- weird anti-exploit code system I have
	if not canStartOrder then return end
	
	local resturantCustoms = plr:WaitForChild("ResturantCustoms")
	local batter = resturantCustoms:WaitForChild("BatterStock")

	if batter.Value < 1 then return end

	local mixer = plrResturant:FindFirstChild(plr.ResturantCustoms.Mixer.Value) -- checks the plrs data and finds what mixer they have, then finds the object of it

	if not mixer then return end

	if mixer:WaitForChild("Ball"):FindFirstChildOfClass("ProximityPrompt") or mixer:WaitForChild("Ball"):FindFirstChildOfClass("BillboardGui") then return end

	canStartOrder = false

	--local function findCookPart()
	--	for i, v in pairs(plrResturant.Stoves:GetDescendants()) do
	--		if v.Parent.Name == "CookingParts" then
	--			return v
	--		end
	--	end
	--end

	--local cookPart
	
	-- removed because of upgradable stoves update
	
	--repeat
	--	cookPart = findCookPart()
	--	print(cookPart)
	--	task.wait(.1)
	--until cookPart:FindFirstChild("Waffle") == nil

	local frame = mainui:FindFirstChild(tostring(code))

	local orderInfo = {}

	local orderFolder = frame:WaitForChild("ToppingsSave")
	if orderFolder:FindFirstChildOfClass("BoolValue") then
		orderInfo[orderFolder:FindFirstChildOfClass("BoolValue").Name] = orderFolder:FindFirstChildOfClass("BoolValue").Name

		updatePlrGui.addToppingList(plr, orderInfo[orderFolder:FindFirstChildOfClass("BoolValue").Name], code)
	end

	frame:Destroy()

	require(script.Parent.MixingHandler).initMix(plr, nil, orderInfo, code)

	task.wait(.1)

	canStartOrder = true
end

function makeOrder(orderInfo, npc)
	--[[
	order info should be setup something like this
	{
		"topping1",
		"topping2" - etc add more toppings whatever
	}
	]]

	for i, v in pairs(orderInfo) do		
		local frame = template:Clone()
		frame.Parent = mainui
		frame.Visible = true

		frame.Name = math.random(1, 9999)

		frame.OrderInfo.Text = "Waffle with ".. tostring(v)

		local folder = Instance.new("Folder")
		folder.Name = "ToppingsSave"
		folder.Parent = frame

		local bool = Instance.new("BoolValue")
		bool.Name = v
		bool.Value = false
		bool.Parent = folder

		local bool2 = Instance.new("BoolValue")
		bool2.Name = "OrderDelivered"
		bool2.Value = false
		bool2.Parent = npc

		if bool.Name == "None" then
			bool.Value = true
		end

		npc.Name = tostring(frame.Name) -- TODO: make this a string value/number value under the NPC model at some point
	end
end


function canSeat()
	local availableSeats = {}
	local availableReg = {}

	for i, v in pairs(tables:GetDescendants()) do
		if v:IsA("Seat") and v.Occupant == nil then
			table.insert(availableSeats, v) -- makes a table of all the available seats
		end
	end

	for i, v in pairs(regs:GetChildren()) do
		if v.Name == "CashRegister" and not v:FindFirstChild("CurrentlyUsing") then
			table.insert(availableReg, v) -- makes table of available registers
		end
	end

	if availableSeats[1] and availableReg[1] then -- if there is at least 1 available seat and available reg, return true
		return true
	else
		return false
	end
end


function seat(npc, register)
	-- is ran after the NPC moves right next to the seat to prevent it from looking too weird
	-- sits the NPC in the chosen seat
	spawn(function() -- multi threading because I was having a weird bug a while back and this fixed it
		for i, v in pairs(tables:GetDescendants()) do
			if not v:IsA("Seat") then continue end
			if v.Occupant ~= nil then  continue end

			npc:WaitForChild("HumanoidRootPart").CFrame = v.CFrame -- 
		end

		if register and register:FindFirstChild("CurrentlyUsing") then
			register:FindFirstChild("CurrentlyUsing"):Destroy()
			-- removes my check for the registers usage, saying that its free again
		end
	end)
end


function giveRandomOrder(npc)
	local toppings = game.ReplicatedStorage.Resources.Assets.Objects.Toppings:GetChildren()
	local randomNum = math.random(1, #toppings) -- gets a random topping

	local ranTopping = toppings[randomNum]

	local order

	order = {
		ranTopping.Name -- makes the order array
	}

	makeOrder(order, npc) -- 
	
end


function moveToRandomCashReg(npc : Model, goal : BasePart)
	local goalReached = false

	local humanoid = npc:FindFirstChild("Humanoid")

	if not humanoid then return end
	
	-- my own check of reg usage
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


			giveRandomOrder(npc)

			task.wait(.5)

			seat(npc, goal.Parent)

		end
	end)
	
end


function loadNPC()
	local ranHair = hair[math.random(1, numHairs)]:Clone()
	local ranShirt = shirts[math.random(1, numShirts)]:Clone()
	local ranPants = pants[math.random(1, numPants)]:Clone() -- gens random choice of shirts, pants, etc

	local newNPC = defaultNPC:Clone()

	newNPC.Parent = workspace.RunTimeInstances.ActiveNPCs

	ranHair.Parent = newNPC
	ranShirt.Parent = newNPC
	ranPants.Parent = newNPC

	newNPC:WaitForChild("HumanoidRootPart").CFrame = game.Workspace.PlrResturant.NPCSpawn.CFrame

	return true, newNPC
end


while task.wait(waitTime.Value / numSeats) do -- TODO: do math later just need it to work for now
	numSeats = #workspace.PlrResturant.Tables:GetChildren() * 2 -- 2 seats per tables
	local numReg = #game.Workspace.PlrResturant.RegisterSpawns:GetChildren()
	local ranReg = game.Workspace.PlrResturant.Registers:GetChildren()[math.random(1, numReg)]
	
	if canSeat() == false then continue end	
	if not ranReg then continue end
	local value, npc = loadNPC()
	
	moveToRandomCashReg(npc, ranReg.PrimaryPart)
end

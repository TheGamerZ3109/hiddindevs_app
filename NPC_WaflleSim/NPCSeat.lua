local plrResturant = game.Workspace.PlrResturant
local tables = plrResturant.Tables
local regs = plrResturant.Registers

local waitTime = game.ServerStorage.GlobalAmounts.NPCWaitTime

local module = {}

function module.canSeat()
	local availableSeats = {}
	local availableReg = {}
	
	for i, v in pairs(tables:GetDescendants()) do
		if v:IsA("Seat") and v.Occupant == nil then
			table.insert(availableSeats, v)
		end
	end
	
	for i, v in pairs(regs:GetChildren()) do
		if v.Name == "CashRegister" and not v:FindFirstChild("CurrentlyUsing") then
			table.insert(availableReg, v)
		end
	end
	
	if availableSeats[1] and availableReg[1] then
		return true
	else
		return false
	end
end

function module.seat(npc, register)
	spawn(function()
		for i, v in pairs(tables:GetDescendants()) do
			if not v:IsA("Seat") then continue end
			if v.Occupant ~= nil then  continue end
			
			npc:WaitForChild("HumanoidRootPart").CFrame = v.CFrame
		end
		
		if register and register:FindFirstChild("CurrentlyUsing") then
			register:FindFirstChild("CurrentlyUsing"):Destroy()
		end
	end)
end

return module

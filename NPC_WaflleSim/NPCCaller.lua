local npcGen = require(script.Parent.NPCGenerator)
local npcMove = require(script.Parent.NPCMove)

local waitTime = game.ServerStorage.GlobalAmounts.NPCWaitTime
waitTime.Value = math.random(1, 7)

local numSeats = 2

while task.wait(waitTime.Value / numSeats) do -- do math later just need it to work for now
	numSeats = #workspace.PlrResturant.Tables:GetChildren() * 2 -- 2 seats per tables
	local numReg = #game.Workspace.PlrResturant.RegisterSpawns:GetChildren()
	local ranReg = game.Workspace.PlrResturant.Registers:GetChildren()[math.random(1, numReg)]
	
	if require(script.Parent.NPCSeat).canSeat() == false then continue end	
	if not ranReg then continue end
	local value, npc = npcGen.loadNPC()
	
	npcMove.moveToRandomCashReg(npc, ranReg.PrimaryPart)
end
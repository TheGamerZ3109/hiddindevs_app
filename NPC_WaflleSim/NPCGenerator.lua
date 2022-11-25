local npcAssets = game.ReplicatedStorage.Resources.Assets.NPCAssets

local hair = npcAssets.Hairs:GetChildren()
local shirts = npcAssets.Shirts:GetChildren()
local pants = npcAssets.Pants:GetChildren()

local numHairs = #hair
local numShirts = #shirts
local numPants = #pants

local defaultNPC = npcAssets.DefaultNPC

local module = {}

function module.loadNPC()
	local ranHair = hair[math.random(1, numHairs)]:Clone()
	local ranShirt = shirts[math.random(1, numShirts)]:Clone()
	local ranPants = pants[math.random(1, numPants)]:Clone()
	
	local newNPC = defaultNPC:Clone()
	
	newNPC.Parent =workspace.RunTimeInstances.ActiveNPCs
	
	ranHair.Parent = newNPC
	ranShirt.Parent = newNPC
	ranPants.Parent = newNPC
	
	newNPC:WaitForChild("HumanoidRootPart").CFrame = game.Workspace.PlrResturant.NPCSpawn.CFrame
	
	return true, newNPC
end

return module
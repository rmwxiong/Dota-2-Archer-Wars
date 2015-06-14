GEMS = {}
BOWS = {"item_fire_arrows", "item_frost_arrows", "item_lightning_arrows"}

function getItemsAmount( itemType )
	local inventory = { caster:GetItemInSlot(0), caster:GetItemInSlot(1), caster:GetItemInSlot(2), caster:GetItemInSlot(3), caster:GetItemInSlot(4), caster:GetItemInSlot(5), }
	local itemsFound = 0
	local itemTypeToScan = ""

	if itemType == "gems" then
 
	for i, _ in pairs(inventory) do
		if inventory[i]:GetName() == name then
			itemsFound = itemsFound + 1
		end
	end

	return itemsFound
end
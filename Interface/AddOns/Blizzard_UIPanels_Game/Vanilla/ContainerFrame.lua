-- See ContainerFrame_Shared.lua for functions shared across Classic expansions

function ContainerFrame_OnLoad(self)
	self:RegisterEvent("BAG_OPEN");
	self:RegisterEvent("BAG_CLOSED");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	ContainerFrame1.bagsShown = 0;
	ContainerFrame1.bags = {};
	ContainerFrame1.forceExtended = false;
end

function ContainerFrame_UpdateQuestItem(frame, itemIndex, itemButton)
	-- Just hide the quest texture if it exists
	local name = frame:GetName();
	local questTexture = _G[name.."Item"..itemIndex.."IconQuestTexture"];

	if(questTexture) then
		questTexture:Hide();
	end
end
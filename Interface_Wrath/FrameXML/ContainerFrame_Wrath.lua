-- See ContainerFrame_Shared.lua for functions shared across Classic expansions

function ContainerFrame_OnLoad(self)
	self:RegisterEvent("BAG_OPEN");
	self:RegisterEvent("BAG_CLOSED");
	self:RegisterEvent("QUEST_ACCEPTED");
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED");
	self:RegisterEvent("CURRENCY_DISPLAY_UPDATE");
	ContainerFrame1.bagsShown = 0;
	ContainerFrame1.bags = {};
	ContainerFrame1.forceExtended = false;
end

function ContainerFrame_UpdateQuestItem(frame, itemIndex, itemButton)
	local id = frame:GetID();
	local name = frame:GetName();

	local isQuestItem, questId, isActive = GetContainerItemQuestInfo(id, itemButton:GetID());

	questTexture = _G[name.."Item"..itemIndex.."IconQuestTexture"];

	if ( questId and not isActive ) then
		questTexture:SetTexture(TEXTURE_ITEM_QUEST_BANG);
		questTexture:Show();
	elseif ( questId or isQuestItem ) then
		questTexture:SetTexture(TEXTURE_ITEM_QUEST_BORDER);
		questTexture:Show();		
	else
		questTexture:Hide();
	end
end
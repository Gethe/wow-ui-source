-- *****************************************************************************************************
-- ***** ITEM FUNCTIONS
-- *****************************************************************************************************
local function OnRelease(framePool, frame)
	frame:Hide();
	frame:ClearAllPoints();
	frame:SetParent(nil);
end

local g_questObjectiveItemPool = CreateFramePool("BUTTON", nil, "QuestObjectiveItemButtonTemplate", OnRelease);
function QuestObjectiveItem_AcquireButton(parent)
	local itemButton = g_questObjectiveItemPool:Acquire();
	itemButton:SetParent(parent);

	return itemButton;
end

function QuestObjectiveItem_ReleaseButton(button)
	g_questObjectiveItemPool:Release(button);
end

function QuestObjectiveItem_Initialize(itemButton, questLogIndex)
	local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex);
	itemButton:SetID(questLogIndex);
	itemButton.charges = charges;
	itemButton.rangeTimer = -1;
	SetItemButtonTexture(itemButton, item);
	SetItemButtonCount(itemButton, charges);
	QuestObjectiveItem_UpdateCooldown(itemButton);
end

function QuestObjectiveItem_OnLoad(self)
	self:RegisterForClicks("AnyUp");
end

function QuestObjectiveItem_OnEvent(self, event, ...)
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		self.rangeTimer = -1;
	elseif ( event == "BAG_UPDATE_COOLDOWN" ) then
		QuestObjectiveItem_UpdateCooldown(self);
	end
end

function QuestObjectiveItem_OnUpdate(self, elapsed)
	-- Handle range indicator
	local rangeTimer = self.rangeTimer;
	if ( rangeTimer ) then	
		rangeTimer = rangeTimer - elapsed;		
		if ( rangeTimer <= 0 ) then
			local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(self:GetID());
			if ( not charges or charges ~= self.charges ) then
				ObjectiveTracker_Update(OBJECTIVE_TRACKER_UPDATE_MODULE_QUEST);
				return;
			end
			local count = self.HotKey;
			local valid = IsQuestLogSpecialItemInRange(self:GetID());
			if ( valid == 0 ) then
				count:Show();
				count:SetVertexColor(1.0, 0.1, 0.1);
			elseif ( valid == 1 ) then
				count:Show();
				count:SetVertexColor(0.6, 0.6, 0.6);
			else
				count:Hide();
			end
			rangeTimer = TOOLTIP_UPDATE_TIME;
		end
		
		self.rangeTimer = rangeTimer;
	end
end

function QuestObjectiveItem_OnShow(self)
	self:RegisterEvent("PLAYER_TARGET_CHANGED");
	self:RegisterEvent("BAG_UPDATE_COOLDOWN");
end

function QuestObjectiveItem_OnHide(self)
	self:UnregisterEvent("PLAYER_TARGET_CHANGED");
	self:UnregisterEvent("BAG_UPDATE_COOLDOWN");
end

function QuestObjectiveItem_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetQuestLogSpecialItem(self:GetID());
end
		
function QuestObjectiveItem_OnClick(self, button)
	if ( IsModifiedClick("CHATLINK") and ChatEdit_GetActiveWindow() ) then
		local link, item, charges, showItemWhenComplete = GetQuestLogSpecialItemInfo(self:GetID());
		if ( link ) then
			ChatEdit_InsertLink(link);
		end
	else
		UseQuestLogSpecialItem(self:GetID());
	end
end

function QuestObjectiveItem_UpdateCooldown(itemButton)
	local start, duration, enable = GetQuestLogSpecialItemCooldown(itemButton:GetID());
	if ( start ) then
		CooldownFrame_Set(itemButton.Cooldown, start, duration, enable);
		if ( duration > 0 and enable == 0 ) then
			SetItemButtonTextureVertexColor(itemButton, 0.4, 0.4, 0.4);
		else
			SetItemButtonTextureVertexColor(itemButton, 1, 1, 1);
		end
	end
end
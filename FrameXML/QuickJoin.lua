QUICK_JOIN_ALREADY_IN_PARTY = "You are already in a group. You must leave your group to join this queue."
----------------------------
---------Constants----------
----------------------------
QUICK_JOIN_NAME_SEPARATION = 2;

----------------------------
-------QuickJoinFrame-------
----------------------------
QuickJoinMixin = {};

function QuickJoinMixin:OnLoad()
	self.ScrollFrame.update = function() self:UpdateScrollFrame(); end
	self.ScrollFrame.dynamic = function(...) return self:GetTopButton(...) end
	self.ScrollFrame.scrollBar.doNotHide = true;
	self.ScrollFrame.scrollBar.trackBG:Hide();

	self.entries = CreateFromMixins(QuickJoinEntriesMixin);
	self.entries:Init();

	HybridScrollFrame_CreateButtons(self.ScrollFrame, "QuickJoinButtonTemplate");

	self:UpdateScrollFrame();
end

function QuickJoinMixin:SetEventsRegistered(registered)
	local func = registered and self.RegisterEvent or self.UnregisterEvent;

	func(self, "SOCIAL_QUEUE_UPDATE");
	func(self, "GROUP_JOINED");
	func(self, "GROUP_LEFT");
end

function QuickJoinMixin:OnShow()
	self:SetEventsRegistered(true);
	self.entries:UpdateAll();
	self:SelectGroup(nil);
	self:UpdateScrollFrame();
end

function QuickJoinMixin:OnHide()
	self:SetEventsRegistered(false);
end

function QuickJoinMixin:OnEvent(event, ...)
	if ( event == "SOCIAL_QUEUE_UPDATE" ) then
		local requester = ...;
		self.entries:UpdateEntry(requester);

		if ( requester == self:GetSelectedGroup() ) then
			local entry = self.entries:GetEntry(requester);
			if ( entry and not entry:CanJoin() ) then
				self:SelectGroup(nil);
			end
		end
		self:UpdateScrollFrame();
	elseif ( event == "GROUP_JOINED" ) then
		local index, guid = ...;
		self.entries:UpdateEntry(guid);

		self:UpdateScrollFrame();
		self:UpdateJoinButtonState();
	elseif ( event == "GROUP_LEFT" ) then
		local guid = ...;
		self.entries:UpdateEntry(guid);

		self:UpdateScrollFrame();
		self:UpdateJoinButtonState();
	end
end

function QuickJoinMixin:UpdateScrollFrame()
	local offset = HybridScrollFrame_GetOffset(self.ScrollFrame);

	local buttons = self.ScrollFrame.buttons;

	local totalHeight = 0;
	local entries = self.entries:GetEntries();
	for i=1, #entries do
		totalHeight = totalHeight + entries[i]:GetFrameHeight();
	end

	for i=1, #buttons do
		local entryIndex = i + offset;
		if ( entryIndex <= #entries ) then
			buttons[i]:SetEntry(entries[entryIndex]);
			buttons[i].Background:SetAlpha(entryIndex % 2 == 0 and 0.1 or 0.05);
			local selected = buttons[i]:GetEntry():GetGUID() == self.selectedGUID;
			buttons[i].Selected:SetShown(selected);
			buttons[i].Highlight:SetAlpha(selected and 0 or 0.5);
			buttons[i]:Show();
		else
			buttons[i]:Hide();
		end
	end

	HybridScrollFrame_Update(self.ScrollFrame, totalHeight, totalHeight);
end

function QuickJoinMixin:GetTopButton(offset)
	local usedHeight = 0;
	local entries = self.entries:GetEntries();
	for i=1, #entries do
		local entry = entries[i];
		local height = entry:GetFrameHeight();
		if ( usedHeight + height >= offset ) then
			return i - 1, offset - usedHeight;
		else
			usedHeight = usedHeight + height;
		end
	end
	return 0, 0;
end

function QuickJoinMixin:SelectGroup(guid)
	self.selectedGUID = guid;
	self:UpdateScrollFrame();
	self:UpdateJoinButtonState();
end

function QuickJoinMixin:GetSelectedGroup()
	return self.selectedGUID;
end

function QuickJoinMixin:JoinQueue()
	local selectedEntry = self.entries:GetEntry(self.selectedGUID);
	if ( selectedEntry ) then
		selectedEntry:AttemptJoin();
	end
end

function QuickJoinMixin:UpdateJoinButtonState()
	if ( IsInGroup(LE_PARTY_CATEGORY_HOME) ) then
		self.JoinQueueButton:Disable();
		self.JoinQueueButton.tooltip = QUICK_JOIN_ALREADY_IN_PARTY;
	elseif ( self:GetSelectedGroup() == nil ) then
		self.JoinQueueButton:Disable();
		self.JoinQueueButton.tooltip = nil;
	else
		self.JoinQueueButton:Enable();
		self.JoinQueueButton.tooltip = nil;
	end
end

----------------------------
------QuickJoinButton------
----------------------------
QuickJoinButtonMixin = {}

function QuickJoinButtonMixin:GetMainPanel()
	return QuickJoinFrame;
end

function QuickJoinButtonMixin:SetEntry(entry)
	entry:ApplyToFrame(self);
	self.entry = entry;
end

function QuickJoinButtonMixin:GetEntry()
	return self.entry;
end

function QuickJoinButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	self:GetEntry():ApplyToTooltip(GameTooltip);
	GameTooltip:Show();
	if ( self:GetEntry():CanJoin() ) then
		self.Highlight:Show();
	end
end

function QuickJoinButtonMixin:OnLeave()
	GameTooltip:Hide();
	self.Highlight:Hide();
end

function QuickJoinButtonMixin:OnClick()
	if ( self:GetEntry():CanJoin() ) then
		self:GetMainPanel():SelectGroup(self:GetEntry():GetGUID());
	end
end

----------------------------
------QuickJoinEntries------
----------------------------
QuickJoinEntriesMixin = {}

function QuickJoinEntriesMixin:Init()
	self:UpdateAll();
end

function QuickJoinEntriesMixin:GetEntries()
	return self.entries;
end

function QuickJoinEntriesMixin:GetEntry(guid)
	return self.entriesByGUID[guid];
end

function QuickJoinEntriesMixin:UpdateAll()
	local groups = C_SocialQueue.GetAllGroups();
	self.entries = {};
	self.entriesByGUID = {};
	for i=1, #groups do
		local entry = CreateFromMixins(QuickJoinEntryMixin);
		entry:Init(groups[i]);
		self.entries[i] = entry;
		self.entriesByGUID[groups[i]] = entry;
	end

	--Sort?
	--table.sort(self.entries, SOMETHING);
end

function QuickJoinEntriesMixin:UpdateEntry(requester)
	local entry = self.entriesByGUID[requester];
	if ( entry ) then
		entry:Update();
	elseif ( C_SocialQueue.GetGroupInfo(requester) ) then
		--Just add the new one to the end
		local entry = CreateFromMixins(QuickJoinEntryMixin);
		entry:Init(requester);
		self.entries[#self.entries+1] = entry;
		self.entriesByGUID[requester] = entry;
	end
end

----------------------------
-------QuickJoinEntry-------
----------------------------
QuickJoinEntryMixin = {}

function QuickJoinEntryMixin:Init(partyGUID)
	self.guid = partyGUID;
	self:UpdateAll();
end

function QuickJoinEntryMixin:GetGUID()
	return self.guid;
end

function QuickJoinEntryMixin:UpdateAll()
	self.displayedMembers = {};
	self.displayedQueues = {};
	self:Update();

	--Sort?
end

local function guidIDGetter(guid)
	return guid; --Guids are unique identifying information as-is.
end

local function queueIDGetter(queue)
	return queue.clientID;
end

function QuickJoinEntryMixin:Update()
	local newMembers = C_SocialQueue.GetGroupMembers(self.guid) or {};
	local newQueues = C_SocialQueue.GetGroupQueues(self.guid) or {};

	self.zombieMemberIndices = self:BackfillAndUpdateFields(newMembers, self.displayedMembers, guidIDGetter);
	self.zombieQueueIndices = self:BackfillAndUpdateFields(newQueues, self.displayedQueues, queueIDGetter);
	self.canJoin = C_SocialQueue.GetGroupInfo(self.guid);
end

function QuickJoinEntryMixin:CanJoin()
	return self.canJoin;
end

function QuickJoinEntryMixin:BackfillAndUpdateFields(newList, oldList, idGetter)
	local toDisplay = {};
	for k, v in pairs(newList) do
		toDisplay[idGetter(v)] = v;
	end

	local slotsToFillIn = {};
	for i=#oldList, 1, -1 do
		local id = idGetter(oldList[i]);
		if ( toDisplay[id] ) then
			oldList[i] = toDisplay[id]; --Update the data
			toDisplay[id] = nil;
		else
			slotsToFillIn[#slotsToFillIn + 1] = i;
		end
	end

	for dataID, dataValue in pairs(toDisplay) do
		if ( #slotsToFillIn > 0 ) then
			local fillIn = slotsToFillIn[#slotsToFillIn];
			oldList[fillIn] = dataValue;
			slotsToFillIn[#slotsToFillIn] = nil;
		else
			oldList[#oldList + 1] = dataValue;
		end
	end

	return tInvert(slotsToFillIn);
end

function QuickJoinEntryMixin:GetActiveLFGListInfo()
	for i=1, #self.displayedQueues do
		if ( not self.zombieQueueIndices[i] ) then
			if ( self.displayedQueues[i].type == "lfglist" ) then
				return self.displayedQueues[i];
			end
		end
	end
end

function QuickJoinEntryMixin:AttemptJoin()
	local lfgListInfo = self:GetActiveLFGListInfo();
	if ( lfgListInfo ) then
		LFGListApplicationDialog_Show(LFGListApplicationDialog, lfgListInfo.lfgListID);
	else
		QuickJoinRoleSelectionFrame:ShowForGroup(self:GetGUID());
	end
end

function QuickJoinEntryMixin:ApplyToTooltip(tooltip)
	SocialQueueUtil_SetTooltip(tooltip, SOCIAL_QUEUE_TOOLTIP_HEADER, self.displayedQueues);
end

function QuickJoinEntryMixin:ApplyToFrame(frame)
	--Names
	for i=1, #self.displayedMembers do
		local name, color = SocialQueueUtil_GetNameAndColor(self.displayedMembers[i]);
		if ( self.zombieMemberIndices[i] or not self:CanJoin() ) then
			name = DISABLED_FONT_COLOR_CODE..name..FONT_COLOR_CODE_CLOSE;
		else
			--Use the color code for our relationship
			name = color..name..FONT_COLOR_CODE_CLOSE;
		end

		local nameObj = frame.Members[i];
		if ( not nameObj ) then
			nameObj = frame:CreateFontString(nil, "ARTWORK", "QuickJoinButtonMemberTemplate");
			nameObj:SetPoint("TOPLEFT", frame.Members[i-1], "BOTTOMLEFT", 0, -QUICK_JOIN_NAME_SEPARATION);
			frame.Members[i] = nameObj;
		end

		nameObj:SetText(name);
		nameObj:Show();
	end

	for i=#self.displayedMembers + 1, #frame.Members do
		frame.Members[i]:Hide();
	end

	--Queues
	for i=1, #self.displayedQueues do
		local queue = self.displayedQueues[i];

		local queueObj = frame.Queues[i];
		if ( not queueObj ) then
			queueObj = frame:CreateFontString(nil, "ARTWORK", "QuickJoinButtonQueueTemplate");
			queueObj:SetPoint("TOPLEFT", frame.Queues[i-1], "BOTTOMLEFT", 0, -QUICK_JOIN_NAME_SEPARATION);
			frame.Queues[i] = queueObj;
		end

		local queueName = SocialQueueUtil_GetQueueName(queue);
		if ( self.zombieQueueIndices[i] or not self:CanJoin() ) then
			queueName = DISABLED_FONT_COLOR_CODE..queueName..FONT_COLOR_CODE_CLOSE;
		end
		queueObj:SetText(queueName);
		queueObj:Show();
	end

	for i=#self.displayedQueues + 1, #frame.Queues do
		frame.Queues[i]:Hide();
	end

	--Height
	frame:SetHeight(self:GetFrameHeight());
end

function QuickJoinEntryMixin:GetFrameHeight()
	return		4	--Buffer height
			+	math.max(	(16 + QUICK_JOIN_NAME_SEPARATION) * #self.displayedMembers, --Member height
							(16 + QUICK_JOIN_NAME_SEPARATION) * #self.displayedQueues); --Queues height
end

----------------------------
---QuickJoinRoleSelection---
----------------------------
QuickJoinRoleSelectionMixin = {};

function QuickJoinRoleSelectionMixin:ShowForGroup(guid)
	self.guid = guid;
	local canJoin, numQueues, needTank, needHealer, needDamage = C_SocialQueue.GetGroupInfo(guid);
	self:SetDisabledRoles(
		not needTank and QUICK_JOIN_ROLE_NOT_NEEDED,
		not needHealer and QUICK_JOIN_ROLE_NOT_NEEDED,
		not needDamage and QUICK_JOIN_ROLE_NOT_NEEDED
	);
	StaticPopupSpecial_Show(self);
end

function QuickJoinRoleSelectionMixin:OnAccept()
	if ( not C_SocialQueue.RequestToJoin(self.guid, self:GetSelectedRoles()) ) then
		UIErrorsFrame:AddMessage(QUICK_JOIN_FAILED, 1.0, 0.1, 0.1, 1.0);
	end
	StaticPopupSpecial_Hide(self);
end

function QuickJoinRoleSelectionMixin:OnCancel()
	StaticPopupSpecial_Hide(self);
end

----------------------------
--Things that don't need their own mixins
----------------------------
function QuickJoin_JoinQueueButtonOnClick(self)
	local quickJoin = self:GetParent();
	quickJoin:JoinQueue();
end

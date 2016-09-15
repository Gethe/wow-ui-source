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
end

function QuickJoinMixin:OnShow()
	self:SetEventsRegistered(true);
	self.entries:UpdateAll();
	self:UpdateScrollFrame();
end

function QuickJoinMixin:OnHide()
	self:SetEventsRegistered(false);
end

function QuickJoinMixin:OnEvent(event, ...)
	if ( event == "SOCIAL_QUEUE_UPDATE" ) then
		local requester = ...;
		self.entries:UpdateEntry(requester);
		self:UpdateScrollFrame();
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
			entries[entryIndex]:ApplyToFrame(buttons[i]);
			buttons[i]:Show();
			buttons[i].Background:SetAlpha(entryIndex % 2 == 0 and 0.1 or 0.05);
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
	else
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

function QuickJoinEntryMixin:ApplyToFrame(frame)
	--Names
	for i=1, #self.displayedMembers do
		local name, color = SocialQueueUtil_GetNameAndColor(self.displayedMembers[i]);
		if ( self.zombieMemberIndices[i] ) then
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
		if ( self.zombieQueueIndices[i] ) then
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

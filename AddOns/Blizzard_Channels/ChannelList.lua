ChannelListMixin = {};

function ChannelListMixin:OnLoad()
	local ResetChannelButton = function(pool, channelButton)
		channelButton:Reset();
	end

	self.headerButtonPool = CreateFramePool("Button", self.Child, "ChannelButtonHeaderTemplate", ResetChannelButton);
	self.textChannelButtonPool = CreateFramePool("Button", self.Child, "ChannelButtonTextTemplate", ResetChannelButton);
	self.voiceChannelButtonPool = CreateFramePool("Button", self.Child, "ChannelButtonVoiceTemplate", ResetChannelButton);
	self.communityChannelButtonPool = CreateFramePool("Button", self.Child, "ChannelButtonCommunityTemplate", ResetChannelButton);
	self.collapsedStates = {};

	self.ScrollBar.Background:Hide();
end

function ChannelListMixin:SetCollapsed(category, collapsed)
	self.collapsedStates[category] = collapsed;
end

function ChannelListMixin:IsCollapsed(category)
	return self.collapsedStates[category];
end

function ChannelListMixin:GetChannelFrame()
	return self:GetParent();
end

function ChannelListMixin:ResetChannelButtonAnchors()
	self.previousChannelButton = nil;
	self.buttons = {};
end

function ChannelListMixin:AnchorChannelButton(channelButton)
	if self.previousChannelButton then
		channelButton:SetPoint("TOPLEFT", self.previousChannelButton, "BOTTOMLEFT", 0, -channelButton:GetVerticalPadding(self.previousChannelButton));
	else
		channelButton:SetPoint("TOPLEFT", self:GetScrollChild(), "TOPLEFT");
	end

	self.previousChannelButton = channelButton;
	table.insert(self.buttons, channelButton);
end

function ChannelListMixin:AddChannelButtonInternal(channelButton, ...)
	self:AnchorChannelButton(channelButton);
	channelButton:Setup(...);
end

function ChannelListMixin:AddHeaderButton(...)
	self:AddChannelButtonInternal(self.headerButtonPool:Acquire(), ...);
end

function ChannelListMixin:AddTextChannelButton(...)
	self:AddChannelButtonInternal(self.textChannelButtonPool:Acquire(), ...);
end

function ChannelListMixin:AddChatSystemButton(channelID)
	local name, header, _, channelNumber, count, active, category, channelType = GetChannelDisplayInfo(channelID);
	if header then
		self:AddHeaderButton(channelID, name, header, channelNumber, count, active, category);
	elseif not self:IsCollapsed(category) then
		self:AddTextChannelButton(channelID, name, header, channelNumber, count, active, category, channelType);
	end
end

function ChannelListMixin:AddVoiceChannelButton(channel, category)
	if not self:IsCollapsed(category) then
		self:AddChannelButtonInternal(self.voiceChannelButtonPool:Acquire(), channel.channelID, category);
	end
end

function ChannelListMixin:AddCommunityChannelButton(channelID, clubId, streamInfo)
	if not self:IsCollapsed(clubId) then
		self:AddChannelButtonInternal(self.communityChannelButtonPool:Acquire(), channelID, clubId, streamInfo);
	end
end

function ChannelListMixin:Update()
	local previouslySelectedChannelID = self:GetSelectedChannelButton() and self:GetSelectedChannelButton():GetChannelID();
	self:SetSelectedChannel(nil);

	self.textChannelButtonPool:ReleaseAll();
	self.voiceChannelButtonPool:ReleaseAll();
	self.communityChannelButtonPool:ReleaseAll();
	self.headerButtonPool:ReleaseAll();
	self:ResetChannelButtonAnchors();

	local numTotalChatChannels = GetNumDisplayChannels();
	local numGroupChatChannels = GetNumGroupChannels();

	-- Add just the group channels
	for i = 1, numGroupChatChannels do
		self:AddChatSystemButton(i);
	end


	-- Then add community streams
	local clubs = C_Club.GetSubscribedClubs();

	Communities_LoadUI();
	CommunitiesFrame.CommunitiesList:PredictFavorites(clubs);
	CommunitiesUtil.SortClubs(clubs);

	local currentStreamChannelID = numTotalChatChannels + 1;
	for _, clubInfo in ipairs(clubs) do
		local streams = C_Club.GetStreams(clubInfo.clubId);

		if #streams > 0 then
			local isHeader = true;
			local channelNumber = nil;
			local count = #streams;
			local isActive = true;
			local category = clubInfo.clubId;	-- use the clubId as the category so that all club streams are grouped under this header

			self:AddHeaderButton(currentStreamChannelID, clubInfo.name, isHeader, channelNumber, count, isActive, category);
			currentStreamChannelID = currentStreamChannelID + 1;

			for _, streamInfo in ipairs(streams) do
				self:AddCommunityChannelButton(currentStreamChannelID, clubInfo.clubId, streamInfo);
				currentStreamChannelID = currentStreamChannelID + 1;
			end
		end
	end

	-- And finally add the rest of the channels
	if numTotalChatChannels > numGroupChatChannels then
		for i = numGroupChatChannels + 1, numTotalChatChannels do
			self:AddChatSystemButton(i);
		end
	end

	self:UpdateScrollBar();

	if previouslySelectedChannelID then
		self:SelectChannelByID(previouslySelectedChannelID);
	end

	if not self:GetSelectedChannelButton() then
		self:SetSelectedChannel(self:GetFirstAvailableChannelButton());
	end
end

local function nameCheckPredicate(button, name)
	return button:GetChannelName() == name;
end

local function voiceChannelCheckPredicate(button, channelID)
	return button:ChannelSupportsVoice() and button:GetVoiceChannelID() == channelID;
end

local function textChannelCheckPredicate(button, channelID)
	return not button:ChannelSupportsVoice() and button:GetChannelID() == channelID;
end

local function channelIDCheckPredicate(button, channelID)
	return button:GetChannelID() == channelID;
end

local function activeVoiceChannelPredicate(button)
	return button:ChannelSupportsVoice() and button:IsVoiceActive();
end

local function matchingChannelTypePredicate(button, channelType)
	return button:GetChannelType() == channelType;
end

local function matchingAnyVoiceChannelPredicate(button)
	return button:ChannelSupportsVoice();
end

local function matchingCommunityStreamPredicate(button, clubId, streamId)
	return button:ChannelIsCommunity() and (button.clubId == clubId) and (button.streamId == streamId);
end

function ChannelListMixin:GetButtonForPredicate(predicate, ...)
	for button in self.textChannelButtonPool:EnumerateActive() do
		if predicate(button, ...) then
			return button;
		end
	end

	for button in self.voiceChannelButtonPool:EnumerateActive() do
		if predicate(button, ...) then
			return button;
		end
	end

	for button in self.communityChannelButtonPool:EnumerateActive() do
		if predicate(button, ...) then
			return button;
		end
	end
end

function ChannelListMixin:GetButtonForName(name)
	return self:GetButtonForPredicate(nameCheckPredicate, name);
end

function ChannelListMixin:GetButtonForVoiceChannelID(channelID)
	return self:GetButtonForPredicate(voiceChannelCheckPredicate, channelID);
end

function ChannelListMixin:GetButtonForTextChannelID(channelID)
	return self:GetButtonForPredicate(textChannelCheckPredicate, channelID);
end

function ChannelListMixin:GetButtonForChannelID(channelID)
	return self:GetButtonForPredicate(channelIDCheckPredicate, channelID);
end

function ChannelListMixin:GetButtonForActiveVoiceChannel()
	return self:GetButtonForPredicate(activeVoiceChannelPredicate);
end

function ChannelListMixin:GetButtonForChannelType(channelType)
	return self:GetButtonForPredicate(matchingChannelTypePredicate, channelType);
end

function ChannelListMixin:GetButtonForCommunityStream(clubId, streamId)
	return self:GetButtonForPredicate(matchingCommunityStreamPredicate, clubId, streamId);
end

function ChannelListMixin:GetButtonForAnyVoiceChannel()
	return self:GetButtonForPredicate(matchingAnyVoiceChannelPredicate);
end

function ChannelListMixin:HasChannel(name)
	return self:GetButtonForName(name) ~= nil;
end

function ChannelListMixin:GetHeightFromActiveButtons()
	local totalHeight = 0;
	if self.buttons then
		-- Desired operation: return self.buttons[1]:GetTop() - self.buttons[#self.buttons]:GetBottom();
		local previousButton;
		for index, button in ipairs(self.buttons) do
			local verticalPadding = previousButton and button:GetVerticalPadding(previousButton) or 0;
			totalHeight = totalHeight + verticalPadding + button:GetHeight();
			previousButton = button;
		end
	end

	return totalHeight;
end

function ChannelListMixin:UpdateScrollBar()
	local frameHeight = self:GetHeightFromActiveButtons();

	self.Child:SetHeight(frameHeight);
	self.scrolling = frameHeight > self:GetHeight();

	self.ScrollBar:SetShown(self.scrolling);

	self:GetChannelFrame():UpdateScrolling();
end

function ChannelListMixin:IsScrolling()
	return self.scrolling;
end

-- TODO: Radio button group?
function ChannelListMixin:SetSelectedChannel(channelButton)
	if channelButton ~= self.selectedChannelButton then
		if channelButton and channelButton:ChannelSupportsText() then
			SetSelectedDisplayChannel(channelButton:GetChannelID());
		end

		local previousChannelButton = self.selectedChannelButton;
		self.selectedChannelButton = channelButton;

		if previousChannelButton then
			previousChannelButton:SetIsSelectedChannel(false);
		end

		if channelButton then
			self.selectedChannelID = channelButton:GetChannelID();
			self.selectedChannelSupportsText = channelButton:ChannelSupportsText();
			channelButton:SetIsSelectedChannel(true);
		else
			self.selectedChannelID = nil;
			self.selectedChannelSupportsText = nil;
		end

		self:GetChannelFrame():OnUserSelectedChannel();
	end
end

function ChannelListMixin:GetSelectedChannelButton()
	return self.selectedChannelButton;
end

function ChannelListMixin:GetSelectedChannelIDAndSupportsText()
	return self.selectedChannelID, self.selectedChannelSupportsText;
end

do
	local function IsSelectableChannelButton(channelButton, optionalChannelToExclude)
		assert(channelButton);
		return not channelButton:IsHeader() and channelButton:IsEnabled() and (not optionalChannelToExclude or channelButton:GetChannelID() ~= optionalChannelToExclude);
	end

	local function GetNeighborForIndex(container, index, step, predicate, ...)
		local limit = (step > 0) and #container or 1;
		for i = index, limit, step do
			local object = container[i];
			if predicate(object, ...) then
				return object;
			end
		end
	end

	local function GetObjectIndex(container, object)
		for index, currentObject in ipairs(container) do
			if currentObject == object then
				return index;
			end
		end
	end

	function ChannelListMixin:GetClosestNeighboringChannelButton(channelButton)
		local index = GetObjectIndex(self.buttons, channelButton);
		if index then
			-- Prioritize forward search over reverse
			return GetNeighborForIndex(self.buttons, index + 1, 1, IsSelectableChannelButton) or GetNeighborForIndex(self.buttons, index - 1, -1, IsSelectableChannelButton);
		end
	end

	function ChannelListMixin:GetFirstAvailableChannelButton(optionalChannelToExclude)
		return GetNeighborForIndex(self.buttons, 1, 1, IsSelectableChannelButton, optionalChannelToExclude)
	end

	function ChannelListMixin:SelectChannelByID(channelID)
		self:SetSelectedChannel(self:GetButtonForChannelID(channelID));
	end

	function ChannelListMixin:SelectChannelByName(channelName)
		self:SetSelectedChannel(self:GetButtonForName(channelName));
	end

	function ChannelListMixin:OnChannelLeft(channelID, channelName)
		local selectedButton = self:GetSelectedChannelButton();
		if selectedButton and selectedButton:FuzzyIsMatchingChannel(channelID, channelName) then
			-- Save channel ids before clearing selected channel to avoid side-effects.

			local nextSelectedChannelButton = self:GetClosestNeighboringChannelButton(selectedButton) or self:GetFirstAvailableChannelButton(selectedButton:GetChannelID());
			local nextSelectedChannelID = nextSelectedChannelButton and nextSelectedChannelButton:GetChannelID();
			self:SetSelectedChannel(nil);

			if nextSelectedChannelID then
				self:SelectChannelByID(nextSelectedChannelID);
			end
		end
	end
end

local function ChannelListDropDown_Initialize(dropdown)
	local count = 0;
	local info;
	local channelFrame = dropdown.channelFrame;
	local channel = dropdown.channel;
	local channelName = channel:GetChannelName();
	local category = channel:GetCategory();

	if channel:ChannelSupportsText() then
		if channelFrame:IsCategoryCustom(category) then
			-- SET PASSWORD if it is a custom Channel and is owner
			if IsDisplayChannelOwner() then
				info = UIDropDownMenu_CreateInfo();
				info.text = CHAT_PASSWORD;
				info.notCheckable = 1;
				info.func = function() StaticPopup_Show("CHANNEL_PASSWORD", channelName, nil, channelName); end;
				UIDropDownMenu_AddButton(info);
				count = count + 1;
			end

			-- INVITE if it is a custom Channel and is owner
			if IsDisplayChannelModerator() then
				info = UIDropDownMenu_CreateInfo();
				info.text = PARTY_INVITE;
				info.notCheckable = 1;
				info.func = function() StaticPopup_Show("CHANNEL_INVITE", channelName, nil, channelName); end;
				UIDropDownMenu_AddButton(info);
				count = count + 1;
			end
		end

		-- JOIN if it is a Global Channel
		if channelFrame:IsCategoryGlobal(category) and not channel:IsActive() then
			info = UIDropDownMenu_CreateInfo();
			info.text = CHAT_JOIN;
			info.notCheckable = 1;
			info.func = function() JoinPermanentChannel(channelName); end;
			UIDropDownMenu_AddButton(info);
			count = count + 1;
		end

		-- LEAVE Channel if not a group channel
		if not channelFrame:IsCategoryGroup(category) and channel:IsActive() then
			info = UIDropDownMenu_CreateInfo();
			info.text = CHAT_LEAVE;
			info.notCheckable = 1;
			info.func = function()
				LeaveChannelByName(channelName);

				if dropdown.voiceChannelID then
					C_VoiceChat.LeaveChannel(dropdown.voiceChannelID);
				end
			end
			UIDropDownMenu_AddButton(info);
			count = count + 1;
		end
	end

	-- Voice only channels are a total hack and being removed at some point...still discussing whether or not we want to
	-- add a voice component to text chat channels
	if channel:ChannelSupportsVoice() and channel:IsUserCreatedChannel() then
		-- also allow leaving voice-only channels while they still exist...
		info = UIDropDownMenu_CreateInfo();
		info.text = CHAT_LEAVE;
		info.notCheckable = 1;
		info.func = function()
			C_VoiceChat.LeaveChannel(dropdown.voiceChannelID);
		end
		UIDropDownMenu_AddButton(info);
		count = count + 1;
	end

	if count > 0 then
		info = UIDropDownMenu_CreateInfo();
		info.text = CANCEL;
		info.notCheckable = 1;
		info.func = function() HideDropDownMenu(1); end;
		UIDropDownMenu_AddButton(info);
	end
end

function ChannelListMixin:ShowDropdown(channel)
	HideDropDownMenu(1);

	if channel then
		local dropdown = self:GetChannelFrame():GetDropdown();
		dropdown.channelFrame = self:GetChannelFrame();
		dropdown.channelID = channel:GetChannelID();
		dropdown.voiceChannelID = channel:ChannelSupportsVoice() and channel:GetVoiceChannelID() or nil;
		dropdown.channel = channel;

		dropdown.initialize = ChannelListDropDown_Initialize;
		dropdown.displayMode = "MENU";
		dropdown.onHide = function() dropdown.channelID = nil; end;
		ToggleDropDownMenu(1, nil, dropdown, "cursor");
	end
end

function ChannelListMixin:UpdateDropdownForChannel(dropdown, channelID)
	-- This channelID is currently always a text channel, it may have a voice component, but
	-- that should be tracked on the channel list button.
	if channelID == dropdown.channelID then
		self:ShowDropdown(self:GetButtonForTextChannelID(channelID));
	end
end
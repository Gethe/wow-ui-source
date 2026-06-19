
BANK_TAB_OFFSET = 4;
BANK_TAB_HEIGHT = BANK_TAB_OFFSET + 73;
NUM_RANK_FLAGS = 21;
MAX_GUILDRANKS = 10;

function ResetDiscordSettings()
	GuildControlUI.selectedDiscordServer = -1;
	GuildControlUI.selectedDiscordChannel = -1;
	C_Discord.UpdateDiscordServers();
	C_Discord.UpdateGuildLobby();
end

function GuildControlUI_OnShow(self)
	if GuildControlUI.selectedTab == 4 then
		ResetDiscordSettings()
	end
end

function GuildControlUI_SetupSelected(selected)
	local function IsSelected(tab)
		return GuildControlUI.selectedTab == tab;
	end

	local function SetSelected(tab)
		GuildControlUI.selectedTab = tab;
		GuildControlUI.numSkipUpdates = 0;

		StaticPopup_Hide("CONFIRM_RANK_AUTHENTICATOR_REMOVE");

		GuildControlUIRankSettingsFrame:Hide();
		GuildControlUIRankOrderFrame:Hide();
		GuildControlUIRankBankFrame:Hide();
		GuildControlUIRankDiscordFrame:Hide();
		if tab == 1 then	
			GuildControlUIRankOrderFrame:Show();		
			GuildControlUI.currFrame = GuildControlUI.orderFrame;
			GuildControlUI.rankUpdate = GuildControlUI_RankOrder_Update;
		elseif tab == 2 then		
			GuildControlUI.currFrame = GuildControlUI.rankPermFrame;
			GuildControlUI.rankUpdate = GuildControlUI_RankPermissions_Update;
			GuildControlUIRankSettingsFrame:Show();
			GuildControlUI.rankUpdate(GuildControlUI.currFrame);
		elseif tab == 3 then		
			GuildControlUI.currFrame = GuildControlUI.bankTabFrame;
			GuildControlUI.rankUpdate = GuildControlUI_BankTabPermissions_Update;
			GuildControlUIRankBankFrame:Show();
			GuildControlUI.rankUpdate(GuildControlUI.currFrame);
		elseif tab == 4 then		
			GuildControlUI.currFrame = GuildControlUI.discordFrame;
			GuildControlUI.rankUpdate = GuildControlUI_Discord_Update;
			GuildControlUIRankDiscordFrame:Show();
			GuildControlUI.rankUpdate(GuildControlUI.currFrame);
			ResetDiscordSettings();
		end
	end

	SetSelected(selected);
	
	GuildControlUI.dropdown:SetWidth(159);
	GuildControlUI.dropdown:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_GUILD_PERMISSIONS");
		if(IsGuildLeader()) then
			rootDescription:CreateRadio(GUILDCONTROL_GUILDRANKS, IsSelected, SetSelected, 1);
			rootDescription:CreateRadio(GUILDCONTROL_RANK_PERMISSIONS, IsSelected, SetSelected, 2);
			if C_GuildBank.IsGuildBankEnabled() then
				rootDescription:CreateRadio(GUILDCONTROL_BANK_PERMISSIONS, IsSelected, SetSelected, 3);
			end
		end
		local discordName = "";
		if(GUILDCONTROL_DISCORD_SETTINGS) then -- might be encrypted
			discordName = string.format(GUILDCONTROL_DISCORD_SETTINGS, CreateAtlasMarkup("UI-ChatIcon-Discord"));
		end
		rootDescription:CreateRadio(discordName, IsSelected, SetSelected, 4);
	end);
end

function GuildControlUI_Setup()
	-- Default to the 'Guild Ranks' tab for guild leaders and the Discord tab for officers (as that should be the only one they can see)
	-- Note: may change when we get our rank info for active player if they aren't the guild leader, only Discord Settings should be available
	--       also needs to handle the 'reloadui' case
	if(not IsGuildLeader()) then
		GuildControlUI_SetupSelected(4);
	else
		GuildControlUI_SetupSelected(1);
	end
end

function GuildControlUI_OnLoad(self)
	self:RegisterEvent("GUILD_RANKS_UPDATE");

	GuildControlUI.numSkipUpdates = 0;
	GuildControlUI.selectedDiscordServer = -1;
	GuildControlUI.selectedDiscordChannel = -1;

	GuildControlUI_Setup();

	local buttonText;
	for i=1, NUM_RANK_FLAGS do
		buttonText = _G["GuildControlUIRankSettingsFrameCheckbox"..i.."Text"];
		if ( buttonText ) then
			buttonText:SetText(_G["GUILDCONTROL_OPTION"..i]);
		end
	end
	
	self.currentRank = 2;
	GuildControlSetRank(2);

	if not C_GuildBank.IsGuildBankEnabled() then
		GuildControlUIRankPermissions_HideGuildBankOptions(self);
	end

	self:RegisterEvent("GUILDBANK_UPDATE_TABS");
	self:RegisterEvent("GUILD_RANKS_UPDATE_ACTIVE_PLAYER");
end


function GuildControlUI_OnEvent(self, event)
	if(event == "GUILD_RANKS_UPDATE_ACTIVE_PLAYER") then
		GuildControlUI_Setup();
		return;
	end

	if(C_CVar.GetCVarBool("useClassicGuildUI")) then
		return;
	end
	-- if the user clicks a checkbox while the results of a previous click still hasn't been
	-- received back from the server, that checkbox will flicker unless we skip updates.
	GuildControlUI.numSkipUpdates = GuildControlUI.numSkipUpdates - 1;
	if ( GuildControlUI.numSkipUpdates < 1 ) then
		GuildControlUI.numSkipUpdates = 0;
		GuildControlUI.rankUpdate(GuildControlUI.currFrame);
	end
end


function GuildControlUI_SubmitChanges(self)

end


function GuildControlUI_SetBankTabChange(self)

	SetGuildBankTabPermissions(self:GetParent():GetParent().tabIndex, self:GetID(), self:GetChecked());
end

function GuildControlUI_SetBankTabWithdrawChange(self)
	local withdrawals = self:GetText();
	if ( not tonumber(withdrawals) ) then
		withdrawals = 0;
	end
	SetGuildBankTabItemWithdraw(self:GetParent():GetParent().tabIndex, withdrawals);
end

function GuildControlUI_BankTabPermissions_Update(self)
	local currentRank = self:GetParent().currentRank;
	-- if currentRank doesn't apply, reset to first available
	if ( currentRank < 2 or currentRank > GuildControlGetNumRanks() ) then
		currentRank = 2;
		self:GetParent().currentRank = 2;
	end
	GuildControlSetRank(currentRank);

	local numTabs = GetNumGuildBankTabs();
	local canBuyTab = false;
	if numTabs < MAX_BUY_GUILDBANK_TABS then
		canBuyTab = true;
		numTabs = numTabs + 1;
	end	
	
	local scrollFrame = self.scrollFrame;
	scrollFrame:SetPoint("BOTTOMRIGHT",-28 ,8);
	local buttonWidth = scrollFrame:GetWidth();

	for i = 1, numTabs do
		local button = _G["GuildControlBankTab"..i];
		if ( not button ) then
			button = CreateFrame("Frame", "GuildControlBankTab"..i, scrollFrame:GetScrollChild(), "BankTabPermissionTemplate");
			if ( GuildControlUI_LocalizeBankTab ) then
				GuildControlUI_LocalizeBankTab(button);
			end
			if ( i == 1 ) then
				button:SetPoint("TOPLEFT", 0, 0);
			else
				local prevButton = _G["GuildControlBankTab"..(i - 1)];
				button:SetPoint("TOPLEFT", prevButton, "BOTTOMLEFT", 0, -BANK_TAB_OFFSET);
			end
		end
		button:SetWidth(buttonWidth);
		local index = i;
		if ( index == numTabs and canBuyTab ) then
			button:Show();
			button.buy:Show();
			button.owned:Hide();
			local tabCost = GetGuildBankTabCost();
			if(  (GetMoney() + GetGuildBankMoney()) >= tabCost ) then
				SetMoneyFrameColor(button.buy.money:GetName(), "white");
				button.buy.button:Enable();
			else
				SetMoneyFrameColor(button.buy.money:GetName(), "red");
				button.buy.button:Disable();
			end
			MoneyFrame_Update(button.buy.money:GetName(), tabCost);
		else
			button.tabIndex = index;
			local name, icon = GetGuildBankTabInfo(index);												-- returns info and permissions for player's rank
			local isViewable, canDeposit, _, numWithdrawals = GetGuildBankTabPermissions(index);	-- returns permissions for the selected rank
			button:Show();
			local ownedTab = button.owned;
			ownedTab.tabName:SetText(name);	
			ownedTab.tabIcon:SetTexture(icon);
			ownedTab.viewCB:SetChecked(isViewable);
			ownedTab.depositCB:SetChecked(canDeposit);
			if ( isViewable ) then
				ownedTab.depositCB:Enable();
				ownedTab.depositCB.text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				ownedTab.editBox.mask:Hide();
				-- do not update text if the user is typing
				if ( ownedTab.editBox:HasFocus() ) then
					ownedTab.editBox.startValue = numWithdrawals;
				else
					ownedTab.editBox:SetText(numWithdrawals);
					ownedTab.editBox:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				end
			else
				ownedTab.depositCB:Disable();
				ownedTab.depositCB.text:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
				if ( ownedTab.editBox:HasFocus() ) then
					ownedTab.editBox:ClearFocus();
				end
				ownedTab.editBox.mask:Show();
				ownedTab.editBox:SetText(numWithdrawals);
				ownedTab.editBox:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
			end
			ownedTab:Show();
			button.buy:Hide();
		end
	end
	-- hide unused buttons (only for people who go from gm of one guild to gm of another guild in the same session)
	for i =  numTabs + 1, MAX_GUILDBANK_TABS do
		local button = _G["GuildControlBankTab"..i];
		if ( button ) then
			button:Hide();
		else
			break;
		end
	end
end

function GuildControlUI_SetupDiscord(self)
	C_Discord.Authorize();
	GuildControlUI.rankUpdate(GuildControlUI.currFrame)
end

function GuildControlUI_UnlinkDiscord()
	C_Discord.GuildUnlink();
	GuildControlUI.rankUpdate(GuildControlUI.currFrame)
end

function GuildControlUI_Discord_HideAll(self)

	if DiscordLinkFrame then
		DiscordLinkFrame:Hide();
	end
	if DiscordUnlinkFrame then
		DiscordUnlinkFrame:Hide();
	end

	self.channelDropdown:Hide();
	self.channelButton:Hide();
	self.serverDropdown:Hide();
	self.channelListTitle:Hide();
	self.serverError:Hide();
end


function GuildControlRankDiscord_OnLoad(self)
	self:RegisterEvent("DISCORD_LINK_UPDATE");
	self:RegisterEvent("DISCORD_STATUS_UPDATE");
	self:RegisterEvent("DISCORD_SERVER_LIST_UPDATE");
	self:RegisterEvent("DISCORD_GUILD_LOBBY_UPDATE");

	self:SetScript("OnEvent", 
		function(self, event)
			GuildControlUI.rankUpdate(GuildControlUI.currFrame);
		end
	);

	self.channelButton:SetScript("OnClick", 
		function(self)
			if ( GuildControlUI.selectedDiscordChannel ~= -1) then
				C_Discord.GuildLink(GuildControlUI.selectedDiscordServer, GuildControlUI.selectedDiscordChannel); 
			end
		end
	);
end

function GuildControlDiscord_Loaded_OnLoad(self)
	self:RegisterEvent("DISCORD_GUILD_SETTINGS_UPDATE");
end

function GuildControlDiscord_SetGuildSettingsCheckboxes(self)
	self.SeparateStream.Button:SetChecked(C_Discord.IsGuildSettingSet(Enum.DiscordGuildSettings.SeparateStream));
end

function GuildControlDiscord_Loaded_OnEvent(self, event)
	if(event == "DISCORD_GUILD_SETTINGS_UPDATE") then
		GuildControlDiscord_SetGuildSettingsCheckboxes(self);
	end
end

function GuildControlUI_Discord_Update(self)
	local isUserOAuthed = C_Discord.IsUserOAuthed();

	local isGuildChannelLinked, linkedChannelName, linkedServerName = C_Discord.GetGuildLinkStatus();
	
	GuildControlUI_Discord_HideAll(self);

	self:Show();

	if(isUserOAuthed) then
		if(isGuildChannelLinked) then
			-- show "your all linked" with an unlink button
			local linkFrame = _G["DiscordLinkFrame"];
			if( not linkFrame ) then
				linkFrame = CreateFrame("Frame", "DiscordLinkFrame", self, "DiscordLinkedTemplate"); -- TODO_DISCORD: try defining this frame in the XML with hidden=true and unhiding it here
				linkFrame:SetPoint("TOPLEFT", 0, 0);
			end
			local serverName = string.format(DISCORD_GUILD_LINKED_SERVER, linkedServerName);
			local channelName = string.format(DISCORD_GUILD_LINKED_CHANNEL, linkedChannelName);
			linkFrame.linkedTitle:SetText(DISCORD_GUILD_SERVER_CHANNEL_LINKED);
			linkFrame.linkedServer:SetText(serverName);
			linkFrame.linkedChannel:SetText(channelName);
			GuildControlDiscord_SetGuildSettingsCheckboxes(linkFrame);
			linkFrame.SeparateStream.Button:SetScript("OnClick", 
				function(self)
					C_Discord.SetGuildSetting(Enum.DiscordGuildSettings.SeparateStream, self:GetChecked());
				end
			);
			linkFrame:Show();
		else
			-- show "install" button and list of servers
			self.serverDropdown:Show();

			local function IsServerSelected(index)
				return GuildControlUI.selectedDiscordServer == index;
			end

			local function SetServerSelected(index)
				GuildControlUI.selectedDiscordServer = index;
				C_Discord.GetServerLinkableChannels(index); 
				GuildControlUI_Discord_Update(GuildControlUI.currFrame);
			end

			local numServers = C_Discord.GetNumDiscordServers();

			self.serverDropdown:SetupMenu(function(dropdown, rootDescription)
				for i = 1, numServers do
					rootDescription:CreateRadio(C_Discord.GetServerName(i), IsServerSelected, SetServerSelected, i);
				end
				rootDescription:SetScrollMode(400); -- start scrolling after the scrollbox gets sufficiently large... some people have a lot of servers
			end);


			if (GuildControlUI.selectedDiscordServer ~= -1) then
				self.channelDropdown:Show();
				self.channelButton:Show();
				self.channelListTitle:Show();

				local serverName = C_Discord.GetServerName(GuildControlUI.selectedDiscordServer);
				local name = string.format(DISCORD_VALID_SERVER_CHANNEL_LIST, serverName);
				self.channelListTitle:SetText(name);

				local function IsChannelSelected(index)
					return GuildControlUI.selectedDiscordChannel == index;
				end

				local function SetChannelSelected(index)
					GuildControlUI.selectedDiscordChannel = index;
				end

				self.channelDropdown:SetupMenu(function(dropdown, rootDescription)
					local numChannels = C_Discord.GetNumDiscordChannels(GuildControlUI.selectedDiscordServer);
					for i = 1, numChannels do
					local channelName = C_Discord.GetDiscordChannelName(GuildControlUI.selectedDiscordServer, i);
						rootDescription:CreateRadio(channelName, IsChannelSelected, SetChannelSelected, i);
					end
					rootDescription:SetScrollMode(400);
				end);
			end
		end
	else
		-- present the user with an option to oauth
		local unlinkFrame = _G["DiscordUnlinkFrame"];
		if( not unlinkFrame ) then
			unlinkFrame = CreateFrame("Frame", "DiscordUnlinkFrame", self, "DiscordUnlinkedTemplate");
			unlinkFrame:SetPoint("TOPLEFT", 0, 0);
		end
		unlinkFrame.unlinkedTitle:SetText(DISCORD_GUILD_NEED_TO_OAUTH);
		unlinkFrame:Show();

	end
end

function GuildControlUI_RankPermissions_Update(self)	
	local currentRank = self:GetParent().currentRank;
	-- if currentRank doesn't apply, reset to first available
	if ( currentRank < 2 or currentRank > GuildControlGetNumRanks() ) then
		currentRank = 2;
		self:GetParent().currentRank = 2;
	end
	GuildControlSetRank(currentRank);

	local flags = C_GuildInfo.GuildControlGetRankFlags(currentRank);
	local checkbox;
	local prefix = self:GetName().."Checkbox";
	for i=1, NUM_RANK_FLAGS do
		checkbox = _G[prefix..i]
		if ( checkbox ) then -- skip obsolete (14)
			checkbox:SetChecked(flags[i]);
		end
	end
	
	self.OfficerCheckbox:SetChecked(flags[self.OfficerCheckbox:GetID()]);
	
	-- enable the gold/day editbox if at least one of Guild Bank Repair and Withdraw Gold are unchecked
	if ( flags[15] or flags[16] ) then
		self.goldBox.mask:Hide();
		-- do not update text if the user is typing
		if ( self.goldBox:HasFocus() ) then
			self.goldBox.startValue = GetGuildBankWithdrawGoldLimit();
		else
			self.goldBox:SetText(GetGuildBankWithdrawGoldLimit());
			self.goldBox:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		end
	else
		if ( self.goldBox:HasFocus() ) then
			self.goldBox:ClearFocus();
		end	
		self.goldBox.mask:Show();
		self.goldBox:SetText(GetGuildBankWithdrawGoldLimit());
		self.goldBox:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
	end
	
	-- disable the Authenticate checkbox for the last rank ,or if a rank has members and the option is unchecked
	checkbox = _G[prefix.."18"];
	if ( currentRank == GuildControlGetNumRanks() ) then
		checkbox.text:SetFontObject("GameFontDisableSmall");
		checkbox:Disable();
		checkbox.tooltipFrame.tooltip = AUTHENTICATOR_GUILD_RANK_LAST;
	elseif ( GetNumMembersInRank(currentRank ) > 0 and not checkbox:GetChecked() ) then
		checkbox.text:SetFontObject("GameFontDisableSmall");
		checkbox:Disable();
		checkbox.tooltipFrame.tooltip = AUTHENTICATOR_GUILD_RANK_IN_USE;
	else
		checkbox.text:SetFontObject("GameFontHighlightSmall");
		checkbox:Enable();
		checkbox.tooltipFrame.tooltip = nil;
	end
	
	
end

GUILD_OFFICER_PERMISSION_STRINGS = {
	GUILD_OFFICER_PERMISSION_ACCESS_CHANNELS,
	GUILD_OFFICER_PERMISSION_REMOVE_FROM_VOICE,
	GUILD_OFFICER_PERMISSION_DELETE_MESSAGES,
	GUILD_OFFICER_PERMISSION_DELETE_EVENTS,
	GUILD_OFFICER_PERMISSION_OFFICER_NOTES,
	GUILD_OFFICER_PERMISSION_PUBLIC_NOTES,
	GUILD_OFFICER_PERMISSION_GUILD_INFO,
	GUILD_OFFICER_PERMISSION_MOTD,
	GUILD_OFFICER_PERMISSION_FINDER_LIST,
	GUILD_OFFICER_PERMISSION_INVITE_APPLICANTS,
	GUILD_OFFICER_PERMISSION_SET_DISCORD,
};

local function CreateRankMenu(dropdown, rootDescription)
	rootDescription:SetTag("MENU_GUILD_RANK");

	local function IsSelected(i)
		return GuildControlUI.currentRank == i;
	end

	local function SetSelected(i)
		local activeEditBox = GuildControlUI.activeEditBox;
		if ( activeEditBox ) then
			activeEditBox:ClearFocus();
		end
		StaticPopup_Hide("CONFIRM_RANK_AUTHENTICATOR_REMOVE");
		GuildControlUI.numSkipUpdates = 0;
		GuildControlUI.currentRank = i;
		GuildControlSetRank(GuildControlUI.currentRank);
		GuildControlUI.rankUpdate(GuildControlUI.currFrame);
	end

	local numRanks = GuildControlGetNumRanks();
	--ignore officer
	for i=2, numRanks do
		rootDescription:CreateRadio(GuildControlGetRankName(i), IsSelected, SetSelected, i);
	end
end

function GuildControlRankSettings_OnLoad(self)
	self.OfficerPermissions:SetText(table.concat(GUILD_OFFICER_PERMISSION_STRINGS, "|n"));
	self.OfficerCheckbox.text:SetFontObject("GameFontHighlightSmall");
	self.OfficerCheckbox.text:SetText(GUILD_CONTROL_RANK_PERMISSION_HAS_OFFICER_PRIVLEGES);
	self.OfficerCheckbox:Enable();

	self.dropdown:SetWidth(180);
	self.dropdown:SetupMenu(CreateRankMenu);
end

function GuildControlRankBank_OnLoad(self)
	self.dropdown:SetWidth(180);
	self.dropdown:SetupMenu(CreateRankMenu);
end


function GuildControlUI_RankOrder_Update(self)	
	local numRanks = GuildControlGetNumRanks();
	if numRanks == MAX_GUILDRANKS then
		self.newButton:Hide();
		self.dupButton:Hide();
	else
		self.newButton:Show();
		--self.dupButton:Show();
	end	
	
	local prefix = self:GetName().."Rank";
	for i=1, numRanks do
		local rankFrame = _G[prefix..i];
		if not rankFrame then
			rankFrame =  CreateFrame("FRAME", prefix..i, self, "RankChangeTemplate");
			rankFrame:SetPoint("TOP", _G[prefix..(i-1)], "BOTTOM", 0, -7);
			rankFrame:SetID(i);
		end
		rankFrame:Show();
		rankFrame.rankLabel:SetText(RANK.." "..i..":");
		rankFrame.nameBox:SetText(GuildControlGetRankName(i));

		if numRanks == 2 then
			rankFrame.deleteButton:Disable();
			rankFrame.deleteButton.tooltip = nil;
			rankFrame.upButton:Disable();
			rankFrame.downButton:Disable();
		elseif i > 1 then
			if ( GetNumMembersInRank(i) == 0 ) then
				-- can't delete last rank if next-to-last has authenticator
				rankFrame.deleteButton:Enable();
				rankFrame.deleteButton.tooltip = nil;
				if ( i == numRanks ) then
					local requiresAuthenticator = C_GuildInfo.GuildControlGetRankFlags(i - 1)[18];
					if ( requiresAuthenticator ) then
						rankFrame.deleteButton:Disable();
						rankFrame.deleteButton.tooltip = AUTHENTICATOR_GUILD_RANK_CHANGE;
					end
				end
			else
				rankFrame.deleteButton:Disable();
				rankFrame.deleteButton.tooltip = ERR_GUILD_RANK_IN_USE;
			end
			local canShiftUp, canShiftDown = GuildControlGetAllowedShifts(i);
			if ( canShiftUp ) then
				rankFrame.upButton:Enable();
				rankFrame.upButton.tooltip = nil;
			else
				-- if it's the last rank then it can't shift up if it would move an authenticated rank to the bottom
				if ( i == numRanks ) then
					rankFrame.upButton:Disable();
					rankFrame.upButton.tooltip = AUTHENTICATOR_GUILD_RANK_CHANGE;
				else
					rankFrame.upButton:Disable();
					rankFrame.upButton.tooltip = nil;
				end
			end
			if ( canShiftDown ) then
				rankFrame.downButton:Enable();
				rankFrame.downButton.tooltip = nil;
			else
				-- if it's the next to last rank then it can't shift down if it would move an authenticated rank to the bottom
				if ( i == numRanks - 1 ) then
					rankFrame.downButton:Disable();
					rankFrame.downButton.tooltip = AUTHENTICATOR_GUILD_RANK_CHANGE;
				else
					rankFrame.downButton:Disable();
					rankFrame.downButton.tooltip = nil;
				end
			end
		end
	end
	--hide removed ransk	
	for i=numRanks+1, MAX_GUILDRANKS do
		local rankFrame = _G[prefix..i];
		if rankFrame then
			rankFrame:Hide()
		end
	end
end


function GuildControlUI_BankFrame_OnLoad(self)
	self:GetParent().scrollFrame = self.scrollFrame;
	self.scrollFrame.update = function() GuildControlUI.rankUpdate(GuildControlUI.currFrame) end;
	self.scrollFrame.stepSize = 8;
end

function GuildControlUI_DiscordFrame_OnLoad(self)
	self:GetParent().scrollFrame = self.scrollFrame;
	self.scrollFrame.update = function() GuildControlUI.rankUpdate(GuildControlUI.currFrame) end;
	self.scrollFrame.stepSize = 8;
end


function GuildControlUI_CheckClicked(self)
	if ( self:GetChecked() ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	end
	GuildControlUI.numSkipUpdates = GuildControlUI.numSkipUpdates + 1;
	GuildControlSetRankFlag(self:GetID(), self:GetChecked());
end



function GuildControlUI_RemoveRankButton_OnClick(self)
	local activeEditBox = GuildControlUI.activeEditBox;
	if ( activeEditBox ) then
		activeEditBox:ClearFocus();
	end
	local index = self:GetParent():GetID();
	GuildControlDelRank(index);
end


function GuildControlUI_AddRankButton_OnClick()
	local activeEditBox = GuildControlUI.activeEditBox;
	if ( activeEditBox ) then
		activeEditBox:ClearFocus();
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPEN);
	GuildControlAddRank(GUILD_NEW_RANK);
end


function GuildControlUI_ShiftRankDownButton_OnClick(self)
	local activeEditBox = GuildControlUI.activeEditBox;
	if ( activeEditBox ) then
		activeEditBox:ClearFocus();
	end
	self:SetButtonState("NORMAL");
	GuildControlUI_DisableRankButtons();
	local index = self:GetParent():GetID();
	GuildControlShiftRankDown(index);
end


function GuildControlUI_ShiftRankUpButton_OnClick(self)
	local activeEditBox = GuildControlUI.activeEditBox;
	if ( activeEditBox ) then
		activeEditBox:ClearFocus();
	end
	self:SetButtonState("NORMAL");
	GuildControlUI_DisableRankButtons();
	local index = self:GetParent():GetID();
	GuildControlShiftRankUp(index);
end

function GuildControlUI_DisableRankButtons()
	local numRanks = GuildControlGetNumRanks();
	for i = 1, numRanks do
		local rankFrame = _G["GuildControlUIRankOrderFrameRank"..i];
		rankFrame.downButton:Disable();
		rankFrame.upButton:Disable();
	end
end

function GuildControlUIRankDropdown_OnClick(self)
	local activeEditBox = GuildControlUI.activeEditBox;
	if ( activeEditBox ) then
		activeEditBox:ClearFocus();
	end
	StaticPopup_Hide("CONFIRM_RANK_AUTHENTICATOR_REMOVE");
	GuildControlUI.numSkipUpdates = 0;
	GuildControlUI.currentRank = self:GetID()+1; --igonre officer
	GuildControlSetRank(GuildControlUI.currentRank);
	GuildControlUI.rankUpdate(GuildControlUI.currFrame);
end

function GuildControlUIRankPermissions_HideGuildBankOptions(self)
	GuildControlUIRankSettingsFrameBankBg:Hide();
	GuildControlUIRankSettingsFrameBankLabel:Hide();
	GuildControlUIRankSettingsFrameCheckbox15:Hide();
	GuildControlUIRankSettingsFrameCheckbox16:Hide();
	GuildControlUIRankSettingsFrameCheckbox19:Hide();
	GuildControlUIRankSettingsFrameGoldBox:Hide();
end

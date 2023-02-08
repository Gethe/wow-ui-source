local function CreateTwitterPanelInitializer(setting, state)
	local options = nil;
	local data = Settings.CreateSettingInitializerData(setting, options, OPTION_TOOLTIP_SOCIAL_ENABLE_TWITTER_FUNCTIONALITY);
	
	local atlasMarkup = CreateAtlasMarkup("WoWShare-TwitterLogo", 14, 11, 0, 0);
	data.name = string.format(SOCIAL_ENABLE_TWITTER_FUNCTIONALITY, atlasMarkup);
	data.state = state;

	return Settings.CreateSettingInitializer("TwitterPanelTemplate", data);
end

TwitterPanelMixin = CreateFromMixins(SettingsCheckBoxControlMixin);

function TwitterPanelMixin:OnLoad()
	SettingsCheckBoxControlMixin.OnLoad(self);
	self.Button:SetPoint("LEFT", self.LoginStatus, "RIGHT", 16, 0);
	self.LoginStatus:SetPoint("LEFT", self.CheckBox, "RIGHT", 16, 0);
end

function TwitterPanelMixin:UpdateControls()
	local state = self.data.state;
	local linked = state.linked;
	local twitterEnabled = GetCVarBool("enableTwitter");

	if state.linked then
		local name = SOCIAL_TWITTER_STATUS_CONNECTED:format(state.screenName);
		local color = twitterEnabled and GREEN_FONT_COLOR or GRAY_FONT_COLOR;
		self.LoginStatus:SetText(color:WrapTextInColorCode(name));
		self.Button:SetText(SOCIAL_TWITTER_DISCONNECT);
	else
		local color = twitterEnabled and RED_FONT_COLOR or GRAY_FONT_COLOR;
		self.LoginStatus:SetText(color:WrapTextInColorCode(SOCIAL_TWITTER_STATUS_NOT_CONNECTED));
		self.Button:SetText(SOCIAL_TWITTER_SIGN_IN);
	end

	self.Button:SetWidth(self.Button:GetTextWidth() + 30);
end

function TwitterPanelMixin:Init(initializer)
	SettingsCheckBoxControlMixin.Init(self, initializer);
	
	local state = self.data.state;
	self.Button:SetScript("OnClick", function(button, buttonName, down)
		if state.linked then
			C_Social.TwitterDisconnect();
		else
			SocialBrowserFrame:Show();
			C_Social.TwitterConnect();
		end
	end);

	state:RegisterCallback(state.Event.StatusUpdate, GenerateClosure(self.UpdateControls, self), self);
	state:RegisterCallback(state.Event.LinkResult, GenerateClosure(self.UpdateControls, self), self);

	self:UpdateControls();
end

function TwitterPanelMixin:Release(initializer)
	self.Button:SetScript("OnClick", nil);

	local state = self.data.state;
	state:UnregisterCallback(state.Event.StatusUpdate, self);
	state:UnregisterCallback(state.Event.LinkResult, self);

	SettingsCheckBoxControlMixin.Release(self);
end

function TwitterPanelMixin:OnCheckBoxValueChanged(twitterEnabled)
	SettingsCheckBoxControlMixin.OnCheckBoxValueChanged(self, twitterEnabled);

	self:UpdateControls();
end

local function Register()
	local category, layout = Settings.RegisterVerticalLayoutCategory(SOCIAL_LABEL);

	-- Order set in GameplaySettingsGroup.lua
	category:SetOrder(CUSTOM_GAMEPLAY_SETTINGS_ORDER[SOCIAL_LABEL]);

	-- Mature Language
	do
		local setting, initializer = Settings.SetupCVarCheckBox(category, "profanityFilter", PROFANITY_FILTER, OPTION_TOOLTIP_PROFANITY_FILTER);
		initializer:AddModifyPredicate(function()
			return GetCVar("textLocale") ~= "zhCN";
		end);
	end

	-- Guild Member Alert
	Settings.SetupCVarCheckBox(category, "guildMemberNotify", GUILDMEMBER_ALERT, OPTION_TOOLTIP_GUILDMEMBER_ALERT);

	-- Block Trades
	Settings.SetupCVarCheckBox(category, "blockTrades", BLOCK_TRADES, OPTION_TOOLTIP_BLOCK_TRADES);

	-- Block Guild Invites
	do
		local defaultValue = false;
		local setting = Settings.RegisterProxySetting(category, "PROXY_BLOCK_GUILD_INVITES", Settings.DefaultVarLocation,
			Settings.VarType.Boolean, BLOCK_GUILD_INVITES, defaultValue, GetAutoDeclineGuildInvites, SetAutoDeclineGuildInvites);
		Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_BLOCK_GUILD_INVITES);
	end
	
	-- Display Only Character Achievements
	do
		local defaultValue = false;
		local setting = Settings.RegisterProxySetting(category, "PROXY_SHOW_ACCOUNT_ACHIEVEMENTS", Settings.DefaultVarLocation,
			Settings.VarType.Boolean, SHOW_ACCOUNT_ACHIEVEMENTS, defaultValue, AreAccountAchievementsHidden, ShowAccountAchievements);
		Settings.CreateCheckBox(category, setting, OPTION_TOOLTIP_SHOW_ACCOUNT_ACHIEVEMENTS);
	end

	-- Block Channel Invites
	Settings.SetupCVarCheckBox(category, "blockChannelInvites", BLOCK_CHAT_CHANNEL_INVITE, OPTION_TOOLTIP_BLOCK_CHAT_CHANNEL_INVITE);

	-- Online Friends
	Settings.SetupCVarCheckBox(category, "showToastOnline", SHOW_TOAST_ONLINE_TEXT, OPTION_TOOLTIP_SHOW_TOAST_ONLINE);

	--Offline Friends
	Settings.SetupCVarCheckBox(category, "showToastOffline", SHOW_TOAST_OFFLINE_TEXT, OPTION_TOOLTIP_SHOW_TOAST_OFFLINE);

	-- Broadcast Updates
	Settings.SetupCVarCheckBox(category, "showToastBroadcast", SHOW_TOAST_BROADCAST_TEXT, OPTION_TOOLTIP_SHOW_TOAST_BROADCAST);

	-- Real ID and BattleTag Friend Requests
	Settings.SetupCVarCheckBox(category, "showToastFriendRequest", SHOW_TOAST_FRIEND_REQUEST_TEXT, OPTION_TOOLTIP_SHOW_TOAST_FRIEND_REQUEST);

	-- Show Toast Window
	Settings.SetupCVarCheckBox(category, "showToastWindow", SHOW_TOAST_WINDOW_TEXT, OPTION_TOOLTIP_SHOW_TOAST_WINDOW);

	-- Auto Accept Quick Join Requests
	Settings.SetupCVarCheckBox(category, "autoAcceptQuickJoinRequests", AUTO_ACCEPT_QUICK_JOIN_TEXT, OPTION_TOOLTIP_AUTO_ACCEPT_QUICK_JOIN);

	--Chat Style
	do
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add("im", IM_STYLE, OPTION_CHAT_STYLE_IM);
			container:Add("classic", CLASSIC_STYLE, OPTION_CHAT_STYLE_CLASSIC);
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, "chatStyle", Settings.VarType.String, GetOptions, CHAT_STYLE, OPTION_TOOLTIP_CHAT_STYLE);
	end

	-- New Whispers
	do
		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add("popout", CONVERSATION_MODE_POPOUT, OPTION_WHISPER_MODE_POPOUT);
			container:Add("inline", CONVERSATION_MODE_INLINE, OPTION_WHISPER_MODE_INLINE);
			container:Add("popout_and_inline", CONVERSATION_MODE_POPOUT_AND_INLINE, OPTION_WHISPER_MODE_POPOUT_AND_INLINE);
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, "whisperMode", Settings.VarType.String, GetOptions, WHISPER_MODE, OPTION_TOOLTIP_WHISPER_MODE);
	end

	-- Chat Timestamps
	do
		local exampleTime = 
		{
			year = 2010,
			month = 12,
			day = 15,
			hour = 15,
			min = 27,
			sec = 32,
		};

		local function CreateTimeStampOption(container, format)
			local label = BetterDate(format, time(exampleTime));
			container:Add(format, label);
		end

		local function GetOptions()
			local container = Settings.CreateControlTextContainer();
			container:Add("none", TIMESTAMP_FORMAT_NONE);
			CreateTimeStampOption(container, TIMESTAMP_FORMAT_HHMM);
			CreateTimeStampOption(container, TIMESTAMP_FORMAT_HHMMSS);
			CreateTimeStampOption(container, TIMESTAMP_FORMAT_HHMM_AMPM);
			CreateTimeStampOption(container, TIMESTAMP_FORMAT_HHMMSS_AMPM);
			CreateTimeStampOption(container, TIMESTAMP_FORMAT_HHMM_24HR);
			CreateTimeStampOption(container, TIMESTAMP_FORMAT_HHMMSS_24HR);
			return container:GetData();
		end

		Settings.SetupCVarDropDown(category, "showTimestamps", Settings.VarType.String, GetOptions, TIMESTAMPS_LABEL, OPTION_TOOLTIP_TIMESTAMPS);
	end

	-- Reset Chat Positions
	do
		local function OnButtonClick()
			FCF_RedockAllWindows();
		end

		local initializer = CreateSettingsButtonInitializer(RESET_CHAT_POSITION, RESET, OnButtonClick, OPTION_TOOLTIP_RESET_CHAT_POSITION);
		layout:AddInitializer(initializer);
	end

	Settings.RegisterCategory(category, SETTING_GROUP_GAMEPLAY);
end

--[[
	Some setting values cannot be obtained until after PEW. (See PROXY_SHOW_ACCOUNT_ACHIEVEMENTS)
]]--
SettingsRegistrar:AddRegistrant(Register);

CVarCallbackRegistry:SetCVarCachable("streamerMode");
CVarCallbackRegistry:SetCVarCachable("streamerModeDockedChat");
CVarCallbackRegistry:SetCVarCachable("streamerNameMasking");
CVarCallbackRegistry:SetCVarCachable("realIDNameMasking");
CVarCallbackRegistry:SetCVarCachable("battleTagNameMasking");
CVarCallbackRegistry:SetCVarCachable("playerBattleTagNameMasking");
CVarCallbackRegistry:SetCVarCachable("groupMessageMasking");
CVarCallbackRegistry:SetCVarCachable("whisperMessageMasking");

function RegisterStreamerMode(category, layout)
	layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(SETTINGS_HEADER_STREAMING));

	local function StreamerOptionsModifiable()
		return GetCVarBool("streamerMode");
	end

	local function AddStreamerOptionsSearchTags(initializer)
		initializer:AddSearchTags(SETTINGS_HEADER_STREAMING);
	end

	local function InitStreamerOption(initializer)
		initializer:AddModifyPredicate(StreamerOptionsModifiable);
		AddStreamerOptionsSearchTags(initializer);
		initializer:AddEvaluateStateCVar("streamerMode");
	end

	local _, enabledInitializer = Settings.SetupCVarCheckbox(category, "streamerMode", SETTING_STREAMER_MODE, OPTION_TOOLTIP_STREAMER_MODE);

	local _, dockedChatInitializer = Settings.SetupCVarCheckbox(category, "streamerModeDockedChat", DOCKED_CHAT_UNCHANGED, OPTION_TOOLTIP_DOCKED_CHAT_UNCHANGED);
	InitStreamerOption(dockedChatInitializer);
	dockedChatInitializer:SetParentInitializer(enabledInitializer, StreamerOptionsModifiable);


	-- Name Anonymization / Masking
	local _, nameMaskingInitializer = Settings.SetupCVarCheckbox(category, "streamerNameMasking", SETTING_NAME_MASKING, OPTION_TOOLTIP_NAME_MASKING);
	InitStreamerOption(nameMaskingInitializer);

	local function NameMaskingOptionsModifiable()
		return GetCVarBool("streamerNameMasking");
	end

	local _, realIDInitializer = Settings.SetupCVarCheckbox(category, "realIDNameMasking", SETTING_REAL_ID_NAMES, OPTION_TOOLTIP_REAL_ID_NAMES);
	InitStreamerOption(realIDInitializer);
	realIDInitializer:SetParentInitializer(nameMaskingInitializer, NameMaskingOptionsModifiable);

	local _, battleTagInitializer = Settings.SetupCVarCheckbox(category, "battleTagNameMasking", SETTINGS_BATTLETAGS, OPTION_TOOLTIP_BATTLETAGS);
	InitStreamerOption(battleTagInitializer);
	battleTagInitializer:SetParentInitializer(nameMaskingInitializer, NameMaskingOptionsModifiable);

	local _, groupMsgInitializer = Settings.SetupCVarCheckbox(category, "groupMessageMasking", SETTING_GROUP_MESSAGES, OPTION_TOOLTIP_GROUP_MESSAGES);
	InitStreamerOption(groupMsgInitializer);
	groupMsgInitializer:SetParentInitializer(nameMaskingInitializer, NameMaskingOptionsModifiable);

	local _, whisperInitializer = Settings.SetupCVarCheckbox(category, "whisperMessageMasking", SETTING_WHISPERS, OPTION_TOOLTIP_WHISPERS);
	InitStreamerOption(whisperInitializer);
	whisperInitializer:SetParentInitializer(nameMaskingInitializer, NameMaskingOptionsModifiable);
end

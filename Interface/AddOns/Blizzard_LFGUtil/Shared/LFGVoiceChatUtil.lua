LFGVoiceChatUtil = {};

local VOICE_MODE_LABELS = {
	[Enum.LFGEntryVoiceMode.None] = VOICE_CHAT_MODE_NONE,
	[Enum.LFGEntryVoiceMode.Legacy] = VOICE_CHAT_MODE_LEGACY,
	[Enum.LFGEntryVoiceMode.Discord] = VOICE_CHAT_MODE_DISCORD,
	[Enum.LFGEntryVoiceMode.Custom] = VOICE_CHAT_MODE_CUSTOM,
};

local VOICE_MODE_TOOLTIPS = {
	[Enum.LFGEntryVoiceMode.Legacy] = OPTION_TOOLTIP_VOICE_CHAT_SERVICE_LEGACY,
	[Enum.LFGEntryVoiceMode.Discord] = OPTION_TOOLTIP_VOICE_CHAT_SERVICE_DISCORD,
};

local VOICE_MODE_MENU_ORDER = {
	Enum.LFGEntryVoiceMode.None,
	Enum.LFGEntryVoiceMode.Discord,
	Enum.LFGEntryVoiceMode.Legacy,
	Enum.LFGEntryVoiceMode.Custom,
};

function LFGVoiceChatUtil.GetVoiceModeLabel(voiceMode)
	return VOICE_MODE_LABELS[voiceMode];
end

function LFGVoiceChatUtil.GetDefaultVoiceMode()
	if not C_VoiceChat.GetActiveChannelID() then
		return Enum.LFGEntryVoiceMode.None;
	end

	if C_VoiceChat.GetActiveVoiceProviderID() == Enum.VoiceProviderID.Discord then
		return Enum.LFGEntryVoiceMode.Discord;
	end

	return Enum.LFGEntryVoiceMode.Legacy;
end

function LFGVoiceChatUtil.SetupVoiceModeDropdown(dropdown, isSelected, setSelected, includeNone)
	if includeNone then
		dropdown:SetDefaultText(VOICE_MODE_LABELS[Enum.LFGEntryVoiceMode.None]);
	end

	dropdown:SetupMenu(function(_dropdown, rootDescription)
		rootDescription:SetTag("MENU_LFG_LISTING_VOICE_CHAT");

		local isDiscordVoiceEnabled = C_Discord.IsVoiceEnabled();
		for _, voiceMode in ipairs(VOICE_MODE_MENU_ORDER) do
			local isHiddenDiscord = voiceMode == Enum.LFGEntryVoiceMode.Discord and not isDiscordVoiceEnabled;
			local isHiddenNone = voiceMode == Enum.LFGEntryVoiceMode.None and not includeNone;
			if not isHiddenDiscord and not isHiddenNone then
				local radio = rootDescription:CreateRadio(VOICE_MODE_LABELS[voiceMode], isSelected, setSelected, voiceMode);
				local tooltipText = VOICE_MODE_TOOLTIPS[voiceMode];
				if tooltipText then
					-- The option tooltip strings are "<title>\n\n<body>".
					local title, body = tooltipText:match("^(.-)\n\n(.*)$");
					radio:SetTooltip(function(tooltip, _elementDescription)
						GameTooltip_SetTitle(tooltip, title or tooltipText, HIGHLIGHT_FONT_COLOR, true);
						if body then
							GameTooltip_AddNormalLine(tooltip, body, true);
						end
					end);
				end
			end
		end
	end);
end

-- Switches the group leader's voice provider preference to match the listing.
function LFGVoiceChatUtil.UpdateLeaderVoiceProvider(voiceMode)
	if IsInGroup() and not UnitIsGroupLeader("player") then
		return;
	end

	local voiceProvider;
	if voiceMode == Enum.LFGEntryVoiceMode.Discord then
		voiceProvider = Enum.VoiceProviderID.Discord;
	elseif voiceMode == Enum.LFGEntryVoiceMode.Legacy then
		voiceProvider = Enum.VoiceProviderID.Legacy;
	end

	if voiceProvider and tonumber(GetCVar("voiceProvider")) ~= voiceProvider then
		SetCVar("voiceProvider", voiceProvider);
	end
end

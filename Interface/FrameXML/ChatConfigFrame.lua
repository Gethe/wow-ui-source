GRAY_CHECKED = 1;
UNCHECKED_ENABLED = 2;
UNCHECKED_DISABLED = 3;
CHATCONFIG_SELECTED_FILTER = nil;
CHATCONFIG_SELECTED_FILTER_OLD_SETTINGS = nil;
MAX_COMBATLOG_FILTERS = 20;
CHATCONFIG_CHANNELS_MAXWIDTH = 145;

local function ShouldDisplayDisabled()
	return not C_SocialRestrictions.IsMuted() and C_SocialRestrictions.IsChatDisabled();
end

local function SetChatButtonGlowEnabled(enabled)
	GlowEmitterFactory:SetShown(ChatConfigFrame.ToggleChatButton, enabled, GlowEmitterMixin.Anims.FadeAnim);
end

local function EnableChatButtonGlow()
	SetChatButtonGlowEnabled(true);
end

local function DisableChatButtonGlow()
	SetChatButtonGlowEnabled(false);
end

--Chat options
--NEW_CHAT_TYPE - Add a new chat type to one of the below sections so that people can change it in the Chat Config.
CHAT_CONFIG_CHAT_LEFT = {
	[1] = {
		type = "SAY",
		checked = function () return IsListeningForMessageType("SAY"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "SAY"); end;
		disabled = ShouldDisplayDisabled;
		onEnterCallback = EnableChatButtonGlow;
		onLeaveCallback = DisableChatButtonGlow;
	},
	[2] = {
		type = "EMOTE",
		checked = function () return IsListeningForMessageType("EMOTE"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "EMOTE"); end;
		disabled = ShouldDisplayDisabled;
		onEnterCallback = EnableChatButtonGlow;
		onLeaveCallback = DisableChatButtonGlow;
	},
	[3] = {
		type = "YELL",
		checked = function () return IsListeningForMessageType("YELL"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "YELL"); end;
		disabled = ShouldDisplayDisabled;
		onEnterCallback = EnableChatButtonGlow;
		onLeaveCallback = DisableChatButtonGlow;
	},
	[4] = {
		text = GUILD_CHAT,
		type = "GUILD",
		checked = function () return IsListeningForMessageType("GUILD"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "GUILD"); end;
		disabled = ShouldDisplayDisabled;
		onEnterCallback = EnableChatButtonGlow;
		onLeaveCallback = DisableChatButtonGlow;
	},
	[5] = {
		text = OFFICER_CHAT,
		type = "OFFICER",
		checked = function () return IsListeningForMessageType("OFFICER"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "OFFICER"); end;
		disabled = ShouldDisplayDisabled;
		onEnterCallback = EnableChatButtonGlow;
		onLeaveCallback = DisableChatButtonGlow;
	},
	[6] = {
		type = "GUILD_ACHIEVEMENT",
		checked = function () return IsListeningForMessageType("GUILD_ACHIEVEMENT"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "GUILD_ACHIEVEMENT"); end;
	},
	[7] = {
		type = "ACHIEVEMENT",
		checked = function () return IsListeningForMessageType("ACHIEVEMENT"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "ACHIEVEMENT"); end;
	},
	[8] = {
		type = "WHISPER",
		checked = function () return IsListeningForMessageType("WHISPER"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "WHISPER"); end;
		disabled = ShouldDisplayDisabled;
		onEnterCallback = EnableChatButtonGlow;
		onLeaveCallback = DisableChatButtonGlow;
	},
	[9] = {
		type = "BN_WHISPER",
		noClassColor = 1,
		checked = function () return IsListeningForMessageType("BN_WHISPER"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "BN_WHISPER"); end;
		disabled = ShouldDisplayDisabled;
		onEnterCallback = EnableChatButtonGlow;
		onLeaveCallback = DisableChatButtonGlow;
	},
	[10] = {
		type = "PARTY",
		checked = function () return IsListeningForMessageType("PARTY"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "PARTY"); end;
		disabled = ShouldDisplayDisabled;
		onEnterCallback = EnableChatButtonGlow;
		onLeaveCallback = DisableChatButtonGlow;
	},
	[11] = {
		type = "PARTY_LEADER",
		checked = function () return IsListeningForMessageType("PARTY_LEADER"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "PARTY_LEADER"); end;
		disabled = ShouldDisplayDisabled;
		onEnterCallback = EnableChatButtonGlow;
		onLeaveCallback = DisableChatButtonGlow;
	},
	[12] = {
		type = "RAID",
		checked = function () return IsListeningForMessageType("RAID"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "RAID"); end;
		disabled = ShouldDisplayDisabled;
		onEnterCallback = EnableChatButtonGlow;
		onLeaveCallback = DisableChatButtonGlow;
	},
	[13] = {
		type = "RAID_LEADER",
		checked = function () return IsListeningForMessageType("RAID_LEADER"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "RAID_LEADER"); end;
		disabled = ShouldDisplayDisabled;
		onEnterCallback = EnableChatButtonGlow;
		onLeaveCallback = DisableChatButtonGlow;
	},
	[14] = {
		type = "RAID_WARNING",
		checked = function () return IsListeningForMessageType("RAID_WARNING"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "RAID_WARNING"); end;
		disabled = ShouldDisplayDisabled;
		onEnterCallback = EnableChatButtonGlow;
		onLeaveCallback = DisableChatButtonGlow;
	},
	[15] = {
		type = "INSTANCE_CHAT",
		checked = function () return IsListeningForMessageType("INSTANCE_CHAT"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "INSTANCE_CHAT"); end;
		disabled = ShouldDisplayDisabled;
		onEnterCallback = EnableChatButtonGlow;
		onLeaveCallback = DisableChatButtonGlow;
	},
	[16] = {
		type = "INSTANCE_CHAT_LEADER",
		checked = function () return IsListeningForMessageType("INSTANCE_CHAT_LEADER"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "INSTANCE_CHAT_LEADER"); end;
		disabled = ShouldDisplayDisabled;
		onEnterCallback = EnableChatButtonGlow;
		onLeaveCallback = DisableChatButtonGlow;
	},
};

do
	if C_VoiceChat.IsTranscriptionAllowed() then
		local transcriptionConfig =
		{
			text = VOICE_CHAT_TRANSCRIPTION,
			type = "VOICE_TEXT",
			checked = function () return IsListeningForMessageType("VOICE_TEXT"); end;
			func = function (self, checked) 
				ToggleChatMessageGroup(checked, "VOICE_TEXT");
				local chatFrame = FCF_GetCurrentChatFrame();
				if ( checked ) then
					chatFrame:RegisterEvent("VOICE_CHAT_CHANNEL_TRANSCRIBING_CHANGED");
					ChatFrame_DisplaySystemMessage(chatFrame, SPEECH_TO_TEXT_HEADER);
				else
					chatFrame:UnregisterEvent("VOICE_CHAT_CHANNEL_TRANSCRIBING_CHANGED");
				end
			end;
			disabled = ShouldDisplayDisabled;
			onEnterCallback = EnableChatButtonGlow;
			onLeaveCallback = DisableChatButtonGlow;
		};
		table.insert(CHAT_CONFIG_CHAT_LEFT, transcriptionConfig);
	end
end

CHAT_CONFIG_CHAT_CREATURE_LEFT = {
	[1] = {
		text = SAY;
		type = "MONSTER_SAY",
		checked = function () return IsListeningForMessageType("MONSTER_SAY"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "MONSTER_SAY"); end;
	},
	[2] = {
		text = EMOTE;
		type = "MONSTER_EMOTE",
		checked = function () return IsListeningForMessageType("MONSTER_EMOTE"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "MONSTER_EMOTE"); end;
	},
	[3] = {
		text = YELL;
		type = "MONSTER_YELL",
		checked = function () return IsListeningForMessageType("MONSTER_YELL"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "MONSTER_YELL"); end;
	},
	[4] = {
		text = WHISPER;
		type = "MONSTER_WHISPER",
		checked = function () return IsListeningForMessageType("MONSTER_WHISPER"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "MONSTER_WHISPER"); end;
	},
	[5] = {
		type = "MONSTER_BOSS_EMOTE",
		checked = function () return IsListeningForMessageType("MONSTER_BOSS_EMOTE"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "MONSTER_BOSS_EMOTE"); end;
	},
	[6] = {
		type = "MONSTER_BOSS_WHISPER",
		checked = function () return IsListeningForMessageType("MONSTER_BOSS_WHISPER"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "MONSTER_BOSS_WHISPER"); end;
	}
};

CHAT_CONFIG_OTHER_COMBAT = {
	[1] = {
		type = "COMBAT_XP_GAIN",
		checked = function () return IsListeningForMessageType("COMBAT_XP_GAIN"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "COMBAT_XP_GAIN"); end;
	},
	[2] = {
 		type = "COMBAT_HONOR_GAIN",
 		checked = function () return IsListeningForMessageType("COMBAT_HONOR_GAIN"); end;
 		func = function (self, checked) ToggleChatMessageGroup(checked, "COMBAT_HONOR_GAIN"); end;
 	},
	[3] = {
 		type = "COMBAT_FACTION_CHANGE",
 		checked = function () return IsListeningForMessageType("COMBAT_FACTION_CHANGE"); end;
 		func = function (self, checked) ToggleChatMessageGroup(checked, "COMBAT_FACTION_CHANGE"); end;
 	},
	[4] = {
 		text = SKILLUPS,
 		type = "SKILL",
 		checked = function () return IsListeningForMessageType("SKILL"); end;
 		func = function (self, checked) ToggleChatMessageGroup(checked, "SKILL"); end;
 	},
	[5] = {
 		text = ITEM_LOOT,
 		type = "LOOT",
 		checked = function () return IsListeningForMessageType("LOOT"); end;
 		func = function (self, checked) ToggleChatMessageGroup(checked, "LOOT"); end;
 	},
	[6] = {
 		text = CURRENCY,
 		type = "CURRENCY",
 		checked = function () return IsListeningForMessageType("CURRENCY"); end;
 		func = function (self, checked) ToggleChatMessageGroup(checked, "CURRENCY"); end;
 	},
	[7] = {
 		text = MONEY_LOOT,
 		type = "MONEY",
 		checked = function () return IsListeningForMessageType("MONEY"); end;
 		func = function (self, checked) ToggleChatMessageGroup(checked, "MONEY"); end;
 	},
	[8] = {
 		type = "TRADESKILLS",
 		checked = function () return IsListeningForMessageType("TRADESKILLS"); end;
 		func = function (self, checked) ToggleChatMessageGroup(checked, "TRADESKILLS"); end;
 	},
	[9] = {
 		type = "OPENING",
 		checked = function () return IsListeningForMessageType("OPENING"); end;
 		func = function (self, checked) ToggleChatMessageGroup(checked, "OPENING"); end;
 	},
	[10] = {
 		type = "PET_INFO",
 		checked = function () return IsListeningForMessageType("PET_INFO"); end;
 		func = function (self, checked) ToggleChatMessageGroup(checked, "PET_INFO"); end;
 	},
	[11] = {
 		type = "COMBAT_MISC_INFO",
		checked = function () return IsListeningForMessageType("COMBAT_MISC_INFO"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "COMBAT_MISC_INFO"); end;
	},
};

CHAT_CONFIG_OTHER_PVP = {
	[1] = {
		type = "BG_SYSTEM_HORDE",
		checked = function () return IsListeningForMessageType("BG_HORDE"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "BG_HORDE"); end;
	},
	[2] = {
		type = "BG_SYSTEM_ALLIANCE",
		checked = function () return IsListeningForMessageType("BG_ALLIANCE"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "BG_ALLIANCE"); end;
	},
	[3] = {
		type = "BG_SYSTEM_NEUTRAL",
		checked = function () return IsListeningForMessageType("BG_NEUTRAL"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "BG_NEUTRAL"); end;
	},
}

CHAT_CONFIG_OTHER_SYSTEM = {
	[1] = {
		text = SYSTEM_MESSAGES,
		type = "SYSTEM",
		checked = function () return IsListeningForMessageType("SYSTEM"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "SYSTEM"); end;
	},
	[2] = {
		type = "ERRORS",
		checked = function () return IsListeningForMessageType("ERRORS"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "ERRORS"); end;
	},
	[3] = {
		type = "IGNORED",
		checked = function () return IsListeningForMessageType("IGNORED"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "IGNORED"); end;
	},
	[4] = {
		type = "CHANNEL",
		checked = function () return IsListeningForMessageType("CHANNEL"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "CHANNEL"); end;
	},
	[5] = {
		type = "TARGETICONS",
		checked = function () return IsListeningForMessageType("TARGETICONS"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "TARGETICONS"); end;
	},
	[6] = {
		type = "BN_INLINE_TOAST_ALERT",
		checked = function () return IsListeningForMessageType("BN_INLINE_TOAST_ALERT"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "BN_INLINE_TOAST_ALERT"); end;
	},
	[7] = {
		type = "PET_BATTLE_COMBAT_LOG",
		checked = function() return IsListeningForMessageType("PET_BATTLE_COMBAT_LOG"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "PET_BATTLE_COMBAT_LOG"); end;
	},
	[8] = {
		type = "PET_BATTLE_INFO",
		checked = function() return IsListeningForMessageType("PET_BATTLE_INFO"); end;
		func = function (self, checked) ToggleChatMessageGroup(checked, "PET_BATTLE_INFO"); end;
	},
}

CHAT_CONFIG_CHANNEL_LIST = {};
CHAT_CONFIG_TEXT_TO_SPEECH_CHANNEL_LIST = {};

-- Combat Options
COMBAT_CONFIG_MESSAGESOURCES_BY = {
	[1] = {
		text = function () return ( UsesGUID("SOURCE") and COMBATLOG_FILTER_STRING_CUSTOM_UNIT or COMBATLOG_FILTER_STRING_ME); end;
		checked = function () return UsesGUID("SOURCE") or IsMessageDoneBy(COMBATLOG_FILTER_MINE); end;
		disabled = function () return UsesGUID("SOURCE"); end;
		func = function (self, checked) ToggleMessageSource(checked, COMBATLOG_FILTER_MINE); end;
		tooltip = FILTER_BY_ME_COMBATLOG_TOOLTIP;	--Don't need to change tooltip because if it is the dummy box, it is disabled which means no tooltip
	},
	[2] = {
		text = COMBATLOG_FILTER_STRING_MY_PET,
		checked = function () return IsMessageDoneBy(COMBATLOG_FILTER_MY_PET); end;
		hidden = function () return UsesGUID("SOURCE"); end;
		func = function (self, checked) ToggleMessageSource(checked, COMBATLOG_FILTER_MY_PET); end;
		tooltip = FILTER_BY_PET_COMBATLOG_TOOLTIP;
	},
	[3] = {
		text = COMBATLOG_FILTER_STRING_FRIENDLY_UNITS,
		checked = function () return IsMessageDoneBy(COMBATLOG_FILTER_FRIENDLY_UNITS); end;
		hidden = function () return UsesGUID("SOURCE"); end;
		func = function (self, checked) ToggleMessageSource(checked, COMBATLOG_FILTER_FRIENDLY_UNITS); end;
		tooltip = FILTER_BY_FRIENDS_COMBATLOG_TOOLTIP;
	},
	[4] = {
		text = COMBATLOG_FILTER_STRING_HOSTILE_PLAYERS,
		checked = function () return IsMessageDoneBy(COMBATLOG_FILTER_HOSTILE_PLAYERS); end;
		hidden = function () return UsesGUID("SOURCE"); end;
		func = function (self, checked) ToggleMessageSource(checked, COMBATLOG_FILTER_HOSTILE_PLAYERS); end;
		tooltip = FILTER_BY_HOSTILE_PLAYERS_COMBATLOG_TOOLTIP;
	},
	[5] = {
		text = COMBATLOG_FILTER_STRING_HOSTILE_UNITS,
		checked = function () return IsMessageDoneBy(COMBATLOG_FILTER_HOSTILE_UNITS); end;
		hidden = function () return UsesGUID("SOURCE"); end;
		func = function (self, checked) ToggleMessageSource(checked, COMBATLOG_FILTER_HOSTILE_UNITS); end;
		tooltip = FILTER_BY_ENEMIES_COMBATLOG_TOOLTIP;
	},
	[6] = {
		text = COMBATLOG_FILTER_STRING_NEUTRAL_UNITS,
		checked = function () return IsMessageDoneBy(COMBATLOG_FILTER_NEUTRAL_UNITS); end;
		hidden = function () return UsesGUID("SOURCE"); end;
		func = function (self, checked) ToggleMessageSource(checked, COMBATLOG_FILTER_NEUTRAL_UNITS); end;
		tooltip = FILTER_BY_NEUTRAL_COMBATLOG_TOOLTIP;
	},
	[7] = {
		text = COMBATLOG_FILTER_STRING_UNKNOWN_UNITS,
		checked = function () return IsMessageDoneBy(COMBATLOG_FILTER_UNKNOWN_UNITS); end;
		hidden = function () return UsesGUID("SOURCE"); end;
		func = function (self, checked) ToggleMessageSource(checked, COMBATLOG_FILTER_UNKNOWN_UNITS); end;
		tooltip = FILTER_BY_UNKNOWN_COMBATLOG_TOOLTIP;
	},
}

COMBAT_CONFIG_MESSAGESOURCES_TO = {
	[1] = {
		text = function () return ( UsesGUID("DEST") and COMBATLOG_FILTER_STRING_CUSTOM_UNIT or COMBATLOG_FILTER_STRING_ME); end;
		checked = function () return UsesGUID("DEST") or IsMessageDoneTo(COMBATLOG_FILTER_MINE); end;
		disabled = function () return UsesGUID("DEST"); end;
		func = function (self, checked) ToggleMessageDest(checked, COMBATLOG_FILTER_MINE); end;
		tooltip = FILTER_TO_ME_COMBATLOG_TOOLTIP; --Don't need to change tooltip because if it is the dummy box, it is disabled which means no tooltip
	},
	[2] = {
		text = COMBATLOG_FILTER_STRING_MY_PET,
		checked = function () return IsMessageDoneTo(COMBATLOG_FILTER_MY_PET); end;
		hidden = function () return UsesGUID("DEST"); end;
		func = function (self, checked) ToggleMessageDest(checked, COMBATLOG_FILTER_MY_PET); end;
		tooltip = FILTER_TO_PET_COMBATLOG_TOOLTIP;
	},
	[3] = {
		text = COMBATLOG_FILTER_STRING_FRIENDLY_UNITS,
		checked = function () return IsMessageDoneTo(COMBATLOG_FILTER_FRIENDLY_UNITS); end;
		hidden = function () return UsesGUID("DEST"); end;
		func = function (self, checked) ToggleMessageDest(checked, COMBATLOG_FILTER_FRIENDLY_UNITS); end;
		tooltip = FILTER_TO_FRIENDS_COMBATLOG_TOOLTIP;
	},
	[4] = {
		text = COMBATLOG_FILTER_STRING_HOSTILE_PLAYERS,
		checked = function () return IsMessageDoneTo(COMBATLOG_FILTER_HOSTILE_PLAYERS); end;
		hidden = function () return UsesGUID("DEST"); end;
		func = function (self, checked) ToggleMessageDest(checked, COMBATLOG_FILTER_HOSTILE_PLAYERS); end;
		tooltip = FILTER_TO_HOSTILE_PLAYERS_COMBATLOG_TOOLTIP;
	},
	[5] = {
		text = COMBATLOG_FILTER_STRING_HOSTILE_UNITS,
		checked = function () return IsMessageDoneTo(COMBATLOG_FILTER_HOSTILE_UNITS); end;
		hidden = function () return UsesGUID("DEST"); end;
		func = function (self, checked) ToggleMessageDest(checked, COMBATLOG_FILTER_HOSTILE_UNITS); end;
		tooltip = FILTER_TO_HOSTILE_COMBATLOG_TOOLTIP;
	},
	[6] = {
		text = COMBATLOG_FILTER_STRING_NEUTRAL_UNITS,
		checked = function () return IsMessageDoneTo(COMBATLOG_FILTER_NEUTRAL_UNITS); end;
		hidden = function () return UsesGUID("DEST"); end;
		func = function (self, checked) ToggleMessageDest(checked, COMBATLOG_FILTER_NEUTRAL_UNITS); end;
		tooltip = FILTER_TO_NEUTRAL_COMBATLOG_TOOLTIP;
	},
	[7] = {
		text = COMBATLOG_FILTER_STRING_UNKNOWN_UNITS,
		checked = function () return IsMessageDoneTo(COMBATLOG_FILTER_UNKNOWN_UNITS); end;
		hidden = function () return UsesGUID("DEST"); end;
		func = function (self, checked) ToggleMessageDest(checked, COMBATLOG_FILTER_UNKNOWN_UNITS); end;
		tooltip = FILTER_TO_UNKNOWN_COMBATLOG_TOOLTIP;
	},
}

COMBAT_CONFIG_MESSAGETYPES_LEFT = {
	[1] = {
		text = MELEE,
		checked = function () return HasMessageTypeGroup(COMBAT_CONFIG_MESSAGETYPES_LEFT, 1) end;
		func = function (self, checked) ToggleMessageTypeGroup(checked, CombatConfigMessageTypesLeft, 1) end;
		tooltip = MELEE_COMBATLOG_TOOLTIP,
		subTypes = {
			[1] = {
				text = DAMAGE,
				type = "SWING_DAMAGE",
				checked = function () return HasMessageType("SWING_DAMAGE"); end;
				func = function (self, checked) ToggleMessageType(checked, "SWING_DAMAGE") end;
				tooltip = SWING_DAMAGE_COMBATLOG_TOOLTIP;
			},
			[2] = {
				text = MISSES,
				type = "SWING_MISSED",
				checked = function () return HasMessageType("SWING_MISSED"); end;
				func = function (self, checked) ToggleMessageType(checked, "SWING_MISSED"); end;
				tooltip = SWING_MISSED_COMBATLOG_TOOLTIP;
			},
		}
	},
	[2] = {
		text = RANGED,
		checked = function () return HasMessageTypeGroup(COMBAT_CONFIG_MESSAGETYPES_LEFT, 2) end;
		func = function (self, checked) ToggleMessageTypeGroup(checked, CombatConfigMessageTypesLeft, 2) end;
		tooltip = RANGED_COMBATLOG_TOOLTIP,
		subTypes = {
			[1] = {
				text = DAMAGE,
				type = "RANGE_DAMAGE",
				checked = function () return HasMessageType("RANGE_DAMAGE"); end;
				func = function (self, checked) ToggleMessageType(checked, "RANGE_DAMAGE"); end;
				tooltip = RANGE_DAMAGE_COMBATLOG_TOOLTIP;
			},
			[2] = {
				text = MISSES,
				type = "RANGE_MISSED",
				checked = function () return HasMessageType("RANGE_MISSED"); end;
				func = function (self, checked) ToggleMessageType(checked, "RANGE_MISSED"); end;
				tooltip = RANGE_MISSED_COMBATLOG_TOOLTIP;
			},
		}
	},
	[3] = {
		text = AURAS,
		checked = function () return HasMessageTypeGroup(COMBAT_CONFIG_MESSAGETYPES_LEFT, 3) end;
		func = function (self, checked) ToggleMessageTypeGroup(checked, CombatConfigMessageTypesLeft, 3) end;
		tooltip = AURAS_COMBATLOG_TOOLTIP,
		subTypes = {
			[1] = {
				text = BENEFICIAL,
				type = {"SPELL_AURA_APPLIED", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_REMOVED", "SPELL_AURA_APPLIED_REMOVED_DOSE", "SPELL_AURA_REFRESH"};
				checked = function () return not CHATCONFIG_SELECTED_FILTER.settings.hideBuffs end;
				func = function (self, checked)
					if ( checked ) then
						CHATCONFIG_SELECTED_FILTER.settings.hideBuffs = false;
						ToggleMessageType(checked, "SPELL_AURA_APPLIED", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_REMOVED", "SPELL_AURA_APPLIED_REMOVED_DOSE", "SPELL_AURA_REFRESH");
					else
						CHATCONFIG_SELECTED_FILTER.settings.hideBuffs = true;
						-- Only stop listening for the messages if hideDebuffs is also true
						if ( CHATCONFIG_SELECTED_FILTER.settings.hideDebuffs ) then
							ToggleMessageType(checked, "SPELL_AURA_APPLIED", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_REMOVED", "SPELL_AURA_APPLIED_REMOVED_DOSE", "SPELL_AURA_REFRESH");
						end
					end
				end;
				tooltip = BENEFICIAL_AURA_COMBATLOG_TOOLTIP;
			},
			[2] = {
				text = HOSTILE,
				type = {"SPELL_AURA_APPLIED", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_REMOVED", "SPELL_AURA_APPLIED_REMOVED_DOSE"};
				checked = function () return not CHATCONFIG_SELECTED_FILTER.settings.hideDebuffs end;
				func = function (self, checked)
					if ( checked ) then
						CHATCONFIG_SELECTED_FILTER.settings.hideDebuffs = false;
						ToggleMessageType(checked, "SPELL_AURA_APPLIED", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_REMOVED", "SPELL_AURA_APPLIED_REMOVED_DOSE");
					else
						CHATCONFIG_SELECTED_FILTER.settings.hideDebuffs = true;
						-- Only stop listening for the messages if hideDebuffs is also true
						if ( CHATCONFIG_SELECTED_FILTER.settings.hideBuffs ) then
							ToggleMessageType(checked, "SPELL_AURA_APPLIED", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_REMOVED", "SPELL_AURA_APPLIED_REMOVED_DOSE");
						end
					end
				end;
				tooltip = HARMFUL_AURA_COMBATLOG_TOOLTIP;
			},
			[3] = {
				text = DISPELS,
				type = {"SPELL_STOLEN", "SPELL_DISPEL_FAILED", "SPELL_DISPEL"};
				checked = function () return HasMessageType("SPELL_STOLEN", "SPELL_DISPEL_FAILED", "SPELL_DISPEL"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_STOLEN", "SPELL_DISPEL_FAILED", "SPELL_DISPEL"); end;
				tooltip = DISPEL_AURA_COMBATLOG_TOOLTIP;
			},
			[4] = {
				text = ENCHANTS,
				type = {"ENCHANT_APPLIED", "ENCHANT_REMOVED"};
				checked = function () return HasMessageType("ENCHANT_APPLIED", "ENCHANT_REMOVED"); end;
				func = function (self, checked) ToggleMessageType(checked, "ENCHANT_APPLIED", "ENCHANT_REMOVED"); end;
				tooltip = ENCHANT_AURA_COMBATLOG_TOOLTIP;
			},
		}
	},
	[4] = {
		text = PERIODIC,
		checked = function () return HasMessageTypeGroup(COMBAT_CONFIG_MESSAGETYPES_LEFT, 4) end;
		func = function (self, checked) ToggleMessageTypeGroup(checked, CombatConfigMessageTypesLeft, 4) end;
		tooltip = SPELL_PERIODIC_COMBATLOG_TOOLTIP,
		subTypes = {
			[1] = {
				text = DAMAGE,
				type = "SPELL_PERIODIC_DAMAGE",
				checked = function () return HasMessageType("SPELL_PERIODIC_DAMAGE"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_PERIODIC_DAMAGE"); end;
				tooltip = SPELL_PERIODIC_DAMAGE_COMBATLOG_TOOLTIP,
			},
			[2] = {
				text = MISSES,
				type = "SPELL_PERIODIC_MISSED",
				checked = function () return HasMessageType("SPELL_PERIODIC_MISSED"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_PERIODIC_MISSED"); end;
				tooltip = SPELL_PERIODIC_MISSED_COMBATLOG_TOOLTIP,
			},
			[3] = {
				text = HEALS,
				type = "SPELL_PERIODIC_HEAL",
				checked = function () return HasMessageType("SPELL_PERIODIC_HEAL"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_PERIODIC_HEAL"); end;
				tooltip = SPELL_PERIODIC_HEAL_COMBATLOG_TOOLTIP,
			},
			[4] = {
				text = OTHER,
				type = {"SPELL_PERIODIC_DRAIN","SPELL_PERIODIC_LEECH"};
				checked = function () return HasMessageType("SPELL_PERIODIC_DRAIN", "SPELL_PERIODIC_LEECH"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_PERIODIC_DRAIN", "SPELL_PERIODIC_LEECH"); end;
				tooltip = SPELL_PERIODIC_OTHER_COMBATLOG_TOOLTIP,
			},
		}
	},

};
COMBAT_CONFIG_MESSAGETYPES_RIGHT = {
	[1] = {
		text = SPELLS,
		checked = function () return HasMessageTypeGroup(COMBAT_CONFIG_MESSAGETYPES_RIGHT, 1) end;
		func = function (self, checked) ToggleMessageTypeGroup(checked, CombatConfigMessageTypesRight, 1) end;
		tooltip = SPELLS_COMBATLOG_TOOLTIP,
		subTypes = {
			[1] = {
				text = DAMAGE,
				type = "SPELL_DAMAGE",
				checked = function () return HasMessageType("SPELL_DAMAGE"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_DAMAGE"); end;
				tooltip = SPELL_DAMAGE_COMBATLOG_TOOLTIP,
			},
			[2] = {
				text = MISSES,
				type = "SPELL_MISSED",
				checked = function () return HasMessageType("SPELL_MISSED"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_MISSED"); end;
				tooltip = SPELL_MISSED_COMBATLOG_TOOLTIP,
			},
			[3] = {
				text = HEALS,
				type = "SPELL_HEAL",
				checked = function () return HasMessageType("SPELL_HEAL"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_HEAL"); end;
				tooltip = SPELL_HEAL_COMBATLOG_TOOLTIP,
			},
			[4] = {
				text = POWER_GAINS,
				type = "SPELL_ENERGIZE",
				checked = function () return HasMessageType("SPELL_ENERGIZE"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_ENERGIZE", "SPELL_PERIODIC_ENERGIZE"); end;
				tooltip = POWER_GAINS_COMBATLOG_TOOLTIP,
			},
			[5] = {
				text = DRAINS,
				type = {"SPELL_DRAIN", "SPELL_LEECH"};
				checked = function () return HasMessageType("SPELL_ENERGIZE"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_ENERGIZE"); end;
				tooltip = SPELL_DRAIN_COMBATLOG_TOOLTIP,
			},
			[5] = {
				text = INTERRUPTS,
				type = {"SPELL_INTERRUPT"};
				checked = function () return HasMessageType("SPELL_INTERRUPT"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_INTERRUPT"); end;
				tooltip = SPELL_INTERRUPT_COMBATLOG_TOOLTIP,
			},
			[5] = {
				text = SPECIAL,
				type = {"SPELL_INSTAKILL"};
				checked = function () return HasMessageType("SPELL_INSTAKILL"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_INSTAKILL"); end;
				tooltip = SPELL_INSTAKILL_COMBATLOG_TOOLTIP,
			},
			[6] = {
				text = EXTRA_ATTACKS,
				type = {"SPELL_EXTRA_ATTACKS"};
				checked = function () return HasMessageType("SPELL_EXTRA_ATTACKS"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_EXTRA_ATTACKS"); end;
				tooltip = SPELL_EXTRA_ATTACKS_COMBATLOG_TOOLTIP,
			},
			[7] = {
				text = SUMMONS,
				type = {"SPELL_SUMMON"};
				checked = function () return HasMessageType("SPELL_SUMMON"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_SUMMON"); end;
				tooltip = SPELL_SUMMON_COMBATLOG_TOOLTIP,
			},
			[8] = {
				text = RESURRECT,
				type = {"SPELL_RESURRECT"};
				checked = function () return HasMessageType("SPELL_RESURRECT"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_RESURRECT"); end;
				tooltip = SPELL_RESURRECT_COMBATLOG_TOOLTIP,
			},
			[9] = {
				text = BUILDING_DAMAGE,
				type = {"SPELL_BUILDING_DAMAGE"};
				checked = function () return HasMessageType("SPELL_BUILDING_DAMAGE"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_BUILDING_DAMAGE"); end;
				tooltip = BUILDING_DAMAGE_COMBATLOG_TOOLTIP,
			},
			[10] = {
				text = BUILDING_HEAL,
				type = {"SPELL_BUILDING_HEAL"};
				checked = function () return HasMessageType("SPELL_BUILDING_HEAL"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_BUILDING_HEAL"); end;
				tooltip = BUILDING_HEAL_COMBATLOG_TOOLTIP,
			},
		}
	},
	[2] = {
		text = SPELL_CASTING,
		checked = function () return HasMessageTypeGroup(COMBAT_CONFIG_MESSAGETYPES_RIGHT, 2) end;
		func = function (self, checked) ToggleMessageTypeGroup(checked, CombatConfigMessageTypesRight, 2) end;
		tooltip = SPELL_CASTING_COMBATLOG_TOOLTIP,
		subTypes = {
			[1] = {
				text = START,
				type = "SPELL_CAST_START",
				checked = function () return HasMessageType("SPELL_CAST_START"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_CAST_START"); end;
				tooltip = SPELL_CAST_START_COMBATLOG_TOOLTIP,
			},
			[2] = {
				text = SUCCESS,
				type = "SPELL_CAST_SUCCESS",
				checked = function () return HasMessageType("SPELL_CAST_SUCCESS"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_CAST_SUCCESS"); end;
				tooltip = SPELL_CAST_SUCCESS_COMBATLOG_TOOLTIP,
			},
			[3] = {
				text = FAILURES,
				type = "SPELL_CAST_FAILED",
				checked = function () return HasMessageType("SPELL_CAST_FAILED"); end;
				func = function (self, checked) ToggleMessageType(checked, "SPELL_CAST_FAILED"); end;
				tooltip = SPELL_CAST_FAILED_COMBATLOG_TOOLTIP,
			},
		}
	},
};
COMBAT_CONFIG_MESSAGETYPES_MISC = {
	[1] = {
		text = DAMAGE_SHIELD,
		checked = function () return HasMessageType("DAMAGE_SHIELD", "DAMAGE_SHIELD_MISSED"); end;
		func = function (self, checked) ToggleMessageType(checked, "DAMAGE_SHIELD", "DAMAGE_SHIELD_MISSED"); end;
		tooltip = DAMAGE_SHIELD_COMBATLOG_TOOLTIP,
	},
	[2] = {
		text = ENVIRONMENTAL_DAMAGE,
		checked = function () return HasMessageType("ENVIRONMENTAL_DAMAGE"); end;
		func = function (self, checked) ToggleMessageType(checked, "ENVIRONMENTAL_DAMAGE"); end;
		tooltip = ENVIRONMENTAL_DAMAGE_COMBATLOG_TOOLTIP,
	},
	[3] = {
		text = KILLS,
		checked = function () return HasMessageType("PARTY_KILL"); end;
		func = function (self, checked) ToggleMessageType(checked, "PARTY_KILL"); end;
		tooltip = KILLS_COMBATLOG_TOOLTIP,
	},
	[4] = {
		text = DEATHS,
		type = {"UNIT_DIED", "UNIT_DESTROYED", "UNIT_DISSIPATES"};
		checked = function () return HasMessageType("UNIT_DIED", "UNIT_DESTROYED", "UNIT_DISSIPATES"); end;
		func = function (self, checked) ToggleMessageType(checked, "UNIT_DIED", "UNIT_DESTROYED", "UNIT_DISSIPATES"); end;
		tooltip = DEATHS_COMBATLOG_TOOLTIP,
	},
};
COMBAT_CONFIG_UNIT_COLORS = {
	[1] = {
		text = COMBATLOG_FILTER_STRING_ME,
		type = "COMBATLOG_FILTER_MINE",
	},
	[2] = {
		text = COMBATLOG_FILTER_STRING_MY_PET,
		type = "COMBATLOG_FILTER_MY_PET",
	},
	[3] = {
		text = COMBATLOG_FILTER_STRING_FRIENDLY_UNITS,
		type = "COMBATLOG_FILTER_FRIENDLY_UNITS",
	},
	[4] = {
		text = COMBATLOG_FILTER_STRING_HOSTILE_UNITS,
		type = "COMBATLOG_FILTER_HOSTILE_UNITS",
	},
	[5] = {
		text = COMBATLOG_FILTER_STRING_HOSTILE_PLAYERS,
		type = "COMBATLOG_FILTER_HOSTILE_PLAYERS",
	},
	[6] = {
		text = COMBATLOG_FILTER_STRING_NEUTRAL_UNITS,
		type = "COMBATLOG_FILTER_NEUTRAL_UNITS",
	},
	[7] = {
		text = COMBATLOG_FILTER_STRING_UNKNOWN_UNITS,
		type = "COMBATLOG_FILTER_UNKNOWN_UNITS",
	},
}

function ChatConfigFrame_OnLoad(self)
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterEvent("CHANNEL_UI_UPDATE");
	self:RegisterEvent("CHAT_REGIONAL_STATUS_CHANGED");
	self:RegisterEvent("CHAT_DISABLED_CHANGE_FAILED");

	ChatConfigCombatSettingsFilters.selectedFilter = 1;
end

function ChatConfigFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		-- Chat Settings
		ChatConfigFrame_ReplaceChatConfigLeftTooltips(C_SocialRestrictions.IsChatDisabled());
		ChatConfig_CreateCheckboxes(ChatConfigChatSettingsLeft, CHAT_CONFIG_CHAT_LEFT, "ChatConfigWideCheckBoxWithSwatchTemplate", PLAYER_MESSAGES);
		ChatConfig_CreateCheckboxes(ChatConfigOtherSettingsCombat, CHAT_CONFIG_OTHER_COMBAT, "ChatConfigCheckBoxWithSwatchTemplate", COMBAT);
		ChatConfig_CreateCheckboxes(ChatConfigOtherSettingsPVP, CHAT_CONFIG_OTHER_PVP, "ChatConfigCheckBoxWithSwatchTemplate", PVP);
		ChatConfig_CreateCheckboxes(ChatConfigOtherSettingsSystem, CHAT_CONFIG_OTHER_SYSTEM, "ChatConfigCheckBoxWithSwatchTemplate", OTHER);
		ChatConfig_CreateCheckboxes(ChatConfigOtherSettingsCreature, CHAT_CONFIG_CHAT_CREATURE_LEFT, "ChatConfigCheckBoxWithSwatchTemplate", CREATURE_MESSAGES);

		-- CombatLog Settings
		ChatConfig_CreateCheckboxes(CombatConfigMessageSourcesDoneBy, COMBAT_CONFIG_MESSAGESOURCES_BY, "ChatConfigCheckBoxTemplate", DONE_BY);
		ChatConfig_CreateCheckboxes(CombatConfigMessageSourcesDoneTo, COMBAT_CONFIG_MESSAGESOURCES_TO, "ChatConfigCheckBoxTemplate", DONE_TO);
		ChatConfig_CreateTieredCheckboxes(CombatConfigMessageTypesLeft, COMBAT_CONFIG_MESSAGETYPES_LEFT, "ChatConfigCheckButtonTemplate", "ChatConfigSmallCheckButtonTemplate");
		ChatConfig_CreateTieredCheckboxes(CombatConfigMessageTypesRight, COMBAT_CONFIG_MESSAGETYPES_RIGHT, "ChatConfigCheckButtonTemplate", "ChatConfigSmallCheckButtonTemplate");
		ChatConfig_CreateTieredCheckboxes(CombatConfigMessageTypesMisc, COMBAT_CONFIG_MESSAGETYPES_MISC, "ChatConfigSmallCheckButtonTemplate", "ChatConfigSmallCheckButtonTemplate");
		ChatConfig_CreateColorSwatches(CombatConfigColorsUnitColors, COMBAT_CONFIG_UNIT_COLORS, "ChatConfigSwatchTemplate", UNIT_COLORS);

		if ( COMBATLOG_FILTER_VERSION and COMBATLOG_FILTER_VERSION > Blizzard_CombatLog_Filter_Version ) then
			CombatConfig_SetCombatFiltersToDefault();
			Blizzard_CombatLog_Filter_Version = COMBATLOG_FILTER_VERSION;
		end

		-- Default selections
		ChatConfigCategory_OnClick(ChatConfigCategoryFrameButton2);
		ChatConfig_UpdateCombatTabs(1);

		ChatConfigCategory_UpdateEnabled();
		ChatConfig_UpdateChatSettings();

		self.hasEnteredWorld = true;
	elseif ( event == "CHANNEL_UI_UPDATE" ) then
		if self.hasEnteredWorld then
			ChatConfigCategory_UpdateEnabled();
			ChatConfig_UpdateChatSettings();
		end
	elseif event == "CHAT_REGIONAL_STATUS_CHANGED" then
		if ChatConfigChannelSettings:IsVisible() then
			ChatConfigChannelSettings_OnShow();
		end
	elseif event == "CHAT_DISABLED_CHANGE_FAILED" then
		local disabled = ...;
		ChatConfigFrame_OnChatDisabledChanged(disabled);
	end
end

function ChatConfig_CreateCheckboxes(frame, checkBoxTable, checkBoxTemplate, title)
	local checkBoxNameString = frame:GetName().."CheckBox";
	local checkBoxName, checkBox, check;
	local width, height;
	local padding = 8;
	local text;
	local checkBoxFontString;

	frame.checkBoxTable = checkBoxTable;
	if ( title ) then
		_G[frame:GetName().."Title"]:SetText(title);
	end
	for index, value in ipairs(checkBoxTable) do
		--If no checkbox then create it
		checkBoxName = checkBoxNameString..index;
		checkBox = _G[checkBoxName];
		if ( not checkBox ) then
			checkBox = CreateFrame("Frame", checkBoxName, frame, checkBoxTemplate);
			checkBox:SetID(index);
		end

		if ( not width ) then
			width = checkBox:GetWidth();
			height = checkBox:GetHeight();
		end
		if ( index > 1 ) then
			checkBox:SetPoint("TOPLEFT", checkBoxNameString..(index-1), "BOTTOMLEFT", 0, 0);
		else
			checkBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4);
		end
		if ( value.text ) then
			text = value.text;
			if type(text) == "function" then
				text = text();
			end
		else
			text = _G[value.type];
		end
		checkBox.type = value.type;
		checkBoxFontString = _G[checkBoxName.."CheckText"];
		checkBoxFontString:SetText(text);
		checkBoxFontString:SetMaxLines(1);
		check = _G[checkBoxName.."Check"];
		check.func = value.func;
		check:SetID(index);
		check.tooltip = value.tooltip;
		check.onEnterCallback = value.onEnterCallback;
		check.onLeaveCallback = value.onLeaveCallback;
		if ( value.maxWidth ) then
			checkBoxFontString:SetWidth(0);
			if ( checkBoxFontString:GetWidth() > value.maxWidth ) then
				checkBoxFontString:SetWidth(value.maxWidth);
				check.tooltip = text;
				check.tooltipStyle = 0;
			end
		end
	end

	for index = #checkBoxTable + 1, MAX_WOW_CHAT_CHANNELS do
		checkBoxName = checkBoxNameString..index;
		checkBox = _G[checkBoxName];
		if checkBox then
			checkBox:Hide();
		end
	end

	--Set Parent frame dimensions
	if ( #checkBoxTable > 0 ) then
		frame:SetWidth(width+padding);
		frame:SetHeight(#checkBoxTable*height+padding);
	end
end

function ChatConfig_CreateTieredCheckboxes(frame, checkBoxTable, checkBoxTemplate, subCheckBoxTemplate, columns, spacing)
	local checkBoxNameString = frame:GetName().."CheckBox";
	local checkBoxName, checkBox, subCheckBoxName, subCheckBox, subCheckBoxNameString;
	local width, height;
	local padding = 8;
	local count = 0;
	local text, subText;
	local yOffset;
	local numColumns = 2;
	local columnIndex = 1;
	local itemsPerColumn;
	if ( columns ) then
		itemsPerColumn = ceil(#checkBoxTable/columns);
	end
	frame.checkBoxTable = checkBoxTable;
	for index, value in ipairs(checkBoxTable) do
		--If no checkbox then create it
		checkBoxName = checkBoxNameString..index;
		if ( not _G[checkBoxName] ) then
			checkBox = CreateFrame("CheckButton", checkBoxName, frame, checkBoxTemplate);
			if ( index > 1 ) then
				if ( columns ) then
					if ( mod(index, columns) == 1 ) then
						checkBox:SetPoint("TOPLEFT", checkBoxNameString..(index-columns), "BOTTOMLEFT", 0, yOffset);
						count = count+1;
					else
						checkBox:SetPoint("TOPLEFT", checkBoxNameString..(index-1), "TOPRIGHT", spacing, 0);
					end
				else
					checkBox:SetPoint("TOPLEFT", checkBoxNameString..(index-1), "BOTTOMLEFT", 0, yOffset);
					count = count+1;
				end
			else
				checkBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4);
				count = count+1;
			end
			if ( value.text ) then
				text = value.text;
			else
				text = _G[value.type];
			end
			_G[checkBoxName.."Text"]:SetText(text);
			if ( value.subTypes ) then
				subCheckBoxNameString = checkBoxName.."_";
				for k, v in ipairs(value.subTypes) do
					subCheckBoxName = subCheckBoxNameString..k;
					if ( not _G[subCheckBoxName] ) then
						subCheckBox = CreateFrame("CheckButton", subCheckBoxName, checkBox, subCheckBoxTemplate);
					end
					if ( k > 1 ) then
						if ( mod(k, numColumns) == 0 ) then
							subCheckBox:SetPoint("LEFT", subCheckBoxNameString..(k-1), "RIGHT", 60, 0);
						else
							subCheckBox:SetPoint("TOPLEFT", subCheckBoxNameString..(k-2), "BOTTOMLEFT", 0, 2);
						end
					else
						subCheckBox:SetPoint("TOPLEFT", checkBox, "BOTTOMLEFT", 15, 2);
					end
					subCheckBox.func = v.func;
					subCheckBox.tooltip = v.tooltip;
					if ( v.text ) then
						subText = v.text;
					else
						subText = _G[v.type];
					end
					_G[subCheckBoxName.."Text"]:SetText(subText);
					count = count+0.6;
				end
				yOffset = -(22*ceil(#value.subTypes/numColumns) + 16);
			else
				yOffset = 0;
			end
			checkBox.func = value.func;
			checkBox.tooltip = value.tooltip;
			if ( not width ) then
				width = checkBox:GetWidth();
				height = checkBox:GetHeight();
			end
		end
	end
	--Set Parent frame dimensions
	if ( count > 0 ) then
		frame:SetWidth(width+padding);
		frame:SetHeight(count*height+padding);
	end
end

function ChatConfig_CreateColorSwatches(frame, swatchTable, swatchTemplate, title)
	local nameString = frame:GetName().."Swatch";
	local swatchName, swatch;
	local width, height;
	local padding = 8;
	local count = 0;
	local text;
	frame.swatchTable = swatchTable;
	if ( title ) then
		_G[frame:GetName().."Title"]:SetText(title);
	end
	for index, value in ipairs(swatchTable) do
		--If no checkbox then create it
		swatchName = nameString..index;
		if ( not _G[swatchName] ) then
			swatch = CreateFrame("Frame", swatchName, frame, swatchTemplate);
			if ( not width ) then
				width = swatch:GetWidth();
				height = swatch:GetHeight();
			end
			if ( index > 1 ) then
				swatch:SetPoint("TOPLEFT", nameString..(index-1), "BOTTOMLEFT", 0, 0);
			else
				swatch:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4);
			end
			if ( value.text ) then
				text = value.text;
			else
				text = _G[value.type];
			end
			_G[swatchName.."Text"]:SetText(text);
			count = count+1;
		end
	end
	--Set Parent frame dimensions
	if ( count > 0 ) then
		frame:SetWidth(width+padding);
		frame:SetHeight(count*height+padding);
	end
end

function ChatConfig_UpdateCheckboxes(frame)
	-- List of message types in current chat frame
	if ( not FCF_GetCurrentChatFrame() ) then
		return;
	end
	local height;
	local checkBoxTable = frame.checkBoxTable;
	local checkBoxNameString = frame:GetName().."CheckBox";
	local checkBoxName, checkBox, baseName, colorSwatch;
	local topnum, padding = 0, 8;
	for index, value in ipairs(checkBoxTable) do
		baseName = checkBoxNameString..index;
		checkBox = _G[baseName.."Check"];
		if ( checkBox ) then
			if ( not height ) then
				height = checkBox:GetParent():GetHeight();
			end
			if ( value.isBlank ) then
				checkBox:Hide();
			else
				checkBox:Show();
				if ( type(value.checked) == "function" ) then
					checkBox:SetChecked(value.checked());
				else
					checkBox:SetChecked(value.checked);
				end
			end
			if ( type(value.disabled) == "function" ) then
				checkBox:SetEnabled(not value.disabled());
			else
				checkBox:SetEnabled(not value.disabled);
			end

			checkBox.tooltip = value.tooltip;

			if ( type(value.hidden) == "function" ) then
				if ( value.hidden() ) then
					checkBox:GetParent():Hide();
				else
					checkBox:GetParent():Show();
					topnum = index;
				end
			else
				if ( value.hidden ) then
					checkBox:GetParent():Hide();
				else
					checkBox:GetParent():Show();
					topnum = index;
				end
			end
			if ( type(value.text) == "function" ) then	--Dynamic text, we should update it
				_G[checkBoxNameString..index.."CheckText"]:SetText(value.text());
			end

			colorSwatch = _G[baseName.."ColorSwatch"];
			if ( colorSwatch ) then
				if ( value.isBlank ) then
					colorSwatch:Hide();
				else
					local r, g, b = GetMessageTypeColor(value.type);
					_G[baseName.."ColorSwatch"].Color:SetVertexColor(r, g, b);
					colorSwatch.type = value.type;
					colorSwatch:Show();
				end
			end
		end
		frame:SetHeight( topnum * height + padding );
	end
	-- Hide remaining checkboxes
	local count = #checkBoxTable+1;
	repeat
		checkBox = _G[checkBoxNameString..count];
		if ( checkBox ) then
			checkBox:Hide();
		end
		count = count+1;
	until not checkBox;
end

function ChatConfig_UpdateSwatches(frame)
	-- List of message types in current chat frame
	if ( not FCF_GetCurrentChatFrame() ) then
		return;
	end
	local table = frame.swatchTable;
	local nameString = frame:GetName().."Swatch";
	local checkBoxName, checkBox, baseName, colorSwatch;
	for index, value in ipairs(table) do
		baseName = nameString..index;
		colorSwatch = _G[baseName.."ColorSwatch"];
		if ( colorSwatch ) then
			_G[baseName.."ColorSwatchNormalTexture"]:SetVertexColor(GetChatUnitColor(value.type));
			colorSwatch.type = value.type;
		end
	end
end

function ChatConfig_UpdateTieredCheckboxFrame(frame)
	-- List of message types in current chat frame
	if ( not FCF_GetCurrentChatFrame() ) then
		return;
	end
	for i=1, #frame.checkBoxTable do
		ChatConfig_UpdateTieredCheckboxes(frame, i);
	end
end

function ChatConfig_UpdateTieredCheckboxes(frame, index)
	local group = frame.checkBoxTable[index];
	local groupChecked;
	local baseName = frame:GetName().."CheckBox"..index;
	local checkBox = _G[baseName];
	if ( checkBox ) then
		groupChecked = group.checked;
		if ( type(groupChecked) == "function" ) then
			local checked = groupChecked();
			checkBox:SetChecked(checked);
			--Set checked so we can use it later
			groupChecked = checked;
		else
			checkBox:SetChecked(groupChecked);
		end
		if ( type(group.disabled) == "function" ) then
			if( group.disabled() ) then
				checkBox:Disable();
			else
				checkBox:Enable();
			end
		else
			if ( group.disabled ) then
				checkBox:Disable();
			else
				checkBox:Enable();
			end
		end
	end
	local subCheckBox;
	if ( group.subTypes ) then
		for k, v in ipairs(group.subTypes) do
			subCheckBox = _G[baseName.."_"..k];
			if ( type(v.checked) == "function" ) then
				subCheckBox:SetChecked(v.checked());
			else
				subCheckBox:SetChecked(v.checked);
			end
			if ( type(v.disabled) == "function" ) then
				if( v.disabled() ) then
					subCheckBox:Disable();
				else
					subCheckBox:Enable();
				end
			else
				if ( v.disabled ) then
					subCheckBox:Disable();
				else
					subCheckBox:Enable();
				end
			end

			subCheckBox:SetEnabled(groupChecked);
		end
	end
end

function CombatConfig_Colorize_Update()
	if ( not CHATCONFIG_SELECTED_FILTER.settings ) then
		return;
	end

	CombatConfigColorsColorizeUnitNameCheck:SetChecked(CHATCONFIG_SELECTED_FILTER.settings.unitColoring);

	-- Spell Names
	CombatConfigColorsColorizeSpellNamesCheck:SetChecked(CHATCONFIG_SELECTED_FILTER.settings.abilityColoring);
	CombatConfigColorsColorizeSpellNamesSchoolColoring:SetEnabled(CHATCONFIG_SELECTED_FILTER.settings.abilityColoring);
	CombatConfigColorsColorizeSpellNamesSchoolColoring:SetChecked(CHATCONFIG_SELECTED_FILTER.settings.abilitySchoolColoring);
	CombatConfigColorsColorizeSpellNamesColorSwatchNormalTexture:SetVertexColor(GetTableColor(CHATCONFIG_SELECTED_FILTER.colors.defaults.spell));

	-- Damage Number
	CombatConfigColorsColorizeDamageNumberCheck:SetChecked(CHATCONFIG_SELECTED_FILTER.settings.amountColoring);
	CombatConfigColorsColorizeDamageNumberSchoolColoring:SetEnabled(CHATCONFIG_SELECTED_FILTER.settings.amountColoring);
	CombatConfigColorsColorizeDamageNumberSchoolColoring:SetChecked(CHATCONFIG_SELECTED_FILTER.settings.amountSchoolColoring);
	CombatConfigColorsColorizeDamageNumberColorSwatchNormalTexture:SetVertexColor(GetTableColor(CHATCONFIG_SELECTED_FILTER.colors.defaults.damage));

	-- Damage School
	CombatConfigColorsColorizeDamageSchoolCheck:SetChecked(CHATCONFIG_SELECTED_FILTER.settings.schoolNameColoring);

	-- Line Coloring
	CombatConfigColorsColorizeEntireLineCheck:SetChecked(CHATCONFIG_SELECTED_FILTER.settings.lineColoring);
	CombatConfigColorsColorizeEntireLineBySource:SetEnabled(CHATCONFIG_SELECTED_FILTER.settings.lineColoring);
	CombatConfigColorsColorizeEntireLineByTarget:SetEnabled(CHATCONFIG_SELECTED_FILTER.settings.lineColoring);

	if ( CHATCONFIG_SELECTED_FILTER.settings.lineColorPriority == 1 ) then
		CombatConfigColorsColorizeEntireLineBySource:SetChecked(true);
		CombatConfigColorsColorizeEntireLineByTarget:SetChecked(false);
	else
		CombatConfigColorsColorizeEntireLineBySource:SetChecked(false);
		CombatConfigColorsColorizeEntireLineByTarget:SetChecked(true);
	end

	-- Line Highlighting
	CombatConfigColorsHighlightingLine:SetChecked(CHATCONFIG_SELECTED_FILTER.settings.lineHighlighting);
	CombatConfigColorsHighlightingAbility:SetChecked(CHATCONFIG_SELECTED_FILTER.settings.abilityHighlighting);
	CombatConfigColorsHighlightingDamage:SetChecked(CHATCONFIG_SELECTED_FILTER.settings.amountHighlighting);
	CombatConfigColorsHighlightingSchool:SetChecked(CHATCONFIG_SELECTED_FILTER.settings.schoolNameHighlighting);


	local text, r, g, b = CombatLog_OnEvent(CHATCONFIG_SELECTED_FILTER, 0, "SPELL_DAMAGE", false, 0x0000000000000001, UnitName("player"), 0x511, 0, 0xF13000012B000820, EXAMPLE_TARGET_MONSTER, 0x10a28, 0, 116, EXAMPLE_SPELL_FROSTBOLT, Enum.Damageclass.MaskFrost, 27, Enum.Damageclass.MaskFrost, nil, nil, nil, 1, nil, nil);
	CombatConfigColorsExampleString1:SetVertexColor(r, g, b);
	CombatConfigColorsExampleString1:SetText(text);

	text, r, g, b = CombatLog_OnEvent(CHATCONFIG_SELECTED_FILTER, 0, "SPELL_DAMAGE", false, 0xF13000024D002914, EXAMPLE_TARGET_MONSTER, 0x10a48, 0, 0x0000000000000001, UnitName("player"), 0x511, 0, 20793,EXAMPLE_SPELL_FIREBALL, Enum.Damageclass.MaskFire, 68, Enum.Damageclass.MaskFire, nil, nil, nil, nil, nil, nil);
	CombatConfigColorsExampleString2:SetVertexColor(r, g, b);
	CombatConfigColorsExampleString2:SetText(text);
end

function CombatConfig_Formatting_Update()
	CombatConfigFormattingShowTimeStamp:SetChecked(CHATCONFIG_SELECTED_FILTER.settings.timestamp);
	CombatConfigFormattingShowBraces:SetChecked(CHATCONFIG_SELECTED_FILTER.settings.braces);

	CombatConfigFormattingUnitNames:SetEnabled(CHATCONFIG_SELECTED_FILTER.settings.braces);
	CombatConfigFormattingSpellNames:SetEnabled(CHATCONFIG_SELECTED_FILTER.settings.braces);
	CombatConfigFormattingItemNames:SetEnabled(CHATCONFIG_SELECTED_FILTER.settings.braces);

	CombatConfigFormattingUnitNames:SetChecked(CHATCONFIG_SELECTED_FILTER.settings.unitBraces);
	CombatConfigFormattingSpellNames:SetChecked(CHATCONFIG_SELECTED_FILTER.settings.spellBraces);
	CombatConfigFormattingItemNames:SetChecked(CHATCONFIG_SELECTED_FILTER.settings.itemBraces);
	CombatConfigFormattingFullText:SetChecked(CHATCONFIG_SELECTED_FILTER.settings.fullText);

	local text, r, g, b = CombatLog_OnEvent(CHATCONFIG_SELECTED_FILTER, 0, "SPELL_DAMAGE", false, 0x0000000000000001, UnitName("player"), 0x511, 0, 0xF13000012B000820, EXAMPLE_TARGET_MONSTER, 0x10a28, 0, 116, EXAMPLE_SPELL_FROSTBOLT, Enum.Damageclass.MaskFrost, 27, Enum.Damageclass.MaskFrost, nil, nil, nil, 1, nil, nil);
	CombatConfigFormattingExampleString1:SetVertexColor(r, g, b);
	CombatConfigFormattingExampleString1:SetText(text);

	text, r, g, b = CombatLog_OnEvent(CHATCONFIG_SELECTED_FILTER, 0, "SPELL_DAMAGE", false, 0xF13000024D002914, EXAMPLE_TARGET_MONSTER, 0x10a48, 0, 0x0000000000000001, UnitName("player"), 0x511, 0, 20793,EXAMPLE_SPELL_FIREBALL, Enum.Damageclass.MaskFire, 68, Enum.Damageclass.MaskFire, nil, nil, nil, nil, nil, nil);
	CombatConfigFormattingExampleString2:SetVertexColor(r, g, b);
	CombatConfigFormattingExampleString2:SetText(text);
end

function CombatConfig_Settings_Update()
	CombatConfigSettingsShowQuickButton:SetChecked(CHATCONFIG_SELECTED_FILTER.hasQuickButton);
	CombatConfigSettingsSolo:SetEnabled(CHATCONFIG_SELECTED_FILTER.hasQuickButton);
	CombatConfigSettingsParty:SetEnabled(CHATCONFIG_SELECTED_FILTER.hasQuickButton);
	CombatConfigSettingsRaid:SetEnabled(CHATCONFIG_SELECTED_FILTER.hasQuickButton);
	CombatConfigSettingsSolo:SetChecked(CHATCONFIG_SELECTED_FILTER.quickButtonDisplay.solo);
	CombatConfigSettingsParty:SetChecked(CHATCONFIG_SELECTED_FILTER.quickButtonDisplay.party);
	CombatConfigSettingsRaid:SetChecked(CHATCONFIG_SELECTED_FILTER.quickButtonDisplay.raid);
end

function CombatConfig_SetFilterName(name)
	CHATCONFIG_SELECTED_FILTER.name = name;
	ChatConfig_UpdateFilterList();
end

function ToggleChatMessageGroup(checked, group)
	if ( checked ) then
		ChatFrame_AddMessageGroup(FCF_GetCurrentChatFrame(), group);
	else
		ChatFrame_RemoveMessageGroup(FCF_GetCurrentChatFrame(), group);
	end
end

function ToggleChatColorNamesByClassGroup(checked, group)
	local info = ChatTypeGroup[group];
	if ( info ) then
		for key, value in pairs(info) do
			SetChatColorNameByClass(strsub(value, 10), checked);	--strsub gets rid of CHAT_MSG_
		end
	else
		SetChatColorNameByClass(group, checked);
	end
end

function ToggleMessageSource(checked, filter)
	if ( not CHATCONFIG_SELECTED_FILTER.filters[1].sourceFlags ) then
		CHATCONFIG_SELECTED_FILTER.filters[1].sourceFlags = {};
	end
	local sourceFlags = CHATCONFIG_SELECTED_FILTER.filters[1].sourceFlags;
	if ( checked ) then
		sourceFlags[filter] = true;
	else
		sourceFlags[filter] = false;
	end
end

function ToggleMessageDest(checked, filter)
	local destFlags;

	if ( UsesGUID( "SOURCE" )  ) then
		if ( not CHATCONFIG_SELECTED_FILTER.filters[1].destFlags ) then
			CHATCONFIG_SELECTED_FILTER.filters[1].destFlags = {};
		end
		destFlags = CHATCONFIG_SELECTED_FILTER.filters[1].destFlags;
	else
		if ( not CHATCONFIG_SELECTED_FILTER.filters[2].destFlags ) then
			CHATCONFIG_SELECTED_FILTER.filters[2].destFlags = {};
		end
			destFlags = CHATCONFIG_SELECTED_FILTER.filters[2].destFlags;
	end
	if ( checked ) then
		destFlags[filter] = true;
	else
		destFlags[filter] = false;
	end
end


-- Create  parent is checked or unchecked if all children are unchecked
function ToggleMessageTypeGroup(checked, frame, index)
	local subTypes = frame.checkBoxTable[index].subTypes;
	local eventList = CHATCONFIG_SELECTED_FILTER.filters[1].eventList;
	if ( subTypes ) then
		local state;
		if ( checked ) then
			for k, v in ipairs(subTypes) do
				state = GetMessageTypeState(v.type);
				if ( state == GRAY_CHECKED or state == true ) then
					if ( type(v.type) == "table" ) then
						for k2, v2 in pairs(v.type) do
							eventList[v2] = true;
						end
					else
						eventList[v.type] = true;
					end
				else
					if ( type(v.type) == "table" ) then
						for k2, v2 in pairs(v.type) do
							eventList[v2] = UNCHECKED_ENABLED;
						end
					else
						eventList[v.type] = UNCHECKED_ENABLED;
					end
				end
			end
		else
			for k, v in ipairs(subTypes) do
				state = GetMessageTypeState(v.type);
				if ( state == true or state == GRAY_CHECKED) then
					if ( type(v.type) == "table" ) then
						for k2, v2 in pairs(v.type) do
							eventList[v2] = GRAY_CHECKED;
						end
					else
						eventList[v.type] = GRAY_CHECKED;
					end
				else
					if ( type(v.type) == "table" ) then
						for k2, v2 in pairs(v.type) do
							eventList[v2] = UNCHECKED_DISABLED;
						end
					else
						eventList[v.type] = UNCHECKED_DISABLED;
					end
				end
			end
		end
	end
	ChatConfig_UpdateTieredCheckboxes(frame, index);
end

function ToggleMessageType(checked, ...)
	local eventList = CHATCONFIG_SELECTED_FILTER.filters[1].eventList;
	for _, type in pairs ( {...} ) do
		if ( checked ) then
			eventList[type] = true;
		else
			eventList[type] = false;
		end
	end
end

function IsListeningForMessageType(messageType)
	local messageTypeList = FCF_GetCurrentChatFrame().messageTypeList;
	for index, value in pairs(messageTypeList) do
		if ( value == messageType ) then
			return true;
		end
	end
	return false;
end

function IsClassColoringMessageType(messageType)
	local groupInfo = ChatTypeGroup[messageType];
	if ( groupInfo ) then
		for key, value in pairs(groupInfo) do	--If any of the sub-categories color by name, we'll consider the entire thing as colored by name.
			local info = ChatTypeInfo[strsub(value, 10)];
			if ( info and Chat_ShouldColorChatByClass(info) ) then
				return true;
			end
		end
		return false;
	else
		local info = ChatTypeInfo[messageType];
		return info and Chat_ShouldColorChatByClass(info);
	end
end

COMBATCONFIG_COLORPICKER_FUNCTIONS = {
	chatUnitColorSwatch = function()
			SetChatUnitColor(CHAT_CONFIG_CURRENT_COLOR_SWATCH.type, ColorPickerFrame:GetColorRGB());
			_G[CHAT_CONFIG_CURRENT_COLOR_SWATCH:GetName().."NormalTexture"]:SetVertexColor(ColorPickerFrame:GetColorRGB());
			CombatConfig_Colorize_Update();
		end;
	chatUnitColorCancel = function()
			SetChatUnitColor(CHAT_CONFIG_CURRENT_COLOR_SWATCH.type, ColorPicker_GetPreviousValues());
			_G[CHAT_CONFIG_CURRENT_COLOR_SWATCH:GetName().."NormalTexture"]:SetVertexColor(ColorPicker_GetPreviousValues());
			CombatConfig_Colorize_Update();
		end;
	spellColorSwatch = function()
			SetTableColor(CHATCONFIG_SELECTED_FILTER.colors.defaults.spell, ColorPickerFrame:GetColorRGB());
			_G[CHAT_CONFIG_CURRENT_COLOR_SWATCH:GetName().."NormalTexture"]:SetVertexColor(ColorPickerFrame:GetColorRGB());
			CombatConfig_Colorize_Update();
		end;
	spellColorCancel = function()
			SetTableColor(CHATCONFIG_SELECTED_FILTER.colors.defaults.spell, ColorPicker_GetPreviousValues());
			_G[CHAT_CONFIG_CURRENT_COLOR_SWATCH:GetName().."NormalTexture"]:SetVertexColor(ColorPicker_GetPreviousValues());
			CombatConfig_Colorize_Update();
		end;
	damageColorSwatch = function()
			SetTableColor(CHATCONFIG_SELECTED_FILTER.colors.defaults.damage, ColorPickerFrame:GetColorRGB());
			_G[CHAT_CONFIG_CURRENT_COLOR_SWATCH:GetName().."NormalTexture"]:SetVertexColor(ColorPickerFrame:GetColorRGB());
			CombatConfig_Colorize_Update();
		end;
	damageColorCancel = function()
			SetTableColor(CHATCONFIG_SELECTED_FILTER.colors.defaults.damage, ColorPicker_GetPreviousValues());
			_G[CHAT_CONFIG_CURRENT_COLOR_SWATCH:GetName().."NormalTexture"]:SetVertexColor(ColorPicker_GetPreviousValues());
			CombatConfig_Colorize_Update();
		end;
	messageTypeColorSwatch = function()
			local messageTypes = ColorPickerFrame.extraInfo;
			if ( messageTypes ) then
				for index, value in pairs(messageTypes) do
					ChangeChatColor(FCF_StripChatMsg(value), ColorPickerFrame:GetColorRGB());
				end
			else
				ChangeChatColor(CHAT_CONFIG_CURRENT_COLOR_SWATCH.type, ColorPickerFrame:GetColorRGB());
			end
			_G[CHAT_CONFIG_CURRENT_COLOR_SWATCH:GetName()].Color:SetVertexColor(ColorPickerFrame:GetColorRGB());
			CombatConfig_Colorize_Update();
		end;
	messageTypeColorCancel = function()
			local messageTypes = ColorPickerFrame.extraInfo;
			if ( messageTypes ) then
				for index, value in pairs(messageTypes) do
					ChangeChatColor(FCF_StripChatMsg(value), ColorPicker_GetPreviousValues());
				end
			else
				ChangeChatColor(CHAT_CONFIG_CURRENT_COLOR_SWATCH.type, ColorPicker_GetPreviousValues());
			end
			_G[CHAT_CONFIG_CURRENT_COLOR_SWATCH:GetName()].Color:SetVertexColor(ColorPicker_GetPreviousValues());
			CombatConfig_Colorize_Update();
		end;
}

function ChatUnitColor_OpenColorPicker(self)
	local info = UIDropDownMenu_CreateInfo();
	info.r, info.g, info.b = GetChatUnitColor(self.type);
	CHAT_CONFIG_CURRENT_COLOR_SWATCH = self;
	info.swatchFunc = COMBATCONFIG_COLORPICKER_FUNCTIONS.chatUnitColorSwatch;
	info.cancelFunc = COMBATCONFIG_COLORPICKER_FUNCTIONS.chatUnitColorCancel;
	OpenColorPicker(info);
end

function SpellColor_OpenColorPicker(self)
	local info = UIDropDownMenu_CreateInfo();
	CHAT_CONFIG_CURRENT_COLOR_SWATCH = self;
	info.r, info.g, info.b = GetTableColor(CHATCONFIG_SELECTED_FILTER.colors.defaults.spell);
	info.swatchFunc = COMBATCONFIG_COLORPICKER_FUNCTIONS.spellColorSwatch;
	info.cancelFunc = COMBATCONFIG_COLORPICKER_FUNCTIONS.spellColorCancel;
	OpenColorPicker(info);
end

function DamageColor_OpenColorPicker(self)
	local info = UIDropDownMenu_CreateInfo();
	CHAT_CONFIG_CURRENT_COLOR_SWATCH = self;
	info.r, info.g, info.b = GetTableColor(CHATCONFIG_SELECTED_FILTER.colors.defaults.damage);
	info.swatchFunc = COMBATCONFIG_COLORPICKER_FUNCTIONS.damageColorSwatch;
	info.cancelFunc = COMBATCONFIG_COLORPICKER_FUNCTIONS.damageColorCancel;
	OpenColorPicker(info);
end

function MessageTypeColor_OpenColorPicker(self)
	local info = UIDropDownMenu_CreateInfo();
	local messageTypeTable;
	info.r, info.g, info.b, messageTypeTable = GetMessageTypeColor(self.type);
	CHAT_CONFIG_CURRENT_COLOR_SWATCH = self;
	info.swatchFunc = COMBATCONFIG_COLORPICKER_FUNCTIONS.messageTypeColorSwatch;
	info.cancelFunc = COMBATCONFIG_COLORPICKER_FUNCTIONS.messageTypeColorCancel;
	info.extraInfo = nil;
	if ( messageTypeTable ) then
		info.extraInfo = messageTypeTable;
	end
	OpenColorPicker(info);
end

function GetMessageTypeColor(messageType)
	local group = ChatTypeGroup[messageType];
	local type;
	if ( group ) then
		type = group[1];
	else
		type = messageType;
	end
	local info = ChatTypeInfo[FCF_StripChatMsg(type)];

	return info.r, info.g, info.b, group;
end

function GetChatUnitColor(type)
	local color = CHATCONFIG_SELECTED_FILTER.colors.unitColoring[_G[type]];
	return color.r, color.g, color.b;
end

function SetChatUnitColor(type, r, g, b)
	SetTableColor(CHATCONFIG_SELECTED_FILTER.colors.unitColoring[_G[type]], r, g, b);
end

function GetSpellNameColor()
	local color = CHATCONFIG_SELECTED_FILTER.colors.defaults.spell;
	return color.r, color.g, color.b;
end

function SetSpellNameColor(r, g, b)
	SetTableColor(CHATCONFIG_SELECTED_FILTER.colors.defaults.spell, r, g, b);
end

-- Convenience functions for pulling and putting rgb values into tables
function GetTableColor(color)
	return color.r, color.g, color.b;
end

function SetTableColor(color, r, g, b)
	color.r = r;
	color.g = g;
	color.b = b;
end


CHAT_CONFIG_CATEGORIES = {
	[1] = "ChatConfigChatSettings",
	[2] = "ChatConfigCombatSettings",
	[3] = "ChatConfigChannelSettings",
	[4] = "ChatConfigOtherSettings",
	[5] = "ChatConfigTextToSpeechSettings",
	[6] = "ChatConfigTextToSpeechMessageSettings",
	[7] = "ChatConfigTextToSpeechChannelSettings",
};

function ChatConfigCategory_OnClick(self)
	self:UnlockHighlight();
	for index, value in ipairs(CHAT_CONFIG_CATEGORIES) do
		if ( self:GetID() == index ) then
			_G[value]:Show();
			self:LockHighlight();
		else
			_G[value]:Hide();
			_G["ChatConfigCategoryFrameButton"..index]:UnlockHighlight();
		end
	end
end

local function UpdateDefaultButtons(combatLogSelected, textToSpeechSelected)
	TextToSpeechDefaultButton:SetShown(textToSpeechSelected);
	TextToSpeechDefaultButton:SetWidth(TextToSpeechDefaultButton.Text:GetWidth() + 32);
	TextToSpeechCharacterSpecificButton:SetPoint("LEFT", TextToSpeechDefaultButton, "RIGHT", 5, 0);
	TextToSpeechCharacterSpecificButton:SetShown(textToSpeechSelected);
	CombatLogDefaultButton:SetShown(combatLogSelected);

	local showChatButtons = not combatLogSelected and not textToSpeechSelected;
	ChatConfigFrame.DefaultButton:SetShown(showChatButtons);
	ChatConfigFrame.RedockButton:SetShown(showChatButtons);
	ChatConfigFrame.ToggleChatButton:SetShown(showChatButtons and not C_SocialRestrictions.IsMuted());
	if showChatButtons then
		ChatConfigFrameToggleChatButton_UpdateAccountChatDisabled(C_SocialRestrictions.IsChatDisabled());
	end
end

function ChatConfigCategory_UpdateEnabled()
	if ( GetChannelList() ) then
		ChatConfigCategoryFrameButton3:Enable();
	else
		ChatConfigCategoryFrameButton3:Disable();
	end
end

local function IsChannelNameChecked(channelList, channelName)
	if channelList then
		for index, value in pairs(channelList) do
			if value == channelName then
				return true;
			end
		end
	end
	return false;
end

function CreateChatChannelList(self, ...)
	if ( not FCF_GetCurrentChatFrame() ) then
		return;
	end
	local channelList = FCF_GetCurrentChatFrame().channelList;
	local zoneChannelList = FCF_GetCurrentChatFrame().zoneChannelList;
	local count = 1;
	CHAT_CONFIG_CHANNEL_LIST = {};
	for i=1, select("#", ...), 3 do
		local channelID = select(i, ...);
		local tag = "CHANNEL"..channelID;
		local channel = select(i+1, ...);
		local disabled = select(i+2, ...);
		if C_ChatInfo.IsChannelRegional(channelID) then
			disabled = disabled or not C_ChatInfo.IsRegionalServiceAvailable();
		end
		local checked = IsChannelNameChecked(channelList, channel);

		while count < channelID do
			-- Leave empty entries for missing channels to allow for re-ordering.
			CHAT_CONFIG_CHANNEL_LIST[count] = {};
			CHAT_CONFIG_CHANNEL_LIST[count].channelID = count;
			CHAT_CONFIG_CHANNEL_LIST[count].text = count..".";
			CHAT_CONFIG_CHANNEL_LIST[count].isBlank = true;
			count = count + 1;
		end

		CHAT_CONFIG_CHANNEL_LIST[count] = {};
		CHAT_CONFIG_CHANNEL_LIST[count].channelID = channelID;
		CHAT_CONFIG_CHANNEL_LIST[count].text = channelID.."."..ChatFrame_ResolveChannelName(channel);
		CHAT_CONFIG_CHANNEL_LIST[count].channelName = channel;
		CHAT_CONFIG_CHANNEL_LIST[count].type = tag;
		CHAT_CONFIG_CHANNEL_LIST[count].maxWidth = CHATCONFIG_CHANNELS_MAXWIDTH;
		CHAT_CONFIG_CHANNEL_LIST[count].checked = checked;
		CHAT_CONFIG_CHANNEL_LIST[count].disabled = disabled;
		CHAT_CONFIG_CHANNEL_LIST[count].func = function (self, checked)
							ChatFrame_SetChannelEnabled(FCF_GetCurrentChatFrame(), CHAT_CONFIG_CHANNEL_LIST[self:GetID()].channelName, checked);
							end;
		count = count+1;
	end
end

function CreateChatTextToSpeechChannelList(self, ...)
	if ( not FCF_GetCurrentChatFrame() ) then
		return;
	end
	local channelList = FCF_GetCurrentChatFrame().channelList;
	local zoneChannelList = FCF_GetCurrentChatFrame().zoneChannelList;
	local count = 1;
	CHAT_CONFIG_TEXT_TO_SPEECH_CHANNEL_LIST = {};
	for i=1, select("#", ...), 3 do
		local channelID = select(i, ...);
		local tag = "CHANNEL"..channelID;
		local channel = select(i+1, ...);
		local disabled = select(i+2, ...);
		if C_ChatInfo.IsChannelRegional(channelID) then
			disabled = disabled or not C_ChatInfo.IsRegionalServiceAvailable();
		end
		
		local channelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(channel);
		local checked = C_TTSSettings.GetChannelEnabled(channelInfo);

		while count < channelID do
			-- Leave empty entries for missing channels to allow for re-ordering.
			CHAT_CONFIG_TEXT_TO_SPEECH_CHANNEL_LIST[count] = {};
			CHAT_CONFIG_TEXT_TO_SPEECH_CHANNEL_LIST[count].channelID = count;
			CHAT_CONFIG_TEXT_TO_SPEECH_CHANNEL_LIST[count].text = count..".";
			CHAT_CONFIG_TEXT_TO_SPEECH_CHANNEL_LIST[count].isBlank = true;
			count = count + 1;
		end

		CHAT_CONFIG_TEXT_TO_SPEECH_CHANNEL_LIST[count] = {};
		CHAT_CONFIG_TEXT_TO_SPEECH_CHANNEL_LIST[count].channelID = channelID;
		CHAT_CONFIG_TEXT_TO_SPEECH_CHANNEL_LIST[count].text = channelID.."."..ChatFrame_ResolveChannelName(channel);
		CHAT_CONFIG_TEXT_TO_SPEECH_CHANNEL_LIST[count].channelName = channel;
		CHAT_CONFIG_TEXT_TO_SPEECH_CHANNEL_LIST[count].type = tag;
		CHAT_CONFIG_TEXT_TO_SPEECH_CHANNEL_LIST[count].maxWidth = CHATCONFIG_CHANNELS_MAXWIDTH;
		CHAT_CONFIG_TEXT_TO_SPEECH_CHANNEL_LIST[count].checked = checked;
		CHAT_CONFIG_TEXT_TO_SPEECH_CHANNEL_LIST[count].disabled = disabled;
		CHAT_CONFIG_TEXT_TO_SPEECH_CHANNEL_LIST[count].func = function (self, checked)
								local channelInfo = C_ChatInfo.GetChannelInfoFromIdentifier(CHAT_CONFIG_TEXT_TO_SPEECH_CHANNEL_LIST[self:GetID()].channelName);
								TextToSpeechFrame_SetChannelEnabled(channelInfo, checked);
							end;
		count = count+1;
	end
end

COMBAT_CONFIG_TABS = {
	[1] = { text = MESSAGE_SOURCES, frame = "CombatConfigMessageSources" },
	[2] = { text = MESSAGE_TYPES, frame = "CombatConfigMessageTypes" },
	[3] = { text = COLORS, frame = "CombatConfigColors" },
	[4] = { text = FORMATTING, frame = "CombatConfigFormatting" },
	[5] = { text = SETTINGS, frame = "CombatConfigSettings" },
};
CHAT_CONFIG_COMBAT_TAB_NAME = "CombatConfigTab";
function ChatConfigCombat_OnLoad()
	-- Create tabs
	local tab;
	local tabName = CHAT_CONFIG_COMBAT_TAB_NAME;
	local name, text;
	for index, value in ipairs(COMBAT_CONFIG_TABS) do
		name = tabName..index;
		if ( not _G[name] ) then
			tab = CreateFrame("BUTTON", name, ChatConfigBackgroundFrame, "ChatConfigTabTemplate");
			if ( index > 1 ) then
				tab:SetPoint("BOTTOMLEFT", _G[tabName..(index-1)], "BOTTOMRIGHT", -1, 0);
			else
				tab:SetPoint("BOTTOMLEFT", ChatConfigBackgroundFrame, "TOPLEFT", 2, -1);
			end

			text = _G[name.."Text"];
			text:SetText(value.text);
			tab:SetID(index);
			PanelTemplates_TabResize(tab, 0);
		end
	end

	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("ConfigFilterButtonTemplate", function(button, elementData)
		ChatConfigCombat_InitButton(button, elementData);
	end);

	ScrollUtil.InitScrollBoxListWithScrollBar(ChatConfigCombatSettings.Filters.ScrollBox, ChatConfigCombatSettings.Filters.ScrollBar, view);
end

function ChatConfigCombatButton_OnClick(button, buttonName, down)
	ChatConfigFilter_OnClick(button:GetElementData().index);
end

function ChatConfigCombat_InitButton(button, elementData)
	local index = elementData.index;
	local text = elementData.filter.name;
	button.NormalText:SetText(text);
	button.name = text;
	if ( index == ChatConfigCombatSettingsFilters.selectedFilter ) then
		button:LockHighlight();
	else
		button:UnlockHighlight();
	end
end

function ChatConfigCombat_OnShow()
	ChatConfigBackgroundFrame:SetPoint("TOPLEFT", ChatConfigCategoryFrame, "TOPRIGHT", 1, -135);
	ChatConfig_ShowCombatTabs();
	UpdateDefaultButtons(true);
end

function ChatConfigCombat_OnHide()
	ChatConfigBackgroundFrame:SetPoint("TOPLEFT", ChatConfigCategoryFrame, "TOPRIGHT", 1, 0);
	ChatConfig_HideCombatTabs();
end

function ChatConfig_UpdateFilterList()
	local dataProvider = CreateDataProvider();
	for index, filter in ipairs(Blizzard_CombatLog_Filters.filters) do
		dataProvider:Insert{index=index, filter=filter};
	end

	ChatConfigCombatSettings.Filters.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);
	-- Update the combat log quick buttons
	Blizzard_CombatLog_Update_QuickButtons();
end

function ChatConfigFilter_OnClick(id)
	if ( #Blizzard_CombatLog_Filters.filters > 0 ) then
		ChatConfigCombatSettingsFilters.selectedFilter = id;
		CHATCONFIG_SELECTED_FILTER = Blizzard_CombatLog_Filters.filters[ChatConfigCombatSettingsFilters.selectedFilter];
	end
	ChatConfig_UpdateFilterList();
	ChatConfig_UpdateCombatSettings();
end

function ChatConfig_UpdateCombatSettings()
	if ( #Blizzard_CombatLog_Filters.filters == 0 ) then
		ChatConfigCombatSettingsFiltersCopyFilterButton:Disable();
		ChatConfigCombatSettingsFiltersDeleteButton:Disable();
		ChatConfig_UpdateCombatTabs(0);
		for index, value in ipairs(COMBAT_CONFIG_TABS) do
			_G[value.frame]:Hide();
		end
		return;
	elseif ( #Blizzard_CombatLog_Filters.filters == 1 ) then
		-- Don't allow them to delete the last filter for now
		ChatConfigCombatSettingsFiltersDeleteButton:Disable();
	else
		ChatConfigCombatSettingsFiltersCopyFilterButton:Enable();
		ChatConfigCombatSettingsFiltersDeleteButton:Enable();
	end
	if ( CanCreateFilters() ) then
		ChatConfigCombatSettingsFiltersAddFilterButton:Enable();
	else
		ChatConfigCombatSettingsFiltersAddFilterButton:Disable();
	end

	ChatConfig_UpdateCheckboxes(CombatConfigMessageSourcesDoneBy);
	ChatConfig_UpdateCheckboxes(CombatConfigMessageSourcesDoneTo);

	ChatConfig_UpdateTieredCheckboxFrame(CombatConfigMessageTypesLeft);
	ChatConfig_UpdateTieredCheckboxFrame(CombatConfigMessageTypesRight);
	ChatConfig_UpdateTieredCheckboxFrame(CombatConfigMessageTypesMisc);

	ChatConfig_UpdateSwatches(CombatConfigColorsUnitColors);
	CombatConfig_Colorize_Update();
	CombatConfig_Formatting_Update();
	CombatConfig_Settings_Update();

	CombatConfigSettingsNameEditBox:SetText(CHATCONFIG_SELECTED_FILTER.name);
end

function ChatConfig_UpdateChatSettings()
	ChatConfig_UpdateCheckboxes(ChatConfigChatSettingsLeft);
	-- Only do this if the ChannelSettings table has been created. It gets created OnShow()
	if ( ChatConfigChannelSettingsLeft.checkBoxTable ) then
		ChatConfig_UpdateCheckboxes(ChatConfigChannelSettingsLeft);
	end
	ChatConfig_UpdateCheckboxes(ChatConfigOtherSettingsCombat);
	ChatConfig_UpdateCheckboxes(ChatConfigOtherSettingsPVP);
	ChatConfig_UpdateCheckboxes(ChatConfigOtherSettingsSystem);
	ChatConfig_UpdateCheckboxes(ChatConfigOtherSettingsCreature);

	ChatConfigFrame.ChatTabManager:UpdateTabDisplay();
end

function ChatConfig_ResetChatSettings()
	C_ChatInfo.ResetDefaultZoneChannels();
	ChatConfig_UpdateChatSettings();
	ChatEdit_CheckUpdateNewcomerEditBoxHint();
end

function UsesGUID(direction)
	if not CHATCONFIG_SELECTED_FILTER then
		return false;
	end

	if ( direction == "SOURCE" and CHATCONFIG_SELECTED_FILTER.filters[1].sourceFlags ) then
		for k,v in pairs( CHATCONFIG_SELECTED_FILTER.filters[1].sourceFlags ) do
			if ( type(k) == "string" ) then
				return true;
			end
		end
	end
	if ( direction == "DEST" and CHATCONFIG_SELECTED_FILTER.filters[1].destFlags ) then
		for k,v in pairs( CHATCONFIG_SELECTED_FILTER.filters[1].destFlags ) do
			if ( type(k) == "string" ) then
				return true;
			end
		end
	end
	return false;
end

function IsMessageDoneBy(filter)
	local sourceFlags;
	if ( not CHATCONFIG_SELECTED_FILTER.filters[1].sourceFlags ) then
		return true;
	end
	sourceFlags = CHATCONFIG_SELECTED_FILTER.filters[1].sourceFlags;

	return sourceFlags[filter];
end

function IsMessageDoneTo(filter)
	local destFlags;

	if ( UsesGUID( "SOURCE" ) or UsesGUID("DEST") ) then
		if ( not CHATCONFIG_SELECTED_FILTER.filters[1].destFlags ) then
			return true;
		end
		destFlags = CHATCONFIG_SELECTED_FILTER.filters[1].destFlags;
	else

		destFlags = Blizzard_CombatLog_Filters.filters[ChatConfigCombatSettingsFilters.selectedFilter].filters[2].destFlags;
	end

	return destFlags[filter];
end

function HasMessageTypeGroup(checkBoxList, index)
	local subTypes = checkBoxList[index].subTypes;
	if ( subTypes ) then
		local state;
		for k, v in ipairs(subTypes) do
			state = GetMessageTypeState(v.type);
			if ( state == GRAY_CHECKED or state == UNCHECKED_DISABLED ) then
				return false;
			elseif ( state ) then --also catches UNCHECKED_ENABLED
				return true;
			end
		end
	end
	return false;
end

function HasMessageType(messageType)
	-- Only look at the first messageType passed in since we're treating them as a unit
	local isListening = GetMessageTypeState(messageType);
	if ( isListening == UNCHECKED_ENABLED or isListening == UNCHECKED_DISABLED ) then
		return false;
	elseif ( isListening ) then
		return true;
	else
		return false;
	end
end

function GetMessageTypeState(messageType)
	if ( type(messageType) == "table" ) then
		return CHATCONFIG_SELECTED_FILTER.filters[1].eventList[messageType[1]];
	else
		return CHATCONFIG_SELECTED_FILTER.filters[1].eventList[messageType];
	end
end

function ChatConfig_UpdateCombatTabs(selectedTabID)
	local tab, text, frame;
	for index, value in ipairs(COMBAT_CONFIG_TABS) do
		tab = _G[CHAT_CONFIG_COMBAT_TAB_NAME..index];
		text = _G[CHAT_CONFIG_COMBAT_TAB_NAME..index.."Text"];
		frame = _G[value.frame];
		if ( (not Blizzard_CombatLog_Filters) or #Blizzard_CombatLog_Filters.filters == 0 ) then
			tab:SetAlpha(0.75);
			text:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
		elseif ( index == selectedTabID ) then
			tab:SetAlpha(1.0);
			text:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			frame:Show();
		else
			tab:SetAlpha(0.75);
			text:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			frame:Hide();
		end

	end
end

function ChatConfig_ShowCombatTabs()
	for index, _ in ipairs(COMBAT_CONFIG_TABS) do
		_G[CHAT_CONFIG_COMBAT_TAB_NAME..index]:Show();
	end
end

function ChatConfig_HideCombatTabs()
	for index, _ in ipairs(COMBAT_CONFIG_TABS) do
		_G[CHAT_CONFIG_COMBAT_TAB_NAME..index]:Hide();
	end
end

function CombatConfig_CreateCombatFilter(name, filter)
	local newFilter;
	if ( not filter ) then
		newFilter = CopyTable(DEFAULT_COMBATLOG_FILTER_TEMPLATE);
	else
		newFilter = CopyTable(filter);
	end
	if ( not name or name == "" ) then
		name = format(DEFAULT_COMBATLOG_FILTER_NAME, #Blizzard_CombatLog_Filters.filters);
	end
	newFilter.name = name;
	newFilter.tooltip = "";
	tinsert(Blizzard_CombatLog_Filters.filters, newFilter);
	-- Scroll filters to top of list
	ChatConfigCombatSettingsFilters.ScrollBox:ScrollToBegin();
	-- Select the new filter
	ChatConfigFilter_OnClick(#Blizzard_CombatLog_Filters.filters);
	-- If creating a filter when there wasn't any before then update the tabs with the first one selected
	if ( #Blizzard_CombatLog_Filters.filters == 1 ) then
		ChatConfig_UpdateCombatTabs(1);
	end
end

function CombatConfig_DeleteCurrentCombatFilter()
	-- Don't allow deletion of all filters
	if ( #Blizzard_CombatLog_Filters.filters <= 1 ) then
		return;
	end
	tremove(Blizzard_CombatLog_Filters.filters, ChatConfigCombatSettingsFilters.selectedFilter);
	-- If the deleted filter comes before or is the selected filter, force the current filter to the first
	if ( ChatConfigCombatSettingsFilters.selectedFilter <= Blizzard_CombatLog_Filters.currentFilter ) then
		Blizzard_CombatLog_QuickButton_OnClick(1);
	end

	-- Scroll filters to top of list
	ChatConfigCombatSettingsFilters.ScrollBox:ScrollToBegin();
	-- Select the first filter
	ChatConfigFilter_OnClick(1);
end

function CombatConfig_SetCombatFiltersToDefault()
	Blizzard_CombatLog_Filters = CopyTable(Blizzard_CombatLog_Filter_Defaults);
	-- Have to call this because of the way the upvalues are setup in the combatlog
	Blizzard_CombatLog_RefreshGlobalLinks();
	Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.filters[1]
	ChatConfig_UpdateFilterList();
	ChatConfigFilter_OnClick(1);
	ChatConfig_UpdateCombatTabs(1);
end

function ChatConfig_MoveFilterUp()
	local selectedFilter = ChatConfigCombatSettingsFilters.selectedFilter;
	if ( selectedFilter == 1 ) then
		return;
	end
	local newIndex = selectedFilter-1;
	tinsert(Blizzard_CombatLog_Filters.filters, newIndex, CHATCONFIG_SELECTED_FILTER);
	tremove(Blizzard_CombatLog_Filters.filters, selectedFilter+1);
	if ( selectedFilter == Blizzard_CombatLog_Filters.currentFilter  ) then
		Blizzard_CombatLog_Filters.currentFilter = newIndex;
	elseif ( newIndex == Blizzard_CombatLog_Filters.currentFilter ) then
		Blizzard_CombatLog_Filters.currentFilter = Blizzard_CombatLog_Filters.currentFilter+1;
	end
	Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.filters[Blizzard_CombatLog_Filters.currentFilter];
	ChatConfigFilter_OnClick(newIndex);
end

function ChatConfig_MoveFilterDown()
	local selectedFilter = ChatConfigCombatSettingsFilters.selectedFilter;
	if ( selectedFilter >= #Blizzard_CombatLog_Filters.filters ) then
		selectedFilter = #Blizzard_CombatLog_Filters.filters;
		return;
	end
	local newIndex = selectedFilter+2;
	tinsert(Blizzard_CombatLog_Filters.filters, newIndex, CHATCONFIG_SELECTED_FILTER);
	tremove(Blizzard_CombatLog_Filters.filters, selectedFilter);
	if ( selectedFilter == Blizzard_CombatLog_Filters.currentFilter  ) then
		Blizzard_CombatLog_Filters.currentFilter = selectedFilter+1;
	elseif ( selectedFilter+1 == Blizzard_CombatLog_Filters.currentFilter ) then
		Blizzard_CombatLog_Filters.currentFilter = selectedFilter;
	end
	Blizzard_CombatLog_CurrentSettings = Blizzard_CombatLog_Filters.filters[Blizzard_CombatLog_Filters.currentFilter];
	ChatConfigFilter_OnClick(selectedFilter+1);
end

function ChatConfigCancel_OnClick()
	-- Copy the old settings back in place
	Blizzard_CombatLog_Filters = CopyTable(CHATCONFIG_SELECTED_FILTER_OLD_SETTINGS);
	-- Have to call this because of the way the upvalues are setup in the combatlog
	Blizzard_CombatLog_RefreshGlobalLinks();

	CHATCONFIG_SELECTED_FILTER = Blizzard_CombatLog_Filters.filters[ChatConfigCombatSettingsFilters.selectedFilter];
	-- Handle the case where the selected filter no longer exists!!!
	if ( not CHATCONFIG_SELECTED_FILTER ) then
		ChatConfigFilter_OnClick(1);
		HideUIPanel(ChatConfigFrame);
		return;
	end

	HideUIPanel(ChatConfigFrame);
end

function CanCreateFilters()
	if ( #Blizzard_CombatLog_Filters.filters == MAX_COMBATLOG_FILTERS ) then
		return false;
	end
	return true;
end

function ChatConfigFrame_PlayCheckboxSound (checked)
	if ( checked ) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
end

function ChatConfigCategoryFrame_Refresh(preserveCategorySelection)
	local currentChatFrame = FCF_GetCurrentChatFrame();
	local isTextToSpeech = CURRENT_CHAT_FRAME_ID == VOICE_WINDOW_ID;

	if ( not isTextToSpeech and currentChatFrame ~= nil and IsCombatLog(currentChatFrame) ) then
		ChatConfigCategoryFrameButton2:Show();
		ChatConfigCategoryFrameButton3:SetPoint("TOPLEFT", ChatConfigCategoryFrameButton2, "BOTTOMLEFT", 0, -1);
		ChatConfigCategoryFrameButton3:SetPoint("TOPRIGHT", ChatConfigCategoryFrameButton2, "BOTTOMRIGHT", 0, -1);
	else
		ChatConfigCategoryFrameButton2:Hide();
		ChatConfigCategoryFrameButton3:SetPoint("TOPLEFT", ChatConfigCategoryFrameButton1, "BOTTOMLEFT", 0, -1);
		ChatConfigCategoryFrameButton3:SetPoint("TOPRIGHT", ChatConfigCategoryFrameButton1, "BOTTOMRIGHT", 0, -1);
	end

	ChatConfigCategoryFrameButton1:SetShown(not isTextToSpeech);
	ChatConfigCategoryFrameButton3:SetShown(not isTextToSpeech);
	ChatConfigCategoryFrameButton4:SetShown(not isTextToSpeech);

	ChatConfigCategoryFrameButton5:SetShown(isTextToSpeech);
	ChatConfigCategoryFrameButton6:SetShown(isTextToSpeech);
	ChatConfigCategoryFrameButton7:SetShown(isTextToSpeech);

	if ( isTextToSpeech ) then
		ChatConfigCategory_OnClick(ChatConfigCategoryFrameButton5);
	elseif ( currentChatFrame ~= nil and IsCombatLog(currentChatFrame) ) then
		ChatConfigCategory_OnClick(ChatConfigCategoryFrameButton2);
	elseif ( 
		not preserveCategorySelection 
		or _G[CHAT_CONFIG_CATEGORIES[2]]:IsShown() 
		or _G[CHAT_CONFIG_CATEGORIES[5]]:IsShown() 
		or _G[CHAT_CONFIG_CATEGORIES[6]]:IsShown() 
		or _G[CHAT_CONFIG_CATEGORIES[7]]:IsShown() 
	) then
		ChatConfigCategory_OnClick(ChatConfigCategoryFrameButton1);
	end

	if ( isTextToSpeech ) then
		ChatConfigFrame.Header:Setup(TEXT_TO_SPEECH_CONFIG);
	else
		ChatConfigFrame.Header:Setup(currentChatFrame ~= nil and CHATCONFIG_HEADER:format(currentChatFrame.name) or "");
	end
	ChatConfigCategory_UpdateEnabled();
end

function ChatConfig_RefreshCurrentChatCategory(preserveCategorySelection)
	if _G[CHAT_CONFIG_CATEGORIES[1]]:IsShown() then
		ChatConfigChatSettings_UpdateCheckboxes();
	-- The combat category is only in 1 chat frame so we don't need to update its checkboxes on a refresh.
	--elseif _G[CHAT_CONFIG_CATEGORIES[2]]:IsShown() then
	elseif _G[CHAT_CONFIG_CATEGORIES[3]]:IsShown() then
		ChatConfigChannelSettings_UpdateCheckboxes();
	elseif _G[CHAT_CONFIG_CATEGORIES[4]]:IsShown() then
		ChatConfigOtherSettings_UpdateCheckboxes();
	end

	ChatConfigCategoryFrame_Refresh(preserveCategorySelection);
end
function ChatConfigChatSettings_UpdateCheckboxes()
	ChatConfig_UpdateCheckboxes(ChatConfigChatSettingsLeft);
end

function ChatConfigChatSettings_OnShow()
	ChatConfigChatSettings_UpdateCheckboxes();
	UpdateDefaultButtons(false);
end

function ChatConfigChannelSettings_UpdateCheckboxes()
	CreateChatChannelList(ChatConfigChannelSettings, GetChannelList());
	ChatConfig_CreateCheckboxes(ChatConfigChannelSettingsLeft, CHAT_CONFIG_CHANNEL_LIST, "MovableChatConfigWideCheckBoxWithSwatchTemplate", CHAT_CONFIG_CHANNEL_SETTINGS_TITLE_WITH_DRAG_INSTRUCTIONS);
	ChatConfig_UpdateCheckboxes(ChatConfigChannelSettingsLeft);
	ChatConfigChannelSettingsLeft:UpdateStates();
end

function ChatConfigChannelSettings_OnShow()
	ChatConfigChannelSettings_UpdateCheckboxes();
	UpdateDefaultButtons(false);
end

local ChannelTypeFormat = "CHANNEL%d";
function ChatConfigChannelSettings_SwapChannelsByIndex(firstChannelIndex, secondChannelIndex)
	local firstChatType = ChannelTypeFormat:format(firstChannelIndex);
	local secondChatType = ChannelTypeFormat:format(secondChannelIndex);
	local firstTypeInfo = ChatTypeInfo[firstChatType];
	local secondTypeInfo = ChatTypeInfo[secondChatType];
	ChatTypeInfo[firstChatType] = secondTypeInfo;
	ChatTypeInfo[secondChatType] = firstTypeInfo;
	C_ChatInfo.SwapChatChannelsByChannelIndex(firstChannelIndex, secondChannelIndex);
	ChatConfigChannelSettings_UpdateCheckboxes();
end

function ChatConfigChannelSettings_MoveChannelDown(channelIndex)
	if channelIndex == #CHAT_CONFIG_CHANNEL_LIST then
		return;
	end

	ChatConfigChannelSettings_SwapChannelsByIndex(channelIndex, channelIndex + 1)
end

function ChatConfigChannelSettings_MoveChannelUp(channelIndex)
	if channelIndex == 1 then
		return;
	end

	ChatConfigChannelSettings_SwapChannelsByIndex(channelIndex, channelIndex - 1)
end

function ChatConfigOtherSettings_UpdateCheckboxes()
	ChatConfig_UpdateCheckboxes(ChatConfigOtherSettingsCombat);
	ChatConfig_UpdateCheckboxes(ChatConfigOtherSettingsPVP);
	ChatConfig_UpdateCheckboxes(ChatConfigOtherSettingsSystem);
	ChatConfig_UpdateCheckboxes(ChatConfigOtherSettingsCreature);
end

function ChatConfigOtherSettings_OnShow()
	ChatConfigOtherSettings_UpdateCheckboxes();
	UpdateDefaultButtons(false);
end

function ChatConfigTextToSpeechSettings_OnShow()
	UpdateDefaultButtons(false, true);
end

function ChatConfigTextToSpeechChannelSettings_UpdateCheckboxes()
	CreateChatTextToSpeechChannelList(ChatConfigTextToSpeechChannelSettings, GetChannelList());
	ChatConfig_CreateCheckboxes(ChatConfigTextToSpeechChannelSettingsLeft, CHAT_CONFIG_TEXT_TO_SPEECH_CHANNEL_LIST, "ChatConfigCheckBoxSmallTemplate", CHANNELS);
	ChatConfig_UpdateCheckboxes(ChatConfigTextToSpeechChannelSettingsLeft);
end

function ChatConfigTextToSpeechChannelSettings_OnShow()
	ChatConfigTextToSpeechChannelSettings_UpdateCheckboxes();
	UpdateDefaultButtons(false, true);
end

function ChatConfigFrameDefaultButton_OnClick()
	FCF_ResetAllWindows();
end

function ChatConfigFrameRedockButton_OnClick()
	FCF_RedockAllWindows();
end

function ChatConfigFrameRedockButton_OnLoad(self)
	self:SetWidth(self:GetTextWidth() + 31);
end

function ChatConfigFrameToggleChatButton_OnClick()
	local newDisabled = not C_SocialRestrictions.IsChatDisabled();
	if newDisabled then
		StaticPopup_Show("CHAT_CONFIG_DISABLE_CHAT");
	else
		C_SocialRestrictions.SetChatDisabled(newDisabled);
		ChatConfigFrame_OnChatDisabledChanged(newDisabled);
	end
end

function ChatConfigFrame_OnChatDisabledChanged(disabled)
	ChatConfigFrameToggleChatButton_UpdateAccountChatDisabled(disabled);
	ChatConfigFrame_ReplaceChatConfigLeftTooltips(disabled);
	ChatConfig_UpdateCheckboxes(ChatConfigChatSettingsLeft);
	
	if disabled then
		local unsubscribe = true;
		C_Club.UnfocusAllStreams(unsubscribe);
	else
		C_Club.FocusCommunityStreams();
	end

	EventRegistry:TriggerEvent("AccountInfo.ChatDisabled", disabled);
end

function ChatConfigFrame_ReplaceChatConfigLeftTooltips(disabled)
	if disabled then
		local tooltip = string.format(RESTRICT_CHAT_CONFIG_TOOLTIP, RESTRICT_CHAT_CONFIG_ENABLE);
		for index, tbl in pairs(CHAT_CONFIG_CHAT_LEFT) do
			if tbl.disabled ~= nil then
				tbl.tooltip = tooltip;
			end
		end
	else
		for index, tbl in pairs(CHAT_CONFIG_CHAT_LEFT) do
			tbl.tooltip = nil;
		end
	end
end

function ChatConfigFrameToggleChatButton_UpdateAccountChatDisabled(disabled)
	local button = ChatConfigFrame.ToggleChatButton;
	button:SetText(disabled and RESTRICT_CHAT_CONFIG_ENABLE or RESTRICT_CHAT_CONFIG_DISABLE);
	button:SetWidth(button:GetTextWidth() + 31);
end

ChatWindowTabMixin = {};

function ChatWindowTabMixin:OnClick()
	self:GetParent():UpdateSelection(self:GetID());
end

function ChatWindowTabMixin:SetChatWindowIndex(chatWindowIndex)
	self:SetID(chatWindowIndex);
	if chatWindowIndex ~= VOICE_WINDOW_ID then
		local chatTab = _G["ChatFrame"..chatWindowIndex.."Tab"];
		self.Text:SetText(chatTab.Text:GetText());
	else
		self.Text:SetText(TEXT_TO_SPEECH)
	end
end

function ChatWindowTabMixin:UpdateWidth()
	local maxTabWidth = self:GetParent():GetMaxTabWidth();
	local maxWidth = (maxTabWidth ~= nil) and (maxTabWidth - 32) or nil;
	PanelTemplates_TabResize(self, 0, nil, maxWidth, maxWidth, self.Text:GetUnboundedStringWidth());
end

ChatConfigFrameTabManagerMixin = {};

local CHAT_TAB_MANAGER_SPACE = 24;

function ChatConfigFrameTabManagerMixin:OnLoad()
	self.tabPool = CreateFramePool("BUTTON", self, "ChatWindowTab");
end

function ChatConfigFrameTabManagerMixin:OnShow()
	self:UpdateTabDisplay();
end

function ChatConfigFrameTabManagerMixin:UpdateTabDisplay()
	self.tabPool:ReleaseAll();

	local lastTab = nil;
	local tabCount = FCF_GetNumActiveChatFrames();
	
	--This is needed to properly skip or include the TTS config tab
	local showTTSConfigTab = GetCVarBool("textToSpeech") or GetCVarBool("remoteTextToSpeech")
	if ( GetCVarBool("textToSpeech") and not GetCVarBool("remoteTextToSpeech") ) then
		tabCount = tabCount + 1;
	end

	for i = 1, tabCount do

		--Skip over the reserved TTS config tab if we aren't showing it. This assumes TTS tab is the last of the reserved tabs.
		local offset = 0;
		if(not showTTSConfigTab and i >= VOICE_WINDOW_ID) then
			offset = 1;
		end

		local tab = self.tabPool:Acquire();
		tab:SetChatWindowIndex(i + offset);
		if lastTab then
			tab:SetPoint("LEFT", lastTab, "RIGHT");
		else
			tab:SetPoint("BOTTOMLEFT", self, "TOPLEFT");
		end

		tab:Show();
		lastTab = tab;
	end

	self:UpdateSelection(CURRENT_CHAT_FRAME_ID);
	self:UpdateWidth();
end

function ChatConfigFrameTabManagerMixin:UpdateSelection(selectedChatWindowIndex)
	CURRENT_CHAT_FRAME_ID = selectedChatWindowIndex;

	local preserveCategorySelection = true;
	ChatConfig_RefreshCurrentChatCategory(preserveCategorySelection);

	for tab in self.tabPool:EnumerateActive() do
		FCFTab_UpdateColors(tab, tab:GetID() == selectedChatWindowIndex);
	end
end

function ChatConfigFrameTabManagerMixin:UpdateWidth(selectedChatWindowIndex)
	self.currentWidth = 0;
	for tab in self.tabPool:EnumerateActive() do
		tab:UpdateWidth();
	end

	self:CalculateCurrentWidth();

	for tab in self.tabPool:EnumerateActive() do
		tab:UpdateWidth();
	end
end

function ChatConfigFrameTabManagerMixin:GetMaxTabWidth()
	local maxWidth = self:GetParent():GetWidth() - CHAT_TAB_MANAGER_SPACE;
	if self:GetCurrentWidth() <= maxWidth then
		return nil;
	end

	return maxWidth / self.tabPool:GetNumActive();
end

function ChatConfigFrameTabManagerMixin:GetCurrentWidth()
	return self.currentWidth;
end

function ChatConfigFrameTabManagerMixin:CalculateCurrentWidth()
	local currentWidth = CHAT_TAB_MANAGER_SPACE;
	for tab in self.tabPool:EnumerateActive() do
		currentWidth = currentWidth + tab:GetWidth();
	end

	self.currentWidth = currentWidth;
end

ChatConfigWideCheckBoxManagerMixin = {};

function ChatConfigWideCheckBoxManagerMixin:OnUpdate(dt)
	if self.movingIndex > #CHAT_CONFIG_CHANNEL_LIST then
		self:StopMovingEntry();
	end

	if not IsMouseButtonDown() or self.movingIndex == nil then
		self:StopMovingEntry();
		return;
	end

	local movingEntry = self:GetMovingEntry();
	if self.movingIndex ~= nil and movingEntry == nil then
		return;
	end

	local cursorY = select(2, GetScaledCursorPosition());
	local top = self:GetTop();
	local bottom = self:GetBottom();
	local centerY = select(2, movingEntry:GetCenter()) * movingEntry:GetScale();
	local height = movingEntry:GetHeight() * movingEntry:GetScale();
	local tooFarUp = top - movingEntry:GetTop() < height / 4;
	local tooFarDown = movingEntry:GetBottom() - bottom < height;

	local distanceToMove = height / 1.7;
	if cursorY - centerY > distanceToMove and not tooFarUp then
		if self.movingIndex > 1 then
			ChatConfigChannelSettings_MoveChannelUp(self.movingIndex);
			self.movingIndex = self.movingIndex - 1;
			self:UpdateStates();
		end
	elseif centerY - cursorY > distanceToMove and not tooFarDown then
		if self.movingIndex < #CHAT_CONFIG_CHANNEL_LIST then
			ChatConfigChannelSettings_MoveChannelDown(self.movingIndex);
			self.movingIndex = self.movingIndex + 1;
			self:UpdateStates();
			self:UpdateStates();
		end
	end
end

function ChatConfigWideCheckBoxManagerMixin:UpdateStates()
	if not self.movingIndex then
		for i, button in ipairs(self.WideCheckBoxes) do
			button:SetState(ChatConfigWideCheckBoxState.Normal);
		end

		return;
	end

	for i, button in ipairs(self.WideCheckBoxes) do
		if button:GetID() == self.movingIndex then
			button:SetState(ChatConfigWideCheckBoxState.Normal);
		else
			button:SetState(ChatConfigWideCheckBoxState.GrayedOut);
		end
	end
end

function ChatConfigWideCheckBoxManagerMixin:StartMovingEntry(index)
	self.movingIndex = index;
	self:SetScript("OnUpdate", ChatConfigWideCheckBoxManagerMixin.OnUpdate);
	self:UpdateStates();
end

function ChatConfigWideCheckBoxManagerMixin:StopMovingEntry()
	self.movingIndex = nil;
	self:SetScript("OnUpdate", nil);
	self:UpdateStates();

	ChatEdit_CheckUpdateNewcomerEditBoxHint();
end

function ChatConfigWideCheckBoxManagerMixin:GetMovingEntry()
	if self.movingIndex == nil then
		return nil;
	end

	for i, button in ipairs(self.WideCheckBoxes) do
		if button:GetID() == self.movingIndex then
			return button;
		end
	end

	return nil;
end

ChatConfigWideCheckBoxMixin = {};

ChatConfigWideCheckBoxState = {
	Normal = 1,
	GrayedOut = 2,
};

function ChatConfigWideCheckBoxMixin:OnLoad()
	self.CheckButton:SetHitRectInsets(0, 0, 0, 0);
	self:RegisterForDrag("LeftButton");
	self.CheckButton.Text:SetPoint("LEFT", self.CheckButton, "RIGHT", 1, 1);
end

function ChatConfigWideCheckBoxMixin:SetState(state)
	self.ArtOverlay.GrayedOut:SetShown(state == ChatConfigWideCheckBoxState.GrayedOut);

	-- Allow certain rulesets to modify state behavior
	local isEnabled = self:GetChannelRuleset() == Enum.ChatChannelRuleset.None;
	self.CloseChannel:SetEnabled(isEnabled);
	local desaturation = 0;
	if not isEnabled then
		desaturation = 1;
	end

	self.CloseChannel:DesaturateHierarchy(desaturation);
end

function ChatConfigWideCheckBoxMixin:GetChannelIndex()
	local channelIndex = self:GetID();
	local channelData = CHAT_CONFIG_CHANNEL_LIST[channelIndex];
	return channelData and channelData.channelID or nil;
end

function ChatConfigWideCheckBoxMixin:GetChannelRuleset()
	local channelIndex = self:GetChannelIndex();
	return channelIndex and C_ChatInfo.GetChannelRuleset(channelIndex) or Enum.ChatChannelRuleset.None;
end

function ChatConfigWideCheckBoxMixin:OnDragStart()
	self:GetParent():StartMovingEntry(self:GetID());
end

function ChatConfigWideCheckBoxMixin:LeaveChannel()
	local channelIndex = self:GetID();
	if CHAT_CONFIG_CHANNEL_LIST[channelIndex].isBlank then
		for i = channelIndex, #CHAT_CONFIG_CHANNEL_LIST - 1 do
			ChatConfigChannelSettings_SwapChannelsByIndex(i, i + 1);
		end
	else
		LeaveChannelByLocalID(CHAT_CONFIG_CHANNEL_LIST[channelIndex].channelID);
		if channelIndex == #CHAT_CONFIG_CHANNEL_LIST then
			CHAT_CONFIG_CHANNEL_LIST[channelIndex] = nil;
		else
			CHAT_CONFIG_CHANNEL_LIST[channelIndex] = {};
			CHAT_CONFIG_CHANNEL_LIST[channelIndex].channelID = channelIndex;
			CHAT_CONFIG_CHANNEL_LIST[channelIndex].text = channelIndex..".";
			CHAT_CONFIG_CHANNEL_LIST[channelIndex].isBlank = true;
		end
	end

	ChatConfigChannelSettings_UpdateCheckboxes();
end

TextToSpeechCharacterSpecificButtonMixin = {};

function TextToSpeechCharacterSpecificButtonMixin:OnLoad()
	local descriptionText = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(CHARACTER_SPECIFIC_SETTINGS);
	self.Text:SetText(descriptionText);
	self.Text:SetFontObject(GameFontNormal);
end

function TextToSpeechCharacterSpecificButtonMixin:OnShow()
	local checked = GetCVarBool("TTSUseCharacterSettings");
	self:SetChecked(checked);
end

function TextToSpeechCharacterSpecificButtonMixin:OnClick(button, down)
	local checked = self:GetChecked();
	if (checked) then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF);
	end
	
	SetCVar("TTSUseCharacterSettings", checked);
	TextToSpeechFrame_Update(TextToSpeechFrame);
end

function TextToSpeechCharacterSpecificButtonMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(CHARACTER_SPECIFIC_SETTINGS_TOOLTIP, nil, nil, nil, nil, true);
end

function TextToSpeechCharacterSpecificButtonMixin:OnHide()
	GameTooltip_Hide();
end
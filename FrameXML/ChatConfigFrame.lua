COMBATLOG_FILTERS_TO_DISPLAY = 4;
CHATCONFIG_FILTER_HEIGHT = 16;
GRAY_CHECKED = 1;
CHATCONFIG_SELECTED_FILTER = 0;
CHATCONFIG_SELECTED_FILTER_FILTERS = 0;
CHATCONFIG_SELECTED_FILTER_COLORS = 0;
CHATCONFIG_SELECTED_FILTER_SETTINGS = 0;

--Chat options
CHAT_CONFIG_CHAT_RIGHT = {
	[1] = {
		type = "PARTY",
		checked = function () return IsListeningForMessageType("PARTY"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "PARTY"); end;
	},
	[2] = {
		type = "RAID",
		checked = function () return IsListeningForMessageType("RAID"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "RAID"); end;
	},
	[3] = {
		type = "RAID_LEADER",
		checked = function () return IsListeningForMessageType("RAID_LEADER"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "RAID_LEADER"); end;
	},
	[4] = {
		type = "RAID_WARNING",
		checked = function () return IsListeningForMessageType("RAID_WARNING"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "RAID_WARNING"); end;
	},
	[5] = {
		type = "BATTLEGROUND",
		checked = function () return IsListeningForMessageType("BATTLEGROUND"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "BATTLEGROUND"); end;
	},
	[6] = {
		type = "BATTLEGROUND_LEADER",
		checked = function () return IsListeningForMessageType("BATTLEGROUND_LEADER"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "BATTLEGROUND_LEADER"); end;
	}
};

CHAT_CONFIG_CHAT_LEFT = {
	[1] = {
		type = "SAY",
		checked = function () return IsListeningForMessageType("SAY"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "SAY"); end;
	},
	[2] = {
		type = "EMOTE",
		checked = function () return IsListeningForMessageType("EMOTE"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "EMOTE"); end;
	},
	[3] = {
		type = "YELL",
		checked = function () return IsListeningForMessageType("YELL"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "YELL"); end;
	},
	[4] = {
		text = GUILD_CHAT,
		type = "GUILD",
		checked = function () return IsListeningForMessageType("GUILD"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "GUILD"); end;
	},
	[5] = {
		text = OFFICER_CHAT,
		type = "GUILD_OFFICER",
		checked = function () return IsListeningForMessageType("GUILD_OFFICER"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "GUILD_OFFICER"); end;
	},
	[6] = {
		type = "WHISPER",
		checked = function () return IsListeningForMessageType("WHISPER"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "WHISPER"); end;
	}
};

CHAT_CONFIG_OTHER_COMBAT = {
	[1] = {
		type = "COMBAT_XP_GAIN",
		checked = function () return IsListeningForMessageType("COMBAT_XP_GAIN"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "COMBAT_XP_GAIN"); end;
	},
	[2] = {
		type = "COMBAT_HONOR_GAIN",
		checked = function () return IsListeningForMessageType("COMBAT_HONOR_GAIN"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "COMBAT_HONOR_GAIN"); end;
	},
	[3] = {
		type = "COMBAT_FACTION_CHANGE",
		checked = function () return IsListeningForMessageType("COMBAT_FACTION_CHANGE"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "COMBAT_FACTION_CHANGE"); end;
	},
	[4] = {
		text = SKILLUPS,
		type = "SKILL",
		checked = function () return IsListeningForMessageType("SKILL"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "SKILL"); end;
	},
	[5] = {
		text = MONEY_LOOT,
		type = "MONEY",
		checked = function () return IsListeningForMessageType("MONEY"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "MONEY"); end;
	},
	[6] = {
		type = "TRADESKILLS",
		checked = function () return IsListeningForMessageType("TRADESKILLS"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "TRADESKILLS"); end;
	},
	[7] = {
		type = "OPENING",
		checked = function () return IsListeningForMessageType("OPENING"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "OPENING"); end;
	},
	[8] = {
		type = "PET_INFO",
		checked = function () return IsListeningForMessageType("PET_INFO"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "PET_INFO"); end;
	},
	[9] = {
		type = "COMBAT_MISC_INFO",
		checked = function () return IsListeningForMessageType("COMBAT_MISC_INFO"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "COMBAT_MISC_INFO"); end;
	},
};

CHAT_CONFIG_OTHER_PVP = {
	[1] = {
		type = "BG_HORDE",
		checked = function () return IsListeningForMessageType("BG_HORDE"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "BG_HORDE"); end;
	},
	[2] = {
		type = "BG_ALLIANCE",
		checked = function () return IsListeningForMessageType("BG_ALLIANCE"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "BG_ALLIANCE"); end;
	},
	[3] = {
		type = "BG_NEUTRAL",
		checked = function () return IsListeningForMessageType("BG_NEUTRAL"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "BG_NEUTRAL"); end;
	},
}

CHAT_CONFIG_OTHER_SYSTEM = {
	[1] = {
		text = SYSTEM_MESSAGES,
		type = "SYSTEM",
		checked = function () return IsListeningForMessageType("SYSTEM"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "SYSTEM"); end;
	},
	[2] = {
		type = "ERRORS",
		checked = function () return IsListeningForMessageType("ERRORS"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "ERRORS"); end;
	},
	[3] = {
		type = "AFK",
		checked = function () return IsListeningForMessageType("AFK"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "AFK"); end;
	},
	[4] = {
		type = "DND",
		checked = function () return IsListeningForMessageType("DND"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "DND"); end;
	},
	[5] = {
		type = "IGNORED",
		checked = function () return IsListeningForMessageType("IGNORED"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "IGNORED"); end;
	},
	[6] = {
		type = "CHANNEL",
		checked = function () return IsListeningForMessageType("CHANNEL"); end;
		func = function (checked) ToggleChatMessageGroup(checked, "CHANNEL"); end;
	},
}

CHAT_CONFIG_CHANNEL_LIST = {};

-- Combat Options
COMBAT_CONFIG_MESSAGESOURCES_BY = {
	[1] = {
		text = COMBATLOG_FILTER_ME,
		checked = function () return IsMessageDoneBy(COMBATLOG_FILTER_MINE); end;
		func = function (checked) ToggleMessageSource(checked, COMBATLOG_FILTER_MINE); end;
		tooltip = FILTER_BY_ME_COMBATLOG_TOOLTIP;
	},
	[2] = {
		text = COMBATLOG_FILTER_MY_PET,
		checked = function () return IsMessageDoneBy(COMBATLOG_FILTER_MY_PET); end;
		func = function (checked) ToggleMessageSource(checked, COMBATLOG_FILTER_MY_PET); end;
		tooltip = FILTER_BY_PET_COMBATLOG_TOOLTIP;
	},
	[3] = {
		text = COMBATLOG_FILTER_FRIENDLY_UNITS,
		checked = function () return IsMessageDoneBy(COMBATLOG_FILTER_FRIENDLY_UNITS); end;
		func = function (checked) ToggleMessageSource(checked, COMBATLOG_FILTER_FRIENDLY_UNITS); end;
		tooltip = FILTER_BY_FRIENDS_COMBATLOG_TOOLTIP;
	},
	[4] = {
		text = COMBATLOG_FILTER_HOSTILE_UNITS,
		checked = function () return IsMessageDoneBy(COMBATLOG_FILTER_HOSTILE_UNITS); end;
		func = function (checked) ToggleMessageSource(checked, COMBATLOG_FILTER_HOSTILE_UNITS); end;
		tooltip = FILTER_BY_ENEMIES_COMBATLOG_TOOLTIP;
	},
	[5] = {
		text = COMBATLOG_FILTER_NEUTRAL_UNITS,
		checked = function () return IsMessageDoneBy(COMBATLOG_FILTER_NEUTRAL_UNITS); end;
		func = function (checked) ToggleMessageSource(checked, COMBATLOG_FILTER_NEUTRAL_UNITS); end;
		tooltip = FILTER_BY_NEUTRAL_COMBATLOG_TOOLTIP;
	},
	[6] = {
		text = COMBATLOG_FILTER_UNKNOWN_UNITS,
		checked = function () return IsMessageDoneBy(COMBATLOG_FILTER_UNKNOWN_UNITS); end;
		func = function (checked) ToggleMessageSource(checked, COMBATLOG_FILTER_UNKNOWN_UNITS); end;
		tooltip = FILTER_BY_UNKNOWN_COMBATLOG_TOOLTIP;
	},
}

COMBAT_CONFIG_MESSAGESOURCES_TO = {
	[1] = {
		text = COMBATLOG_FILTER_ME,
		checked = function () return IsMessageDoneTo(COMBATLOG_FILTER_MINE); end;
		func = function (checked) ToggleMessageDest(checked, COMBATLOG_FILTER_MINE); end;
		tooltip = FILTER_TO_ME_COMBATLOG_TOOLTIP;
	},
	[2] = {
		text = COMBATLOG_FILTER_MY_PET,
		checked = function () return IsMessageDoneTo(COMBATLOG_FILTER_MY_PET); end;
		func = function (checked) ToggleMessageDest(checked, COMBATLOG_FILTER_MY_PET); end;
		tooltip = FILTER_TO_PET_COMBATLOG_TOOLTIP;
	},
	[3] = {
		text = COMBATLOG_FILTER_FRIENDLY_UNITS,
		checked = function () return IsMessageDoneTo(COMBATLOG_FILTER_FRIENDLY_UNITS); end;
		func = function (checked) ToggleMessageDest(checked, COMBATLOG_FILTER_FRIENDLY_UNITS); end;
		tooltip = FILTER_TO_FRIENDS_COMBATLOG_TOOLTIP;
	},
	[4] = {
		text = COMBATLOG_FILTER_HOSTILE_UNITS,
		checked = function () return IsMessageDoneTo(COMBATLOG_FILTER_HOSTILE_UNITS); end;
		func = function (checked) ToggleMessageDest(checked, COMBATLOG_FILTER_HOSTILE_UNITS); end;
		tooltip = FILTER_TO_HOSTILE_COMBATLOG_TOOLTIP;
	},
	[5] = {
		text = COMBATLOG_FILTER_NEUTRAL_UNITS,
		checked = function () return IsMessageDoneTo(COMBATLOG_FILTER_NEUTRAL_UNITS); end;
		func = function (checked) ToggleMessageDest(checked, COMBATLOG_FILTER_NEUTRAL_UNITS); end;
		tooltip = FILTER_TO_NEUTRAL_COMBATLOG_TOOLTIP;
	},
	[6] = {
		text = COMBATLOG_FILTER_UNKNOWN_UNITS,
		checked = function () return IsMessageDoneTo(COMBATLOG_FILTER_UNKNOWN_UNITS); end;
		func = function (checked) ToggleMessageDest(checked, COMBATLOG_FILTER_UNKNOWN_UNITS); end;
		tooltip = FILTER_TO_UNKNOWN_COMBATLOG_TOOLTIP;
	},
}

COMBAT_CONFIG_MESSAGETYPES_LEFT = {
	[1] = {
		text = MELEE,
		checked = function () return HasMessageTypeGroup("COMBAT_CONFIG_MESSAGETYPES_LEFT", 1) end;
		func = function (checked) ToggleMessageTypeGroup(checked, "CombatConfigMessageTypesLeft", 1) end;
		tooltip = MELEE_COMBATLOG_TOOLTIP,
		subTypes = {
			[1] = {
				text = DAMAGE,
				type = "SWING_DAMAGE",
				checked = function () return HasMessageType("SWING_DAMAGE"); end;
				func = function (checked) return ToggleMessageType(checked, "SWING_DAMAGE") end;
				tooltip = SWING_DAMAGE_COMBATLOG_TOOLTIP;
			},
			[2] = {
				text = MISSES,
				type = "SWING_MISSED",
				checked = function () return HasMessageType("SWING_MISSED"); end;
				func = function (checked) return ToggleMessageType(checked, "SWING_MISSED"); end;
				tooltip = SWING_MISSED_COMBATLOG_TOOLTIP;
			},
		}
	},
	[2] = {
		text = RANGED,
		checked = function () return HasMessageTypeGroup("COMBAT_CONFIG_MESSAGETYPES_LEFT", 2) end;
		func = function (checked) ToggleMessageTypeGroup(checked, "CombatConfigMessageTypesLeft", 2) end;
		tooltip = RANGED_COMBATLOG_TOOLTIP,
		subTypes = {
			[1] = {
				text = DAMAGE,
				type = "RANGE_DAMAGE",
				checked = function () return HasMessageType("RANGE_DAMAGE"); end;
				func = function (checked) return ToggleMessageType(checked, "RANGE_DAMAGE"); end;
				tooltip = RANGE_DAMAGE_COMBATLOG_TOOLTIP;
			},
			[2] = {
				text = MISSES,
				type = "RANGE_MISSED",
				checked = function () return HasMessageType("RANGE_MISSED"); end;
				func = function (checked) return ToggleMessageType(checked, "RANGE_MISSED"); end;
				tooltip = RANGE_MISSED_COMBATLOG_TOOLTIP;
			},
		}
	},
	[3] = {
		text = AURAS,
		checked = function () return HasMessageTypeGroup("COMBAT_CONFIG_MESSAGETYPES_LEFT", 3) end;
		func = function (checked) ToggleMessageTypeGroup(checked, "CombatConfigMessageTypesLeft", 3) end;
		tooltip = AURAS_COMBATLOG_TOOLTIP,
		subTypes = {
			[1] = {
				text = BENEFICIAL,
				type = {"SPELL_AURA_APPLIED", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_APPLIED_REMOVED", "SPELL_AURA_APPLIED_REMOVED_DOSE"};
				checked = function () return not CHATCONFIG_SELECTED_FILTER_FILTERS[1].hideBuffs end;
				func = function (checked) 
					if ( checked ) then
						CHATCONFIG_SELECTED_FILTER_FILTERS[1].hideBuffs = false;
						ToggleMessageType(checked, "SPELL_AURA_APPLIED", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_APPLIED_REMOVED", "SPELL_AURA_APPLIED_REMOVED_DOSE");
					else
						CHATCONFIG_SELECTED_FILTER_FILTERS[1].hideBuffs = true;
						-- Only stop listening for the messages if hideDebuffs is also true
						if ( CHATCONFIG_SELECTED_FILTER_FILTERS[1].hideDebuffs ) then
							ToggleMessageType(checked, "SPELL_AURA_APPLIED", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_APPLIED_REMOVED", "SPELL_AURA_APPLIED_REMOVED_DOSE");
						end
					end
				end;
				tooltip = BENEFICIAL_AURA_COMBATLOG_TOOLTIP;
			},
			[2] = {
				text = HOSTILE,
				type = {"SPELL_AURA_APPLIED", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_APPLIED_REMOVED", "SPELL_AURA_APPLIED_REMOVED_DOSE"};
				checked = function () return not CHATCONFIG_SELECTED_FILTER_FILTERS[1].hideDebuffs end;
				func = function (checked) 
					if ( checked ) then
						CHATCONFIG_SELECTED_FILTER_FILTERS[1].hideDebuffs = false;
						ToggleMessageType(checked, "SPELL_AURA_APPLIED", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_APPLIED_REMOVED", "SPELL_AURA_APPLIED_REMOVED_DOSE");
					else
						CHATCONFIG_SELECTED_FILTER_FILTERS[1].hideDebuffs = true;
						-- Only stop listening for the messages if hideDebuffs is also true
						if ( CHATCONFIG_SELECTED_FILTER_FILTERS[1].hideBuffs ) then
							ToggleMessageType(checked, "SPELL_AURA_APPLIED", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_APPLIED_REMOVED", "SPELL_AURA_APPLIED_REMOVED_DOSE");
						end
					end
				end;
				tooltip = HARMFUL_AURA_COMBATLOG_TOOLTIP;
			},
			[3] = {
				text = DISPELS,
				type = {"SPELL_DISPELLED_AURA","SPELL_STOLEN_AURA", "SPELL_DISPEL_FAILED"};
				checked = function () return HasMessageType("SPELL_DISPELLED_AURA", "SPELL_STOLEN_AURA", "SPELL_DISPEL_FAILED"); end;
				func = function (checked) return ToggleMessageType(checked, "SPELL_DISPELLED_AURA", "SPELL_STOLEN_AURA", "SPELL_DISPEL_FAILED"); end;
				tooltip = DISPEL_AURA_COMBATLOG_TOOLTIP;
			},
			[4] = {
				text = ENCHANTS,
				type = {"ENCHANT_APPLIED", "ENCHANT_REMOVED"};
				checked = function () return HasMessageType("ENCHANT_APPLIED", "ENCHANT_REMOVED"); end;
				func = function (checked) return ToggleMessageType(checked, "ENCHANT_APPLIED", "ENCHANT_REMOVED"); end;
				tooltip = ENCHANT_AURA_COMBATLOG_TOOLTIP;
			},
		}
	},
	[4] = {
		text = PERIODIC,
		checked = function () return HasMessageTypeGroup("COMBAT_CONFIG_MESSAGETYPES_LEFT", 4) end;
		func = function (checked) ToggleMessageTypeGroup(checked, "CombatConfigMessageTypesLeft", 4) end;
		tooltip = SPELL_PERIODIC_COMBATLOG_TOOLTIP,
		subTypes = {
			[1] = {
				text = DAMAGE,
				type = "SPELL_PERIODIC_DAMAGE",
				checked = function () return HasMessageType("SPELL_PERIODIC_DAMAGE"); end;
				func = function (checked) return ToggleMessageType(checked, "SPELL_PERIODIC_DAMAGE"); end;
				tooltip = SPELL_PERIODIC_DAMAGE_COMBATLOG_TOOLTIP,
			},
			[2] = {
				text = MISSES,
				type = "SPELL_PERIODIC_MISSED",
				checked = function () return HasMessageType("SPELL_PERIODIC_MISSED"); end;
				func = function (checked) return ToggleMessageType(checked, "SPELL_PERIODIC_MISSED"); end;
				tooltip = SPELL_PERIODIC_MISSED_COMBATLOG_TOOLTIP,
			},
			[3] = {
				text = HEALS,
				type = "SPELL_PERIODIC_HEAL",
				checked = function () return HasMessageType("SPELL_PERIODIC_HEAL"); end;
				func = function (checked) return ToggleMessageType(checked, "SPELL_PERIODIC_HEAL"); end;
				tooltip = SPELL_PERIODIC_HEAL_COMBATLOG_TOOLTIP,
			},
			[4] = {
				text = OTHER,
				type = {"SPELL_PERIODIC_ENERGIZE", "SPELL_PERIODIC_DRAIN","SPELL_PERIODIC_LEECH"};
				checked = function () return HasMessageType("SPELL_PERIODIC_ENERGIZE", "SPELL_PERIODIC_DRAIN", "SPELL_PERIODIC_LEECH"); end;
				func = function (checked) return ToggleMessageType(checked, "SPELL_PERIODIC_ENERGIZE", "SPELL_PERIODIC_DRAIN", "SPELL_PERIODIC_LEECH"); end;
				tooltip = SPELL_PERIODIC_OTHER_COMBATLOG_TOOLTIP,
			},
		}
	},
	
};
COMBAT_CONFIG_MESSAGETYPES_RIGHT = {
	[1] = {
		text = SPELLS,
		checked = function () return HasMessageTypeGroup("COMBAT_CONFIG_MESSAGETYPES_RIGHT", 1) end;
		func = function (checked) ToggleMessageTypeGroup(checked, "CombatConfigMessageTypesRight", 1) end;
		tooltip = SPELLS_COMBATLOG_TOOLTIP,
		subTypes = {
			[1] = {
				text = DAMAGE,
				type = "SPELL_DAMAGE",
				checked = function () return HasMessageType("SPELL_DAMAGE"); end;
				func = function (checked) return ToggleMessageType(checked, "SPELL_DAMAGE"); end;
				tooltip = SPELL_DAMAGE_COMBATLOG_TOOLTIP,
			},
			[2] = {
				text = MISSES,
				type = "SPELL_MISSED",
				checked = function () return HasMessageType("SPELL_MISSED"); end;
				func = function (checked) return ToggleMessageType(checked, "SPELL_MISSED"); end;
				tooltip = SPELL_MISSED_COMBATLOG_TOOLTIP,
			},
			[3] = {
				text = HEALS,
				type = "SPELL_HEAL",
				checked = function () return HasMessageType("SPELL_HEAL"); end;
				func = function (checked) return ToggleMessageType(checked, "SPELL_HEAL"); end;
				tooltip = SPELL_HEAL_COMBATLOG_TOOLTIP,
			},
			[4] = {
				text = POWER_GAINS,
				type = "SPELL_ENERGIZE",
				checked = function () return HasMessageType("SPELL_ENERGIZE"); end;
				func = function (checked) return ToggleMessageType(checked, "SPELL_ENERGIZE"); end;
				tooltip = POWER_GAINS_COMBATLOG_TOOLTIP,
			},
			[5] = {
				text = DRAINS,
				type = {"SPELL_DRAIN", "SPELL_LEECH"};
				checked = function () return HasMessageType("SPELL_ENERGIZE"); end;
				func = function (checked) return ToggleMessageType(checked, "SPELL_ENERGIZE"); end;
				tooltip = SPELL_DRAIN_COMBATLOG_TOOLTIP,
			},
			[5] = {
				text = INTERRUPTS,
				type = {"SPELL_INTERRUPT"};
				checked = function () return HasMessageType("SPELL_INTERRUPT"); end;
				func = function (checked) return ToggleMessageType(checked, "SPELL_INTERRUPT"); end;
				tooltip = SPELL_INTERRUPT_COMBATLOG_TOOLTIP,
			},
			[5] = {
				text = SPECIAL,
				type = {"SPELL_INSTAKILL"};
				checked = function () return HasMessageType("SPELL_INSTAKILL"); end;
				func = function (checked) return ToggleMessageType(checked, "SPELL_INSTAKILL"); end;
				tooltip = SPELL_INSTAKILL_COMBATLOG_TOOLTIP,
			},
			[6] = {
				text = EXTRA_ATTACKS,
				type = {"SPELL_EXTRA_ATTACKS"};
				checked = function () return HasMessageType("SPELL_EXTRA_ATTACKS"); end;
				func = function (checked) return ToggleMessageType(checked, "SPELL_EXTRA_ATTACKS"); end;
				tooltip = SPELL_EXTRA_ATTACKS_COMBATLOG_TOOLTIP,
			},
		}
	},
	[2] = {
		text = SPELL_CASTING,
		checked = function () return HasMessageTypeGroup("COMBAT_CONFIG_MESSAGETYPES_RIGHT", 2) end;
		func = function (checked) ToggleMessageTypeGroup(checked, "CombatConfigMessageTypesRight", 2) end;
		tooltip = SPELL_CASTING_COMBATLOG_TOOLTIP,
		subTypes = {
			[1] = {
				text = START,
				type = "SPELL_CAST_START",
				checked = function () return HasMessageType("SPELL_CAST_START"); end;
				func = function (checked) return ToggleMessageType(checked, "SPELL_CAST_START"); end;
				tooltip = SPELL_CAST_START_COMBATLOG_TOOLTIP,
			},
			[2] = {
				text = SUCCESS,
				type = "SPELL_CAST_SUCCESS",
				checked = function () return HasMessageType("SPELL_CAST_SUCCESS"); end;
				func = function (checked) return ToggleMessageType(checked, "SPELL_CAST_SUCCESS"); end;
				tooltip = SPELL_CAST_SUCCESS_COMBATLOG_TOOLTIP,
			},
			[3] = {
				text = FAILURES,
				type = "SPELL_CAST_FAILED",
				checked = function () return HasMessageType("SPELL_CAST_FAILED"); end;
				func = function (checked) return ToggleMessageType(checked, "SPELL_CAST_FAILED"); end;
				tooltip = SPELL_CAST_FAILED_COMBATLOG_TOOLTIP,
			},
		}
	},
};
COMBAT_CONFIG_MESSAGETYPES_MISC = {
	[1] = {
		text = DAMAGE_SHIELD,
		checked = function () return HasMessageType("DAMAGE_SHIELD"); end;
		func = function (checked) return ToggleMessageType(checked, "DAMAGE_SHIELD"); end;
		tooltip = DAMAGE_SHIELD_COMBATLOG_TOOLTIP,
	},
	[2] = {
		text = ENVIRONMENTAL_DAMAGE,
		checked = function () return HasMessageType("ENVIRONMENTAL_DAMAGE"); end;
		func = function (checked) return ToggleMessageType(checked, "ENVIRONMENTAL_DAMAGE"); end;
		tooltip = ENVIRONMENTAL_DAMAGE_COMBATLOG_TOOLTIP,
	},
	[3] = {
		text = KILLS,
		checked = function () return HasMessageType("PARTY_KILL"); end;
		func = function (checked) return ToggleMessageType(checked, "PARTY_KILL"); end;
		tooltip = KILLS_COMBATLOG_TOOLTIP,
	},
	[4] = {
		text = DEATHS,
		type = {"UNIT_DIED", "UNIT_DESTROYED"};
		checked = function () return HasMessageType("DAMAGE_SHIELD"); end;
		func = function (checked) return ToggleMessageType(checked, "RANGE_MISSED"); end;
		tooltip = DEATHS_COMBATLOG_TOOLTIP,
	},
};
COMBAT_CONFIG_UNIT_COLORS = {
	[1] = {
		text = COMBATLOG_FILTER_ME,
		type = "COMBATLOG_FILTER_MINE",
	},
	[2] = {
		text = COMBATLOG_FILTER_MY_PET,
		type = "COMBATLOG_FILTER_MY_PET",
	},
	[3] = {
		text = COMBATLOG_FILTER_FRIENDLY_UNITS,
		type = "COMBATLOG_FILTER_FRIENDLY_UNITS",
	},
	[4] = {
		text = COMBATLOG_FILTER_HOSTILE_UNITS,
		type = "COMBATLOG_FILTER_HOSTILE_UNITS",
	},
	[5] = {
		text = COMBATLOG_FILTER_NEUTRAL_UNITS,
		type = "COMBATLOG_FILTER_NEUTRAL_UNITS",
	},
	[6] = {
		text = COMBATLOG_FILTER_UNKNOWN_UNITS,
		type = "COMBATLOG_FILTER_MINE",
	},
}

function ChatConfigFrame_OnLoad()
	-- Chat Settings
	ChatConfig_CreateCheckboxes(ChatConfigChatSettingsLeft, CHAT_CONFIG_CHAT_LEFT, "ChatConfigCheckBoxWithSwatchTemplate");
	ChatConfig_CreateCheckboxes(ChatConfigChatSettingsRight, CHAT_CONFIG_CHAT_RIGHT, "ChatConfigCheckBoxWithSwatchTemplate");
	ChatConfig_CreateCheckboxes(ChatConfigOtherSettingsCombat, CHAT_CONFIG_OTHER_COMBAT, "ChatConfigCheckBoxWithSwatchTemplate", COMBAT);
	ChatConfig_CreateCheckboxes(ChatConfigOtherSettingsPVP, CHAT_CONFIG_OTHER_PVP, "ChatConfigCheckBoxWithSwatchTemplate", PVP);
	ChatConfig_CreateCheckboxes(ChatConfigOtherSettingsSystem, CHAT_CONFIG_OTHER_SYSTEM, "ChatConfigCheckBoxWithSwatchTemplate", OTHER);

	-- CombatLog Settings
	ChatConfig_CreateCheckboxes(CombatConfigMessageSourcesDoneBy, COMBAT_CONFIG_MESSAGESOURCES_BY, "ChatConfigCheckBoxTemplate", DONE_BY);
	ChatConfig_CreateCheckboxes(CombatConfigMessageSourcesDoneTo, COMBAT_CONFIG_MESSAGESOURCES_TO, "ChatConfigCheckBoxTemplate", DONE_TO);
	ChatConfig_CreateTieredCheckboxes(CombatConfigMessageTypesLeft, COMBAT_CONFIG_MESSAGETYPES_LEFT, "ChatConfigCheckButtonTemplate", "ChatConfigSmallCheckButtonTemplate");
	ChatConfig_CreateTieredCheckboxes(CombatConfigMessageTypesRight, COMBAT_CONFIG_MESSAGETYPES_RIGHT, "ChatConfigCheckButtonTemplate", "ChatConfigSmallCheckButtonTemplate");
	ChatConfig_CreateTieredCheckboxes(CombatConfigMessageTypesMisc, COMBAT_CONFIG_MESSAGETYPES_MISC, "ChatConfigSmallCheckButtonTemplate", "ChatConfigSmallCheckButtonTemplate");
	ChatConfig_CreateColorSwatches(CombatConfigColorsUnitColors, COMBAT_CONFIG_UNIT_COLORS, "ChatConfigSwatchTemplate", UNIT_COLORS);

	-- Default selections
	ChatConfigCategory_OnClick(ChatConfigCategoryFrameButton2);
	ChatConfig_UpdateCombatTabs(1);
end

function ChatConfig_CreateCheckboxes(frame, checkBoxTable, checkBoxTemplate, title)
	local checkBoxNameString = frame:GetName().."CheckBox";
	local checkBoxName, checkBox, check;
	local width, height;
	local padding = 8;
	local count = 0;
	local text;
	frame.checkBoxTable = checkBoxTable;
	if ( title ) then
		getglobal(frame:GetName().."Title"):SetText(title);
	end
	for index, value in ipairs(checkBoxTable) do
		--If no checkbox then create it
		checkBoxName = checkBoxNameString..index;
		if ( not getglobal(checkBoxName) ) then
			checkBox = CreateFrame("Frame", checkBoxName, frame, checkBoxTemplate);
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
			else
				text = getglobal(value.type);
			end
			getglobal(checkBoxName.."CheckText"):SetText(text);
			check = getglobal(checkBoxName.."Check");
			check.func = value.func;
			check:SetID(index);
			check.tooltip = value.tooltip;
			count = count+1;
		end
	end
	--Set Parent frame dimensions
	if ( count > 0 ) then
		frame:SetWidth(width+padding);
		frame:SetHeight(count*height+padding);
	end
end

function ChatConfig_CreateTieredCheckboxes(frame, checkBoxTable, checkBoxTemplate, subCheckBoxTemplate)
	local checkBoxNameString = frame:GetName().."CheckBox";
	local checkBoxName, checkBox, subCheckBoxName, subCheckBox, subCheckBoxNameString;
	local width, height;
	local padding = 8;
	local count = 0;
	local text, subText;
	local yOffset;
	local numColumns = 2;
	frame.checkBoxTable = checkBoxTable;
	for index, value in ipairs(checkBoxTable) do
		--If no checkbox then create it
		checkBoxName = checkBoxNameString..index;
		if ( not getglobal(checkBoxName) ) then
			checkBox = CreateFrame("CheckButton", checkBoxName, frame, checkBoxTemplate);
			if ( index > 1 ) then
				checkBox:SetPoint("TOPLEFT", checkBoxNameString..(index-1), "BOTTOMLEFT", 0, yOffset);
			else
				checkBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4);
			end
			if ( value.text ) then
				text = value.text;
			else
				text = getglobal(value.type);
			end
			getglobal(checkBoxName.."Text"):SetText(text);
			if ( value.subTypes ) then
				subCheckBoxNameString = checkBoxName.."_"; 
				for k, v in ipairs(value.subTypes) do
					subCheckBoxName = subCheckBoxNameString..k;
					if ( not getglobal(subCheckBoxName) ) then
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
						subText = getglobal(v.type);
					end
					getglobal(subCheckBoxName.."Text"):SetText(subText);
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
			count = count+1;
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
		getglobal(frame:GetName().."Title"):SetText(title);
	end
	for index, value in ipairs(swatchTable) do
		--If no checkbox then create it
		swatchName = nameString..index;
		if ( not getglobal(swatchName) ) then
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
				text = getglobal(value.type);
			end
			getglobal(swatchName.."Text"):SetText(text);
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
	local checkBoxTable = frame.checkBoxTable;
	local checkBoxNameString = frame:GetName().."CheckBox";
	local checkBoxName, checkBox, baseName, colorSwatch;
	for index, value in ipairs(checkBoxTable) do
		baseName = checkBoxNameString..index;
		checkBox = getglobal(baseName.."Check");
		if ( checkBox ) then
			if ( type(value.checked) == "function" ) then
				checkBox:SetChecked(value.checked());
			else
				checkBox:SetChecked(value.checked);	
			end
			colorSwatch = getglobal(baseName.."ColorSwatch");
			if ( colorSwatch ) then
				getglobal(baseName.."ColorSwatchNormalTexture"):SetVertexColor(GetMessageTypeColor(value.type));
				colorSwatch.messageType = value.type;
			end
		end
	end
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
		swatch = getglobal(baseName.."ColorSwatch");
		if ( swatch ) then
			getglobal(baseName.."ColorSwatchNormalTexture"):SetVertexColor(GetChatUnitColor(value.type));
			swatch.type = value.type;
		end
	end
end

function ChatConfig_UpdateTieredCheckboxes(frame)
	-- List of message types in current chat frame
	if ( not FCF_GetCurrentChatFrame() ) then
		return;
	end
	local checkBoxTable = frame.checkBoxTable;
	local checkBoxNameString = frame:GetName().."CheckBox";
	local checkBoxName, checkBox, baseName, subCheckBox, checked;
	for index, value in ipairs(checkBoxTable) do
		baseName = checkBoxNameString..index;
		checkBox = getglobal(baseName);
		if ( checkBox ) then
			checked = value.checked;
			if ( type(checked) == "function" ) then
				checkBox:SetChecked(checked());
				--Set checked so we can use it later
				checked = checked();
			else
				checkBox:SetChecked(checked);	
			end
		end
		if ( value.subTypes ) then
			for k, v in ipairs(value.subTypes) do
				subCheckBox = getglobal(baseName.."_"..k);
				if ( type(v.checked) == "function" ) then
					subCheckBox:SetChecked(v.checked());
				else
					subCheckBox:SetChecked(v.checked);	
				end
				if ( checked ) then
					OptionsFrame_EnableCheckBox(subCheckBox, nil, nil, 1);
				else
					OptionsFrame_DisableCheckBox(subCheckBox);
				end
			end
		end
	end
end

function CombatConfig_Colorize_Update()
	CombatConfigColorsColorizeUnitNameCheck:SetChecked(CHATCONFIG_SELECTED_FILTER_SETTINGS.unitColoring);
	
	-- Spell Names
	CombatConfigColorsColorizeSpellNamesCheck:SetChecked(CHATCONFIG_SELECTED_FILTER_SETTINGS.abilityColoring);
	if ( CHATCONFIG_SELECTED_FILTER_SETTINGS.abilityColoring ) then
		OptionsFrame_EnableCheckBox(CombatConfigColorsColorizeSpellNamesSchoolColoring, nil, nil, 1);
	else
		OptionsFrame_DisableCheckBox(CombatConfigColorsColorizeSpellNamesSchoolColoring);
	end
	CombatConfigColorsColorizeSpellNamesSchoolColoring:SetChecked(CHATCONFIG_SELECTED_FILTER_SETTINGS.abilitySchoolColoring);
	CombatConfigColorsColorizeSpellNamesColorSwatchNormalTexture:SetVertexColor(GetTableColor(CHATCONFIG_SELECTED_FILTER_COLORS.defaults.spell));
	
	-- Damage Number
	CombatConfigColorsColorizeDamageNumberCheck:SetChecked(CHATCONFIG_SELECTED_FILTER_SETTINGS.amountColoring);
	if ( CHATCONFIG_SELECTED_FILTER_SETTINGS.amountColoring ) then
		OptionsFrame_EnableCheckBox(CombatConfigColorsColorizeDamageNumberSchoolColoring, nil, nil, 1);
	else
		OptionsFrame_DisableCheckBox(CombatConfigColorsColorizeDamageNumberSchoolColoring);
	end
	CombatConfigColorsColorizeDamageNumberSchoolColoring:SetChecked(CHATCONFIG_SELECTED_FILTER_SETTINGS.amountSchoolColoring);
	CombatConfigColorsColorizeDamageNumberColorSwatchNormalTexture:SetVertexColor(GetTableColor(CHATCONFIG_SELECTED_FILTER_COLORS.defaults.damage));
	
	-- Damage School
	CombatConfigColorsColorizeDamageSchoolCheck:SetChecked(CHATCONFIG_SELECTED_FILTER_SETTINGS.schoolNameColoring);
	
	-- Line Coloring
	CombatConfigColorsColorizeEntireLineCheck:SetChecked(CHATCONFIG_SELECTED_FILTER_SETTINGS.lineColoring);
	if ( CHATCONFIG_SELECTED_FILTER_SETTINGS.lineColoring ) then
		OptionsFrame_EnableCheckBox(CombatConfigColorsColorizeEntireLineBySource, nil, nil, 1);
		OptionsFrame_EnableCheckBox(CombatConfigColorsColorizeEntireLineByTarget, nil, nil, 1);
	else
		OptionsFrame_DisableCheckBox(CombatConfigColorsColorizeEntireLineBySource);
		OptionsFrame_DisableCheckBox(CombatConfigColorsColorizeEntireLineByTarget);
	end
	if ( CHATCONFIG_SELECTED_FILTER_SETTINGS.lineColorPriority == 1 ) then
		CombatConfigColorsColorizeEntireLineBySource:SetChecked(1);
		CombatConfigColorsColorizeEntireLineByTarget:SetChecked(nil);
	else
		CombatConfigColorsColorizeEntireLineBySource:SetChecked(nil);
		CombatConfigColorsColorizeEntireLineByTarget:SetChecked(1);
	end
end

function CombatConfig_Formatting_Update()
	CombatConfigFormattingShowTimeStamp:SetChecked(CHATCONFIG_SELECTED_FILTER_SETTINGS.timestamp);
	CombatConfigFormattingShowBraces:SetChecked(CHATCONFIG_SELECTED_FILTER_SETTINGS.braces);
	if ( CHATCONFIG_SELECTED_FILTER_SETTINGS.braces ) then
		OptionsFrame_EnableCheckBox(CombatConfigFormattingUnitNames, nil, nil, 1);
		OptionsFrame_EnableCheckBox(CombatConfigFormattingSpellNames, nil, nil, 1);
		OptionsFrame_EnableCheckBox(CombatConfigFormattingItemNames, nil, nil, 1);
	else
		OptionsFrame_DisableCheckBox(CombatConfigFormattingUnitNames);
		OptionsFrame_DisableCheckBox(CombatConfigFormattingSpellNames);
		OptionsFrame_DisableCheckBox(CombatConfigFormattingItemNames);
	end
	CombatConfigFormattingUnitNames:SetChecked(CHATCONFIG_SELECTED_FILTER_SETTINGS.unitBraces);
	CombatConfigFormattingSpellNames:SetChecked(CHATCONFIG_SELECTED_FILTER_SETTINGS.spellBraces);
	CombatConfigFormattingItemNames:SetChecked(CHATCONFIG_SELECTED_FILTER_SETTINGS.itemBraces);

	debugdump(CHATCONFIG_SELECTED_FILTER);
	local text, r, g, b = CombatLog_OnEvent("", CHATCONFIG_SELECTED_FILTER, 0, "SPELL_DAMAGE", 0x0000000000000001,"Player",0x511,0xF13000012B000820,EXAMPLE_TARGET_MONSTER,0x10a28,116,EXAMPLE_SPELL_FROSTBOLT,SCHOOL_MASK_FROST,27,SCHOOL_MASK_FROST,nil,nil,nil,1,nil,nil);
	CombatConfigFormattingExampleString:SetVertexColor(r, g, b);
	CombatConfigFormattingExampleString:SetText(text);
end

function CombatConfig_Settings_Update()
	CombatConfigSettingsShowQuickButton:SetChecked(CHATCONFIG_SELECTED_FILTER.hasQuickButton);
	if ( CHATCONFIG_SELECTED_FILTER.hasQuickButton ) then
		OptionsFrame_EnableCheckBox(CombatConfigSettingsSolo, nil, nil, 1);
		OptionsFrame_EnableCheckBox(CombatConfigSettingsParty, nil, nil, 1);
		OptionsFrame_EnableCheckBox(CombatConfigSettingsRaid, nil, nil, 1);
	else
		OptionsFrame_DisableCheckBox(CombatConfigSettingsSolo);
		OptionsFrame_DisableCheckBox(CombatConfigSettingsParty);
		OptionsFrame_DisableCheckBox(CombatConfigSettingsRaid);
	end
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

function ToggleChatChannel(checked, channel)
	if ( checked ) then
		ChatFrame_AddChannel(FCF_GetCurrentChatFrame(), channel);
	else
		ChatFrame_RemoveChannel(FCF_GetCurrentChatFrame(), channel);
	end
end

function ToggleMessageSource(checked, filter)
	if ( not CHATCONFIG_SELECTED_FILTER_FILTERS[1].sourceFlags ) then
		CHATCONFIG_SELECTED_FILTER_FILTERS[1].sourceFlags = {};
	end
	local sourceFlags = CHATCONFIG_SELECTED_FILTER_FILTERS[1].sourceFlags;
	if ( checked ) then
		sourceFlags[filter] = true;
	else
		sourceFlags[filter] = false;
	end
end

function ToggleMessageDest(checked, filter)
	if ( not CHATCONFIG_SELECTED_FILTER_FILTERS[2].destFlags ) then
		CHATCONFIG_SELECTED_FILTER_FILTERS[2].destFlags = {};
	end
	local destFlags = CHATCONFIG_SELECTED_FILTER_FILTERS[2].destFlags;
	if ( checked ) then
		destFlags[filter] = true;
	else
		destFlags[filter] = false;
	end
end

function ToggleMessageTypeGroup(checked, frame, index)
	local subTypes = getglobal(frame).checkBoxTable[index].subTypes;
	local eventList = CHATCONFIG_SELECTED_FILTER_FILTERS[1].eventList;
	if ( subTypes ) then
		local state;
		if ( checked ) then
			for k, v in ipairs(subTypes) do
				state = GetMessageTypeState(v.type);
				if ( state == GRAY_CHECKED ) then
					if ( type(v.type) == "table" ) then
						for k2, v2 in pairs(v.type) do
							eventList[v2] = true;
						end
					else
						eventList[v.type] = true;
					end
					
				end
			end
		else
			for k, v in ipairs(subTypes) do
				state = GetMessageTypeState(v.type);
				if ( state == true ) then
					if ( type(v.type) == "table" ) then
						for k2, v2 in pairs(v.type) do
							eventList[v2] = GRAY_CHECKED;
						end
					else
						eventList[v.type] = GRAY_CHECKED;
					end
				end
			end
		end
	end
	ChatConfig_UpdateTieredCheckboxes(getglobal(frame));
end

function ToggleMessageType(checked, ...)
	local eventList = CHATCONFIG_SELECTED_FILTER_FILTERS[1].eventList;
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

COMBATCONFIG_COLORPICKER_FUNCTIONS = {
	chatUnitColorSwatch = function() 
			SetChatUnitColor(CHAT_CONFIG_CURRENT_COLOR_SWATCH.type, ColorPickerFrame:GetColorRGB());
			getglobal(CHAT_CONFIG_CURRENT_COLOR_SWATCH:GetName().."NormalTexture"):SetVertexColor(ColorPickerFrame:GetColorRGB());
		end;
	chatUnitColorCancel = function() 
			SetChatUnitColor(CHAT_CONFIG_CURRENT_COLOR_SWATCH.type, ColorPicker_GetPreviousValues());
			getglobal(CHAT_CONFIG_CURRENT_COLOR_SWATCH:GetName().."NormalTexture"):SetVertexColor(ColorPicker_GetPreviousValues());
		end;
	spellColorSwatch = function() 
			SetTableColor(CHATCONFIG_SELECTED_FILTER_COLORS.defaults.spell, ColorPickerFrame:GetColorRGB());
			getglobal(CHAT_CONFIG_CURRENT_COLOR_SWATCH:GetName().."NormalTexture"):SetVertexColor(ColorPickerFrame:GetColorRGB());
		end;
	spellColorCancel = function() 
			SetTableColor(CHATCONFIG_SELECTED_FILTER_COLORS.defaults.spell, ColorPicker_GetPreviousValues());
			getglobal(CHAT_CONFIG_CURRENT_COLOR_SWATCH:GetName().."NormalTexture"):SetVertexColor(ColorPicker_GetPreviousValues());
		end;
	damageColorSwatch = function() 
			SetTableColor(CHATCONFIG_SELECTED_FILTER_COLORS.defaults.damage, ColorPickerFrame:GetColorRGB());
			getglobal(this:GetName().."NormalTexture"):SetVertexColor(ColorPickerFrame:GetColorRGB());
		end;
	damageColorCancel = function() 
			SetTableColor(CHATCONFIG_SELECTED_FILTER_COLORS.defaults.damage, ColorPicker_GetPreviousValues());
			getglobal(this:GetName().."NormalTexture"):SetVertexColor(ColorPicker_GetPreviousValues());
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
	info.r, info.g, info.b = GetTableColor(CHATCONFIG_SELECTED_FILTER_COLORS.defaults.spell);
	info.swatchFunc = COMBATCONFIG_COLORPICKER_FUNCTIONS.spellColorSwatch;
	info.cancelFunc = COMBATCONFIG_COLORPICKER_FUNCTIONS.spellColorCancel;
	OpenColorPicker(info);
end

function DamageColor_OpenColorPicker(self)
	local info = UIDropDownMenu_CreateInfo();
	CHAT_CONFIG_CURRENT_COLOR_SWATCH = self;
	info.r, info.g, info.b = GetTableColor(CHATCONFIG_SELECTED_FILTER_COLORS.defaults.damage);
	info.swatchFunc = COMBATCONFIG_COLORPICKER_FUNCTIONS.spellColorSwatch;
	info.cancelFunc = COMBATCONFIG_COLORPICKER_FUNCTIONS.spellColorCancel;
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
	return info.r, info.g, info.b;
end

function GetChatUnitColor(type)
	local color = CHATCONFIG_SELECTED_FILTER_COLORS.unitColoring[getglobal(type)];
	return color.r, color.g, color.b;
end

function SetChatUnitColor(type, r, g, b)
	local currentColor = CHATCONFIG_SELECTED_FILTER_COLORS.unitColoring[getglobal(type)];
	currentColor.r = r;
	currentColor.g = g;
	currentColor.b = b;
end

function GetSpellNameColor()
	local color = CHATCONFIG_SELECTED_FILTER_COLORS.defaults.spell;
	return color.r, color.g, color.b;
end

function SetSpellNameColor(r, g, b)
	local currentColor = CHATCONFIG_SELECTED_FILTER_COLORS.defaults.spell;
	currentColor.r = r;
	currentColor.g = g;
	currentColor.b = b;
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
};

function ChatConfigCategory_OnClick(self)
	self:UnlockHighlight();
	for index, value in ipairs(CHAT_CONFIG_CATEGORIES) do
		if ( self:GetID() == index ) then
			getglobal(value):Show();
			self:LockHighlight();
		else
			getglobal(value):Hide();
			getglobal("ChatConfigCategoryFrameButton"..index):UnlockHighlight();
		end
	end
end

function CreateChatChannelList(...)
	if ( not FCF_GetCurrentChatFrame() ) then
		return;
	end
	local channelList = FCF_GetCurrentChatFrame().channelList;
	local zoneChannelList = FCF_GetCurrentChatFrame().zoneChannelList;
	local channel, channelID, tag;
	local checked;
	local count = 1;
	CHAT_CONFIG_CHANNEL_LIST = {};
	for i=1, select("#", ...), 2 do
		channelID = select(i, ...);
		tag = "CHANNEL"..channelID;
		channel = select(i+1, ...);
		checked = nil;
		if ( channelList ) then
			for index, value in pairs(channelList) do
				if ( value == channel ) then
					checked = 1;
				end
			end
		end
		if ( zoneChannelList ) then
			for index, value in pairs(zoneChannelList) do
				if ( value == channel ) then
					checked = 1;
				end
			end
		end
		CHAT_CONFIG_CHANNEL_LIST[count] = {};
		CHAT_CONFIG_CHANNEL_LIST[count].text = channelID.."."..channel;
		CHAT_CONFIG_CHANNEL_LIST[count].channelName = channel;
		CHAT_CONFIG_CHANNEL_LIST[count].type = tag;
		CHAT_CONFIG_CHANNEL_LIST[count].checked = checked;
		CHAT_CONFIG_CHANNEL_LIST[count].func = function (checked) 
							ToggleChatChannel(checked, CHAT_CONFIG_CHANNEL_LIST[this:GetID()].channelName); 
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
		if ( not getglobal(name) ) then
			tab = CreateFrame("BUTTON", name, ChatConfigBackgroundFrame, "ChatConfigTabTemplate");
			if ( index > 1 ) then
				tab:SetPoint("BOTTOMLEFT", getglobal(tabName..(index-1)), "BOTTOMRIGHT", -1, 0);
			else
				tab:SetPoint("BOTTOMLEFT", ChatConfigBackgroundFrame, "TOPLEFT", 2, -1);
			end
			
			text = getglobal(name.."Text");
			text:SetText(value.text);
			tab:SetID(index);
			PanelTemplates_TabResize(0, tab);
		end
	end
end

function ChatConfig_UpdateFilterList()
	local index;
	local offset = FauxScrollFrame_GetOffset(ChatConfigCombatSettingsFiltersScrollFrame);
	local button, buttonName, filter, text;
	for i=1, COMBATLOG_FILTERS_TO_DISPLAY do
		index = offset+i;
		buttonName = "ChatConfigCombatSettingsFiltersButton"..i;
		button = getglobal(buttonName);
		if ( index <= #Blizzard_CombatLog_Filters.filters ) then
			text = Blizzard_CombatLog_Filters.filters[index].name;
			getglobal(buttonName.."NormalText"):SetText(text);
			button.name = text;
			button:Show();
			if ( index == ChatConfigCombatSettingsFilters.selectedFilter ) then
				button:LockHighlight();
			else
				button:UnlockHighlight();
			end
		else
			button:Hide();
		end
	end
	if ( FauxScrollFrame_Update(ChatConfigCombatSettingsFiltersScrollFrame, #Blizzard_CombatLog_Filters.filters, COMBATLOG_FILTERS_TO_DISPLAY, CHATCONFIG_FILTER_HEIGHT ) ) then
		ChatConfigCombatSettingsFiltersButton1:SetPoint("TOPRIGHT", ChatConfigCombatSettingsFilters, "TOPRIGHT", -29, -7);
	else
		ChatConfigCombatSettingsFiltersButton1:SetPoint("TOPRIGHT", ChatConfigCombatSettingsFilters, "TOPRIGHT", -5, -7);
	end
	-- Update the combat log quick buttons
	Blizard_CombatLog_Update_QuickButtons();
end

function ChatConfigFilter_OnClick(id)
	ChatConfigCombatSettingsFilters.selectedFilter = id+FauxScrollFrame_GetOffset(ChatConfigCombatSettingsFiltersScrollFrame);
	CHATCONFIG_SELECTED_FILTER = Blizzard_CombatLog_Filters.filters[ChatConfigCombatSettingsFilters.selectedFilter];
	CHATCONFIG_SELECTED_FILTER_FILTERS = CHATCONFIG_SELECTED_FILTER.filters;
	CHATCONFIG_SELECTED_FILTER_COLORS = CHATCONFIG_SELECTED_FILTER.colors;
	CHATCONFIG_SELECTED_FILTER_SETTINGS = CHATCONFIG_SELECTED_FILTER.settings;
	ChatConfig_UpdateFilterList();
	ChatConfig_UpdateCombatSettings();
end

function ChatConfig_UpdateCombatSettings()
	ChatConfig_UpdateCheckboxes(CombatConfigMessageSourcesDoneBy);
	ChatConfig_UpdateCheckboxes(CombatConfigMessageSourcesDoneTo);
	
	ChatConfig_UpdateTieredCheckboxes(CombatConfigMessageTypesLeft);
	ChatConfig_UpdateTieredCheckboxes(CombatConfigMessageTypesRight);
	ChatConfig_UpdateTieredCheckboxes(CombatConfigMessageTypesMisc);

	ChatConfig_UpdateSwatches(CombatConfigColorsUnitColors);
	CombatConfig_Colorize_Update();
	CombatConfig_Formatting_Update();
	CombatConfig_Settings_Update();

	CombatConfigSettingsNameEditBox:SetText(CHATCONFIG_SELECTED_FILTER.name);
end

function IsMessageDoneBy(filter)
	local sourceFlags = CHATCONFIG_SELECTED_FILTER_FILTERS[1].sourceFlags;
	if ( not sourceFlags ) then
		return true;
	end
	return sourceFlags[filter];
end

function IsMessageDoneTo(filter)
	local destFlags = Blizzard_CombatLog_Filters.filters[ChatConfigCombatSettingsFilters.selectedFilter].filters[2].destFlags;
	if ( not destFlags ) then
		return true;
	end
	return destFlags[filter];
end

function HasMessageTypeGroup(checkBoxList, index)
	local subTypes = getglobal(checkBoxList)[index].subTypes;
	if ( subTypes ) then
		local state;
		for k, v in ipairs(subTypes) do
			state = GetMessageTypeState(v.type);
			if ( state == GRAY_CHECKED ) then
				return false;
			end
		end
		return true;
	end
	return false;
end

function HasMessageType(messageType)
	-- Only look at the first messageType passed in since we're treating them as a unit
	local isListening = GetMessageTypeState(messageType);
	if ( isListening ) then
		return true;
	else
		return false;
	end
end

function GetMessageTypeState(messageType)
	if ( type(messageType) == "table" ) then
		return CHATCONFIG_SELECTED_FILTER_FILTERS[1].eventList[messageType[1]];
	else
		return CHATCONFIG_SELECTED_FILTER_FILTERS[1].eventList[messageType];
	end
end

function ChatConfig_UpdateCombatTabs(selectedTabID)
	local tab, text, frame;
	for index, value in ipairs(COMBAT_CONFIG_TABS) do
		tab = getglobal(CHAT_CONFIG_COMBAT_TAB_NAME..index);
		text = getglobal(CHAT_CONFIG_COMBAT_TAB_NAME..index.."Text");
		frame = getglobal(value.frame);
		if ( index == selectedTabID ) then
			tab:SetAlpha(1.0);
			text:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			frame:Show();
		else
			tab:SetAlpha(0.5);
			text:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
			frame:Hide();
		end

	end
end

function ChatConfig_ShowCombatTabs()
	for index, _ in ipairs(COMBAT_CONFIG_TABS) do
		getglobal(CHAT_CONFIG_COMBAT_TAB_NAME..index):Show();
	end
end

function ChatConfig_HideCombatTabs()
	for index, _ in ipairs(COMBAT_CONFIG_TABS) do
		getglobal(CHAT_CONFIG_COMBAT_TAB_NAME..index):Hide();
	end
end

function CombatConfig_CreateCombatFilter(name)
	local newFilter = DEFAULT_COMBATLOG_FILTER_TEMPLATE;
	newFilter.name = name;
	tinsert(Blizzard_CombatLog_Filters.filters, newFilter);
	-- Scroll filters to top of list
	ChatConfigCombatSettingsFiltersScrollFrameScrollBar:SetValue(0);
	-- Select the new filter
	ChatConfigFilter_OnClick(#Blizzard_CombatLog_Filters.filters);
end

function CombatConfig_DeleteCurrentCombatFilter()
	tremove(Blizzard_CombatLog_Filters.filters, ChatConfigCombatSettingsFilters.selectedFilter);
	-- Scroll filters to top of list
	ChatConfigCombatSettingsFiltersScrollFrameScrollBar:SetValue(0);
	-- Select the first filter
	ChatConfigFilter_OnClick(1);
end
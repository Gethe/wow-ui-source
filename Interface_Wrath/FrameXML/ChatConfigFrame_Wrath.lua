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

function GetTemplateForChatConfigFrame()
	return "ChatConfigCheckBoxWithSwatchAndClassColorTemplate";
end

function GetChatConfigChannelInfo()
	return "MovableChatConfigWideCheckBoxWithSwatchTemplate", CHAT_CONFIG_CHANNEL_SETTINGS_TITLE_WITH_DRAG_INSTRUCTIONS;
end

function ColorClassesCheckBox_OnClick(self, checked)
	ToggleChatColorNamesByClassGroup(checked, self:GetParent().type);
end

function UpdateColorClassCheckboxes(baseName, value)
	local colorClasses = _G[baseName.."ColorClasses"];
	if ( colorClasses ) then
		colorClasses:SetChecked(IsClassColoringMessageType(value.type));
	end
end

function HideClassColors(value, checkBoxName)
	if ( value.noClassColor ) then
		_G[checkBoxName.."ColorClasses"]:Hide();
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

function IsClassColoringMessageType(messageType)
	local groupInfo = ChatTypeGroup[messageType];
	if ( groupInfo ) then
		for key, value in pairs(groupInfo) do	--If any of the sub-categories color by name, we'll consider the entire thing as colored by name.
			local info = ChatTypeInfo[strsub(value, 10)];
			if ( info and info.colorNameByClass ) then
				return true;
			end
		end
		return false;
	else
		local info = ChatTypeInfo[messageType];
		return info and info.colorNameByClass;
	end
end
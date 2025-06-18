DelvesToastMixin = {};

local DelvesConstants =
{
	MessageDuration = 20,
	PlayerHyperlink = "playername",
}

function DelvesToastMixin:OnLoad()
	self:RegisterEvent("DELVE_ASSIST_ACTION");

	AlertFrame_SetDuration(self, DelvesConstants.MessageDuration);

	self.CloseButton:SetScript("OnEnter", function(button)
		self:OnEnter();
	end)

	self.CloseButton:SetScript("OnLeave", function(button)
		self:OnLeave();
	end)

	self.CloseButton:SetScript("OnClick", function(button)
		self:Hide();
	end)

	local alertSystem = ChatAlertFrame:AddAutoAnchoredSubSystem(self);
	ChatAlertFrame:SetSubSystemAnchorPriority(alertSystem, 0);
end

function DelvesToastMixin:OnHyperlinkClick(link, text, button)
	if button == "RightButton" then
		local linkType, linkData = LinkUtil.SplitLinkData(link);
		if linkType == DelvesConstants.PlayerHyperlink then
			local contextData = { name = linkData };
			UnitPopup_OpenMenu("FRIEND", contextData);
		end
	else
		self:OnClick(button);
	end
end

local function GetPlayerName(data)
	local fullName = data.assistedPlayer;
	local coloredFullName = NORMAL_FONT_COLOR:WrapTextInColorCode(fullName);
	return string.format("|H%s:%s|h%s|h", DelvesConstants.PlayerHyperlink, fullName, coloredFullName);
end

local function GetFormattedMessage(data)
	local assistAction = data.assistAction;
	if assistAction == Enum.AssistActionType.LoungingPlayer then
	elseif assistAction == Enum.AssistActionType.GraveMarker then
	elseif assistAction == Enum.AssistActionType.PlacedVo then
		return NOTIFY_ASSIST_ACTION_PLACED_VO:format(GetPlayerName(data), data.mapName);
	elseif assistAction == Enum.AssistActionType.PlayerGuardian then
	elseif assistAction == Enum.AssistActionType.PlayerSlayer then
		return NOTIFY_ASSIST_ACTION_PLAYER_SLAYER:format(GetPlayerName(data), data.creatureName, data.mapName);
	elseif assistAction == Enum.AssistActionType.CapturedBuff then
		local spellName = C_Spell.GetSpellName(data.receivedSpellID);
		return NOTIFY_ASSIST_ACTION_CAPTURED_BUFF:format(GetPlayerName(data), spellName, data.mapName);
	end
end

function DelvesToastMixin:OnEvent(event, ...)
	if event == "DELVE_ASSIST_ACTION" then
		local data = ...;
		data.message = GetFormattedMessage(data);
		self:SetToast(data);
	end
end

function DelvesToastMixin:SetToast(data)
	self.Text:SetHeight(0);
	self.Text:SetText(data.message);

	PlaySound(SOUNDKIT.UI_BNET_TOAST);

	AlertFrame_ShowNewAlert(self);
end

function DelvesToastMixin:OnEnter()
	AlertFrame_PauseOutAnimation(self);
end

function DelvesToastMixin:OnLeave()
	AlertFrame_ResumeOutAnimation(self);
end

function DelvesToastMixin:OnClick(button)
	if button == "LeftButton" then
		self:Hide();
	end
end

SocialUIUtil = {};

local battleNetFriendTagToLabel =
{
	[Enum.BattleNetFriendTag.Professions] = SOCIAL_UI_BATTLE_NET_FRIEND_TAG_LABEL_PROFESSIONS,
	[Enum.BattleNetFriendTag.PvP] = SOCIAL_UI_BATTLE_NET_FRIEND_TAG_LABEL_PVP,
	[Enum.BattleNetFriendTag.Raiding] = SOCIAL_UI_BATTLE_NET_FRIEND_TAG_LABEL_RAIDING,
	[Enum.BattleNetFriendTag.Dungeons] = SOCIAL_UI_BATTLE_NET_FRIEND_TAG_LABEL_DUNGEONS,
	[Enum.BattleNetFriendTag.Delves] = SOCIAL_UI_BATTLE_NET_FRIEND_TAG_LABEL_DELVE,
	[Enum.BattleNetFriendTag.Questing] = SOCIAL_UI_BATTLE_NET_FRIEND_TAG_LABEL_QUESTING,
	[Enum.BattleNetFriendTag.Roleplaying] = SOCIAL_UI_BATTLE_NET_FRIEND_TAG_LABEL_ROLEPLAYING,
	[Enum.BattleNetFriendTag.DamagerRole] = SOCIAL_UI_BATTLE_NET_FRIEND_TAG_LABEL_DPS,
	[Enum.BattleNetFriendTag.HealerRole] = SOCIAL_UI_BATTLE_NET_FRIEND_TAG_LABEL_HEALER,
	[Enum.BattleNetFriendTag.TankRole] = SOCIAL_UI_BATTLE_NET_FRIEND_TAG_LABEL_TANK,
};
assertsafe(Enum.BattleNetFriendTagMeta.NumValues == table.count(battleNetFriendTagToLabel), "Not all BattleNetFriendTags have a label defined in battleNetFriendTagToLabel!");

function SocialUIUtil.GetLabelForBattleNetFriendTag(battleNetFriendTag)
	return battleNetFriendTagToLabel[battleNetFriendTag] or "";
end

local battleNetFriendTagInterestsUIOrder =
{
	Enum.BattleNetFriendTag.Professions,
	Enum.BattleNetFriendTag.PvP,
	Enum.BattleNetFriendTag.Raiding,
	Enum.BattleNetFriendTag.Dungeons,
	Enum.BattleNetFriendTag.Delves,
	Enum.BattleNetFriendTag.Questing,
	Enum.BattleNetFriendTag.Roleplaying,
};

function SocialUIUtil.GetBattleNetFriendTagInterestsUIOrder()
	return battleNetFriendTagInterestsUIOrder;
end

local battleNetFriendTagRoleUIOrder =
{
	Enum.BattleNetFriendTag.DamagerRole,
	Enum.BattleNetFriendTag.HealerRole,
	Enum.BattleNetFriendTag.TankRole,
};

function SocialUIUtil.GetBattleNetFriendTagRoleUIOrder()
	return battleNetFriendTagRoleUIOrder;
end

local presenceTypeToIcon =
{
	[Enum.SocialUIPresenceType.Unknown] = "friends-status-offline",
	[Enum.SocialUIPresenceType.Online] = "friends-status-online",
	[Enum.SocialUIPresenceType.Offline] = "friends-status-offline",
	[Enum.SocialUIPresenceType.Away] = "friends-status-away",
	[Enum.SocialUIPresenceType.Busy] = "friends-status-busy",
	[Enum.SocialUIPresenceType.AppearOffline] = "friends-status-offline",
};

function SocialUIUtil.GetIconForPresenceType(presenceType)
	return presenceTypeToIcon[presenceType] or presenceTypeToIcon[Enum.SocialUIPresenceType.Unknown];
end

local presenceTypeToLabel =
{
	[Enum.SocialUIPresenceType.Unknown] = SOCIAL_UI_PRESENCE_TYPE_LABEL_UNKNOWN,
	[Enum.SocialUIPresenceType.Online] = SOCIAL_UI_PRESENCE_TYPE_LABEL_ONLINE,
	[Enum.SocialUIPresenceType.Offline] = SOCIAL_UI_PRESENCE_TYPE_LABEL_OFFLINE,
	[Enum.SocialUIPresenceType.Away] = SOCIAL_UI_PRESENCE_TYPE_LABEL_AWAY,
	[Enum.SocialUIPresenceType.Busy] = SOCIAL_UI_PRESENCE_TYPE_LABEL_BUSY,
	[Enum.SocialUIPresenceType.AppearOffline] = SOCIAL_UI_PRESENCE_TYPE_LABEL_APPEAR_OFFLINE,
};

function SocialUIUtil.GetLabelForPresenceType(presenceType)
	return presenceTypeToLabel[presenceType] or presenceTypeToLabel[Enum.SocialUIPresenceType.Unknown];
end

function SocialUIUtil.GetPresenceTypeSelf()
	local _deprecatedPresenceID, _battleTag, _opaqueID, _broadcastText, isAFK, isBusy, _isRealIDEnabled = BNGetInfo();
	if isAFK then
		return Enum.SocialUIPresenceType.Away;
	elseif isBusy then
		return Enum.SocialUIPresenceType.Busy;
	end

	return Enum.SocialUIPresenceType.Online;
end

function SocialUIUtil.GetPresenceTypeForBattleNetAccountInfo(accountInfo)
	if not accountInfo or not accountInfo.gameAccountInfo.isOnline then
		return Enum.SocialUIPresenceType.Offline;
	elseif accountInfo.isAFK or accountInfo.gameAccountInfo.isGameAFK then
		return Enum.SocialUIPresenceType.Away;
	elseif accountInfo.isDND or accountInfo.gameAccountInfo.isGameBusy then
		return Enum.SocialUIPresenceType.Busy;
	end

	return Enum.SocialUIPresenceType.Online;
end

function SocialUIUtil.SetBattleNetPresenceFromSocialUIPresence(presenceType)
	if presenceType == Enum.SocialUIPresenceType.Online then
		C_BattleNet.SetAFK(false);
		C_BattleNet.SetDND(false);
	elseif presenceType == Enum.SocialUIPresenceType.Away then
		C_BattleNet.SetAFK(true);
	elseif presenceType == Enum.SocialUIPresenceType.Busy then
		C_BattleNet.SetDND(true);
	end
end

local function GetNameForIgnoreEntry(ignoreIndex)
	return C_FriendList.GetIgnoreName(ignoreIndex) or UNKNOWN;
end

local function GetNameForBattleNetInviteBlockEntry(blockIndex)
	local _blockID, blockName = BNGetBlockedInfo(blockIndex);
	return blockName or UNKNOWN;
end

local SocialBlockTypeToNameGetter = 
{
	[Enum.SocialUIBlockType.Ignore] = GetNameForIgnoreEntry,
	[Enum.SocialUIBlockType.BattleNetInviteBlock] = GetNameForBattleNetInviteBlockEntry,
};

function SocialUIUtil.GetBlockedName(blockType, blockIndex)
	local nameGetter = SocialBlockTypeToNameGetter[blockType];
	return nameGetter and nameGetter(blockIndex) or "";
end

local TOOLTIP_SEPARATOR_OPTIONS =
{
	height = 10,
	anchor = Enum.TooltipTextureAnchor.All,
	margin = { left = 0, right = 0, top = -2, bottom = -2 },
};

function SocialUIUtil.AddSeparatorToTooltip(tooltip)
	-- We need a line for the separator texture to anchor to (see Enum.TooltipTextureAnchor.All)
	-- We set wrapText to true because this line needs to span the full width of the tooltip.
	local wrapText = true;
	local r, g, b = 0, 0, 0;
	tooltip:AddLine(" ", r, g, b, wrapText);

	tooltip:AddTexture("Interface\\Common\\UI-TooltipDivider-Transparent", TOOLTIP_SEPARATOR_OPTIONS);
end

function SocialUIUtil.InitializeUserScaledDropdownButton(button)
	button.fontString:SetFontObject(UserScaledFontGameHighlight);

	local scaledPadding = TextSizeManager:GetScaledValue(6);
	button:SetHeight(button.fontString:GetLineHeight() + scaledPadding);
end

function SocialUIUtil.InitializeUserScaledDropdownTitle(title)
	title.fontString:SetFontObject(UserScaledFontGameNormal);

	local scaledPadding = TextSizeManager:GetScaledValue(6);
	title.fontString:SetHeight(title.fontString:GetLineHeight() + scaledPadding);
end

SocialUIScrollableElementExtentPreviewerMixin = {};

function SocialUIScrollableElementExtentPreviewerMixin:OnLoad()
	self.TemplateRegistrations = {};
	self.TemplateExtentCache = {};
end

local function BuildRegistrationInfoFromKeyValues(keyValues)
	local registrationInfo = {};
	if not keyValues then
		return registrationInfo;
	end

	for _index, keyValue in ipairs(keyValues) do
		local key = keyValue.key;
		if key == "baseHeight" then
			registrationInfo.baseHeight = tonumber(keyValue.value) or 0;
		elseif key == "useScaleWeight" then
			registrationInfo.useScaleWeight = (keyValue.value == "true");
		elseif key == "useScaleWeightForHeight" then
			registrationInfo.useScaleWeightForHeight = (keyValue.value == "true");
		elseif key == "scaleWeight" then
			registrationInfo.scaleWeight = tonumber(keyValue.value) or 1;
		end
	end

	return registrationInfo;
end

function SocialUIScrollableElementExtentPreviewerMixin:RegisterTemplateForExtentPreview(templateName, baseHeightCalculator)
	local templateAlreadyRegistered = self.TemplateRegistrations[templateName] ~= nil;
	if templateAlreadyRegistered then
		return;
	end

	local templateInfo = C_XMLUtil.GetTemplateInfo(templateName);
	if not templateInfo then
		return;
	end

	local registrationInfo = BuildRegistrationInfoFromKeyValues(templateInfo.keyValues);
	registrationInfo.baseHeightCalculator = baseHeightCalculator;

	self.TemplateRegistrations[templateName] = registrationInfo;
	self.TemplateExtentCache[templateName] = self:CalculateTemplateExtent(templateName);
end

local function CalculateScaledHeight(baseHeight, registrationInfo)
	if registrationInfo.useScaleWeightForHeight then
		return TextSizeManager:GetScaledValueWeighted(baseHeight, registrationInfo);
	else
		return TextSizeManager:GetScaledValue(baseHeight);
	end
end

function SocialUIScrollableElementExtentPreviewerMixin:CalculateTemplateExtent(templateName)
	local registrationInfo = self.TemplateRegistrations[templateName];
	if not registrationInfo then
		return 0;
	end

	local baseHeight;
	if registrationInfo.baseHeightCalculator then
		baseHeight = registrationInfo.baseHeightCalculator();
	else
		baseHeight = registrationInfo.baseHeight;
	end

	return baseHeight and CalculateScaledHeight(baseHeight, registrationInfo) or 0;
end

function SocialUIScrollableElementExtentPreviewerMixin:ClearTemplateExtentCache()
	table.wipe(self.TemplateExtentCache);
end

function SocialUIScrollableElementExtentPreviewerMixin:GetTemplateExtent(templateName)
	if not self.TemplateExtentCache[templateName] and self.TemplateRegistrations[templateName] then
		self.TemplateExtentCache[templateName] = self:CalculateTemplateExtent(templateName);
	end

	return self.TemplateExtentCache[templateName] or 0;
end

function SocialUIScrollableElementExtentPreviewerMixin:RegisterScrollableTemplatesForExtentPreview(templates)
	for _index, templateEntry in ipairs(templates) do
		local hasCalculatorOverride = type(templateEntry) == "table";
		if hasCalculatorOverride then
			self:RegisterTemplateForExtentPreview(templateEntry.template, templateEntry.baseHeightCalculator);
		else
			self:RegisterTemplateForExtentPreview(templateEntry);
		end
	end
end

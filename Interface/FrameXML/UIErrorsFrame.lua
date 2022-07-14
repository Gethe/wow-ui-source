UIErrorsMixin = {};

function UIErrorsMixin:OnLoad()
	self:RegisterEvent("SYSMSG");
	self:RegisterEvent("UI_INFO_MESSAGE");
	self:RegisterEvent("UI_ERROR_MESSAGE");

	self.flashingFontStrings = {};
end

function UIErrorsMixin:OnEvent(event, ...)
	if event == "SYSMSG" then
		local message, r, g, b = ...;
		self:AddMessage(message, r, g, b, 1.0);
	elseif event == "UI_INFO_MESSAGE" then
		local messageType, message = ...;
		self:TryDisplayMessage(messageType, message, YELLOW_FONT_COLOR:GetRGB());
	elseif event == "UI_ERROR_MESSAGE" then
		local messageType, message = ...;
		self:TryDisplayMessage(messageType, message, RED_FONT_COLOR:GetRGB());
	end
end

local FLASH_DURATION_SEC = 0.2;
function UIErrorsMixin:OnUpdate()
	local now = GetTime();
	local needsMoreUpdates = false;
	for fontString, timeStart in pairs(self.flashingFontStrings) do
		if fontString:GetText() == fontString.origMsg then
			if fontString:IsShown() and now - timeStart <= FLASH_DURATION_SEC then
				local percent = (now - timeStart) / FLASH_DURATION_SEC;
				local easedPercent = (percent > .5 and (1.0 - percent) / .5 or percent / .5) * .4;

				fontString:SetTextColor(fontString.origR + easedPercent, fontString.origG + easedPercent, fontString.origB + easedPercent);
				needsMoreUpdates = true;
			else
				fontString:SetTextColor(fontString.origR, fontString.origG, fontString.origB);
				self.flashingFontStrings[fontString] = nil;
			end
		else
			self.flashingFontStrings[fontString] = nil;
		end
	end

	if not needsMoreUpdates then
		self:SetScript("OnUpdate", nil);
	end
end

local THROTTLED_MESSAGE_TYPES = {
	[LE_GAME_ERR_SPELL_FAILED_TOTEMS] = true,
	[LE_GAME_ERR_SPELL_FAILED_EQUIPPED_ITEM] = true,
	[LE_GAME_ERR_SPELL_ALREADY_KNOWN_S] = true,
	[LE_GAME_ERR_SPELL_FAILED_SHAPESHIFT_FORM_S] = true,
	[LE_GAME_ERR_SPELL_FAILED_ALREADY_AT_FULL_MANA] = true,
	[LE_GAME_ERR_OUT_OF_MANA] = true,
	[LE_GAME_ERR_SPELL_OUT_OF_RANGE] = true,
	[LE_GAME_ERR_SPELL_FAILED_S] = true,
	[LE_GAME_ERR_SPELL_FAILED_REAGENTS] = true,
	[LE_GAME_ERR_SPELL_FAILED_REAGENTS_GENERIC] = true,
	[LE_GAME_ERR_SPELL_FAILED_NOTUNSHEATHED] = true,
	[LE_GAME_ERR_SPELL_UNLEARNED_S] = true,
	[LE_GAME_ERR_SPELL_FAILED_EQUIPPED_SPECIFIC_ITEM] = true,
	[LE_GAME_ERR_SPELL_FAILED_ALREADY_AT_FULL_POWER_S] = true,
	[LE_GAME_ERR_SPELL_FAILED_EQUIPPED_ITEM_CLASS_S] = true,
	[LE_GAME_ERR_SPELL_FAILED_ALREADY_AT_FULL_HEALTH] = true,
	[LE_GAME_ERR_GENERIC_NO_VALID_TARGETS] = true,

	[LE_GAME_ERR_ITEM_COOLDOWN] = true,
	[LE_GAME_ERR_CANT_USE_ITEM] = true,
	[LE_GAME_ERR_SPELL_FAILED_ANOTHER_IN_PROGRESS] = true,
};

local BLACK_LISTED_MESSAGE_TYPES = {
	[LE_GAME_ERR_ABILITY_COOLDOWN] = true,
	[LE_GAME_ERR_SPELL_COOLDOWN] = true,
	[LE_GAME_ERR_SPELL_FAILED_ANOTHER_IN_PROGRESS] = true,

	[LE_GAME_ERR_OUT_OF_HOLY_POWER] = true,
	[LE_GAME_ERR_OUT_OF_POWER_DISPLAY] = true,
	[LE_GAME_ERR_OUT_OF_SOUL_SHARDS] = true,
	[LE_GAME_ERR_OUT_OF_FOCUS] = true,
	[LE_GAME_ERR_OUT_OF_COMBO_POINTS] = true,
	[LE_GAME_ERR_OUT_OF_CHI] = true,
	[LE_GAME_ERR_OUT_OF_PAIN] = true,
	[LE_GAME_ERR_OUT_OF_HEALTH] = true,
	[LE_GAME_ERR_OUT_OF_RAGE] = true,
	[LE_GAME_ERR_OUT_OF_ARCANE_CHARGES] = true,
	[LE_GAME_ERR_OUT_OF_RANGE] = true,
	[LE_GAME_ERR_OUT_OF_ENERGY] = true,
	[LE_GAME_ERR_OUT_OF_LUNAR_POWER] = true,
	[LE_GAME_ERR_OUT_OF_RUNIC_POWER] = true,
	[LE_GAME_ERR_OUT_OF_INSANITY] = true,
	[LE_GAME_ERR_OUT_OF_RUNES] = true,
	[LE_GAME_ERR_OUT_OF_FURY] = true,
	[LE_GAME_ERR_OUT_OF_MAELSTROM] = true,
};

function UIErrorsMixin:FlashFontString(fontString)
	if GetCVarBool("flashErrorMessageRepeats") then
		if self.flashingFontStrings[fontString] then
			self.flashingFontStrings[fontString] = GetTime();
		else
			fontString.origR, fontString.origG, fontString.origB = fontString:GetTextColor();
			fontString.origMsg = fontString:GetText();
			self.flashingFontStrings[fontString] = GetTime();
		end
		self:SetScript("OnUpdate", self.OnUpdate);
	end
end

function UIErrorsMixin:TryFlashingExistingMessage(messageType, message)
	local existingFontString = self:GetFontStringByID(messageType);
	if existingFontString and existingFontString:GetText() == message then
		self:FlashFontString(existingFontString);

		self:ResetMessageFadeByID(messageType);
		return true;
	end
	return false;
end

function UIErrorsMixin:ShouldDisplayMessageType(messageType, message)
	if BLACK_LISTED_MESSAGE_TYPES[messageType] then
		return false;
	end
	if THROTTLED_MESSAGE_TYPES[messageType] then
		if self:TryFlashingExistingMessage(messageType, message) then
			return false;
		end
	end

	return true;
end

function UIErrorsMixin:TryDisplayMessage(messageType, message, r, g, b)
	if self:ShouldDisplayMessageType(messageType, message) then
		self:AddMessage(message, r, g, b, 1.0, messageType);

		local errorStringId, soundKitID, voiceID = GetGameMessageInfo(messageType);
		if voiceID then
			PlayVocalErrorSoundID(voiceID);
		elseif soundKitID then
			PlaySound(soundKitID);
		end
	end
end

local function AddExternalMessage(self, message, color)
	if not self:TryFlashingExistingMessage(LE_GAME_ERR_SYSTEM, message) then
		local r, g, b = color:GetRGB();
		self:AddMessage(message, r, g, b, 1.0, LE_GAME_ERR_SYSTEM);
	end
end

function UIErrorsMixin:AddExternalErrorMessage(message)
	AddExternalMessage(self, message, RED_FONT_COLOR);
end

function UIErrorsMixin:AddExternalWarningMessage(message)
	AddExternalMessage(self, message, YELLOW_FONT_COLOR);
end
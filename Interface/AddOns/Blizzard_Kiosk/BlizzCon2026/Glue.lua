local experienceConfig =
{
	[Enum.Bc26Experience.Skyborne] =
	{
		GetTemplateSetID = function()
			return Kiosk.GetCharacterTemplateSetID(Enum.KioskExperience.One) or KIOSK_DEFAULT_TEMPLATE_SET_ID1;
		end,
		GetSessionDuration = function()
			return Kiosk.GetSessionDuration(Enum.KioskExperience.One) or KIOSK_DEFAULT_SESSION_DURATION1;
		end,
	},
	[Enum.Bc26Experience.Dungeon] =
	{
		GetTemplateSetID = function()
			return Kiosk.GetCharacterTemplateSetID(Enum.KioskExperience.Two) or KIOSK_DEFAULT_TEMPLATE_SET_ID2;
		end,
		GetSessionDuration = function()
			return Kiosk.GetSessionDuration(Enum.KioskExperience.Two) or KIOSK_DEFAULT_SESSION_DURATION2;
		end,
	}
};

GlueKioskFrameMixin = CreateFromMixins(KioskFrameMixin);

function GlueKioskFrameMixin:OnLoad()
	KioskFrameMixin.OnLoad(self);

	self:RegisterEvent("CHARACTER_CREATION_RESULT");
	self:RegisterEvent("CHARACTER_LIST_RETRIEVAL_RESULT");

	-- Restarting the session at glues causes character select to dump
	-- the character list and not attempt to recover it. Always request
	-- this list so our execution steps are reliable.
	GetCharacterListUpdate();

	C_Log.LogMessage("Kiosk UI Loaded.");
end

local function DoEnterWorld()
	C_Log.LogMessage("Kiosk: Entering world.");

	EnterWorld();
end

function GlueKioskFrameMixin:TryCharacterDeletion()
	-- Deletion forbidden after receipt of a character being created.
	if self.createdGuid then
		return;
	end

	-- Allow one attempt at deleting characters. We want to avoid perpetual deletion
	-- attempts that could cause character creation or new character selection to fail.
	if self.checkedDeletion then
		return;
	end

	-- Client side deletion requires the character list to first be known.
	if not IsCharacterListReceived() then
		return;
	end

	self.checkedDeletion = true;

	if GetNumCharacters() > 0 then
		KioskDeleteAllCharacters();

		C_Log.LogMessage("Kiosk: Deleting characters.");
	else
		C_Log.LogMessage("Kiosk: Skipping character deletion, no characters to delete.");
	end
end

function GlueKioskFrameMixin:OnEvent(event, ...)
	KioskFrameMixin.OnEvent(self, event, ...);
	C_Log.LogMessage(string.format("Kiosk event: %s", event));

	if event == "KIOSK_SESSION_RESTART" then
		-- Reload ensures we start in a pristine Kiosk and UI state.
		ReloadUI();
	elseif event == "CHARACTER_CREATION_RESULT" then
		local success, _errorToken, guid = ...;
		if not success then
			return;
		end
		-- Store the character guid so we can select it after the next character
		-- list arrives on the client.
		self.createdGuid = guid;
	elseif event == "CHARACTER_LIST_RETRIEVAL_RESULT" then
		-- Will exit if a character is already created.
		self:TryCharacterDeletion();

		-- Attempt to select the created character, otherwise, if already selected, enter world.
		if self.createdGuid then
			if not self.hasAttemptedSelection then
				self.hasAttemptedSelection = true;

				if GetCharacterGUID(GetCharacterSelection()) ~= self.createdGuid then
					self:RegisterEvent("UPDATE_SELECTED_CHARACTER");

					self.pendingSelectionGuid = self.createdGuid;

					for charIndex = 1, GetNumCharacters() do
						if GetCharacterGUID(charIndex) == self.pendingSelectionGuid then
							SelectCharacter(charIndex);
							break;
						end
					end
				else
					DoEnterWorld();
				end
			end
		end

		KioskModeSplash:CheckEnabled();
	elseif event == "UPDATE_SELECTED_CHARACTER" then
		-- See CHARACTER_LIST_RETRIEVAL_RESULT
		assertsafe(self.pendingSelectionGuid ~= nil);
		if GetCharacterGUID(GetCharacterSelection()) == self.pendingSelectionGuid then
			DoEnterWorld();
		end
	end
end

GlueKioskExperienceButtonMixin = CreateFromMixins(ButtonStateBehaviorMixin);

function GlueKioskExperienceButtonMixin:GetBackgroundAtlas()
	if self:IsDown() then
		return "Kiosk-Mode-button-pressed-c60";
	end
	return "Kiosk-Mode-button-c60";
end

function GlueKioskExperienceButtonMixin:OnButtonStateChanged()
	local atlas = self:GetBackgroundAtlas();
	self.Background:SetAtlas(atlas, TextureKitConstants.UseAtlasSize);

	local showHighlight = self.selected or self:IsOver();
	self.Highlight:SetShown(showHighlight);
end

function GlueKioskExperienceButtonMixin:SetSelected(selected)
	self.selected = selected;
	self:OnButtonStateChanged();
end

GlueKioskModeSplashMixin = {};

function GlueKioskModeSplashMixin:OnLoad()
	self.enableTimeRemaining = tonumber(GetCVar("KioskWarmupSeconds")) or 10;

	self:SetParent(GetAppropriateTopLevelParent());
	self:SetFrameStrata("FULLSCREEN");

	self.Background:SetTexture("Interface/CharacterSelection/Kiosk-Mode-Welcome-background-c60");

	local function SetupButton(button, text, callback)
		button.Text:SetText(text);

		button:SetScript("OnClick", function()
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);

			callback();
		end);
	end
	
	local function SelectExperience(experience)
		local config = experienceConfig[experience];

		C_CharacterCreation.SetCharacterTemplateSetID(config.GetTemplateSetID());

		Kiosk.StartSession(config.GetSessionDuration());

		self:Hide();

		GlueParent_SetScreen("charcreate");

		C_BlizzCon2026.SetExperience(experience);
	end

	SetupButton(self.StarterButton, "Starting Experience", function()
		SelectExperience(Enum.Bc26Experience.Skyborne);
	end);

	SetupButton(self.DungeonButton, "Dungeon Experience", function()
		SelectExperience(Enum.Bc26Experience.Dungeon);
	end);

	self:SetButtonsEnabled(false);
end

function GlueKioskModeSplashMixin:AreConditionsMet()
	-- The character list must have been recieved so we have the required
	-- race unlock information for the templates to not be rejected.
	if not IsCharacterListReceived() then
		return false;
	end

	-- The fallback timer must have reached 0. This is being extra careful
	-- in case there is another message that needs to be processed before
	-- we can safely continue.
	if self.enableTimeRemaining > 0 then
		return false;
	end

	return true;
end

function GlueKioskModeSplashMixin:CheckEnabled()
	self:SetButtonsEnabled(self:AreConditionsMet());
end

function GlueKioskModeSplashMixin:OnUpdate(elapsed)
	self.enableTimeRemaining = self.enableTimeRemaining - elapsed;
	if self.enableTimeRemaining <= 0 then
		self:SetScript("OnUpdate", nil);
		self:CheckEnabled();
		C_Log.LogMessage("Kiosk: Warmup time expired.");
	end
end

function GlueKioskModeSplashMixin:SetButtonsEnabled(enabled)
	self.StarterButton:SetEnabled(enabled);
	self.DungeonButton:SetEnabled(enabled);
	self.Spinner:SetShown(not enabled);
end

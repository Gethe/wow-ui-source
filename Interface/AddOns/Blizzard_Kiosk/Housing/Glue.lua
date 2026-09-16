-- Move required code from Unused.lua to here as needed.
GlueKioskFrameMixin = {};

-- This is currently set to false because the Housing Kiosk demo has no glue component at all. However
-- because all of these functions are still called by character select code, it needs to continue to
-- exist rather than being moved to Unused.lua/xml.
local function HasGlueFlow()
	return false;
end

function GlueKioskFrameMixin:OnEvent(event, ...)
	KioskFrameMixin.OnEvent(self, event, ...);

	if event == "KIOSK_SESSION_EXPIRATION_CHANGED" then
		if UIErrorsFrame then
			UIErrorsFrame:AddExternalWarningMessage(KIOSK_SESSION_TIMER_CHANGED);
		end

		StaticPopup_Show("OKAY", KIOSK_SESSION_TIMER_CHANGED);
	end
end

function GlueKioskFrameMixin:HandleCharacterCreateOnShow()
	if not HasGlueFlow() then
		return false;
	end

	if Kiosk.IsCompetitiveModeEnabled() then
		return false;
	end

	local templateIndex = Kiosk.GetCharacterTemplateSetIndex();
	if templateIndex then
		C_CharacterCreation.SetCharacterTemplate(templateIndex);
	else
		C_CharacterCreation.ClearCharacterTemplate();
	end

	return true;
end

function GlueKioskFrameMixin:NavBack()
	if not HasGlueFlow() then
		return false;
	end

	if Kiosk.IsCompetitiveModeEnabled() then
		return false;
	end

	GlueParent_SetScreen("kioskmodesplash");
	return true;
end

function GlueKioskFrameMixin:HandleCreateCharacter()
	if not HasGlueFlow() then
		return false;
	end

	self:SetAutoEnterWorld(true);
	return true;
end

function GlueKioskFrameMixin:HandleCheckEnterWorld()
	if not HasGlueFlow() then
		return false;
	end

	if KioskMode_IsWaitingOnTrial() then
		return false;
	end

	if self:GetAutoEnterWorld() then
		EnterWorld();
		return true;
	end

	if not IsGMClient() then
		KioskDeleteAllCharacters();
	end

	if not Kiosk.IsCompetitiveModeEnabled() then
		GlueParent_SetScreen("kioskmodesplash");
	end

	return true;
end

function GlueKioskFrameMixin:HandleCharacterListUpdate()
	if not HasGlueFlow() then
		return false;
	end

	if Kiosk.IsCompetitiveModeEnabled() then
		return false;
	end

	GlueParent_SetScreen("kioskmodesplash");
	return true;
end

function GlueKioskFrameMixin:HandleReturnToCharacterSelect()
	if not HasGlueFlow() then
		return false;
	end

	GlueParent_SetScreen("kioskmodesplash");
	return true;
end

function GlueKioskFrameMixin:HandleCharacterSelectShown()
	if not HasGlueFlow() then
		return false;
	end

	if Kiosk.IsCompetitiveModeEnabled() then
		return false;
	end

	CharacterSelectUI:Hide();
	return true;
end

function GlueKioskFrameMixin:HandleAutoLoginToRealm()
	if not HasGlueFlow() then
		return false;
	end

	if Kiosk.IsCompetitiveModeEnabled() then
		return false;
	end

	GlueParent_SetScreen("kioskmodesplash");
	return true;
end

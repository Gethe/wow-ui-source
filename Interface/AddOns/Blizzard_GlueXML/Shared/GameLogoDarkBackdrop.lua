GameLogoDarkBackdropMixin = {};

function GameLogoDarkBackdropMixin:OnLoad()
	self:RegisterEvent("GAME_MODE_DISPLAY_INFO_UPDATED");
	self:Update();
end

function GameLogoDarkBackdropMixin:OnEvent(event)
	if event == "GAME_MODE_DISPLAY_INFO_UPDATED" then
		self:Update();
	end
end

function GameLogoDarkBackdropMixin:Update()
	local gameModeDisplayInfo = C_GameRules.GetCurrentGameModeDisplayInfo();
	if gameModeDisplayInfo then
		if gameModeDisplayInfo.logoUsesDarkBackdrop then
			self.BackdropTexture:Show();
			return;
		end
	end

	self.BackdropTexture:Hide();
end

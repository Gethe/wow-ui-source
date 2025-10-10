--[[ Shared EditModeManagerOverrides ]]
--[[
	Override these functions for each game flavor (e.g., Mainline, Classic, etc.).
]]

function EditModeAccountSettingsMixin:PrepareSettingsCheckButtonVisibility()
	-- As a default, do not hide any settings.
	for _, checkButton in pairs(self.settingsCheckButtons) do
		checkButton.shouldHide = false;
	end
end

function EditModeAccountSettingsMixin:EditModeFrameSetup()
end

function EditModeAccountSettingsMixin:EditModeFrameReset()
end

function EditModeManagerFrameMixin:GetRightActionBars()
	return { };
end

function EditModeManagerFrameMixin:GetRightActionBarTopLimit()
	return UIParent:GetTop();
end

function EditModeManagerFrameMixin:GetRightActionBarBottomLimit()
	return UIParent:GetBottom();
end

function EditModeManagerFrameMixin:GetBottomActionBars()
	return { };
end

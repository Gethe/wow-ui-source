function EditModePersonalResourceDisplaySystemMixin:ShouldShowSetting(setting)
	if setting == Enum.EditModePersonalResourceDisplaySetting.HideClassInfoOnPlayerFrame then
		return false;
	end

	return EditModeSystemMixin.ShouldShowSetting(self, setting);
end

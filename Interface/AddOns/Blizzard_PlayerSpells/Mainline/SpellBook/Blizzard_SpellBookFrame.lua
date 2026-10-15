function SpellBookFrameMixin:SetupSettingsDropdown()
	self.SettingsDropdown:SetupMenu(function(dropdown, rootDescription)
		self:SetupHidePassivesCheckbox(rootDescription);
	end);
end

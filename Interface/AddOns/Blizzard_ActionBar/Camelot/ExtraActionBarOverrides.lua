function ActionButtonUtil.IsExtraActionButtonDisabled()
	-- Camelot has no extra action bar and no EXTRAACTIONBUTTON1 binding, so Quick Keybind mode shouldn't offer a placeholder button.
	return true;
end

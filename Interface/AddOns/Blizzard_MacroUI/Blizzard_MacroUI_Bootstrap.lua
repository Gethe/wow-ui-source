local AddonName = ...;

function MacroFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ShowMacroFrame()
	if MacroFrame_LoadUI() then
		MacroFrame_Show();
	end
end

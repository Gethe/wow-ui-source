local AddonName = ...;

function ItemSocketingFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function ShowItemSocketingFrame()
	if ItemSocketingFrame_LoadUI() then
		ItemSocketingFrame_Update();
		ShowUIPanel(ItemSocketingFrame);
	end
end

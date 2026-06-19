local AddonName = ...;

function AnimaDiversionFrame_LoadUI()
	return LoadAddOnWithErrorHandling(AddonName);
end

function TryShowAnimaDiversionFrame(...)
	if AnimaDiversionFrame_LoadUI() then
		AnimaDiversionFrame:TryShow(...);
	end
end

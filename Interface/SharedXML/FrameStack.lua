do 
	local frameStackLoader = CreateFrame("FRAME");
	frameStackLoader:RegisterEvent("TOGGLE_FRAMESTACK");

	frameStackLoader:SetScript("OnEvent", function(self, event, ...)
		if (event == "TOGGLE_FRAMESTACK") then
			if (IsOnGlueScreen()) then
				LoadAddOn("Blizzard_DebugTools");
			else
				UIParentLoadAddOn("Blizzard_DebugTools");
			end

			local showHidden, showRegions, showAnchors = ...;
			if (showHidden == nil) then
				showHidden = false;
			end
			if (showRegions == nil) then
				showRegions = true;
			end
			if (showAnchors == nil) then
				showAnchors = true;
			end

			FrameStackTooltip_Toggle(showHidden, showRegions, showAnchors);
		end
	end);
end
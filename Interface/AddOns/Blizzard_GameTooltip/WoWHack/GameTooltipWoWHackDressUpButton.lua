
local function GameTooltip_WoWHackShowDressUpButton(tooltip, _tooltipData)
	local ctrlBinding = GetBindingAction("CTRL");
	if tooltip.IsEmbedded or not GetCVarBool("simpleKeybinds") or
		not C_GameRules.IsGameRuleActive(Enum.GameRule.AllowSimpleKeybindOption) or
		(not ctrlBinding or ctrlBinding == "" or ctrlBinding == "NONE") or
		(tooltip ~= ItemRefTooltip) then
		return;
	end

	local _, itemLink = TooltipUtil.GetDisplayedItem(tooltip);
	if itemLink and LinkUtil.IsDressUpLink(itemLink) then
		local button = tooltip.DressUpButton;
		if not button then
			button = CreateFrame("Button", nil, tooltip, "GameTooltipWoWHackDressUpButtonTemplate");
			button:SetScript("OnClick", function(self)
				if self.itemLink then
					DressUpLink(self.itemLink);
				end
			end);
			
			button:Hide();
			tooltip.DressUpButton = button;
		end
		button.itemLink = itemLink;
		GameTooltip_InsertFrame(tooltip, button, 4);
		-- The tooltip size doesn't fully get set until the frame ends, so we delay to size and show the button until next frame. 
		RunNextFrame(function()
			if tooltip.DressUpButton:IsShown() and button.itemLink == itemLink then
				button:SetWidth(tooltip:GetWidth() - 21);
				button:Show();
			end
		end);
	end
end

-- Empty function to overwrite comparisons.
GameTooltip_ShowCompareItem = function(...) 
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, GameTooltip_WoWHackShowDressUpButton);


function ExpBarMixin:UpdateCurrentText()
	if (self.maxBar > 0) then
		self:SetBarText("(" .. math.ceil((self.currXP / self.maxBar) * 100) .. "%) " .. self.currXP .. " / " .. self.maxBar);
	end
end

function ExpBarMixin:UpdateStatusBarTextures(isRested)
	if (isRested) then
		self.StatusBar:SetStatusBarColor(0.0, 0.39, 0.88, 1.0);
		self.ExhaustionLevelFillBar:SetVertexColor(0.0, 0.39, 0.88, 0.15);
		self.ExhaustionTick.Highlight:SetVertexColor(0.0, 0.39, 0.88);
	else
		self.StatusBar:SetStatusBarColor(0.58, 0.0, 0.55, 1.0);
		self.ExhaustionLevelFillBar:SetVertexColor(0.58, 0.0, 0.55, 0.15);
		self.ExhaustionTick.Highlight:SetVertexColor(0.58, 0.0, 0.55);
	end
end

function ExhaustionTickMixin:ExhaustionToolTipText()
	local exhaustionStateID, exhaustionStateName, exhaustionStateMultiplier = GetRestState();
	exhaustionStateMultiplier = exhaustionStateMultiplier * 100;
	local restedText = format(EXHAUST_TOOLTIP1, exhaustionStateName, exhaustionStateMultiplier);

	if ( GetCVar("showNewbieTips") == "1" ) then
		local tooltipText = NEWBIE_TOOLTIP_XPBAR .. "\n\n" .. restedText;
		GameTooltip_AddNewbieTip(self, XPBAR_LABEL, 1.0, 1.0, 1.0, tooltipText, 1);
	else
		local x,y = self:GetCenter();
		if ( x ~= nil and self:IsVisible() ) then
			if ( x >= ( GetScreenWidth() / 2 ) ) then
				GameTooltip:SetOwner(self, "ANCHOR_LEFT");
			else
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
			end
		else
			GameTooltip_SetDefaultAnchor(GameTooltip, UIParent);
		end

		GameTooltip:SetText(restedText);
	end
end

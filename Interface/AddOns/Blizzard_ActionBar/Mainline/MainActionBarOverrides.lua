
function MainActionBarMixin:UpdateEndCaps(overrideHideEndCaps)
	local factionGroup = UnitFactionGroup("player");
	local showEndCaps = false;

	if ( factionGroup and factionGroup ~= "Neutral" ) then

		if ( factionGroup == "Alliance" ) then
			self.EndCaps.LeftEndCap:SetAtlas("ui-hud-actionbar-gryphon-left");
			self.EndCaps.RightEndCap:SetAtlas("ui-hud-actionbar-gryphon-right");
		elseif ( factionGroup == "Horde" ) then
			self.EndCaps.LeftEndCap:SetAtlas("ui-hud-actionbar-wyvern-left");
			self.EndCaps.RightEndCap:SetAtlas("ui-hud-actionbar-wyvern-right");
		end

		showEndCaps = true;
	end

	self.EndCaps:SetShown(showEndCaps and not overrideHideEndCaps);
end

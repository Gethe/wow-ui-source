-------------------------------------------------------
----------Constants
-------------------------------------------------------
local MAX_VERBOSE_LFG_ACTIVITIES_MINIMAP_TOOLTIP = 20;

-------------------------------------------------------
----------LFGEyeTemplateMixin
-------------------------------------------------------
LFGEyeTemplateMixin = {};

function LFGEyeTemplateMixin:OnLoad()
	self:StopAnimating();
end

function LFGEyeTemplateMixin:OnUpdate(elapsed)
	local textureInfo = LFG_EYE_TEXTURES[self.queueType or "default"];
	AnimateTexCoords(self.Texture, textureInfo.width, textureInfo.height, textureInfo.iconSize, textureInfo.iconSize, textureInfo.frames, elapsed, textureInfo.delay)
end

function LFGEyeTemplateMixin:StartAnimating()
	self:SetScript("OnUpdate", self.OnUpdate);
end

function LFGEyeTemplateMixin:StopAnimating()
	self:SetScript("OnUpdate", nil);
	if ( self.Texture.frame ) then
		self.Texture.frame = 1;	--To start the animation over.
	end
	local textureInfo = LFG_EYE_TEXTURES[self.queueType or "default"];
	self.Texture:SetTexCoord(0, textureInfo.iconSize / textureInfo.width, 0, textureInfo.iconSize / textureInfo.height);
end

-------------------------------------------------------
----------LFGMinimapMixin
-------------------------------------------------------
LFGMinimapMixin = {};

function LFGMinimapMixin:OnLoad()
	self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE");
	self:RegisterEvent("PLAYER_ENTERING_WORLD");
	self:RegisterUnitEvent("UNIT_LEVEL", "player");
	self:RegisterEvent("UPDATE_BINDINGS");
	self:RegisterForClicks("LeftButtonUp", "RightButtonUp");
	self:SetFrameLevel(self:GetFrameLevel()+1)

	self:UpdateTooltipText();
	self:UpdateVisibility();
end

function LFGMinimapMixin:UpdateVisibility()
	local canUse, failureReason = C_LFGInfo.CanPlayerUsePremadeGroup();
	self:SetShown(canUse);
end

function LFGMinimapMixin:UpdateTooltipText()
	self.tooltipText = MicroButtonTooltipText(LFG_BUTTON, "TOGGLEGROUPFINDER");
	self.newbieText = NEWBIE_TOOLTIP_LFGPARENT;
end

function LFGMinimapMixin:OnEvent(event)
	if ( event == "LFG_LIST_ACTIVE_ENTRY_UPDATE" ) then
		if ( C_LFGList.HasActiveEntryInfo() ) then
			self.eye:StartAnimating();
		else
			self.eye:StopAnimating();
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		self:UpdateVisibility();
	elseif ( event == "UNIT_LEVEL" ) then
		self:UpdateVisibility();
	elseif ( event == "UPDATE_BINDINGS" ) then
		self:UpdateTooltipText();
	end
end

function LFGMinimapMixin:OnClick(button)
	local hasEditableListing = C_LFGList.HasActiveEntryInfo() and LFGListingUtil_CanEditListing();
	if ( button == "LeftButton" or not hasEditableListing ) then
		ToggleLFGParentFrame();
	elseif ( button == "RightButton" ) then
		MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
			local editButton = rootDescription:CreateButton(LFG_LIST_EDIT, function()
				ShowLFGParentFrame(1);
			end);
			editButton:SetEnabled(hasEditableListing);
	
	
			local unlistButton = rootDescription:CreateButton(LFG_LIST_UNLIST, function()
				C_LFGList.RemoveListing();
			end);
			unlistButton:SetEnabled(hasEditableListing);
		end);
	end
end

function LFGMinimapMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT");
	local activeEntryInfo = C_LFGList.GetActiveEntryInfo();

	if (activeEntryInfo) then
		local numActivities = #activeEntryInfo.activityIDs;
		if (numActivities > 0) then
			local verbose = numActivities <= MAX_VERBOSE_LFG_ACTIVITIES_MINIMAP_TOOLTIP;
			GameTooltip:SetText(LFG_LIST_MY_ACTIVITY_LIST_HEADER, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			
			local organizedActivities = LFGUtil_OrganizeActivitiesByActivityGroup(activeEntryInfo.activityIDs);
			local activityGroupIDs = GetKeysArray(organizedActivities);
			LFGUtil_SortActivityGroupIDs(activityGroupIDs);
			for _, activityGroupID in ipairs(activityGroupIDs) do
				local activityIDs = organizedActivities[activityGroupID];
				if (activityGroupID == 0) then -- Free-floating activities (no group)
					for _, activityID in ipairs(activityIDs) do
						local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
						local activityName = LFGUtil_GetActivityInfoName(activityInfo);
						if (activityInfo and activityName ~= "") then
							GameTooltip:AddLine(activityName);
						end
					end
				else -- Grouped activities
					local activityGroupName = C_LFGList.GetActivityGroupInfo(activityGroupID);
					if (verbose) then
						GameTooltip:AddLine(activityGroupName, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
						for _, activityID in ipairs(activityIDs) do
							local activityInfo = C_LFGList.GetActivityInfoTable(activityID);
							local activityName = LFGUtil_GetActivityInfoName(activityInfo);
							if (activityInfo and activityName ~= "") then
								GameTooltip:AddLine(string.format(LFG_LIST_INDENT, activityName));
							end
						end
					else
						GameTooltip:AddLine(activityGroupName.." ("..string.format(LFGBROWSE_ACTIVITY_COUNT, #activityIDs)..")", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
					end
				end
			end

			if (activeEntryInfo.comment and activeEntryInfo.comment ~= "") then
				GameTooltip:AddLine(string.format(LFG_LIST_COMMENT_FORMAT, activeEntryInfo.comment), DISABLED_FONT_COLOR.r, DISABLED_FONT_COLOR.g, DISABLED_FONT_COLOR.b);
			end

			GameTooltip:Show();
		else
			GameTooltip:Hide();
		end
	else
		-- No Active Entry; show standard button tooltip.
		GameTooltip_AddNewbieTip(self, self.tooltipText, 1.0, 1.0, 1.0, self.newbieText);
	end
end

function LFGMinimapMixin:OnLeave()
	GameTooltip:Hide();
end
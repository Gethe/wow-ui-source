
-- These are functions that were deprecated in 9.1.5, and will be removed in the next expansion.
-- Please upgrade to the updated APIs as soon as possible.

if not IsPublicBuild() then
	return;
end

-- Tooltips have moved to use the NineSlicePanel interface. Some old functionality remains (see SharedXML\SharedTooltipTemplates.lua)
do
	-- These functions are no longer meaningful
	TooltipBackdropTemplateMixin.OnBackdropLoaded = function() end;
	TooltipBackdropTemplateMixin.OnBackdropSizeChanged = function() end;
	TooltipBackdropTemplateMixin.GetEdgeSize = function() return 0 end;
	TooltipBackdropTemplateMixin.GetBackdropCoordValue = function() return 0 end;
	TooltipBackdropTemplateMixin.SetupTextureCoordinates = function() end;
	TooltipBackdropTemplateMixin.SetupPieceVisuals = function() end;
	TooltipBackdropTemplateMixin.HasBackdropInfo = function() return false end;
	TooltipBackdropTemplateMixin.GetBackdrop = function() return nil end;

	-- These functions will just apply the default backdrop and show the artwork
	TooltipBackdropTemplateMixin.ApplyBackdrop = function(self)
		local layout = NineSliceUtil.GetLayout("TooltipDefaultLayout");
		NineSliceUtil.ApplyLayout(self.NineSlice, layout);
		self.NineSlice:Show();
	end;
	TooltipBackdropTemplateMixin.SetBackdrop = function(self)
		local layout = NineSliceUtil.GetLayout("TooltipDefaultLayout");
		NineSliceUtil.ApplyLayout(self.NineSlice, layout);
		self.NineSlice:Show();
	end;

	-- This function will just hide the artwork
	TooltipBackdropTemplateMixin.ClearBackdrop = function(self)
		self.NineSlice:Hide();
	end;
end

-- Item Upgrade Revamp these functions have been converted to tag
do
	function GetItemUpgradeItemInfo(numUpgradeLevels)
		if ( not numUpgradeLevels ) then
			numUpgradeLevels = 1;
		end

		local upgradeInfo = C_ItemUpgrade.GetItemUpgradeItemInfo();
		if (not upgradeInfo) then
			return;
		end

		local iconID = upgradeInfo.iconID;
		local name = upgradeInfo.name;
		local displayQuality = upgradeInfo.displayQuality;
		--No longer have access to the bound status from this function
		local boundStatus = "";
		local upgradeProgress = upgradeInfo.currUpgrade;
		local maxUpgrade = upgradeInfo.maxUpgrade;

		--Deprecated function only used one currency not multiple as the new version supports
		local totalCost = 0;
		local currencyID = 0;
		if( upgradeInfo.upgradeLevelInfos[2] ) then
			local upgradeLevel =  upgradeInfo.upgradeLevelInfos[2];
			currencyID = upgradeLevel.costsToUpgrade[1].currencyID;
			for upgradeIndex = 2, numUpgradeLevels+1 do
				upgradeLevel = upgradeInfo.upgradeLevelInfos[upgradeIndex];
				totalCost = totalCost + upgradeLevel.costsToUpgrade[1].cost;
			end
		end

		local failureMessage = upgradeInfo.failureMessage;

		return iconID, name, displayQuality, boundStatus, upgradeProgress, maxUpgrade, totalCost, currencyID, failureMessage;
	end

	function GetItemUpgradeStats(upgraded, numUpgradeLevels)
		local stats = {};
		local unformattedStats = C_ItemUpgrade.GetItemUpgradeStats(upgraded, numUpgradeLevels);
		if (not unformattedStats) then
			return;
		end

		for i=1, #unformattedStats * 3 do
			local currStat = unformattedStats[math.ceil(i/3)];
			if ( i % 3 == 1) then
				stats[i] = currStat.displayString;
			elseif ( i % 3 == 2) then
				stats[i] = currStat.statValue;
			elseif ( i % 3 == 0) then
				stats[i] = currStat.active;
			end
		end

		return unpack(stats);
	end

	function SetItemUpgradeFromCursorItem()
		C_ItemUpgrade.SetItemUpgradeFromCursorItem();
	end

	function ClearItemUpgrade()
		C_ItemUpgrade.ClearItemUpgrade();
	end

	function UpgradeItem()
		C_ItemUpgrade.UpgradeItem();
	end

	function CloseItemUpgrade()	
		C_ItemUpgrade.CloseItemUpgrade();
	end

	function GetItemUpdateLevel()
		return C_ItemUpgrade.GetItemUpdateLevel();
	end
end

-- C_LFGList API
do
	-- Use GetLfgCategoryInfo going forward
	function C_LFGList.GetCategoryInfo(categoryID)
		local categoryInfo = C_LFGList.GetLfgCategoryInfo(categoryID);
		if categoryInfo then
			return categoryInfo.name, categoryInfo.separateRecommended, categoryInfo.autoChooseActivity, categoryInfo.preferCurrentArea, categoryInfo.showPlaystyleDropdown;
		end
	end
end

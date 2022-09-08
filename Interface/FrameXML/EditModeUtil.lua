EditModeUtil = { };

function EditModeUtil:IsRightAnchoredActionBar(systemFrame)
	return (systemFrame == MultiBarRight)
		or (systemFrame == MultiBarLeft);
end

function EditModeUtil:IsBottomAnchoredActionBar(systemFrame)
	return (systemFrame == MultiBarBottomRight)
		or (systemFrame == MultiBarBottomLeft)
		or (systemFrame == MainMenuBar)
		or (systemFrame == StanceBar)
		or (systemFrame == PetActionBar)
		or (systemFrame == PossessActionBar);
end

function EditModeUtil:GetRightActionBarWidth()
	local offset = 0;
	if MultiBar3_IsVisible and MultiBar3_IsVisible() and MultiBarRight:IsInDefaultPosition() then
		local point, relativeTo, relativePoint, offsetX, offsetY = MultiBarRight:GetPoint(1);
		offset = MultiBarRight:GetWidth() - offsetX; -- Subtract x offset since it will be a negative value due to us anchoring to the right side and anchoring towards the middle
	end

	if MultiBar4_IsVisible and MultiBar4_IsVisible() and MultiBarLeft:IsInDefaultPosition() then
		local point, relativeTo, relativePoint, offsetX, offsetY = MultiBarLeft:GetPoint(1);
		offset = MultiBarLeft:GetWidth() - offsetX;
	end

	return offset;
end

function EditModeUtil:GetBottomActionBarHeight(includeMainMenuBar)
	local actionBarHeight = 0;

	if OverrideActionBar:IsShown() then
		local point, relativeTo, relativePoint, offsetX, offsetY = OverrideActionBar:GetPoint(1);
		actionBarHeight =  offsetY + OverrideActionBar:GetHeight();

		if OverrideActionBar.xpBar:IsShown() then
			actionBarHeight =  actionBarHeight + OverrideActionBar.xpBar:GetHeight();
		end

		return actionBarHeight + 5;
	end

	actionBarHeight = includeMainMenuBar and MainMenuBar:GetBottomAnchoredHeight() or 0;
	actionBarHeight = actionBarHeight + MultiBarBottomLeft:GetBottomAnchoredHeight();
	actionBarHeight = actionBarHeight + MultiBarBottomRight:GetBottomAnchoredHeight();
	actionBarHeight = actionBarHeight + StanceBar:GetBottomAnchoredHeight();
	actionBarHeight = actionBarHeight + (PetActionBar and PetActionBar:GetBottomAnchoredHeight() or 0);
	actionBarHeight = actionBarHeight + PossessActionBar:GetBottomAnchoredHeight();
	return actionBarHeight;
end

function EditModeUtil:GetRightContainerAnchor()
	local xOffset = -EditModeUtil:GetRightActionBarWidth() - 5;
	local anchor = AnchorUtil.CreateAnchor("TOPRIGHT", UIParent, "TOPRIGHT", xOffset, -260);
	return anchor;
end

function EditModeUtil:GetSettingMapFromSettings(settings, displayInfoMap)
	local settingMap = {};
	for _, settingInfo in ipairs(settings) do
		settingMap[settingInfo.setting] = { value = settingInfo.value };

		if displayInfoMap and displayInfoMap[settingInfo.setting] then
			settingMap[settingInfo.setting].displayValue = displayInfoMap[settingInfo.setting]:ConvertValueForDisplay(settingInfo.value);
		end
	end
	return settingMap;
end


MinimapTrackingDropdownMixin = { };

function MinimapTrackingDropdownMixin:OnLoad()
	self:RegisterEvent("MINIMAP_UPDATE_TRACKING");
	MinimapTracking_Update();
	MiniMapTrackingBackground:SetAlpha(0.6);
	
	local function IsSelected(trackingInfo)
		local info = C_Minimap.GetTrackingInfo(trackingInfo.index);
		return info and info.active;
	end

	local function SetSelected(trackingInfo)
		local selected = IsSelected(trackingInfo);
		C_Minimap.SetTracking(trackingInfo.index, not selected);
	end

	self:SetupMenu(function(dropdown, rootDescription)
		rootDescription:SetTag("MENU_MINIMAP_TRACKING");

		rootDescription:CreateButton(UNCHECK_ALL, function()
			C_Minimap.ClearAllTracking();
			return MenuResponse.Refresh;
		end);

		local hunterInfo = {};
		local regularInfo = {};
	
		for index = 1, C_Minimap.GetNumTrackingTypes() do
			local trackingInfo = C_Minimap.GetTrackingInfo(index);
			if trackingInfo then
				trackingInfo.index = index;
				local tbl = (trackingInfo.subType == HUNTER_TRACKING) and hunterInfo or regularInfo;
				table.insert(tbl, trackingInfo);
			end
		end

		local function CreateCheckboxWithIcon(parentDescription, trackingInfo)
			local name = trackingInfo.name;
			trackingInfo.text = name;
	
			local texture = trackingInfo.texture;
			local desc = parentDescription:CreateCheckbox(
				name,
				IsSelected,
				SetSelected,
				trackingInfo);
	
			desc:AddInitializer(function(button, description, menu)
				local rightTexture = button:AttachTexture();
				rightTexture:SetSize(20, 20);
				rightTexture:SetPoint("RIGHT");
				rightTexture:SetTexture(texture);
		
				local fontString = button.fontString;
				fontString:SetPoint("RIGHT", rightTexture, "LEFT");
	
				if trackingInfo.type == "spell" then
					local uv0, uv1 = .0625, .9;
					rightTexture:SetTexCoord(uv0, uv1, uv0, uv1);
				end
					
				-- The size is explicitly provided because this requires a right-justified icon.
				local width, height = fontString:GetUnboundedStringWidth() + 60, 20;
				return width, height;
			end);
	
			return desc;
		end
	
		local hunterCount = #hunterInfo;
		if hunterCount > 0 then
			local hunterMenuDesc = rootDescription;
			--[[if hunterCount > 1 then
				hunterMenuDesc = rootDescription:CreateButton(HUNTER_TRACKING_TEXT);
			end]] -- FRESH-212: Uncomment this block.

			for index, info in ipairs(hunterInfo) do
				CreateCheckboxWithIcon(hunterMenuDesc, info);
			end

			rootDescription:CreateDivider(); -- FRESH-212: Remove this line.
		end

		for index, info in ipairs(regularInfo) do
			CreateCheckboxWithIcon(rootDescription, info);
		end
	end);
end

function MinimapTrackingDropdownMixin:OnEvent(event, ...)
	if event == "MINIMAP_UPDATE_TRACKING" then
		MinimapTracking_Update();
		self:GenerateMenu();
	end
end

function MinimapTrackingDropdownMixin:OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_LEFT");
	GameTooltip:SetText(TRACKING, 1, 1, 1);
	GameTooltip:AddLine(MINIMAP_TRACKING_TOOLTIP_NONE, nil, nil, nil, true);
	GameTooltip:Show();
end

function MinimapTrackingDropdownMixin:OnLeave()
	GameTooltip:Hide();
end

function MinimapTracking_Update()
	local currentTexture = MiniMapTrackingIcon:GetTexture();
	local bestTexture = [[Interface\Minimap\Tracking\None]];
	local count = C_Minimap.GetNumTrackingTypes();
	for id = 1, count do
		local trackingInfo = C_Minimap.GetTrackingInfo(id);
		if trackingInfo and trackingInfo.active then
			if (trackingInfo.type == "spell") then
				if (currentTexture == trackingInfo.texture) then
					return;
				end
				MiniMapTrackingIcon:SetTexture(trackingInfo.texture);
				MinimapTrackingShineFadeIn();
				return;
			else
				bestTexture = trackingInfo.texture;
			end
		end
	end
	MiniMapTrackingIcon:SetTexture(bestTexture);
	MinimapTrackingShineFadeIn();
end

function MinimapTrackingShineFadeIn()
	-- Fade in the shine and then fade it out with the ComboPointShineFadeOut function
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = 0.5;
	fadeInfo.finishedFunc = MinimapTrackingShineFadeOut;
	UIFrameFade(MiniMapTrackingShine, fadeInfo);
end

function MinimapTrackingShineFadeOut()
	UIFrameFadeOut(MiniMapTrackingShine, 0.5);
end

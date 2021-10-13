GroupMembersDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

function GroupMembersDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	self:GetMap():SetPinTemplateType("GroupMembersPinTemplate", "UnitPositionFrame");
	-- a single permanent pin
	local pin = self:GetMap():AcquirePin("GroupMembersPinTemplate", self);
	pin:SetPosition(0.5, 0.5);
	pin:SetNeedsPeriodicUpdate(true);
	pin:UpdateShownUnits();
	self.pin = pin;
	self.onClickHandler = self.onClickHandler or function(mapCanvas, button, cursorX, cursorY) return self.pin:OnCanvasClicked(button, cursorX, cursorY) end;
	mapCanvas:AddCanvasClickHandler(self.onClickHandler);
end

function GroupMembersDataProviderMixin:OnRemoved(mapCanvas)
	self:GetMap():RemoveAllPinsByTemplate("GroupMembersPinTemplate");
	mapCanvas:RemoveCanvasClickHandler(self.onClickHandler);

	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
end

function GroupMembersDataProviderMixin:OnMapChanged()
	self.pin:OnMapChanged();
end

function GroupMembersDataProviderMixin:RefreshAllData(fromOnShow)
	self.pin:Refresh(fromOnShow);
end

function GroupMembersDataProviderMixin:SetUnitPinSize(unit, size)
	local unitPinSizes = self:GetUnitPinSizesTable();
	if unitPinSizes[unit] then
		unitPinSizes[unit] = size;
		if self.pin then
			self.pin:UpdateShownUnits();
		end
	end
end

function GroupMembersDataProviderMixin:EnumerateUnitPinSizes()
	local unitPinSizes = self:GetUnitPinSizesTable();
	return next, unitPinSizes;
end

function GroupMembersDataProviderMixin:ShouldShowUnit(unit)
	local unitPinSizes = self:GetUnitPinSizesTable();
	return unitPinSizes[unit] > 0;
end

function GroupMembersDataProviderMixin:GetUnitPinSizesTable()
	if not self.unitPinSizes then
		self.unitPinSizes = {
			player = 27,
			party = 11,
			raid = 11 * 0.75;
		};
	end
	return self.unitPinSizes;
end

--[[ Group Members Pin ]]--
GroupMembersPinMixin = CreateFromMixins(MapCanvasPinMixin);

function GroupMembersPinMixin:OnLoad()
	UnitPositionFrameMixin.OnLoad(self);
	self:SetAlphaLimits(1.0, 1.0, 1.0);
	self:SetIgnoreGlobalPinScale(true);
	self:UseFrameLevelType("PIN_FRAME_LEVEL_GROUP_MEMBER");

	self:SetPlayerPingTexture(1, "Interface\\minimap\\UI-Minimap-Ping-Center", 32, 32);
	self:SetPlayerPingTexture(2, "Interface\\minimap\\UI-Minimap-Ping-Expand", 32, 32);
	self:SetPlayerPingTexture(3, "Interface\\minimap\\UI-Minimap-Ping-Rotate", 70, 70);

	self:SetMouseOverUnitExcluded("player", true);
	self:SetPinTexture("player", "Interface\\WorldMap\\WorldMapArrow");
end

function GroupMembersPinMixin:OnAcquired(dataProvider)
	self.dataProvider = dataProvider;
	self:SynchronizePinSizes();
end

function GroupMembersPinMixin:OnShow()
	UnitPositionFrameMixin.OnShow(self);
end

function GroupMembersPinMixin:OnHide()
	UnitPositionFrameMixin.OnHide(self);
	if self.dataProvider:ShouldShowUnit("player") then
		self:StopPlayerPing();
	end
	if GameTooltip:GetOwner() == self then
		GameTooltip:Hide();
	end
end

function GroupMembersPinMixin:OnUpdate()
	self:Refresh();
end

function GroupMembersPinMixin:Refresh(fromOnShow)
	self:UpdatePlayerPins();

	self:UpdateTooltips(GameTooltip);

	if fromOnShow then
		self:OnMapChanged();
	end
end

function GroupMembersPinMixin:OnMapChanged()
	local mapID = self:GetMap():GetMapID();
	local hideMapIcons = C_Map.GetMapDisplayInfo(mapID);
	if hideMapIcons then
		self:Hide();
	else
		self:SetUiMapID(mapID);
		self:Show();
		if self.dataProvider:ShouldShowUnit("player") then
			self:StartPlayerPing(2, .25);
		end
	end
end

function GroupMembersPinMixin:UpdateShownUnits()
	for unit, size in self.dataProvider:EnumerateUnitPinSizes() do
		self:SetShouldShowUnits(unit, size > 0);
	end
end

function GroupMembersPinMixin:SynchronizePinSizes()
	local scale = self:GetMap():GetCanvasScale();
	for unit, size in self.dataProvider:EnumerateUnitPinSizes() do
		if self.dataProvider:ShouldShowUnit(unit) then
			self:SetPinSize(unit, size / scale);
		end
	end
	self:SetPlayerPingScale(.65 / scale);
end

function GroupMembersPinMixin:OnCanvasSizeChanged()
	self:SetSize(self:GetMap():DenormalizeHorizontalSize(1.0), self:GetMap():DenormalizeVerticalSize(1.0));
	self:SynchronizePinSizes();
end

function GroupMembersPinMixin:OnCanvasScaleChanged()
	self:SynchronizePinSizes();
end

function GroupMembersPinMixin:OnCanvasClicked(button, cursorX, cursorY)
	self.reportableUnits = { };
	if GetCVarBool("enablePVPNotifyAFK") and button == "RightButton" then
		local _, instanceType = IsInInstance();
		if instanceType == "pvp" or IsInActiveWorldPVP() then
			local timeNowSeconds = GetTime();
			local mouseOverUnits = self:GetCurrentMouseOverUnits();
			for unit in pairs(mouseOverUnits) do
				if unit ~= "player" and not GetIsPVPInactive(unit, timeNowSeconds) then
					tinsert(self.reportableUnits, unit);
				end
			end
		end

		if #self.reportableUnits > 0 then
			local function InitializeReportDropDown(self)
				self:GetParent():InitializeReportDropDown();
			end
			UIDropDownMenu_Initialize(self.ReportDropDown, InitializeReportDropDown, "MENU");
			ToggleDropDownMenu(1, nil, self.ReportDropDown, "cursor", 0, -5);
			return true;
		end
	end

	return false;
end

function GroupMembersPinMixin:InitializeReportDropDown()
	local info = UIDropDownMenu_CreateInfo();
	info.text = PVP_REPORT_AFK;
	info.notClickable = 1;
	info.isTitle = 1;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);

	for i, unit in ipairs(self.reportableUnits) do
		info = UIDropDownMenu_CreateInfo();
		info.func = function(self, unit)
			ReportPlayerIsPVPAFK(unit);
		end;
		info.arg1 = unit;
		info.text = UnitName(unit);
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info);
	end

	if #self.reportableUnits > 1 then
		info = UIDropDownMenu_CreateInfo();
		info.func = function()
			for i, unit in ipairs(self.reportableUnits) do
				ReportPlayerIsPVPAFK(unit);
			end
		end;
		info.text = PVP_REPORT_AFK_ALL;
		info.notCheckable = true;
		UIDropDownMenu_AddButton(info);
	end

	info = UIDropDownMenu_CreateInfo();
	info.text = CANCEL;
	info.notCheckable = true;
	UIDropDownMenu_AddButton(info);
end
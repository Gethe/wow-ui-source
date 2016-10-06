GroupMembersDataProviderMixin = CreateFromMixins(MapCanvasDataProviderMixin);

local SIZE_DIVIDEND = 13;

function GroupMembersDataProviderMixin:OnAdded(mapCanvas)
	MapCanvasDataProviderMixin.OnAdded(self, mapCanvas);
	self:GetMap():SetPinTemplateType("GroupMembersPinTemplate", "UnitPositionFrame");
	-- a single permanent pin
	local pin = self:GetMap():AcquirePin("GroupMembersPinTemplate");
	pin:SetPosition(0.5, 0.5);
	pin:Show();
	self.pin = pin;
end

function GroupMembersDataProviderMixin:OnRemoved(mapCanvas)
	MapCanvasDataProviderMixin.OnRemoved(self, mapCanvas);
	self:GetMap():RemoveAllPinsByTemplate("GroupMembersPinTemplate");
end

function GroupMembersDataProviderMixin:OnShow()
	assert(self.ticker == nil);
	self.ticker = C_Timer.NewTicker(0, function() self:RefreshAllData() end);
end

function GroupMembersDataProviderMixin:OnHide()
	self.ticker:Cancel();
	self.ticker = nil;
end

function GroupMembersDataProviderMixin:OnMapChanged()
	local mapAreaID = self:GetMap():GetMapID();
	self.pin:SetOverrideMapID(mapAreaID);
end

function GroupMembersDataProviderMixin:RefreshAllData(fromOnShow)
	self.pin:SetSize(self:GetMap():DenormalizeHorizontalSize(1.0), self:GetMap():DenormalizeVerticalSize(1.0));

	local memberCount = 0;
	local unitBase;
	if IsInRaid() then
		memberCount = MAX_RAID_MEMBERS;
		unitBase = "raid";
	elseif IsInGroup() then
		memberCount = MAX_PARTY_MEMBERS;
		unitBase = "party";
	end

	self.pin:ClearUnits();
	local scale = FlightMapFrame.ScrollContainer:GetCanvasScale();
	local size = SIZE_DIVIDEND / scale;
	for i = 1, memberCount do
		local unit = unitBase..i;
		if UnitExists(unit) and not UnitIsUnit(unit, "player") then
			local atlas = UnitInSubgroup(unit) and "WhiteCircle-RaidBlips" or "WhiteDotCircle-RaidBlips";
			local class = select(2, UnitClass(unit));
			local r, g, b = GetClassColor(class);
			self.pin:AddUnitAtlas(unit, atlas, size, size, r, g, b, 1);
		end
	end
	self.pin:FinalizeUnits();

	self.pin:UpdateTooltips(GameTooltip);
end

--[[ Group Members Pin ]]--
GroupMembersPinMixin = CreateFromMixins(MapCanvasPinMixin);

function GroupMembersPinMixin:OnLoad()
	self:SetAlphaLimits(1.0, 1.0, 1.0);
	self:SetScalingLimits(0, 1, 1);
end
DamageMeterSourceWindowMixin = {};

local DamageMeterSourceWindowMixinEvents = {
	"GLOBAL_MOUSE_DOWN",
};

function DamageMeterSourceWindowMixin:GetName()
	return self.Name;
end

function DamageMeterSourceWindowMixin:GetScrollBox()
	return self.ScrollBox;
end

function DamageMeterSourceWindowMixin:GetScrollBar()
	return self.ScrollBar;
end

function DamageMeterSourceWindowMixin:GetHeader()
	return self.Header;
end

function DamageMeterSourceWindowMixin:OnLoad()
	self:InitializeScrollBox();
end

function DamageMeterSourceWindowMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, DamageMeterSourceWindowMixinEvents);

	self:Refresh(ScrollBoxConstants.DiscardScrollPosition);
end

function DamageMeterSourceWindowMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, DamageMeterSourceWindowMixinEvents);

	self:ClearSource();
end

function DamageMeterSourceWindowMixin:OnEvent(event, ...)
	if event == "GLOBAL_MOUSE_DOWN" then
		if not DoesAncestryIncludeAny(self, GetMouseFoci()) then
			self:Hide();
		end
	end
end

function DamageMeterSourceWindowMixin:InitializeScrollBox()
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("DamageMeterSpellEntryTemplate", function(frame, elementData)
		frame:Init(elementData);
		frame:SetUseClassColor(self:ShouldUseClassColor());
		frame:SetBarHeight(self:GetBarHeight());
		frame:SetTextScale(self:GetTextScale());
		frame:SetShowBarIcons(self:ShouldShowBarIcons());
		frame:SetStyle(self:GetStyle());
	end);

	local topPadding, bottomPadding, leftPadding, rightPadding = 0, 0, 0, 0;
	local elementSpacing = 4;
	view:SetPadding(topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing);

	ScrollUtil.InitScrollBoxListWithScrollBar(self:GetScrollBox(), self:GetScrollBar(), view);

	local topLeftX, topLeftY = 20, -5;
	local bottomRightX, bottomRightY = -22, 6;
	local withBarXOffset = 20;
	local scrollBoxAnchorsWithBar = {
		CreateAnchor("TOPLEFT", self:GetHeader(), "BOTTOMLEFT", topLeftX, topLeftY),
		CreateAnchor("BOTTOMRIGHT", bottomRightX - withBarXOffset, bottomRightY);
	};
	local scrollBoxAnchorsWithoutBar = {
		CreateAnchor("TOPLEFT", self:GetHeader(), "BOTTOMLEFT", topLeftX, topLeftY),
		CreateAnchor("BOTTOMRIGHT", bottomRightX, bottomRightY);
	};
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(self:GetScrollBox(), self:GetScrollBar(), scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);
end

function DamageMeterSourceWindowMixin:GetCombatSessionSource()
	if not self.sourceGUID then
		return nil;
	end

	local damageMeterType = self:GetDamageMeterType();

	local sessionType = self:GetSessionType();
	if sessionType then
		return C_DamageMeter.GetCombatSessionSourceFromType(sessionType, damageMeterType, self.sourceGUID);
	end

	local sessionID = self:GetSessionID();
	if sessionID then
		return C_DamageMeter.GetCombatSessionSourceFromID(sessionID, damageMeterType, self.sourceGUID);
	end

	return nil;
end

function DamageMeterSourceWindowMixin:BuildDataProvider()
	local combatSessionSource = self:GetCombatSessionSource();
	local combatSpells = combatSessionSource and combatSessionSource.combatSpells or {};
	local maxAmount = combatSessionSource and combatSessionSource.maxAmount or 0;

	local dataProvider = CreateDataProvider();
	for i, combatSpell in ipairs(combatSpells) do
		combatSpell.sourceGUID = self.sourceGUID;
		combatSpell.classFilename = self.classFilename;
		combatSpell.maxAmount = maxAmount;
		combatSpell.index = i;

		dataProvider:Insert(combatSpell);
	end

	return dataProvider;
end

function DamageMeterSourceWindowMixin:Refresh(retainScrollPosition)
	self:GetScrollBox():SetDataProvider(self:BuildDataProvider(), retainScrollPosition);
end

function DamageMeterSourceWindowMixin:EnumerateEntryFrames()
	return self:GetScrollBox():EnumerateFrames();
end

function DamageMeterSourceWindowMixin:ForEachEntryFrame(func, ...)
	for _index, frame in self:EnumerateEntryFrames() do
		func(frame, ...);
	end
end

function DamageMeterSourceWindowMixin:GetEntryFrameCount()
	return self:GetScrollBox():GetFrameCount();
end

function DamageMeterSourceWindowMixin:SetSource(source)
	self.sourceGUID = source.sourceGUID;
	self.totalAmount = source.totalAmount;
	self.sourceName = source.name;
	self.classFilename = source.classFilename;

	self:UpdateName();
end

function DamageMeterSourceWindowMixin:ClearSource()
	self.sourceGUID = nil;
	self.totalAmount = nil;
	self.sourceName = nil;
	self.classFilename = nil;
end

function DamageMeterSourceWindowMixin:GetSourceGUID()
	return self.sourceGUID;
end

function DamageMeterSourceWindowMixin:GetTotalAmount()
	return self.totalAmount;
end

function DamageMeterSourceWindowMixin:SetDamageMeterType(damageMeterType)
	self.damageMeterType = damageMeterType;
end

function DamageMeterSourceWindowMixin:GetDamageMeterType()
	return self.damageMeterType;
end

function DamageMeterSourceWindowMixin:SetSession(sessionType, sessionID)
	self.sessionType = sessionType;
	self.sessionID = sessionID;

	self:Refresh(ScrollBoxConstants.RetainScrollPosition);
end

function DamageMeterSourceWindowMixin:GetSessionType()
	return self.sessionType;
end

function DamageMeterSourceWindowMixin:GetSessionID()
	return self.sessionID;
end

function DamageMeterSourceWindowMixin:AnchorToSessionWindow(sessionWindow)
	self:ClearAllPoints();

	local sessionWindowCenterX, _sessionWindowCenterY = sessionWindow:GetCenter();
	local screenCenterX, _screenCenterY = UIParent:GetCenter();

	-- Anchor in whatever direction has more room.
	if sessionWindowCenterX < screenCenterX then
		self:SetPoint("TOPLEFT", sessionWindow, "TOPRIGHT");
	else
		self:SetPoint("TOPRIGHT", sessionWindow, "TOPLEFT");
	end
end

function DamageMeterSourceWindowMixin:GetNameText()
	return self.sourceName;
end

function DamageMeterSourceWindowMixin:UpdateName()
	local text = self:GetNameText();
	self:GetName():SetText(text);
end

function DamageMeterSourceWindowMixin:OnUseClassColorChanged(useClassColor)
	self:GetScrollBox():ForEachFrame(function(frame) frame:SetUseClassColor(useClassColor); end);
end

function DamageMeterSourceWindowMixin:ShouldUseClassColor()
	return self.useClassColor == true;
end

function DamageMeterSourceWindowMixin:SetUseClassColor(useClassColor)
	useClassColor = (useClassColor == true);

	if self.useClassColor ~= useClassColor then
		self.useClassColor = useClassColor;
		self:OnUseClassColorChanged(useClassColor);
	end
end

function DamageMeterSourceWindowMixin:OnBarHeightChanged(barHeight)
	local retainScrollPosition = true;
	self:GetScrollBox():GetView():SetElementExtent(barHeight);
	self:Refresh(retainScrollPosition);
end

function DamageMeterSourceWindowMixin:GetBarHeight()
	return self.barHeight or DAMAGE_METER_DEFAULT_BAR_HEIGHT;
end

function DamageMeterSourceWindowMixin:SetBarHeight(barHeight)
	if not ApproximatelyEqual(self:GetBarHeight(), barHeight) then
		self.barHeight = barHeight;
		self:OnBarHeightChanged(barHeight);
	end
end

function DamageMeterSourceWindowMixin:OnTextScaleChanged(textScale)
	self:GetScrollBox():ForEachFrame(function(frame) frame:SetTextScale(textScale); end);
end

function DamageMeterSourceWindowMixin:GetTextScale()
	return self.textScale or 1;
end

function DamageMeterSourceWindowMixin:SetTextScale(textScale)
	if not ApproximatelyEqual(self:GetTextScale(), textScale) then
		self.textScale = textScale;
		self:OnTextScaleChanged(textScale);
	end
end

function DamageMeterSourceWindowMixin:OnShowBarIconsChanged(showBarIcons)
	self:ForEachEntryFrame(function(frame) frame:SetShowBarIcons(showBarIcons); end);
end

function DamageMeterSourceWindowMixin:ShouldShowBarIcons()
	return self.showBarIcons == true;
end

function DamageMeterSourceWindowMixin:SetShowBarIcons(showBarIcons)
	showBarIcons = (showBarIcons == true);

	if self.showBarIcons ~= showBarIcons then
		self.showBarIcons = showBarIcons;
		self:OnShowBarIconsChanged(showBarIcons);
	end
end

function DamageMeterSourceWindowMixin:OnStyleChanged(style)
	self:ForEachEntryFrame(function(frame) frame:SetStyle(style); end);
end

function DamageMeterSourceWindowMixin:GetStyle()
	return self.style or Enum.DamageMeterStyle.Default;
end

function DamageMeterSourceWindowMixin:SetStyle(style)
	if self.style ~= style then
		self.style = style;
		self:OnStyleChanged(style);
	end
end

DamageMeterSourceWindowMixin = {};

local DamageMeterSourceWindowMixinEvents = {
	"GLOBAL_MOUSE_DOWN",
};

function DamageMeterSourceWindowMixin:GetScrollBox()
	return self.ScrollBox;
end

function DamageMeterSourceWindowMixin:GetScrollBar()
	return self.ScrollBar;
end

function DamageMeterSourceWindowMixin:GetResizeButton()
	return self.ResizeButton;
end

function DamageMeterSourceWindowMixin:GetBackground()
	return self.Background;
end

function DamageMeterSourceWindowMixin:OnLoad()
	self:InitializeScrollBox();
	self:InitializeResizeButton();
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

function DamageMeterSourceWindowMixin:OnEnter()
	-- Handle showing the ResizeButton under the correct conditions.
	self:SetScript("OnUpdate", function()
		local resizeButton = self:GetResizeButton();
		local shouldResizeButtonBeShown = (self:IsMouseOver() or resizeButton:IsMouseOver() or self:IsResizing());

		if shouldResizeButtonBeShown and resizeButton:GetAlpha() == 0 then
			self.ShowResizeButton:Play();
			self.EmphasizeScrollBar:Play();
		elseif not shouldResizeButtonBeShown and resizeButton:GetAlpha() > 0 then
			self:SetScript("OnUpdate", nil);

			local reverse = true;
			self.ShowResizeButton:Play(reverse);
			self.EmphasizeScrollBar:Play(reverse);
		end
	end);
end

function DamageMeterSourceWindowMixin:InitializeScrollBoxPadding(view)
	local topPadding, bottomPadding, leftPadding, rightPadding = 0, 0, 0, 0;
	local elementSpacing = self:GetBarSpacing();

	view:SetPadding(topPadding, bottomPadding, leftPadding, rightPadding, elementSpacing);
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
		frame:SetBackgroundAlpha(self:GetBackgroundAlpha());
	end);

	self:InitializeScrollBoxPadding(view);
	ScrollUtil.InitScrollBoxListWithScrollBar(self:GetScrollBox(), self:GetScrollBar(), view);

	local topLeftX, topLeftY = 20, -15;
	local bottomRightX, bottomRightY = -22, 17;
	local withBarXOffset = 20;
	local scrollBoxAnchorsWithBar = {
		CreateAnchor("TOPLEFT", self:GetBackground(), "TOPLEFT", topLeftX, topLeftY),
		CreateAnchor("BOTTOMRIGHT", bottomRightX - withBarXOffset, bottomRightY);
	};
	local scrollBoxAnchorsWithoutBar = {
		CreateAnchor("TOPLEFT", self:GetBackground(), "TOPLEFT", topLeftX, topLeftY),
		CreateAnchor("BOTTOMRIGHT", bottomRightX, bottomRightY);
	};
	ScrollUtil.AddManagedScrollBarVisibilityBehavior(self:GetScrollBox(), self:GetScrollBar(), scrollBoxAnchorsWithBar, scrollBoxAnchorsWithoutBar);
end

function DamageMeterSourceWindowMixin:InitializeResizeButton()
	local resizeButton = self:GetResizeButton();

	resizeButton:SetScript("OnMouseDown", function(button, mouseButtonName, _down)
		if mouseButtonName == "LeftButton" then
			button:SetButtonState("PUSHED", true);
			button:GetHighlightTexture():Hide();

			if self:IsRightSide() then
				self:StartSizing("BOTTOMRIGHT");
			else
				self:StartSizing("BOTTOMLEFT");
			end

			self.isResizing = true;
		end
	end);

	resizeButton:SetScript("OnMouseUp", function(button, mouseButtonName, _down)
		if mouseButtonName == "LeftButton" then
			button:SetButtonState("NORMAL", false);
			button:GetHighlightTexture():Show();
			self:StopMovingOrSizing();
			self:SetUserPlaced(false);
			self.isResizing = false;
		end
	end);

	resizeButton:SetScript("OnEnter", function()
		self:OnEnter();
	end);
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

function DamageMeterSourceWindowMixin:ShowsValuePerSecondAsPrimary()
	return self.showsValuePerSecondAsPrimary == true;
end

function DamageMeterSourceWindowMixin:BuildDataProvider()
	local combatSessionSource = self:GetCombatSessionSource();
	local combatSpells = combatSessionSource and combatSessionSource.combatSpells or {};
	local maxAmount = combatSessionSource and combatSessionSource.maxAmount or 0;
	local showsValuePerSecondAsPrimary = self:ShowsValuePerSecondAsPrimary();

	local dataProvider = CreateDataProvider();
	for i, combatSpell in ipairs(combatSpells) do
		combatSpell.sourceGUID = self.sourceGUID;
		combatSpell.classFilename = self.classFilename;
		combatSpell.maxAmount = maxAmount;
		combatSpell.index = i;
		combatSpell.showsValuePerSecondAsPrimary = showsValuePerSecondAsPrimary;

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
	self.showsValuePerSecondAsPrimary = source.showsValuePerSecondAsPrimary;
end

function DamageMeterSourceWindowMixin:ClearSource()
	self.sourceGUID = nil;
	self.totalAmount = nil;
	self.sourceName = nil;
	self.classFilename = nil;
	self.showsValuePerSecondAsPrimary = nil;
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

function DamageMeterSourceWindowMixin:IsResizing()
	return self.isResizing == true;
end

function DamageMeterSourceWindowMixin:IsRightSide()
	return self.isRightSide == true;
end

function DamageMeterSourceWindowMixin:AnchorToSessionWindow(sessionWindow)
	self:ClearAllPoints();

	local resizeButton = self:GetResizeButton();
	resizeButton:ClearAllPoints();

	local sessionWindowCenterX, _sessionWindowCenterY = sessionWindow:GetCenter();
	local screenCenterX, _screenCenterY = UIParent:GetCenter();

	-- Anchor in whatever direction has more room.
	if sessionWindowCenterX < screenCenterX then
		self.isRightSide = true;
		self:SetPoint("TOPLEFT", sessionWindow, "TOPRIGHT");
		self:SetPoint("BOTTOMLEFT", sessionWindow, "BOTTOMRIGHT");

		resizeButton:SetPoint("BOTTOMRIGHT", 1, 1);
		resizeButton:GetNormalTexture():SetTexCoord(0, 1, 0, 1);
		resizeButton:GetHighlightTexture():SetTexCoord(0, 1, 0, 1);
		resizeButton:GetPushedTexture():SetTexCoord(0, 1, 0, 1);
	else
		self.isRightSide = false;
		self:SetPoint("TOPRIGHT", sessionWindow, "TOPLEFT");
		self:SetPoint("BOTTOMRIGHT", sessionWindow, "BOTTOMLEFT");

		resizeButton:SetPoint("BOTTOMLEFT", -1, 1);
		resizeButton:GetNormalTexture():SetTexCoord(1, 0, 0, 1);
		resizeButton:GetHighlightTexture():SetTexCoord(1, 0, 0, 1);
		resizeButton:GetPushedTexture():SetTexCoord(1, 0, 0, 1);
	end

	self:Refresh(ScrollBoxConstants.DiscardScrollPosition);
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
	self:GetScrollBox():GetView():SetElementExtent(barHeight);
	self:Refresh(ScrollBoxConstants.RetainScrollPosition);
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

function DamageMeterSourceWindowMixin:OnBarSpacingChanged(_spacing)
	self:InitializeScrollBoxPadding(self:GetScrollBox():GetView());
	self:Refresh(ScrollBoxConstants.RetainScrollPosition);
end

function DamageMeterSourceWindowMixin:GetBarSpacing()
	return self.barSpacing or DAMAGE_METER_DEFAULT_BAR_SPACING;
end

function DamageMeterSourceWindowMixin:SetBarSpacing(spacing)
	if self.barSpacing ~= spacing then
		self.barSpacing = spacing;
		self:OnBarSpacingChanged(spacing);
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

function DamageMeterSourceWindowMixin:OnBackgroundAlphaChanged(alpha)
	self:ForEachEntryFrame(function(frame) frame:SetBackgroundAlpha(alpha); end);
end

function DamageMeterSourceWindowMixin:GetBackgroundAlpha()
	return self.backgroundAlpha or 1;
end

function DamageMeterSourceWindowMixin:SetBackgroundAlpha(alpha)
	if not ApproximatelyEqual(self:GetBackgroundAlpha(), alpha) then
		self.backgroundAlpha = alpha;
		self:OnBackgroundAlphaChanged(alpha);
	end
end

function DamageMeterSourceWindowMixin:DoesCurrentStyleUseBackground()
	return self:GetStyle() == Enum.DamageMeterStyle.FullBackground;
end

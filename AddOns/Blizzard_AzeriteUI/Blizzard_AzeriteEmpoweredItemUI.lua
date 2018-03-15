AzeriteEmpoweredItemUIMixin = {};

function AzeriteEmpoweredItemUIMixin:OnLoad()
	UIPanelWindows[self:GetName()] = { area = "left", pushable = 0, xoffset = 35, yoffset = -9, bottomClampOverride = 100, showFailedFunc = function() self:OnShowFailed(); end, };

	self.transformTree = CreateFromMixins(TransformTreeMixin);
	self.transformTree:OnLoad();

	local root = self.transformTree:GetRoot();
	root:SetLocalScale(.5855);

	self.BackgroundFrame.Rank2RingBg.transformNode = root:CreateNodeFromTexture(self.BackgroundFrame.Rank2RingBg);
	self.BackgroundFrame.Rank3RingBg.transformNode = root:CreateNodeFromTexture(self.BackgroundFrame.Rank3RingBg);
	self.BackgroundFrame.Rank4RingBg.transformNode = root:CreateNodeFromTexture(self.BackgroundFrame.Rank4RingBg);

	self.BackgroundFrame.Rank2RingBgGlow.SelectedAnim = self.SelectRank2Anim;
	self.BackgroundFrame.Rank3RingBgGlow.SelectedAnim = self.SelectRank3Anim;
	self.BackgroundFrame.Rank4RingBgGlow.SelectedAnim = self.SelectRank4Anim;

	self.BackgroundFrame.Rank2RingBgGlow.FadeAnim = self.FadeRank2Anim;
	self.BackgroundFrame.Rank3RingBgGlow.FadeAnim = self.FadeRank3Anim;
	self.BackgroundFrame.Rank4RingBgGlow.FadeAnim = self.FadeRank4Anim;

	self.tierPool = CreateFramePool("FRAME", self, "AzeriteEmpoweredItemTierTemplate");
	self.powerPool = CreateTransformFrameNodePool("BUTTON", self.BackgroundFrame, "AzeriteEmpoweredItemPowerTemplate");
end

function AzeriteEmpoweredItemUIMixin:OnUpdate(elapsed)
	if self.dirty then
		self.dirty = nil;
		self:Refresh();
	end

	for tierIndex, tierFrame in ipairs(self.tiersByIndex) do
		tierFrame:PerformAnimations();
	end

	self.transformTree:ResolveTransforms();
end

function AzeriteEmpoweredItemUIMixin:OnShow()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);

	self.transformTree:GetRoot():SetLocalPosition(CreateVector2D(self.BackgroundFrame:GetWidth() * .5, self.BackgroundFrame:GetHeight() * .5));
end

function AzeriteEmpoweredItemUIMixin:OnHide()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
	self:Clear();
end

function AzeriteEmpoweredItemUIMixin:OnEvent(event, ...)
	if event == "AZERITE_ITEM_POWER_LEVEL_CHANGED" then
		local azeriteItemLocation, oldPowerLevel, newPowerLevel = ...;
		self:MarkDirty();
	elseif event == "AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED" then
		local item = ...;
		self:MarkDirty();
	end
end

function AzeriteEmpoweredItemUIMixin:OnShowFailed()
	self:Clear();
end

function AzeriteEmpoweredItemUIMixin:OnTierAnimationFinished(tierFrame)
	self:MarkDirty();
end

function AzeriteEmpoweredItemUIMixin:IsItemValid()
	return self.empoweredItem and not self.empoweredItem:IsItemEmpty();
end

local function HideAll(widgets)
	for i, widget in ipairs(widgets) do
		widget:Hide();
	end
end

function AzeriteEmpoweredItemUIMixin:Clear()
	StaticPopup_Hide("CONFIRM_AZERITE_EMPOWERED_BIND");

	if self.empoweredItem then
		self.empoweredItem:UnlockItem();
	end
	if self.itemDataLoadedCancelFunc then
		self.itemDataLoadedCancelFunc();
		self.itemDataLoadedCancelFunc = nil;
	end
	self.empoweredItemLocation = nil;
	self.empoweredItem = nil;

	self.tierPool:ReleaseAll();
	self.tiersByIndex = {};
	self.powerPool:ReleaseAll();

	HideAll(self.BackgroundFrame.RingBackgrounds);
	for i, widgetBackground in ipairs(self.BackgroundFrame.RingBackgrounds) do
		widgetBackground.transformNode:Unlink();
	end
	HideAll(self.BackgroundFrame.RingBorders);
	HideAll(self.BackgroundFrame.RingGlows);

	self:MarkDirty();

	self:UnregisterEvent("AZERITE_ITEM_POWER_LEVEL_CHANGED");
	self:UnregisterEvent("AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED");
end

function AzeriteEmpoweredItemUIMixin:SetToItemAtLocation(itemLocation)
	self:Clear();

	self.empoweredItemLocation = itemLocation;
	self.empoweredItem = Item:CreateFromItemLocation(self.empoweredItemLocation);
	if not self:IsItemValid() then
		HideUIPanel(self);
		return;
	end

	self.empoweredItem:LockItem();

	self.TitleText:SetText("");

	self.itemDataLoadedCancelFunc = self.empoweredItem:ContinueWithCancelOnItemLoad(function()
		SetPortraitToTexture(self.portrait, self.empoweredItem:GetItemIcon());
		self.TitleText:SetText(self.empoweredItem:GetItemName());
	end);

	self:RegisterEvent("AZERITE_ITEM_POWER_LEVEL_CHANGED");
	self:RegisterEvent("AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED");

	self:RebuildTiers();

	self:MarkDirty();
end

function AzeriteEmpoweredItemUIMixin:MarkDirty()
	self.dirty = true;
end

function AzeriteEmpoweredItemUIMixin:Refresh()
	if not self:IsItemValid() then
		HideUIPanel(self);
		return;
	end

	self:UpdateTiers();
end

function AzeriteEmpoweredItemUIMixin:UpdateTiers()
	local azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem();
	local azeriteItemPowerLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation);

	for tierIndex, tierFrame in ipairs(self.tiersByIndex) do
		tierFrame:Update(azeriteItemPowerLevel);
	end
end

function AzeriteEmpoweredItemUIMixin:RebuildTiers()
	local allTierInfo = C_AzeriteEmpoweredItem.GetAllTierInfo(self.empoweredItemLocation);
	local previousTier = nil;
	for tierIndex, tierInfo in ipairs(allTierInfo) do
		local tierFrame = self.tierPool:Acquire();
		self.tiersByIndex[tierIndex] = tierFrame;

		local tierArrayIndex = tierIndex;
		local tierRingBackground = self.BackgroundFrame.RingBackgrounds[tierArrayIndex];
		local tierRingBackgroundNode = nil;
		if tierRingBackground then
			tierRingBackground:Show();
			tierRingBackgroundNode = tierRingBackground.transformNode;
			tierRingBackgroundNode:SetParentTransform(self.transformTree:GetRoot());
		end

		local tierRingGlow = self.BackgroundFrame.RingGlows[tierArrayIndex];
		tierFrame:Setup(self, self.empoweredItemLocation, tierInfo, previousTier, tierRingGlow, tierRingBackgroundNode or self.transformTree:GetRoot(), self.powerPool);

		local tierRingBorder = self.BackgroundFrame.RingBorders[tierArrayIndex];
		if tierRingBorder then
			tierRingBorder:Show();
		end

		previousTier = tierFrame;
	end
end
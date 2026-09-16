-------------------------------------------------------
----------Constants
-------------------------------------------------------
MAX_WHOS_FROM_SERVER = 50;
LFG_TAB_WHO = 3;

local whoSortValue = 1;

-------------------------------------------------------
----------LFGWhoListButtonMixin
-------------------------------------------------------
LFGWhoListButtonMixin = {};

function LFGWhoListButtonMixin:OnClick(button)
	if button == "LeftButton" then
		LFGWhoListFrame.selectedWho = self.index or nil;
	else
		local name = self.OriginalName or self.Name:GetText();
		FriendsFrame_ShowDropdown(name, 1);
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
end

function LFGWhoListButtonMixin:OnEnter()
	if self.tooltip1 and self.tooltip2 and self.tooltip3 then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT");
		GameTooltip:SetText(self.tooltip1);
		GameTooltip:AddLine(self.tooltip2, 1, 1, 1);
		GameTooltip:AddLine(self.tooltip3, 1, 1, 1);
		GameTooltip:Show();
	end
end

function LFGWhoListButtonMixin:SetSelected(selected)
	if selected then
		self.Selected:Show();
	else
		self.Selected:Hide();
	end
end

function LFGWhoListButtonMixin:InitButton(elementData, selected)
	local index = elementData.index;
	local info = elementData.info;
	self.index = index;

	self:SetSelected(selected);



	local classTextColor;
	if info.filename then
		classTextColor = RAID_CLASS_COLORS[info.filename];
	else
		classTextColor = HIGHLIGHT_FONT_COLOR;
	end

	local name = info.fullName;
	if info.timerunningSeasonID then
		name = TimerunningUtil.AddTinyIcon(name);
		self.OriginalName = info.fullName;
	end

	self.Name:SetText(name);

	local levelText = LFG_WHO_LEVEL:format(info.level);
	self.Level:SetText(levelText);
	self.Race:SetText(info.raceStr);
	self.Class:SetText(info.classStr);
	self.Class:SetTextColor(classTextColor.r, classTextColor.g, classTextColor.b);

	local variableColumnTable = { info.area, info.fullGuildName, info.raceStr };
	local variableText = variableColumnTable[whoSortValue];
	self.Variable:SetText(variableText);

	local fullGuildName = info.fullGuildName
	self.GuildName:SetText(fullGuildName);

	if self.Variable:IsTruncated() or self.Level:IsTruncated() or self.Name:IsTruncated() then
		self.tooltip1 = info.fullName;
		self.tooltip2 = WHO_LIST_LEVEL_TOOLTIP:format(info.level);
		self.tooltip3 = variableText;
	else
		self.tooltip1 = nil;
		self.tooltip2 = nil;
		self.tooltip3 = nil;
	end
end

-------------------------------------------------------
----------WhoFrameEditBoxMixin
-------------------------------------------------------
WhoFrameEditBoxMixin = {};

function WhoFrameEditBoxMixin:OnLoad()
	-- Hiding this art so we can show the backdrop instead
	self.Left:Hide();
	self.Middle:Hide();
	self.Right:Hide();

	self.searchIcon:SetAtlas("glues-characterSelect-icon-search", TextureKitConstants.IgnoreAtlasSize);

	self.Instructions:SetFontObject(self.instructionsFontObject);
	-- This text can be scaled so we try to fit all (or least most) of the text and then truncate + tooltip where necessary
	self.Instructions:SetMaxLines(2);
end

function WhoFrameEditBoxMixin:OnShow()
	EventRegistry:RegisterCallback("TextSizeManager.OnTextScaleUpdated", function()
		self:AdjustHeightToFitInstructions();
	end, self);

	self:AdjustHeightToFitInstructions();
	EditBox_ClearFocus(self);
end

function WhoFrameEditBoxMixin:AdjustHeightToFitInstructions()
	local linesShown = math.min(self.Instructions:GetNumLines(), self.Instructions:GetMaxLines());
	local totalInstructionHeight = linesShown * self.Instructions:GetLineHeight();
	local padding = 20;
	self:SetHeight(totalInstructionHeight + padding);
end

function WhoFrameEditBoxMixin:OnHide()
	EventRegistry:UnregisterCallback("TextSizeManager.OnTextScaleUpdated", self);
end

function WhoFrameEditBoxMixin:OnEnter()
	local isTruncated = self.Instructions:IsShown() and self.Instructions:IsTruncated();
	if not isTruncated then
		return;
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip_AddHighlightLine(GameTooltip, self.instructionText);
	GameTooltip:Show();
end

function WhoFrameEditBoxMixin:OnLeave()
	GameTooltip:Hide();
end

function WhoFrameEditBoxMixin:OnEnterPressed()
	C_FriendList.SendWho(self:GetText(), Enum.SocialWhoOrigin.Social);
	self:ClearFocus();
end


-------------------------------------------------------
----------WhoSearchMixin
-------------------------------------------------------
WhoSearchMixin = {};
function WhoSearchMixin:OnClick()
	local searchText = LFGWhoListFrame.EditBox:GetText();
	C_FriendList.SendWho(searchText, Enum.SocialWhoOrigin.Social);
	LFGWhoListFrame.EditBox:ClearFocus();
end

-------------------------------------------------------
----------LFGWhoListMixin
-------------------------------------------------------
LFGWhoListMixin = {};

function LFGWhoListMixin:OnLoad()
	self:RegisterEvent("WHO_LIST_UPDATE");

	self:SetPortraitAtlasRaw("groupfinder-eye-frame");

	self:SetupScrollView();
end

function LFGWhoListMixin:OnEvent(event, ...)
	if ( event == "WHO_LIST_UPDATE" ) then
		self:UpdateWhoList();
	end
end

function LFGWhoListMixin:SetupScrollView()
	local function InitializeWhoButton(frame, elementData)
		frame:SetScript("OnClick", function(button, buttonName)
			if buttonName == "LeftButton" then
				self.selectionBehavior:ToggleSelect(button);
			else
				local name = button.OriginalName or button.Name:GetText();
				FriendsFrame_ShowDropdown(name, 1);
			end
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON);
		end);

		local selected = self.selectionBehavior:IsSelected(frame);
		frame:InitButton(elementData, selected);
	end

	-- Who list
	local view = CreateScrollBoxListLinearView();
	view:SetElementInitializer("LFGWhoListButtonTemplate", InitializeWhoButton);		

	ScrollUtil.InitScrollBoxListWithScrollBar(self.ScrollBox, self.ScrollBar, view);

	local function OnSelectionChanged(o, elementData, selected)
		local button = self.ScrollBox:FindFrame(elementData);
		if button then
			button:SetSelected(selected);
		end
	end;

	self.selectionBehavior = ScrollUtil.AddSelectionBehavior(self.ScrollBox);
	self.selectionBehavior:RegisterCallback(SelectionBehaviorMixin.Event.OnSelectionChanged, OnSelectionChanged, self);
end

function LFGWhoListMixin:OnShow()
	C_FriendList.SetWhoToUi(true);
end

function LFGWhoListMixin:OnHide()
	C_FriendList.SetWhoToUi(false);
end

function LFGWhoListMixin:UpdateWhoList()
	local numWhos, totalCount = C_FriendList.GetNumWhoResults();

	local displayedText = "";
	if ( totalCount > MAX_WHOS_FROM_SERVER ) then
		displayedText = format(WHO_FRAME_SHOWN_TEMPLATE, MAX_WHOS_FROM_SERVER);
	end
	self.WhoFrameTotals:SetText(format(WHO_FRAME_TOTAL_TEMPLATE, totalCount).."  "..displayedText);

	local dataProvider = CreateDataProvider();
	for index = 1, numWhos do
		local info = C_FriendList.GetWhoInfo(index);
		-- All scrollable text in the Who List uses font that can be resized by the player
		dataProvider:Insert({index=index, info=info, fontObject=UserScaledFontGameNormalSmall, });
	end
	self.ScrollBox:SetDataProvider(dataProvider, ScrollBoxConstants.RetainScrollPosition);

	if not C_SocialUI.IsSystemEnabled() then
		PanelTemplates_SetTab(LFGParentFrame, 3);
		ShowUIPanel(LFGParentFrame);
	end
end

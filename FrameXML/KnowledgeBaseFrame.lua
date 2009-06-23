-- CONSTANTS
KBASE_NUM_ARTICLES_PER_PAGE = 20;
KBASE_NUM_FAKE_CATEGORIES = 1;
KBASE_NUM_FAKE_SUBCATEGORIES = 1;
KBASE_TOOLTIP_DELAY = .7;
KBASE_SEARCH_BUTTON_DELAY = 1;

-- Internal variables
KBASE_CURRENT_PAGE = 1;
KBASE_SEARCH_PERFORMED = 0;
KBASE_SETUP_LOADED = 0;
KBASE_ENABLE_SEARCH = 1;

function KnowledgeBaseFrame_OnLoad(self)
	self:RegisterEvent("UPDATE_GM_STATUS");
	self:RegisterEvent("KNOWLEDGE_BASE_SETUP_LOAD_SUCCESS");
	self:RegisterEvent("KNOWLEDGE_BASE_SETUP_LOAD_FAILURE");
	self:RegisterEvent("KNOWLEDGE_BASE_QUERY_LOAD_SUCCESS");
	self:RegisterEvent("KNOWLEDGE_BASE_QUERY_LOAD_FAILURE");
	self:RegisterEvent("KNOWLEDGE_BASE_ARTICLE_LOAD_SUCCESS");
	self:RegisterEvent("KNOWLEDGE_BASE_ARTICLE_LOAD_FAILURE");
	self:RegisterEvent("KNOWLEDGE_BASE_SYSTEM_MOTD_UPDATE");
	self:RegisterEvent("KNOWLEDGE_BASE_SERVER_MESSAGE");

	-- ADDITIONAL LAYOUT
	KnowledgeBaseFrame_DisableButtons();

	KnowledgeBaseMotdText:SetWidth(KnowledgeBaseFrame:GetWidth() - KnowledgeBaseMotdLabel:GetWidth() - 80);
	KnowledgeBaseMotdTextFrame:SetWidth(KnowledgeBaseMotdText:GetWidth())
	KnowledgeBaseMotdTextFrame:SetHeight(KnowledgeBaseMotdText:GetHeight())

	KnowledgeBaseServerMessageText:SetWidth(KnowledgeBaseFrame:GetWidth() - KnowledgeBaseServerMessageLabel:GetWidth() - 80);
	KnowledgeBaseServerMessageTextFrame:SetWidth(KnowledgeBaseServerMessageText:GetWidth())
	KnowledgeBaseServerMessageTextFrame:SetHeight(KnowledgeBaseServerMessageText:GetHeight())

	KnowledgeBaseFrameEditBox:SetMaxBytes(128);
	KnowledgeBaseFrameEditBox:SetText(KBASE_DEFAULT_SEARCH_TEXT);

	KnowledgeBaseArticleListFrameCount:SetPoint("TOPRIGHT", "KnowledgeBaseArticleListFramePreviousButton", "TOPLEFT", -6, -7);

	KnowledgeBaseArticleScrollChildFrameTitle:SetWidth(KnowledgeBaseArticleScrollChildFrame:GetWidth() - KnowledgeBaseArticleScrollChildFrameBackButton:GetWidth() - 10);
	KnowledgeBaseArticleScrollChildFrameText:SetWidth(KnowledgeBaseArticleScrollChildFrame:GetWidth() - 10);
	KnowledgeBaseArticleListFramePreviousButton:SetPoint("RIGHT", "KnowledgeBaseArticleListFrameNextButton", "LEFT", - (KnowledgeBaseArticleListFramePreviousButtonText:GetWidth() +   KnowledgeBaseArticleListFrameNextButtonText:GetWidth() + 5), 0);
end

function KnowledgeBaseFrame_OnShow(self)
	if ( KBASE_SETUP_LOADED == 0 ) then
		KBSetup_BeginLoading(KBASE_NUM_ARTICLES_PER_PAGE, KBASE_CURRENT_PAGE);
	end

	GetGMStatus();
	GetGMTicket();
	KnowledgeBaseFrame_UpdateMotd();
	KnowledgeBaseFrame_UpdateServerMessage();
	KnowledgeBaseFrameEditBox:SetFocus();

	HelpFrame.back = KnowledgeBaseFrameCancel;
end

function KnowledgeBaseFrame_OnEvent(self, event, ...)
	if ( event ==  "KNOWLEDGE_BASE_SETUP_LOAD_SUCCESS" ) then
		KBASE_SETUP_LOADED = 1;

		UIDropDownMenu_Initialize(KnowledgeBaseFrameCategoryDropDown, KnowledgeBaseFrameCategoryDropDown_Initialize);
		UIDropDownMenu_Initialize(KnowledgeBaseFrameSubCategoryDropDown, KnowledgeBaseFrameSubCategoryDropDown_Initialize);

		local articleHeaderCount = KBSetup_GetArticleHeaderCount();
		local totalArticleHeaderCount = KBSetup_GetTotalArticleCount();
		KnowledgeBaseFrame_EnableButtons(articleHeaderCount, totalArticleHeaderCount);

		if ( articleHeaderCount > 0 ) then
			KnowledgeBaseArticleListFrame_PopulateArticleList(articleHeaderCount, totalArticleHeaderCount, KBSetup_GetArticleHeaderData);
			KnowledgeBaseFrame_ShowSearchFrame();
		else
			KnowledgeBaseErrorFrame_SetErrorMessage(KBASE_ERROR_NO_RESULTS);
			KnowledgeBaseFrame_ShowErrorFrame();
		end
	end

	if ( event ==  "KNOWLEDGE_BASE_SETUP_LOAD_FAILURE" ) then
		KnowledgeBaseErrorFrame_SetErrorMessage(KBASE_ERROR_LOAD_FAILURE);
		KnowledgeBaseFrame_ShowErrorFrame();
		KnowledgeBaseFrame_DisableButtons(nil);
		-- enable top issues button, to give them a chance to get the ui loaded
		KnowledgeBaseFrameTopIssuesButton:Enable();

		KBASE_SETUP_LOADED = 0;
	end

	if ( event == "KNOWLEDGE_BASE_QUERY_LOAD_SUCCESS" ) then
		KnowledgeBaseArticleListFrameTitle:SetText(KBASE_SEARCH_RESULTS);

		local articleHeaderCount = KBQuery_GetArticleHeaderCount();
		local totalArticleHeaderCount = KBQuery_GetTotalArticleCount();
		KnowledgeBaseFrame_EnableButtons(KBQuery_GetArticleHeaderCount(), KBQuery_GetTotalArticleCount());

		if ( articleHeaderCount > 0 ) then
			KnowledgeBaseArticleListFrame_PopulateArticleList(articleHeaderCount, totalArticleHeaderCount, KBQuery_GetArticleHeaderData);
			KnowledgeBaseFrame_ShowSearchFrame();
		else
			KnowledgeBaseErrorFrame_SetErrorMessage(KBASE_ERROR_NO_RESULTS);
			KnowledgeBaseFrame_ShowErrorFrame();
		end
	end

	if ( event == "KNOWLEDGE_BASE_QUERY_LOAD_FAILURE" ) then
		KnowledgeBaseErrorFrame_SetErrorMessage(KBASE_ERROR_LOAD_FAILURE);
		KnowledgeBaseFrame_ShowErrorFrame();
	end

	if ( event == "KNOWLEDGE_BASE_ARTICLE_LOAD_SUCCESS" ) then

		local id, subject, subjectAlt, text, keywords, languageId, isHot = KBArticle_GetData();
		KnowledgeBaseArticleScrollChildFrameTitle:SetText(subject);
		KnowledgeBaseArticleScrollChildFrameText:SetText(text);
		KnowledgeBaseArticleScrollChildFrameArticleId:SetFormattedText(KBASE_ARTICLE_ID, id);

		KnowledgeBaseArticleScrollFrameScrollBar:SetValue(0);

		KnowledgeBaseFrame_ShowArticleFrame();
	end

	if ( event == "KNOWLEDGE_BASE_ARTICLE_LOAD_FAILURE" ) then
		KnowledgeBaseErrorFrame_SetErrorMessage(KBASE_ERROR_LOAD_FAILURE);
		KnowledgeBaseFrame_ShowErrorFrame();
	end

	if ( event == "UPDATE_GM_STATUS" ) then
		local status = ...;
		if ( status == GMTICKET_QUEUE_STATUS_ENABLED ) then
			GetGMTicket();
		else
			KnowledgeBaseFrameGMTalk:Disable();
			KnowledgeBaseFrameReportIssue:Disable();
		end
	end

	if ( event ==  "KNOWLEDGE_BASE_SYSTEM_MOTD_UPDATE" ) then
		KnowledgeBaseFrame_UpdateMotd();
	end

	if ( event ==  "KNOWLEDGE_BASE_SERVER_MESSAGE" ) then
		KnowledgeBaseFrame_UpdateServerMessage();
	end
end

function KnowledgeBaseFrame_UpdateMotd()
	local currentMotd =  KBSystem_GetMOTD();
	if ( currentMotd  ) then
		local singleLine = gsub(currentMotd, "\n", " ");
		KnowledgeBaseMotdText:SetText(singleLine);
	else
		KnowledgeBaseMotdText:SetText(nil);
	end
	KnowledgeBaseUpdateTopPanelPositions();
end

function KnowledgeBaseFrame_UpdateServerMessage()
	local currrentServerNotice =  KBSystem_GetServerNotice();
	if ( currrentServerNotice  ) then
		local closeBracketIndex = strfind(currrentServerNotice, "] ", 1, true);
		if ( closeBracketIndex ) then
			currrentServerNotice = strsub(currrentServerNotice, closeBracketIndex + 2);		
		end
		KnowledgeBaseServerMessageText:SetText(currrentServerNotice);
	else
		KnowledgeBaseServerMessageText:SetText(nil);
	end

	KnowledgeBaseUpdateTopPanelPositions();
end

function KnowledgeBaseFrame_Search(resetCurrentPage)
	if ( not KBSetup_IsLoaded() ) then
		return;
	end

	KnowledgeBaseFrame_DisableButtons();

	local categoryIndex = (UIDropDownMenu_GetSelectedID(KnowledgeBaseFrameCategoryDropDown) or 1) - KBASE_NUM_FAKE_CATEGORIES;
	local subcategoryIndex = (UIDropDownMenu_GetSelectedID(KnowledgeBaseFrameSubCategoryDropDown) or 1) - KBASE_NUM_FAKE_SUBCATEGORIES;

	local searchText = KnowledgeBaseFrameEditBox:GetText();
	if ( searchText == KBASE_DEFAULT_SEARCH_TEXT ) then
		searchText = "";
	end

	if ( resetCurrentPage == 1 ) then
		KBASE_CURRENT_PAGE = 1;
	end

	KBQuery_BeginLoading(searchText,
		categoryIndex,
		subcategoryIndex,
		KBASE_NUM_ARTICLES_PER_PAGE,
		KBASE_CURRENT_PAGE);

	KBASE_SEARCH_PERFORMED = 1;
end

function KnowledgeBaseFrame_LoadTopIssues()
	KnowledgeBaseFrame_DisableButtons();
	KBASE_SEARCH_PERFORMED = 0;
	KBASE_CURRENT_PAGE = 1;
	KBASE_SETUP_LOADED = 0;
	KBSetup_BeginLoading(KBASE_NUM_ARTICLES_PER_PAGE, KBASE_CURRENT_PAGE);
end

function DisablePagingButton(button)
	button:Disable();
	local buttonText = _G[button:GetName() .. "Text"];
	buttonText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
end

function EnablePagingButton(button)
	button:Enable();
	local buttonText = _G[button:GetName() .. "Text"];
	buttonText:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
end

function KnowledgeBaseFrame_DisableButtons()
	KBASE_ENABLE_SEARCH = 0;
	KnowledgeBaseFrameTopIssuesButton:Disable();
	KnowledgeBaseFrameSearchButton:Disable();

	KnowledgeBaseFrameTopIssuesButton.enableDelay = KBASE_SEARCH_BUTTON_DELAY;
	KnowledgeBaseFrameSearchButton.enableDelay = KBASE_SEARCH_BUTTON_DELAY;

	UIDropDownMenu_DisableDropDown(KnowledgeBaseFrameCategoryDropDown);
	UIDropDownMenu_DisableDropDown(KnowledgeBaseFrameSubCategoryDropDown);

	DisablePagingButton(KnowledgeBaseArticleListFrameNextButton);
	DisablePagingButton(KnowledgeBaseArticleListFramePreviousButton);
end

function KnowledgeBaseFrame_EnableButtons(articleCount, totalArticleCount)
	KBASE_ENABLE_SEARCH = 1;

	UIDropDownMenu_EnableDropDown(KnowledgeBaseFrameCategoryDropDown);
	UpdateSubCategoryEnabledState();

	if ( KBASE_CURRENT_PAGE == 1 ) then
		DisablePagingButton(KnowledgeBaseArticleListFramePreviousButton);
	else
		EnablePagingButton(KnowledgeBaseArticleListFramePreviousButton);
	end

	if ( articleCount ) then
		if (articleCount ==  KBASE_NUM_ARTICLES_PER_PAGE and (totalArticleCount > (KBASE_CURRENT_PAGE * KBASE_NUM_ARTICLES_PER_PAGE)) ) then
			EnablePagingButton(KnowledgeBaseArticleListFrameNextButton);
		else
			DisablePagingButton(KnowledgeBaseArticleListFrameNextButton);
		end
	end
end

function KnowledgeBaseFrame_ShowSearchFrame()
	KnowledgeBaseArticleListFrame:Show();
	KnowledgeBaseArticleScrollFrame:Hide();
	KnowledgeBaseErrorFrame:Hide();
end

function KnowledgeBaseFrame_ShowArticleFrame()
	KnowledgeBaseArticleListFrame:Hide();
	KnowledgeBaseArticleScrollFrame:Show();
	KnowledgeBaseErrorFrame:Hide();
end

function KnowledgeBaseFrame_ShowErrorFrame()
	KnowledgeBaseArticleListFrame:Hide();
	KnowledgeBaseArticleScrollFrame:Hide();
	KnowledgeBaseErrorFrame:Show();
end

function KnowledgeBaseFrameCategoryDropDown_OnLoad(self)
	UIDropDownMenu_SetWidth(self, 120);
	UIDropDownMenu_SetText(self, CATEGORY);
end

function KnowledgeBaseFrameCategoryDropDown_Initialize()
	KnowledgeBaseFrameCategoryDropDown_AddInfo(0, ALL);
	local numCategories = KBSetup_GetCategoryCount();
	for i=1, numCategories do
		local categoryId, categoryCaption = KBSetup_GetCategoryData(i);
		KnowledgeBaseFrameCategoryDropDown_AddInfo(i, categoryCaption);
	end
end

function KnowledgeBaseFrameCategoryDropDown_AddInfo(id, caption)
	local info = UIDropDownMenu_CreateInfo();
	info.value = id;
	info.text = caption;
	info.func = KnowledgeBaseFrameCategoryButton_OnClick;
	local checked = nil;
	local selectedId = UIDropDownMenu_GetSelectedID(KnowledgeBaseFrameCategoryDropDown);
	if (selectedId and ((selectedId - KBASE_NUM_FAKE_CATEGORIES) ==  id)) then
		checked = 1;
	end
	info.checked = checked;
	UIDropDownMenu_AddButton(info);
end

function KnowledgeBaseFrameCategoryButton_OnClick(self)
	local oldSelectedCategoryId = UIDropDownMenu_GetSelectedID(KnowledgeBaseFrameCategoryDropDown);
	local selectedCategoryId = self:GetID();
	
	if ( selectedCategoryId == oldSelectedCategoryId) then
		return;
	end
	
	UIDropDownMenu_SetSelectedID(KnowledgeBaseFrameCategoryDropDown, selectedCategoryId);

	UIDropDownMenu_SetSelectedID(KnowledgeBaseFrameSubCategoryDropDown, 0);
	UIDropDownMenu_ClearAll(KnowledgeBaseFrameSubCategoryDropDown);
	UIDropDownMenu_SetText(KnowledgeBaseFrameSubCategoryDropDown, SUBCATEGORY);

	UpdateSubCategoryEnabledState();
end

function KnowledgeBaseFrameSubCategoryDropDown_OnLoad(self)
	UIDropDownMenu_SetWidth(self, 120);
	UIDropDownMenu_SetText(self, SUBCATEGORY);
end

function UpdateSubCategoryEnabledState()
	local selectedCategoryId = UIDropDownMenu_GetSelectedID(KnowledgeBaseFrameCategoryDropDown);
	if ( not selectedCategoryId or selectedCategoryId == 1 ) then
		UIDropDownMenu_DisableDropDown(KnowledgeBaseFrameSubCategoryDropDown);
		return;
	end
	
	local numSubCategories = KBSetup_GetSubCategoryCount(selectedCategoryId - KBASE_NUM_FAKE_CATEGORIES);	
	if ( numSubCategories == 0 ) then
		UIDropDownMenu_DisableDropDown(KnowledgeBaseFrameSubCategoryDropDown);
	else
		UIDropDownMenu_EnableDropDown(KnowledgeBaseFrameSubCategoryDropDown);
	end
end

function KnowledgeBaseFrameSubCategoryDropDown_Initialize()
	local selectedCategoryId = UIDropDownMenu_GetSelectedID(KnowledgeBaseFrameCategoryDropDown);
	if ( not selectedCategoryId or selectedCategoryId == 1 ) then
		return;
	end
	selectedCategoryId = selectedCategoryId - KBASE_NUM_FAKE_CATEGORIES;

	KnowledgeBaseFrameSubCategoryDropDown_AddInfo(0, ALL);
	local numCategories = KBSetup_GetSubCategoryCount(selectedCategoryId);
	for i=1, numCategories do
		local categoryId, categoryCaption = KBSetup_GetSubCategoryData(selectedCategoryId, i);
		KnowledgeBaseFrameSubCategoryDropDown_AddInfo(i, categoryCaption);
	end

	UpdateSubCategoryEnabledState();
end

function KnowledgeBaseFrameSubCategoryDropDown_AddInfo(id, caption)
	local info = UIDropDownMenu_CreateInfo();
	info.value = id;
	info.text = caption;
	info.func = KnowledgeBaseFrameSubCategoryButton_OnClick;
	local checked = nil;
	local selectedId = UIDropDownMenu_GetSelectedID(KnowledgeBaseFrameSubCategoryDropDown);
	if (selectedId and ((selectedId - KBASE_NUM_FAKE_SUBCATEGORIES) ==  id)) then
		checked = 1;
	end
	info.checked = checked;
	UIDropDownMenu_AddButton(info);
end

function KnowledgeBaseFrameSubCategoryButton_OnClick(self)
	UIDropDownMenu_SetSelectedID(KnowledgeBaseFrameSubCategoryDropDown, self:GetID());
end

function KnowledgeBaseArticleListFrame_HideArticleList()
	for i=1, KBASE_NUM_ARTICLES_PER_PAGE do
		local frame = _G["KnowledgeBaseArticleListItem" .. i];
		frame:Hide();
	end
end

function KnowledgeBaseArticleListFrame_PopulateArticleList(articleCount, totalArticleCount, dataFunc)
	KnowledgeBaseArticleListFrame_HideArticleList();
	for i=1, articleCount do
		local articleId, articleHeader, isArticleHot, isArticleUpdated =   dataFunc(i);
		local frame = _G["KnowledgeBaseArticleListItem" .. i];
		frame.number = i + ((KBASE_CURRENT_PAGE -1) * KBASE_NUM_ARTICLES_PER_PAGE);
		frame.articleId = articleId;
		frame.articleHeader = articleHeader;
		frame.isArticleHot = isArticleHot;
		frame.isArticleUpdated = isArticleUpdated;

		KnowledgeBaseArticleListItem_Update(frame);
		frame:Show();
	end

	KnowledgeBaseArticleListFrameCount:SetFormattedText(KBASE_ARTICLE_COUNT,
		(((KBASE_CURRENT_PAGE -1) * KBASE_NUM_ARTICLES_PER_PAGE) + 1),
		min(articleCount, (KBASE_CURRENT_PAGE * KBASE_NUM_ARTICLES_PER_PAGE)) + ((KBASE_CURRENT_PAGE -1) * KBASE_NUM_ARTICLES_PER_PAGE),
		 totalArticleCount);
end

function KnowledgeBaseArticleListItem_Update(frame)
	local numberText = _G[frame:GetName() .. "Number"];
	numberText:SetText(frame.number .. ".");

	local updatedIcon = _G[frame:GetName() .. "UpdatedIcon"];

	if ( frame.isArticleUpdated ) then
		updatedIcon:Show();
	else
		updatedIcon:Hide();
	end

	local hotIcon = _G[frame:GetName() .. "HotIcon"];
	if ( frame.isArticleHot ) then
		hotIcon:Show();
	else
		hotIcon:Hide();
	end

	local titleText = _G[frame:GetName() .. "Title"];
	titleText:SetText(frame.articleHeader);
end

function KnowledgeBaseUpdateTopPanelPositions()
	if ( KnowledgeBaseMotdText:GetText() ) then
		KnowledgeBaseMotdLabel:Show();
		KnowledgeBaseMotdTextFrame:Show();
	else
		KnowledgeBaseMotdLabel:Hide();
		KnowledgeBaseMotdTextFrame:Hide();
	end

	if ( KnowledgeBaseServerMessageText:GetText() ) then
		KnowledgeBaseServerMessageLabel:Show();
		KnowledgeBaseServerMessageTextFrame:Show();
	else
		KnowledgeBaseServerMessageLabel:Hide();
		KnowledgeBaseServerMessageTextFrame:Hide();
	end

	if ( KnowledgeBaseMotdLabel:IsShown() ) then
		KnowledgeBaseServerMessageLabel:SetPoint("TOPLEFT", KnowledgeBaseMotdLabel, "BOTTOMLEFT", 0, -5);
	else
		KnowledgeBaseServerMessageLabel:SetPoint("TOPLEFT", KnowledgeBaseMotdLabel, "TOPLEFT", 0, 0);
	end
end

function KnowledgeBaseArticleListFrame_PreviousPage()

	if ( KBASE_CURRENT_PAGE == 1 ) then
		return;
	end

	KBASE_CURRENT_PAGE = KBASE_CURRENT_PAGE  - 1;

	KnowledgeBaseFrame_DisableButtons();

	if ( KBASE_SEARCH_PERFORMED == 1 ) then
		KnowledgeBaseFrame_Search(0);
	else
		KBASE_SETUP_LOADED = 0;
		KBSetup_BeginLoading(KBASE_NUM_ARTICLES_PER_PAGE, KBASE_CURRENT_PAGE);
	end
end

function KnowledgeBaseArticleListFrame_NextPage()

	KBASE_CURRENT_PAGE = KBASE_CURRENT_PAGE  + 1;

	KnowledgeBaseFrame_DisableButtons();

	if ( KBASE_SEARCH_PERFORMED == 1 ) then
		KnowledgeBaseFrame_Search(0);
	else
		KBASE_SETUP_LOADED = 0;
		KBSetup_BeginLoading(KBASE_NUM_ARTICLES_PER_PAGE, KBASE_CURRENT_PAGE);
	end
end

function KnowledgeBaseErrorFrame_SetErrorMessage(message)
	KnowledgeBaseErrorFrameText:SetText(message);
end

function KnowledgeBaseArticleListItem_OnClick(self)
	PlaySound("igMainMenuOptionCheckBoxOn");
	local searchText = KnowledgeBaseFrameEditBox:GetText();
	local searchType = 2;
	if (searchText == KBASE_DEFAULT_SEARCH_TEXT or searchText == "") then
		searchType = 1;
	end
	KBArticle_BeginLoading(self.articleId, searchType);
end

function KnowledgeBaseArticleListItem_OnEnter(self)
	self.tooltipDelay = KBASE_TOOLTIP_DELAY;
end

function KnowledgeBaseArticleListItem_OnUpdate(self, ...)
	if ( not self.tooltipDelay ) then
		return;
	end

	local elapsed = ...;
	self.tooltipDelay = self.tooltipDelay - elapsed;
	if ( self.tooltipDelay > 0 ) then
		return;
	end

	self.tooltipDelay = nil;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 15);
	GameTooltip:SetText(self.articleHeader, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);

	if ( self.isArticleHot ) then
		GameTooltip:AddLine(KBASE_HOT_ISSUE);
		GameTooltip:AddTexture("Interface\\HelpFrame\\HotIssueIcon");
	end

	if ( self.isArticleUpdated ) then
		GameTooltip:AddLine(KBASE_RECENTLY_UPDATED);
		GameTooltip:AddTexture("Interface\\GossipFrame\\AvailableQuestIcon");
	end

	GameTooltip:SetMinimumWidth(220, 1);
	GameTooltip:Show();
end

function KnowledgeBaseArticleListItem_OnLeave(self)
	self.tooltipDelay = nil;
	GameTooltip:SetMinimumWidth(0, 0);
	GameTooltip:Hide();
end

function KnowledgeBaseServerMessageTextFrame_OnEnter(self)
	self.tooltipDelay = KBASE_TOOLTIP_DELAY;
end

function KnowledgeBaseServerMessageTextFrame_OnUpdate(self, elapsed)
	if ( not self.tooltipDelay ) then
		return;
	end

	self.tooltipDelay = self.tooltipDelay - elapsed;
	if ( self.tooltipDelay > 0 ) then
		return;
	end

	self.tooltipDelay = nil;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 15);
	GameTooltip:SetText(KnowledgeBaseServerMessageText:GetText(), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);
	GameTooltip:SetMinimumWidth(220, 1);
	GameTooltip:Show();
end

function KnowledgeBaseServerMessageTextFrame_OnLeave(self)
	self.tooltipDelay = nil;
	GameTooltip:SetMinimumWidth(0, 0);
	GameTooltip:Hide();
end

function KnowledgeBaseMotdTextFrame_OnEnter(self)
	self.tooltipDelay = KBASE_TOOLTIP_DELAY;
end

function KnowledgeBaseMotdTextFrame_OnUpdate(self, elapsed)
	if ( not self.tooltipDelay ) then
		return;
	end

	self.tooltipDelay = self.tooltipDelay - elapsed;
	if ( self.tooltipDelay > 0 ) then
		return;
	end

	self.tooltipDelay = nil;
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 15);
	GameTooltip:SetText(KnowledgeBaseMotdText:GetText(), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);
	GameTooltip:SetMinimumWidth(220, 1);
	GameTooltip:Show();
end

function KnowledgeBaseMotdTextFrame_OnLeave(self)
	self.tooltipDelay = nil;
	GameTooltip:SetMinimumWidth(0, 0);
	GameTooltip:Hide();
end

function SearchButton_OnUpdate(self, elapsed)
	if ( KBASE_ENABLE_SEARCH == 0 or ( not self.enableDelay ) ) then
		return;
	end

	self.enableDelay = self.enableDelay - elapsed;
	if ( self.enableDelay > 0 ) then
		return;
	end

	self.enableDelay = nil;
	self:Enable();
end
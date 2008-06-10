-- CONSTANTS
KBASE_NUM_ARTICLES_PER_PAGE = 20;
KBASE_NUM_FAKE_CATEGORIES = 1;
KBASE_NUM_FAKE_SUBCATEGORIES = 1;
KBASE_TOOLTIP_DELAY = .7;
KBASE_SEARCH_BUTTON_DELAY = 1;

-- Internal variables
KBASE_CURRENT_PAGE = 1;
KBASE_SEARCH_PERFORMED = 0;  -- make this 0 instead?
KBASE_SETUP_LOADED = 0;
KBASE_ENABLE_SEARCH = 1;

function KnowledgeBaseFrame_OnLoad()
	this:RegisterEvent("UPDATE_GM_STATUS");
	this:RegisterEvent("UPDATE_TICKET");
	this:RegisterEvent("KNOWLEDGE_BASE_SETUP_LOAD_SUCCESS");
	this:RegisterEvent("KNOWLEDGE_BASE_SETUP_LOAD_FAILURE");
	this:RegisterEvent("KNOWLEDGE_BASE_QUERY_LOAD_SUCCESS");
	this:RegisterEvent("KNOWLEDGE_BASE_QUERY_LOAD_FAILURE");
	this:RegisterEvent("KNOWLEDGE_BASE_ARTICLE_LOAD_SUCCESS");
	this:RegisterEvent("KNOWLEDGE_BASE_ARTICLE_LOAD_FAILURE");
	this:RegisterEvent("KNOWLEDGE_BASE_SYSTEM_MOTD_UPDATE");
	this:RegisterEvent("KNOWLEDGE_BASE_SERVER_MESSAGE");

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

function KnowledgeBaseFrame_OnShow()
	UpdateMicroButtons();
	PlaySound("igCharacterInfoOpen");
	if ( KBASE_SETUP_LOADED == 0 ) then
		KBSetup_BeginLoading(KBASE_NUM_ARTICLES_PER_PAGE, KBASE_CURRENT_PAGE);
	end

	GetGMStatus();
	GetGMTicket();
	KnowledgeBaseFrame_UpdateMotd();
	KnowledgeBaseFrame_UpdateServerMessage();
	KnowledgeBaseFrameEditBox:SetFocus();
end

function KnowledgeBaseFrame_OnHide()
	PlaySound("igCharacterInfoClose");
	UpdateMicroButtons();
end

function KnowledgeBaseFrame_OnEvent()
	if ( event ==  "KNOWLEDGE_BASE_SETUP_LOAD_SUCCESS" ) then
		KBASE_SETUP_LOADED = 1;

		UIDropDownMenu_Initialize(KnowledgeBaseFrameCategoryDropDown, KnowledgeBaseFrameCategoryDropDown_Initialize);
		UIDropDownMenu_Initialize(KnowledgeBaseFrameSubCategoryDropDown, KnowledgeBaseFrameSubCategoryDropDown_Initialize);

		KnowledgeBaseFrame_EnableButtons(KBSetup_GetArticleHeaderCount());

		if ( KBSetup_GetArticleHeaderCount() > 0 ) then
			KnowledgeBaseArticleListFrame_PopulateArticleList(KBSetup_GetArticleHeaderCount, KBSetup_GetArticleHeaderData, KBSetup_GetTotalArticleCount);
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
		KnowledgeBaseFrame_EnableButtons(KBQuery_GetArticleHeaderCount());

		if ( KBQuery_GetArticleHeaderCount() > 0 ) then
			KnowledgeBaseArticleListFrame_PopulateArticleList(KBQuery_GetArticleHeaderCount, KBQuery_GetArticleHeaderData, KBQuery_GetTotalArticleCount);
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
		KnowledgeBaseArticleScrollChildFrameArticleId:SetText(format(KBASE_ARTICLE_ID, id));

		KnowledgeBaseArticleScrollFrame:UpdateScrollChildRect();
		KnowledgeBaseArticleScrollFrameScrollBar:SetValue(0);

		KnowledgeBaseFrame_ShowArticleFrame();
	end

	if ( event == "KNOWLEDGE_BASE_ARTICLE_LOAD_FAILURE" ) then
		KnowledgeBaseErrorFrame_SetErrorMessage(KBASE_ERROR_LOAD_FAILURE);
		KnowledgeBaseFrame_ShowErrorFrame();
	end

	if ( event ==  "UPDATE_GM_STATUS" ) then
		if ( arg1 == 1 ) then
			GetGMTicket();
		else
			KnowledgeBaseFrameOpenTicket:Disable();
			KnowledgeBaseFrameOpenTicketEdit:Disable();
			KnowledgeBaseFrameOpenTicketCancel:Disable();
		end
	end

	if ( event == "UPDATE_TICKET" ) then
		if ( PETITION_QUEUE_ACTIVE ) then
			if (  arg1 and arg1 ~= 0 ) then
				KnowledgeBaseFrameOpenTicket:Disable();
				KnowledgeBaseFrameOpenTicketEdit:Enable();
				KnowledgeBaseFrameOpenTicketCancel:Enable();
			else
				KnowledgeBaseFrameOpenTicket:Enable();
				KnowledgeBaseFrameOpenTicketEdit:Disable();
				KnowledgeBaseFrameOpenTicketCancel:Disable();
			end
		end
	end

	if ( event ==  "KNOWLEDGE_BASE_SYSTEM_MOTD_UPDATE" ) then
		KnowledgeBaseFrame_UpdateMotd();
	end

	if ( event ==  "KNOWLEDGE_BASE_SERVER_MESSAGE" ) then
		KnowledgeBaseFrame_UpdateServerMessage();
	end
end

function ToggleKnowledgeBaseFrame()
	if ( KnowledgeBaseFrame:IsVisible() ) then
		HideUIPanel(KnowledgeBaseFrame);
	elseif ( HelpFrame:IsVisible() ) then
		HideUIPanel(HelpFrame);		
	else
		StaticPopup_Hide("HELP_TICKET");
		StaticPopup_Hide("HELP_TICKET_ABANDON_CONFIRM");
		HideUIPanel(HelpFrame);
		ShowUIPanel(KnowledgeBaseFrame);
	end
end

function OpenHelpFrame()
	HideUIPanel(KnowledgeBaseFrame);

	if ( PETITION_QUEUE_ACTIVE ) then
		ShowUIPanel(HelpFrame);
	else
		StaticPopup_Show("HELP_TICKET_QUEUE_DISABLED");
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
		closeBracketIndex = strfind(currrentServerNotice, "] ", 1, true);
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
	buttonText = getglobal(button:GetName() .. "Text");
	buttonText:SetTextColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b);
end

function EnablePagingButton(button)
	button:Enable();
	buttonText = getglobal(button:GetName() .. "Text");
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

function KnowledgeBaseFrame_EnableButtons(articleCount)
	KBASE_ENABLE_SEARCH = 1;
--	KnowledgeBaseFrameTopIssuesButton:Enable();
--	KnowledgeBaseFrameSearchButton:Enable();

	UIDropDownMenu_EnableDropDown(KnowledgeBaseFrameCategoryDropDown);
	UpdateSubCategoryEnabledState();

	if ( KBASE_CURRENT_PAGE == 1 ) then
		DisablePagingButton(KnowledgeBaseArticleListFramePreviousButton);
	else
		EnablePagingButton(KnowledgeBaseArticleListFramePreviousButton);
	end

	if ( articleCount ) then
		if (articleCount ==  KBASE_NUM_ARTICLES_PER_PAGE) then
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

function KnowledgeBaseFrameCategoryDropDown_OnLoad()
	UIDropDownMenu_SetWidth(120, KnowledgeBaseFrameCategoryDropDown);
	UIDropDownMenu_SetText(CATEGORY, KnowledgeBaseFrameCategoryDropDown);
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

function KnowledgeBaseFrameCategoryButton_OnClick()
	local oldSelectedCategoryId = UIDropDownMenu_GetSelectedID(KnowledgeBaseFrameCategoryDropDown);
	local selectedCategoryId = this:GetID();
	
	if ( selectedCategoryId == oldSelectedCategoryId) then
		return;
	end
	
	UIDropDownMenu_SetSelectedID(KnowledgeBaseFrameCategoryDropDown, selectedCategoryId);

	UIDropDownMenu_SetSelectedID(KnowledgeBaseFrameSubCategoryDropDown, 0);
	UIDropDownMenu_ClearAll(KnowledgeBaseFrameSubCategoryDropDown);
	UIDropDownMenu_SetText(SUBCATEGORY, KnowledgeBaseFrameSubCategoryDropDown);

	UpdateSubCategoryEnabledState();
end

function KnowledgeBaseFrameSubCategoryDropDown_OnLoad()
	UIDropDownMenu_SetWidth(120, KnowledgeBaseFrameSubCategoryDropDown);
	UIDropDownMenu_SetText(SUBCATEGORY, KnowledgeBaseFrameSubCategoryDropDown);
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

function KnowledgeBaseFrameSubCategoryButton_OnClick()
	UIDropDownMenu_SetSelectedID(KnowledgeBaseFrameSubCategoryDropDown, this:GetID());
end

function KnowledgeBaseArticleListFrame_HideArticleList()
	for i=1, KBASE_NUM_ARTICLES_PER_PAGE do
		local frame = getglobal("KnowledgeBaseArticleListItem" .. i);
		frame:Hide();
	end
end

function KnowledgeBaseArticleListFrame_PopulateArticleList(countFunc, dataFunc, totalCountFunc)
	KnowledgeBaseArticleListFrame_HideArticleList();
	local numArticleHeaders = countFunc();
	for i=1, numArticleHeaders do
		local articleId, articleHeader, isArticleHot, isArticleUpdated =   dataFunc(i);
		local frame = getglobal("KnowledgeBaseArticleListItem" .. i);
		frame.number = i + ((KBASE_CURRENT_PAGE -1) * KBASE_NUM_ARTICLES_PER_PAGE);
		frame.articleId = articleId;
		frame.articleHeader = articleHeader;
		frame.isArticleHot = isArticleHot;
		frame.isArticleUpdated = isArticleUpdated;

		KnowledgeBaseArticleListItem_Update(frame);
		frame:Show();
	end

	KnowledgeBaseArticleListFrameCount:SetText(format(KBASE_ARTICLE_COUNT,
		(((KBASE_CURRENT_PAGE -1) * KBASE_NUM_ARTICLES_PER_PAGE) + 1),
		min(numArticleHeaders, (KBASE_CURRENT_PAGE * KBASE_NUM_ARTICLES_PER_PAGE)) + ((KBASE_CURRENT_PAGE -1) * KBASE_NUM_ARTICLES_PER_PAGE),
		 totalCountFunc()));
end

function KnowledgeBaseArticleListItem_Update(frame)
	local numberText = getglobal(frame:GetName() .. "Number");
	numberText:SetText(frame.number .. ".");

	local updatedIcon = getglobal(frame:GetName() .. "UpdatedIcon");

	if ( frame.isArticleUpdated ) then
		updatedIcon:Show();
	else
		updatedIcon:Hide();
	end

	local hotIcon = getglobal(frame:GetName() .. "HotIcon");
	if ( frame.isArticleHot ) then
		hotIcon:Show();
	else
		hotIcon:Hide();
	end

	local titleText = getglobal(frame:GetName() .. "Title");
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

	if ( KnowledgeBaseMotdLabel:IsVisible() ) then
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

function KnowledgeBaseArticleListItem_OnClick()
	PlaySound("igMainMenuOptionCheckBoxOn");
	local searchText = KnowledgeBaseFrameEditBox:GetText();
	local searchType = 2;
	if (searchText == KBASE_DEFAULT_SEARCH_TEXT or searchText == "") then
		searchType = 1;
	end
	KBArticle_BeginLoading(this.articleId, searchType);
end

function KnowledgeBaseArticleListItem_OnEnter()
	this.tooltipDelay = KBASE_TOOLTIP_DELAY;
end

function KnowledgeBaseArticleListItem_OnUpdate(elapsed)
	if ( not this.tooltipDelay ) then
		return;
	end
	this.tooltipDelay = this.tooltipDelay - elapsed;
	if ( this.tooltipDelay > 0 ) then
		return;
	end

	this.tooltipDelay = nil;
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT", 15);
	GameTooltip:SetText(this.articleHeader, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);

	if ( this.isArticleHot ) then
		GameTooltip:AddLine(KBASE_HOT_ISSUE);
		GameTooltip:AddTexture("Interface\\HelpFrame\\HotIssueIcon");
	end

	if ( this.isArticleUpdated ) then
		GameTooltip:AddLine(KBASE_RECENTLY_UPDATED);
		GameTooltip:AddTexture("Interface\\GossipFrame\\AvailableQuestIcon");
	end

	GameTooltip:SetMinimumWidth(220, 1);
	GameTooltip:Show();
end

function KnowledgeBaseArticleListItem_OnLeave()
	this.tooltipDelay = nil;
	GameTooltip:SetMinimumWidth(0, 0);
	GameTooltip:Hide();
end

function KnowledgeBaseServerMessageTextFrame_OnEnter()
	this.tooltipDelay = KBASE_TOOLTIP_DELAY;
end

function KnowledgeBaseServerMessageTextFrame_OnUpdate(elapsed)
	if ( not this.tooltipDelay ) then
		return;
	end
	this.tooltipDelay = this.tooltipDelay - elapsed;
	if ( this.tooltipDelay > 0 ) then
		return;
	end

	this.tooltipDelay = nil;
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT", 15);
	GameTooltip:SetText(KnowledgeBaseServerMessageText:GetText(), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);
	GameTooltip:SetMinimumWidth(220, 1);
	GameTooltip:Show();
end

function KnowledgeBaseServerMessageTextFrame_OnLeave()
	this.tooltipDelay = nil;
	GameTooltip:SetMinimumWidth(0, 0);
	GameTooltip:Hide();
end

function KnowledgeBaseMotdTextFrame_OnEnter()
	this.tooltipDelay = KBASE_TOOLTIP_DELAY;
end

function KnowledgeBaseMotdTextFrame_OnUpdate(elapsed)
	if ( not this.tooltipDelay ) then
		return;
	end
	this.tooltipDelay = this.tooltipDelay - elapsed;
	if ( this.tooltipDelay > 0 ) then
		return;
	end

	this.tooltipDelay = nil;
	GameTooltip:SetOwner(this, "ANCHOR_RIGHT", 15);
	GameTooltip:SetText(KnowledgeBaseMotdText:GetText(), HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b, 1);
	GameTooltip:SetMinimumWidth(220, 1);
	GameTooltip:Show();
end

function KnowledgeBaseMotdTextFrame_OnLeave()
	this.tooltipDelay = nil;
	GameTooltip:SetMinimumWidth(0, 0);
	GameTooltip:Hide();
end

function SearchButton_OnUpdate(elapsed)
	if ( KBASE_ENABLE_SEARCH == 0 ) then
		return;
	end

	if ( not this.enableDelay ) then
		return;
	end

	this.enableDelay = this.enableDelay - elapsed;
	if ( this.enableDelay > 0 ) then
		return;
	end

	this.enableDelay = nil;
	this:Enable();
end
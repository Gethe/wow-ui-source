CampaignOverviewMixin = {};

function CampaignOverviewMixin:OnLoad()
	self.ScrollFrame.ScrollBar:ClearAllPoints();
	self.ScrollFrame.ScrollBar:SetAllPoints(QuestScrollFrame.ScrollBar);
	self.Header.BackButton:SetMode("questlog");

	self.linePool = CreateFontStringPool(self.ScrollFrame.ScrollChild, "BACKGROUND", 0);
	self.texturePool = CreateTexturePool(self.ScrollFrame.ScrollChild, "BACKGROUND", -1);
end

do
	dynamicEvents = {
		"QUEST_LOG_UPDATE",
		"QUEST_LOG_CRITERIA_UPDATE",
		"GROUP_ROSTER_UPDATE",
		"PARTY_MEMBER_ENABLE",
		"PARTY_MEMBER_DISABLE",
		"QUEST_ACCEPTED",
		"QUEST_SESSION_JOINED",
		"QUEST_SESSION_LEFT",
		"LORE_TEXT_UPDATED_CAMPAIGN",
	};

	function CampaignOverviewMixin:OnShow()
		FrameUtil.RegisterFrameForEvents(self, dynamicEvents);
	end

	function CampaignOverviewMixin:OnHide()
		self.linePool:ReleaseAll();
		self.texturePool:ReleaseAll();
		FrameUtil.UnregisterFrameForEvents(self, dynamicEvents);
	end
end

function CampaignOverviewMixin:OnEvent(event, ...)
	if event == "LORE_TEXT_UPDATED_CAMPAIGN" then
		self:UpdateCampaignLoreText(...);
	else
		self:RequestLoreText();
	end
end

function CampaignOverviewMixin:SetCampaign(campaignID)
	self.Header:SetCampaign(campaignID);
	self:RequestLoreText();
end

function CampaignOverviewMixin:RequestLoreText()
	C_LoreText.RequestLoreTextForCampaignID(self.Header:GetCampaign():GetID());
end

function CampaignOverviewMixin:SetupEntry(index, entry)
	local line = self.linePool:Acquire();
	line:SetWidth(220);
	line.layoutIndex = index;

	if entry.isHeader then
		self:SetupEntryHeader(index, entry, line);
	else
		self:SetupEntryStandard(index, entry, line);
	end
end

function CampaignOverviewMixin:SetupEntryHeader(index, entry, line)
	entry.text = "\n" .. entry.text;
	line:SetFontObject(Game13FontShadow);
	line:SetTextColor(HIGHLIGHT_FONT_COLOR:GetRGBA());
	line:SetJustifyH("CENTER");
	line:SetJustifyV("BOTTOM");

	local texture = self.texturePool:Acquire();
	texture:SetPoint("BOTTOM", line, "BOTTOM", 0, -5);
	texture:SetAtlas("Campaign-QuestLog-LoreDivider", true);
	texture:SetWidth(line:GetWidth());
	texture:Show();

	self:SetupEntryData(index, entry, line);
end

function CampaignOverviewMixin:SetupEntryStandard(index, entry, line)
	line:SetFontObject(SystemFont_Shadow_Med1);
	line:SetTextColor(LORE_TEXT_BODY_COLOR:GetRGBA());
	line:SetJustifyH("LEFT");
	line:SetJustifyV("TOP");

	self:SetupEntryData(index, entry, line);
end

function CampaignOverviewMixin:SetupEntryData(index, entry, line)
	line:SetText(entry.text);
	line:Show();
end

function CampaignOverviewMixin:UpdateCampaignLoreText(campaignID, textEntries)
	self.linePool:ReleaseAll();
	self.texturePool:ReleaseAll();

	for index, entry in ipairs(textEntries) do
		self:SetupEntry(index, entry);
	end

	self.ScrollFrame.ScrollChild:Layout();
	self.ScrollFrame:UpdateScrollChildRect();
	self.ScrollFrame:UpdateFade();
end

FadeScrollMixin = {};

function FadeScrollMixin:OnVerticalScroll(offset)
	ScrollFrame_OnVerticalScroll(self, offset);
	self:UpdateFade();
end

function FadeScrollMixin:GetVerticalScrollNormalized()
	local range = self:GetVerticalScrollRange();
	local offset = self:GetVerticalScroll();
	if range ~= 0 then
		return offset / range;
	end

	return nil;
end

function FadeScrollMixin:UpdateFade()
	local offset = self:GetVerticalScrollNormalized();
	if offset ~= nil then
		if offset < 0.15 then
			self.TopShadow:SetAlpha(ClampedPercentageBetween(offset, 0, 0.15));
		end

		if offset > 0.85 then
			self.BottomShadow:SetAlpha(1 - ClampedPercentageBetween(offset, 0.85, 1));
		end
	else
		self.TopShadow:SetAlpha(0);
		self.BottomShadow:SetAlpha(0);
	end
end
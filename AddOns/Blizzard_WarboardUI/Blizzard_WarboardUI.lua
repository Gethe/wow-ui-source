WarboardQuestChoiceFrameMixin = CreateFromMixins(QuestChoiceFrameMixin);

local contentTextureKitRegions = {
	["Header"] = "warboard-header-%s",
}

local titleTextureKitRegions = {
	["Left"] = "warboard-title-%s-left",
	["Right"] = "warboard-title-%s-right",
	["Middle"] = "_warboard-title-%s-middle",
}

function WarboardQuestChoiceFrameMixin:OnLoad()
	self.QuestionText = self.Title.Text;
	self.initOptionHeight = 337;
	self.optionStaticHeight = 275;
	self.initWindowHeight = 549;
	self.initOptionBackgroundHeight = 337;
	self.initOptionHeaderTextHeight = 20;

	QuestChoiceFrameMixin.OnLoad(self);
end

-- Adding this as this frame does not show rewards, so disabling the function to avoid lua errors from missing elements.
function WarboardQuestChoiceFrameMixin:ShowRewards(numChoices)
end

function WarboardQuestChoiceFrameMixin:TryShow()
	local uiTextureKitID, hideWarboardHeader = select(4, GetQuestChoiceInfo());
	SetupTextureKits(uiTextureKitID, self, contentTextureKitRegions);
	SetupTextureKits(uiTextureKitID, self.Title, titleTextureKitRegions);
	self.Header:SetShown(not hideWarboardHeader);
	QuestChoiceFrameMixin.TryShow(self);
end

function WarboardQuestChoiceFrameMixin:OnHeightChanged(heightDiff)
	local maxHeaderTextHeight = self.initOptionHeaderTextHeight;
	
	for _, option in pairs(self.Options) do
		maxHeaderTextHeight = math.max(maxHeaderTextHeight, option.Header.Text:GetHeight());
	end

	local headerTextDifference = math.floor(maxHeaderTextHeight) - self.initOptionHeaderTextHeight;

	for _, option in pairs(self.Options) do
		option.Header.Text:SetHeight(maxHeaderTextHeight);
		option:SetHeight(option:GetHeight() + headerTextDifference);
		option.Header.Background:SetHeight(self.initOptionBackgroundHeight + heightDiff + headerTextDifference);
	end
end

function WarboardQuestChoiceFrameMixin:Update()
	QuestChoiceFrameMixin.Update(self);

	local _, _, numOptions = GetQuestChoiceInfo();

	self.Title:SetPoint("RIGHT", self.Options[numOptions], "RIGHT", 3, 0);
end

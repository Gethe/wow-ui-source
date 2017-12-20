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
	self.initOptionHeight = 332;
	self.optionStaticHeight = 270;
	self.initWindowHeight = 544;
	self.initOptionBackgroundHeight = 332;
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
	for _, option in pairs(self.Options) do
		option.Header.Background:SetHeight(self.initOptionBackgroundHeight + heightDiff);
	end
end

function WarboardQuestChoiceFrameMixin:Update()
	QuestChoiceFrameMixin.Update(self);

	local _, _, numOptions = GetQuestChoiceInfo();

	self.Title:SetPoint("RIGHT", self.Options[numOptions], "RIGHT", -6, 0);
end

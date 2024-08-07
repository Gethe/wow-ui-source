
POIButtonUtil = {};

POIButtonUtil.Type = {
	Custom = 1,
	Quest = 2,
	Content = 3,
	AreaPOI = 4,
};

POIButtonUtil.Style = {
	Waypoint = 1,
	QuestInProgress = 2,
	QuestComplete = 3,
	QuestDisabled = 4,
	QuestThreat = 5,
	ContentTracking = 6,
	WorldQuest = 7,
	BonusObjective = 9,
	AreaPOI = 10,
};

local styleXType = {
	[POIButtonUtil.Style.Waypoint] = POIButtonUtil.Type.None,
	[POIButtonUtil.Style.QuestInProgress] = POIButtonUtil.Type.Quest,
	[POIButtonUtil.Style.QuestComplete] = POIButtonUtil.Type.Quest,
	[POIButtonUtil.Style.QuestDisabled] = POIButtonUtil.Type.Quest,
	[POIButtonUtil.Style.QuestThreat] = POIButtonUtil.Type.Quest,
	[POIButtonUtil.Style.ContentTracking] = POIButtonUtil.Type.Content,
	[POIButtonUtil.Style.WorldQuest] = POIButtonUtil.Type.Quest,
	[POIButtonUtil.Style.BonusObjective] = POIButtonUtil.Type.Quest,
	[POIButtonUtil.Style.AreaPOI] = POIButtonUtil.Type.AreaPOI,
}

function POIButtonUtil.GetStyle(questID)
	local quest = QuestCache:Get(questID);

	if quest:IsComplete() then
		return POIButtonUtil.Style.QuestComplete;
	elseif quest:IsDisabledForSession() then
		return POIButtonUtil.Style.QuestDisabled;
	else
		return POIButtonUtil.Style.QuestInProgress;
	end
end

function POIButtonUtil.GetTypeFromStyle(style)
	return styleXType[style];
end

function POIButtonUtil.ShowLegendGlow(pin)
    if not pin.LegendGlow then
        local glow = pin:CreateTexture(nil, "BACKGROUND");
        if pin.Glow then
            glow:SetPoint("TOPLEFT", pin.Glow, "TOPLEFT");
            glow:SetPoint("BOTTOMRIGHT", pin.Glow, "BOTTOMRIGHT");
        else
            glow:SetPoint("TOPLEFT", pin, "TOPLEFT", -18, 18);
            glow:SetPoint("BOTTOMRIGHT", pin, "BOTTOMRIGHT", 18, -18);
        end
        glow:SetAtlas("UI-QuestPoi-OuterGlow");
        pin.LegendGlow = glow;
    end
    pin.LegendGlow:Show();
end

function POIButtonUtil.HideLegendGlow(pin)
    pin.LegendGlow:Hide();
end

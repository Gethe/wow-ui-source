
NUMGOSSIPBUTTONS = 16;

function GossipFrame_OnLoad()
	this:RegisterEvent("GOSSIP_SHOW");
	this:RegisterEvent("GOSSIP_CLOSED");
end

function GossipFrame_OnEvent()
	if ( event == "GOSSIP_SHOW" ) then
		if ( not GossipFrame:IsVisible() ) then
			ShowUIPanel(GossipFrame);
			if ( not GossipFrame:IsVisible() ) then
				CloseGossip();
				return;
			end
		end
		GossipFrameUpdate();
	elseif ( event == "GOSSIP_CLOSED" ) then
		HideUIPanel(GossipFrame);
	end
end

function GossipFrameUpdate()
	GossipFrame.buttonIndex = 1;
	GossipGreetingText:SetText(GetGossipText());
	GossipFrameAvailableQuestsUpdate(GetGossipAvailableQuests());
	GossipFrameActiveQuestsUpdate(GetGossipActiveQuests());
	GossipFrameOptionsUpdate(GetGossipOptions());
	for i=GossipFrame.buttonIndex, NUMGOSSIPBUTTONS do
		getglobal("GossipTitleButton" .. i):Hide();
	end
	GossipFrameNpcNameText:SetText(UnitName("npc"));
	if ( UnitExists("npc") ) then
		SetPortraitTexture(GossipFramePortrait, "npc");
	else
		GossipFramePortrait:SetTexture("Interface\\QuestFrame\\UI-QuestLog-BookIcon");
	end
end

function GossipTitleButton_OnClick()
	if ( this.type == "Available" ) then
		SelectGossipAvailableQuest(this:GetID());
	elseif ( this.type == "Active" ) then
		SelectGossipActiveQuest(this:GetID());
	else
		SelectGossipOption(this:GetID());
	end
end

function GossipFrameAvailableQuestsUpdate(...)
	local titleButton;
	local titleIndex = 1;
	for i=1, arg.n, 2 do
		if ( GossipFrame.buttonIndex > NUMGOSSIPBUTTONS ) then
			message("This NPC has too many quests and/or gossip options.");
		end
		titleButton = getglobal("GossipTitleButton" .. GossipFrame.buttonIndex);
		titleButton:SetText(arg[i]);
		GossipResize(titleButton);
		titleButton:SetID(titleIndex);
		titleButton.type="Available";
		getglobal(titleButton:GetName() .. "GossipIcon"):SetTexture("Interface\\GossipFrame\\AvailableQuestIcon");
		GossipFrame.buttonIndex = GossipFrame.buttonIndex + 1;
		titleIndex = titleIndex + 1;
		titleButton:Show();
	end
	if ( GossipFrame.buttonIndex > 1 ) then
		titleButton = getglobal("GossipTitleButton" .. GossipFrame.buttonIndex);
		titleButton:Hide();
		GossipFrame.buttonIndex = GossipFrame.buttonIndex + 1;
	end
end

function GossipFrameActiveQuestsUpdate(...)
	local titleButton;
	local titleIndex = 1;
	for i=1, arg.n, 2 do
		if ( GossipFrame.buttonIndex > NUMGOSSIPBUTTONS ) then
			message("This NPC has too many quests and/or gossip options.");
		end
		titleButton = getglobal("GossipTitleButton" .. GossipFrame.buttonIndex);
		titleButton:SetText(arg[i]);
		GossipResize(titleButton);
		titleButton:SetID(titleIndex);
		titleButton.type="Active";
		getglobal(titleButton:GetName() .. "GossipIcon"):SetTexture("Interface\\GossipFrame\\ActiveQuestIcon");
		GossipFrame.buttonIndex = GossipFrame.buttonIndex + 1;
		titleIndex = titleIndex + 1;
		titleButton:Show();
	end
	if ( titleIndex > 1 ) then
		titleButton = getglobal("GossipTitleButton" .. GossipFrame.buttonIndex);
		titleButton:Hide();
		GossipFrame.buttonIndex = GossipFrame.buttonIndex + 1;
	end
end

function GossipFrameOptionsUpdate(...)
	local titleButton;
	local titleIndex = 1;
	for i=1, arg.n, 2 do
		if ( GossipFrame.buttonIndex > NUMGOSSIPBUTTONS ) then
			message("This NPC has too many quests and/or gossip options.");
		end
		titleButton = getglobal("GossipTitleButton" .. GossipFrame.buttonIndex);
		titleButton:SetText(arg[i]);
		GossipResize(titleButton);
		titleButton:SetID(titleIndex);
		titleButton.type="Gossip";
		getglobal(titleButton:GetName() .. "GossipIcon"):SetTexture("Interface\\GossipFrame\\" .. arg[i+1] .. "GossipIcon");
		GossipFrame.buttonIndex = GossipFrame.buttonIndex + 1;
		titleIndex = titleIndex + 1;
		titleButton:Show();
	end
end

function GossipResize(titleButton)
	titleButton:SetHeight( titleButton:GetTextHeight() + 2);
end
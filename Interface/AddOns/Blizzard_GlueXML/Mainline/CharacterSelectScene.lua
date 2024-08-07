
local PartyTags = {
	"party1",
	"party2",
	"party3",
	"party4",
};


CharacterSelectSceneMixin = {}

local CharacterSelectSceneEvents = {
	"CHARACTER_LIST_UPDATE",
	"UPDATE_SELECTED_CHARACTER",
};

function CharacterSelectSceneMixin:OnLoad()
	ModelSceneMixin.OnLoad(self);
	SetWorldFrameStrata(self);
	self:SetFrameLevel(self:GetFrameLevel() + 10);

	self.highestLoadedIndex = 0;
end

function CharacterSelectSceneMixin:OnShow()
	FrameUtil.RegisterFrameForEvents(self, CharacterSelectSceneEvents);

	self:UpdateScene();
end

function CharacterSelectSceneMixin:OnHide()
	FrameUtil.UnregisterFrameForEvents(self, CharacterSelectSceneEvents);
end

function CharacterSelectSceneMixin:OnEvent(event, ...)
	if event == "CHARACTER_LIST_UPDATE" then
		self:UpdateScene();
	elseif event == "UPDATE_SELECTED_CHARACTER" then
		local charID = ...;
		self:UpdateScene(CharacterSelectListUtil.GetIndexFromCharID(charID));
	end
end

function CharacterSelectSceneMixin:GetNextCharacterIndex()
	local numCharacters = GetNumCharacters();
	if numCharacters == 0 then
		return nil;
	end

	local selectIndex = self.highestLoadedIndex + 1;
	if selectIndex == CharacterSelect.selectedIndex then
		selectIndex = selectIndex + 1;
	end

	if selectIndex > numCharacters then
		return math.random(1, numCharacters);
	else
		self.highestLoadedIndex = selectIndex;
		return selectIndex;
	end
end

function CharacterSelectSceneMixin:SetActor(actor, selectIndex)
	local apiIndex = selectIndex - 1;
	LoadCharacterModel(apiIndex);
	actor:SetPlayerModelFromGlues(apiIndex);
	--self:AddOrUpdateDropShadow(actor, 2.5);
end

function CharacterSelectSceneMixin:UpdateScene(selectedIndex)
	local sceneID = self:GetSceneID();
	if not sceneID then
		self:Hide();
		return;
	end

	LoadMapScene(0);
	self:SetFromModelSceneID(sceneID);

	local selectedActor = self:GetActorByTag("selected");
	if selectedActor then
		local selectIndex = selectedIndex or CharacterSelect.selectedIndex;
		if selectIndex then
			self:SetActor(selectedActor, selectIndex);
		end
	end

	for i, actorTag in ipairs(PartyTags) do
		local actor = self:GetActorByTag(actorTag);
		if actor then
			local selectIndex = self:GetNextCharacterIndex();
			if selectIndex then
				self:SetActor(actor, selectIndex);
			end
		end
	end
end

function CharacterSelectSceneMixin:GetSceneID()
	local experimentalSceneID = tonumber(GetCVar("experimentalCharacterScene"));
	if experimentalSceneID == 0 then
		return nil;
	end

	return experimentalSceneID;
end

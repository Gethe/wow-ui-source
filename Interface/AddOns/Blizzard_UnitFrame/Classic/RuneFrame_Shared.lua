--Readability == win

FirstTime = true;
MAX_RUNES = 6;

RUNETYPE_BLOOD = 1;
RUNETYPE_FROST = 2;
RUNETYPE_UNHOLY = 3;
RUNETYPE_DEATH = 4;

iconTextures = {};
iconTextures[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood";
iconTextures[RUNETYPE_FROST] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost";
iconTextures[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy";
iconTextures[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death";

runeTextures = {
	[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Blood-Off.tga",
	[RUNETYPE_FROST] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Frost-Off.tga",
	[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\UI-PlayerFrame-DeathKnight-Death-Off.tga",
	[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Chromatic-Off.tga",
}

runeEnergizeTextures = {
	[RUNETYPE_BLOOD] = "Interface\\PlayerFrame\\Deathknight-Energize-Blood",
	[RUNETYPE_FROST] = "Interface\\PlayerFrame\\Deathknight-Energize-Frost",
	[RUNETYPE_UNHOLY] = "Interface\\PlayerFrame\\Deathknight-Energize-Unholy",
	[RUNETYPE_DEATH] = "Interface\\PlayerFrame\\Deathknight-Energize-White",
}

runeColors = {
	[RUNETYPE_BLOOD] = {1, 0, 0},
	[RUNETYPE_FROST] = {0, 1, 1},
	[RUNETYPE_UNHOLY] = {0, 0.5, 0},
	[RUNETYPE_DEATH] = {0.8, 0.1, 1},
}
runeMapping = {
	[1] = "BLOOD",
	[2] = "FROST",
	[3] = "UNHOLY",
	[4] = "DEATH",
}

function RuneButton_OnEnter(self)
	if ( self.tooltipText ) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
		GameTooltip:SetText(self.tooltipText);
		GameTooltip:Show();
	end
end

function RuneButton_OnLeave(self)
	GameTooltip:Hide();
end

function RuneButton_Update (self, rune, dontFlash)
	rune = rune or self:GetID();
	local runeType = GetRuneType(rune);

	if ( (not dontFlash) and (runeType) and (runeType ~= self.rune.runeType)) then 
		self.shine:SetVertexColor(unpack(runeColors[runeType]));
		RuneButton_ShineFadeIn(self.shine)
	end

	if (self.colorOrb) then self.colorOrb:SetTexture(runeEnergizeTextures[runeType]); end
	
	if (runeType) then
		self.rune:SetTexture(iconTextures[runeType]);
		self.rune:Show();
		self.rune.runeType = runeType;
		self.tooltipText = _G["COMBAT_TEXT_RUNE_"..runeMapping[runeType]];
	else
		self.rune:Hide();
		self.tooltipText = nil;
	end

end

function RuneButton_ShineFadeIn(self)
	if self.shining then
		return
	end
	local fadeInfo={
	mode = "IN",
	timeToFade = 0.5,
	finishedFunc = RuneButton_ShineFadeOut,
	finishedArg1 = self,
	}
	self.shining=true;
	UIFrameFade(self, fadeInfo);
end

function RuneButton_ShineFadeOut(self)
	self.shining=false;
	UIFrameFadeOut(self, 0.5);
end
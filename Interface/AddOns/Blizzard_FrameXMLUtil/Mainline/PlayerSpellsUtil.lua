local function CheckLoadPlayerSpellsFrame()
	if not PlayerSpellsFrame then
		PlayerSpellsFrame_LoadUI();
	end
end

local function SetOrClearInspectUnit(inspectUnit)
	if inspectUnit then
		PlayerSpellsFrame:SetInspectUnit(inspectUnit);
	elseif PlayerSpellsFrame:IsInspecting() then
		PlayerSpellsFrame:ClearInspectUnit();
	end
end

--------------------------- Frame Open Helpers --------------------------------

PlayerSpellsUtil = {};

PlayerSpellsUtil.FrameTabs = {
	ClassSpecializations = 1,
	ClassTalents = 2,
	SpellBook = 3,
}

PlayerSpellsUtil.SpellBookCategories = {
	Class = 1,
	General = 2,
	Pet = 3,
}

function PlayerSpellsUtil.OpenToClassTalentsTab(inspectUnit)
	CheckLoadPlayerSpellsFrame();
	SetOrClearInspectUnit(inspectUnit);

	if PlayerSpellsFrame:TrySetTab(PlayerSpellsUtil.FrameTabs.ClassTalents) then
		ShowUIPanel(PlayerSpellsFrame);
	end
end

function PlayerSpellsUtil.OpenToClassSpecializationsTab()
	CheckLoadPlayerSpellsFrame();
	PlayerSpellsFrame:ClearInspectUnit();

	if PlayerSpellsFrame:TrySetTab(PlayerSpellsUtil.FrameTabs.ClassSpecializations) then
		ShowUIPanel(PlayerSpellsFrame);
	end
end

function PlayerSpellsUtil.OpenToSpellBookTab()
	CheckLoadPlayerSpellsFrame();
	PlayerSpellsFrame:ClearInspectUnit();

	if PlayerSpellsFrame:TrySetTab(PlayerSpellsUtil.FrameTabs.SpellBook) then
		ShowUIPanel(PlayerSpellsFrame);
	end
end

function PlayerSpellsUtil.OpenToSpellBookTabAtSpell(spellID, knownSpellsOnly, toggleFlyout, flyoutReason)
	CheckLoadPlayerSpellsFrame();
	PlayerSpellsFrame:ClearInspectUnit();

	if PlayerSpellsFrame:TrySetTab(PlayerSpellsUtil.FrameTabs.SpellBook) then
		ShowUIPanel(PlayerSpellsFrame);
		return PlayerSpellsFrame.SpellBookFrame:GoToSpell(spellID, knownSpellsOnly, toggleFlyout, flyoutReason);
	end
	return nil;
end

-- spellBookCategory expects a PlayerSpellsUtil.SpellBookCategories value
function PlayerSpellsUtil:OpenToSpellBookTabAtCategory(spellBookCategory)
	CheckLoadPlayerSpellsFrame();
	PlayerSpellsFrame:ClearInspectUnit();

	if PlayerSpellsFrame:TrySetTab(PlayerSpellsUtil.FrameTabs.SpellBook) then
		ShowUIPanel(PlayerSpellsFrame);
		PlayerSpellsFrame.SpellBookFrame:TrySetCategory(spellBookCategory);
	end
end

-- spellBookCategory expects a PlayerSpellsUtil.SpellBookCategories value or nil
function PlayerSpellsUtil.ToggleSpellBookFrame(spellBookCategory)
	if DISALLOW_FRAME_TOGGLING then
		return;
	end

	CheckLoadPlayerSpellsFrame();

	local alreadyShowing = PlayerSpellsFrame:IsShown()
							and PlayerSpellsFrame:IsFrameTabActive(PlayerSpellsUtil.FrameTabs.SpellBook)
							and	(not spellBookCategory or PlayerSpellsFrame.SpellBookFrame:IsCategoryActive(spellBookCategory));

	if alreadyShowing then
		HideUIPanel(PlayerSpellsFrame);
	else
		SetOrClearInspectUnit(inspectUnit);

		if PlayerSpellsFrame:TrySetTab(PlayerSpellsUtil.FrameTabs.SpellBook) then
			if not spellBookCategory or PlayerSpellsFrame.SpellBookFrame:TrySetCategory(spellBookCategory) then
				ShowUIPanel(PlayerSpellsFrame);
			end
		end
	end
end

-- suggestedTab expects a PlayerSpellsUtil.FrameTabs value or nil
function PlayerSpellsUtil.TogglePlayerSpellsFrame(suggestedTab, inspectUnit)
	if DISALLOW_FRAME_TOGGLING then
		return false;
	end

	CheckLoadPlayerSpellsFrame();

	-- During Class_ChangeSpec tutorial, force to open to the Specializations tab when no other specific tab is specified.
	if not suggestedTab and PlayerSpellsFrame:ShouldOpenToSpecTab() then
		suggestedTab = PlayerSpellsUtil.FrameTabs.ClassSpecializations;
	end

	local alreadyShowing = PlayerSpellsFrame:IsShown()
							and (not suggestedTab or PlayerSpellsFrame:IsFrameTabActive(suggestedTab));

	if alreadyShowing then
		HideUIPanel(PlayerSpellsFrame);
	else
		SetOrClearInspectUnit(inspectUnit);

		if suggestedTab and not PlayerSpellsFrame:TrySetTab(suggestedTab) then
			return false;
		end

		ShowUIPanel(PlayerSpellsFrame);
	end

	return true;
end

function PlayerSpellsUtil.InspectLoadout(linkData)
	CheckLoadPlayerSpellsFrame();

	local _specID, level, inspectString = string.split(":", linkData);
	level = tonumber(level);

	PlayerSpellsFrame:SetInspectString(inspectString, level);

	if PlayerSpellsFrame:TrySetTab(PlayerSpellsUtil.FrameTabs.ClassTalents) then
		ShowUIPanel(PlayerSpellsFrame);
	end
end

function PlayerSpellsUtil.SetPlayerSpellsFrameMinimizedOnNextShow(minimizedOnNextShow)
	CheckLoadPlayerSpellsFrame();

	PlayerSpellsFrame:SetMinimizedOnNextShow(minimizedOnNextShow);
end

-- suggestedTab expects a PlayerSpellsUtil.FrameTabs value or nil
function TogglePlayerSpellsFrame(suggestedTab, inspectUnit)
	PlayerSpellsUtil.TogglePlayerSpellsFrame(suggestedTab, inspectUnit);
end

function PlayerSpellsUtil.ToggleClassTalentFrame(inspectUnit)
	PlayerSpellsUtil.TogglePlayerSpellsFrame(PlayerSpellsUtil.FrameTabs.ClassTalents, inspectUnit)
end

function PlayerSpellsUtil.ToggleClassTalentOrSpecFrame()
	if not PlayerSpellsUtil.TogglePlayerSpellsFrame(PlayerSpellsUtil.FrameTabs.ClassTalents) then
		PlayerSpellsUtil.TogglePlayerSpellsFrame(PlayerSpellsUtil.FrameTabs.ClassSpecializations);
	end
end
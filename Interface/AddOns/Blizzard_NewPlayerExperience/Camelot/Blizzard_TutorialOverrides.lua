local _, addonTable = ...;
local TutorialData = addonTable.TutorialData;

function NewPlayerExperience:ShouldNPEShutdownOnLevelUp()
	local playerLevel = UnitLevel("player");
	return playerLevel >= TutorialData.TUTORIAL_LEVEL_LIMIT;
end

local originalKeyboardMouseConfirmButton_OnClick = TutorialKeyboardMouseFrame_Frame.KeyboardMouseConfirmButton_OnClick;
function TutorialKeyboardMouseFrame_Frame:KeyboardMouseConfirmButton_OnClick()
	originalKeyboardMouseConfirmButton_OnClick(self);
	C_Tutorial.SendTutorialStartButtonTelem(false);
end

local originalKeyboardMouseSkipTutorialButton_OnClick = TutorialKeyboardMouseFrame_Frame.KeyboardMouseSkipTutorialButton_OnClick;
function TutorialKeyboardMouseFrame_Frame:KeyboardMouseSkipTutorialButton_OnClick()
	originalKeyboardMouseSkipTutorialButton_OnClick(self);
	C_Tutorial.SendTutorialStartButtonTelem(true);
end

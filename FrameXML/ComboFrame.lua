COMBOFRAME_FADE_IN = 0.3;
COMBOFRAME_FADE_OUT = 0.5;
COMBOFRAME_HIGHLIGHT_FADE_IN = 0.4;
COMBOFRAME_SHINE_FADE_IN = 0.3;
COMBOFRAME_SHINE_FADE_OUT = 0.4;
COMBO_FRAME_LAST_NUM_POINTS = 0;

function ComboFrame_OnEvent(self, event, ...)
	if ( event == "PLAYER_TARGET_CHANGED" ) then
		ComboFrame_Update();
	elseif ( event == "UNIT_COMBO_POINTS" ) then
		local unit = ...;
		if ( unit == PlayerFrame.unit ) then
			ComboFrame_Update();
		end
	end
end

function ComboFrame_Update()
	local comboPoints = GetComboPoints(PlayerFrame.unit, "target");
	local comboPoint, comboPointHighlight, comboPointShine;
	if ( comboPoints > 0 ) then
		if ( not ComboFrame:IsShown() ) then
			ComboFrame:Show();
			UIFrameFadeIn(ComboFrame, COMBOFRAME_FADE_IN);
		end

		
		for i=1, MAX_COMBO_POINTS do
			local fadeInfo = {};
			comboPoint = _G["ComboPoint" .. i];
			comboPoint:Show();
			comboPointHighlight = _G["ComboPoint"..i.."Highlight"];
			comboPointShine = _G["ComboPoint"..i.."Shine"];
			if ( i <= comboPoints ) then
				if ( i > COMBO_FRAME_LAST_NUM_POINTS ) then
					-- Fade in the highlight and set a function that triggers when it is done fading
					fadeInfo.mode = "IN";
					fadeInfo.timeToFade = COMBOFRAME_HIGHLIGHT_FADE_IN;
					fadeInfo.finishedFunc = ComboPointShineFadeIn;
					fadeInfo.finishedArg1 = comboPointShine;
					UIFrameFade(comboPointHighlight, fadeInfo);
				end
			else
				if ( ENABLE_COLORBLIND_MODE == "1" ) then
					comboPoint:Hide();
				end
				comboPointHighlight:SetAlpha(0);
				comboPointShine:SetAlpha(0);
			end
		end
	else
		ComboPoint1Highlight:SetAlpha(0);
		ComboPoint1Shine:SetAlpha(0);
		ComboFrame:Hide();
	end
	COMBO_FRAME_LAST_NUM_POINTS = comboPoints;
end

function ComboPointShineFadeIn(frame)
	-- Fade in the shine and then fade it out with the ComboPointShineFadeOut function
	local fadeInfo = {};
	fadeInfo.mode = "IN";
	fadeInfo.timeToFade = COMBOFRAME_SHINE_FADE_IN;
	fadeInfo.finishedFunc = ComboPointShineFadeOut;
	fadeInfo.finishedArg1 = frame;
	UIFrameFade(frame, fadeInfo);
end

--hack since a frame can't have a reference to itself in it
function ComboPointShineFadeOut(frame)
	UIFrameFadeOut(frame, COMBOFRAME_SHINE_FADE_OUT);
end

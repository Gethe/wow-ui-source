
function TextStatusBar_Initialize()
	this:RegisterEvent("CVAR_UPDATE");
	this.lockShow = 0;
end

function SetTextStatusBarText(bar, text)
	if ( not bar or not text ) then
		return
	end
	bar.TextString = text;
end

function TextStatusBar_OnEvent(cvar, value)
	if ( event == "CVAR_UPDATE" and cvar == "STATUS_BAR_TEXT" ) then
		if ( this.TextString ) then
			if ( value == "1" and this.textLockable ) then
				this.TextString:Show();
			elseif ( this.lockShow == 0 ) then
				this.TextString:Hide();
			end
		end
	end
end

function TextStatusBar_UpdateTextString(textStatusBar)
	if ( not textStatusBar ) then
		textStatusBar = this;
	end
	local string = textStatusBar.TextString;
	if(string) then
		local value = textStatusBar:GetValue();
		local valueMin, valueMax = textStatusBar:GetMinMaxValues();
		if ( valueMax > 0 ) then
			textStatusBar:Show();
			if ( value == 0 and textStatusBar.zeroText ) then
				string:SetText(textStatusBar.zeroText);
				textStatusBar.isZero = 1;
				string:Show();
			else
				textStatusBar.isZero = nil;
				if ( textStatusBar.prefix ) then
					string:SetText(textStatusBar.prefix.." "..value.." / "..valueMax);
				else
					string:SetText(value.." / "..valueMax);
				end
				if ( UIOptionsFrameCheckButtons["STATUS_BAR_TEXT"].value == "1" and textStatusBar.textLockable ) then
					string:Show();
				elseif ( textStatusBar.lockShow > 0 ) then
					string:Show();
				else
					string:Hide();
				end
			end
		else
			textStatusBar:Hide();
		end
	end
end

function TextStatusBar_OnValueChanged()
	TextStatusBar_UpdateTextString();
end

function SetTextStatusBarTextPrefix(bar, prefix)
	if ( bar and bar.TextString ) then
		bar.prefix = prefix;
	end
end

function SetTextStatusBarTextZeroText(bar, zeroText)
	if ( bar and bar.TextString ) then
		bar.zeroText = zeroText;
	end
end

function ShowTextStatusBarText(bar)
	if ( bar and bar.TextString ) then
		if ( not bar.lockShow ) then
			bar.lockShow = 0;
		end
		bar.TextString:Show();
		bar.lockShow = bar.lockShow + 1;
	end
end

function HideTextStatusBarText(bar)
	if ( bar and bar.TextString ) then
		if ( not bar.lockShow ) then
			bar.lockShow = 0;
		end
		if ( bar.lockShow > 0 ) then
			bar.lockShow = bar.lockShow - 1;
		end
		if ( bar.lockShow > 0 or this.isZero == 1) then
			bar.TextString:Show();
		elseif ( UIOptionsFrameCheckButtons["STATUS_BAR_TEXT"].value == "1" and bar.textLockable ) then
			bar.TextString:Show();
		else
			bar.TextString:Hide();
		end
	end
end

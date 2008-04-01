
function OpenStackSplitFrame(maxStack, parent, anchor, anchorTo)
	if ( StackSplitFrame.owner ) then
		StackSplitFrame.owner.hasStackSplit = 0;
	end

	StackSplitFrame.maxStack = maxStack;
	if ( StackSplitFrame.maxStack < 2 ) then
		StackSplitFrame:Hide();
		return;
	end

	StackSplitFrame.owner = parent;
	parent.hasStackSplit = 1;
	StackSplitFrame.split = 1;
	StackSplitFrame.typing = 0;
	StackSplitText:SetText(StackSplitFrame.split);
	StackSplitLeftButton:Disable();
	StackSplitRightButton:Enable();

	StackSplitFrame:ClearAllPoints();
	StackSplitFrame:SetPoint(anchor, parent:GetName(), anchorTo, 0, 0);
	StackSplitFrame:Show();
end

function UpdateStackSplitFrame(maxStack)
	StackSplitFrame.maxStack = maxStack;
	if ( StackSplitFrame.maxStack < 2 ) then
		if ( StackSplitFrame.owner ) then
			StackSplitFrame.owner.hasStackSplit = 0;
		end
		StackSplitFrame:Hide();
		return;
	end

	if ( StackSplitFrame.split > StackSplitFrame.maxStack ) then
		StackSplitFrame.split = StackSplitFrame.maxStack;
		StackSplitText:SetText(StackSplitFrame.split);
	end

	if ( StackSplitFrame.split == StackSplitFrame.maxStack ) then
		StackSplitRightButton:Disable();
	else
		StackSplitRightButton:Enable();
	end

	if ( StackSplitFrame.split == 1 ) then
		StackSplitLeftButton:Disable();
	else
		StackSplitLeftButton:Enable();
	end
end

function StackSplitFrame_OnChar()
	if ( arg1 < "0" or arg1 > "9" ) then
		return;
	end

	if ( this.typing == 0 ) then
		this.typing = 1;
		this.split = 0;
	end

	local split = (this.split * 10) + arg1;
	if ( split == this.split ) then
		if( this.split == 0 ) then
			this.split = 1;
		end
		return;
	end

	if ( split <= this.maxStack ) then
		this.split = split;
		StackSplitText:SetText(split);
		if ( split == this.maxStack ) then
			StackSplitRightButton:Disable();
		else
			StackSplitRightButton:Enable();
		end
		if ( split == 1 ) then
			StackSplitLeftButton:Disable();
		else
			StackSplitLeftButton:Enable();
		end
	elseif ( split == 0 ) then
		this.split = 1;
	end
end

function StackSplitFrame_OnKeyDown()
	if ( arg1 == "BACKSPACE" or arg1 == "DELETE" ) then
		if ( this.typing == 0 or this.split == 1 ) then
			return;
		end

		this.split = floor(this.split / 10);
		if ( this.split <= 1 ) then
			this.split = 1;
			this.typing = 0;
			StackSplitLeftButton:Disable();
		else
			StackSplitLeftButton:Enable();
		end
		StackSplitText:SetText(this.split);
		if ( this.money == this.maxStack ) then
			StackSplitRightButton:Disable();
		else
			StackSplitRightButton:Enable();
		end
	elseif ( arg1 == "ENTER" ) then
		StackSplitFrameOkay_Click();
	elseif ( arg1 == "ESCAPE" ) then
		StackSplitFrameCancel_Click();
	elseif ( arg1 == "LEFT" or arg1 == "DOWN" ) then
		StackSplitFrameLeft_Click();
	elseif ( arg1 == "RIGHT" or arg1 == "UP" ) then
		StackSplitFrameRight_Click();
	end
end

function StackSplitFrameLeft_Click()
	if ( StackSplitFrame.split == 1 ) then
		return;
	end

	StackSplitFrame.split = StackSplitFrame.split - 1;
	StackSplitText:SetText(StackSplitFrame.split);
	if ( StackSplitFrame.split == 1 ) then
		StackSplitLeftButton:Disable();
	end
	StackSplitRightButton:Enable();
end

function StackSplitFrameRight_Click()
	if ( StackSplitFrame.split == StackSplitFrame.maxStack ) then
		return;
	end

	StackSplitFrame.split = StackSplitFrame.split + 1;
	StackSplitText:SetText(StackSplitFrame.split);
	if ( StackSplitFrame.split == StackSplitFrame.maxStack ) then
		StackSplitRightButton:Disable();
	end
	StackSplitLeftButton:Enable();
end

function StackSplitFrameOkay_Click()
	if ( StackSplitFrame.owner ) then
		StackSplitFrame.owner.SplitStack(StackSplitFrame.owner, StackSplitFrame.split);
	end
	StackSplitFrame:Hide();
end

function StackSplitFrameCancel_Click()
	StackSplitFrame:Hide();
end

function StackSplitFrame_OnHide()
	if ( StackSplitFrame.owner ) then
		StackSplitFrame.owner.hasStackSplit = 0;
	end
end

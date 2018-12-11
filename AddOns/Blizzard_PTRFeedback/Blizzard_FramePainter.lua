FramePainter = {}
FramePainter.Assets = {
    [1] = "Interface\\DialogFrame\\UI-DialogBox-TestWatermark-Border",
    [2] = "Interface\\DialogFrame\\UI-DialogBox-TestWatermark-Border",
    [3] = "Interface\\FriendsFrame\\InformationIcon.blp",
    [4] = "Interface\\FriendsFrame\\InformationIcon-Highlight.blp",
}

function FramePainter.Help()
    for k,v in pairs(FramePainter) do
        if (type(v) == "function") then
            print(string.format("function FramePainter.%s()", k))
        end
    end
end

function FramePainter.AddBorder(frame)
    frame.Border = CreateFrame("Frame", nil, frame)

    frame.Border:SetFrameStrata(frame:GetFrameStrata(), frame:GetFrameLevel() + 1)

    frame.Border:SetPoint("TOPLEFT", frame, "TOPLEFT", -4, 4)
    frame.Border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 4, -4)
    frame.Border:SetBackdrop({edgeFile = FramePainter.Assets[1], edgeSize = 16})
end

function FramePainter.AddTooltip(frame, title, text, anchor, minWidth, owner, x, y)
    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(owner or self, anchor or "ANCHOR_RIGHT", x or 0, y or 0);
        GameTooltip:SetText(title, 1, 1, 1, true);
        GameTooltip:AddLine(text, nil, nil, nil, true);
        GameTooltip:SetMinimumWidth(minWidth or 100);
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
end

function FramePainter.AddDrag(frame)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function(self,button)
        self:StartMoving()
    end)
    frame:SetScript("OnDragStop", function(self,button)
        self:StopMovingOrSizing()
    end)
end

function FramePainter.AddInfoButton(frame, corner)
    if (not frame.InfoButton) then
        frame.InfoButton = CreateFrame("Button", nil, frame)
        frame.InfoButton:SetSize(20,20)
        frame.InfoButton:SetNormalTexture(FramePainter.Assets[3])
        frame.InfoButton:SetHighlightTexture(FramePainter.Assets[4], "ADD")
        frame.InfoButton:SetPoint("CENTER", frame, corner or "TOPLEFT")
        frame.InfoButton:SetFrameStrata("HIGH", frame:GetFrameLevel() + 1)
    end
end

function FramePainter.AddBackground(frame, texturePath)
    if (not frame.Background) then
        frame.Background = frame:CreateTexture()
        frame.Background:SetPoint("TOPLEFT", frame, "TOPLEFT")
        frame.Background:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT")
        frame.Background:SetVertTile(true)
        frame.Background:SetHorizTile(true)
        frame.Background:SetTexture(texturePath, true, true)
        frame.Background:SetDrawLayer("ARTWORK")
    end
end

function FramePainter.NewCheckBox(anchor1, parent, anchor2, contents, left, up, r, g, b, isFree)
    local newCheckBox = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    if (not isFree) then
        newCheckBox:SetPoint(anchor1, parent, anchor2, left or 0, (up or 0) - 12)
    end
    newCheckBox.text = newCheckBox:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    newCheckBox.text:SetPoint("BOTTOM", newCheckBox, "TOP", 0, 0)
    newCheckBox.text:SetJustifyH("CENTER")
    newCheckBox.text:SetJustifyV("CENTER")
    newCheckBox.text:SetText(contents)
    newCheckBox.text:SetTextColor(r or 1, g or 1, b or 1)
    return newCheckBox
end

function FramePainter.NewEditBox(buttonname, anchor1, parent, anchor2, contents, w, h)
    local newEditBox = CreateFrame("EditBox", buttonname, parent)
    newEditBox:SetPoint(anchor1, parent, anchor2, 0, 0)
    FramePainter.AddBorder(newEditBox)
    newEditBox:SetSize(w, h*0.75)

    newEditBox:SetFont("Fonts\\ARIALN.TTF", h/2.5, OUTLINE)
    newEditBox:SetAutoFocus(false)
    newEditBox:SetTextInsets(12, 12, 0, 4)
    newEditBox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    newEditBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    newEditBox:SetMaxLetters(255)
    newEditBox.text = newEditBox:CreateFontString(nil, "OVERLAY", "GameTooltipText")
    newEditBox.text:SetWidth(w)
    newEditBox.text:SetHeight(h)
    newEditBox.text:SetPoint("BOTTOM", newEditBox, "TOP", 0, -8)
    newEditBox.text:SetJustifyH("CENTER")
    newEditBox.text:SetJustifyV("CENTER")
    newEditBox.text:SetText(contents)
    newEditBox:SetFrameStrata(parent:GetFrameStrata(), parent:GetFrameLevel() + 1)
    return newEditBox
end
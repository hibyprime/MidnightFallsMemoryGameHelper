local addonName = "MidnightFallsMemoryGameHelper"
local FRAME_WIDTH  = 366
local FRAME_HEIGHT = 180
local ENABLED = true

local frame = CreateFrame("Frame", "MidnightFallsMemoryGameHelperFrame", UIParent, "BackdropTemplate")
frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
frame:SetPoint("CENTER", UIParent, "CENTER", 400, 200)
frame:SetMovable(true)
frame:EnableMouse(false)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop",  frame.StopMovingOrSizing)
frame:SetClampedToScreen(true)

local output = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
output:SetPoint("TOPLEFT",  frame, "TOPLEFT",  10, -28)
output:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
output:SetJustifyH("LEFT")
output:SetJustifyV("TOP")
output:SetWordWrap(true)
output:SetText(" ")

local function ParseMessage(msg)
    output:SetText(output:GetText() .. "|T" .. msg .. ":64|t  ")

    C_Timer.NewTimer (22, function ()
        output:SetText(" ")
    end)
end

local function Toggle()
    if (ENABLED) then
        print("Hiding Midnight Falls Memory Game Helper")
        frame:Hide()
        ENABLED = false
    else
        print("Showing Midnight Falls Memory Game Helper")
        frame:Show()
        ENABLED = true
    end
end

local listener = CreateFrame("Frame")
listener:RegisterEvent("CHAT_MSG_SAY")

listener:SetScript("OnEvent", function(self, event, msg)
    pcall(ParseMessage, msg)
end)

SLASH_MIDNIGHTFALLSMEMORYGAMEHELPER1 = "/mfmgh"
SlashCmdList["MIDNIGHTFALLSMEMORYGAMEHELPER"] = function(msg)
    msg = msg:lower()
    if msg == "lock" then
        frame:EnableMouse(false)
        frame:SetBackdrop(false)
    elseif msg == "unlock" then
        frame:EnableMouse(true)
        frame:SetBackdrop({
            bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 16, edgeSize = 16,
            insets = { left = 4, right = 4, top = 4, bottom = 4 },
        })
        frame:SetBackdropColor(0, 0, 0, 0.8)
    else
        Toggle()
    end
end

Toggle()
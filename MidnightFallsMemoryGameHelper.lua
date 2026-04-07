local addonName = "MidnightFallsMemoryGameHelper"
local FRAME_WIDTH  = 200
local FRAME_HEIGHT = 210
local ENABLED = true

MFMGH_DB = MFMGH_DB or {}

local function SavePosition(f, key)
    local point, _, relativePoint, x, y = f:GetPoint()
    MFMGH_DB[key] = { point = point, relativePoint = relativePoint, x = x, y = y }
end

local function LoadPosition(f, key, defaultX, defaultY)
    if MFMGH_DB[key] then
        local p = MFMGH_DB[key]
        f:ClearAllPoints()
        f:SetPoint(p.point, UIParent, p.relativePoint, p.x, p.y)
    else
        f:SetPoint("CENTER", UIParent, "CENTER", defaultX, defaultY)
    end
end

local frame = CreateFrame("Frame", "MidnightFallsMemoryGameHelperFrame", UIParent, "BackdropTemplate")
frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
LoadPosition(frame, "mainFrame", 400, 200)
frame:SetMovable(true)
frame:EnableMouse(false)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SavePosition(self, "mainFrame")
end)
frame:SetClampedToScreen(true)

local icons = {}
local MAX_ICONS = 5

local pentagramPoints = {
    {  35,  50 },
    {  57, -18 },
    {   0, -60 },
    { -57, -18 },
    { -35,  50 },
}

local chatMsgs = {
    [1] = "Interface\\AddOns\\MidnightFallsMemoryGameHelper\\Icons\\mfcircle",
    [2] = "Interface\\AddOns\\MidnightFallsMemoryGameHelper\\Icons\\mft",
    [3] = "Interface\\AddOns\\MidnightFallsMemoryGameHelper\\Icons\\mfcross",
    [4] = "Interface\\AddOns\\MidnightFallsMemoryGameHelper\\Icons\\mftriangle",
    [5] = "Interface\\AddOns\\MidnightFallsMemoryGameHelper\\Icons\\mfdiamond",
}

local tankIcon = nil
local TANK_ICON_PATH = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES"

-- Macro frame + buttons
local macroFrame = nil
local macroButtons = {}
local macrosVisible = false

local function CreateMacroFrame()
    if macroFrame then return end

    macroFrame = CreateFrame("Frame", "MFMGH_MacroFrame", UIParent, "BackdropTemplate")
    macroFrame:SetSize(232, 60)
    LoadPosition(macroFrame, "macroFrame", 400, 100)
    macroFrame:SetMovable(true)
    macroFrame:EnableMouse(true)
    macroFrame:RegisterForDrag("LeftButton")
    macroFrame:SetScript("OnDragStart", macroFrame.StartMoving)
    macroFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        SavePosition(self, "macroFrame")
    end)

    macroFrame:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    macroFrame:SetBackdropColor(0, 0, 0, 0.8)

    macroFrame:Hide()
end

local function CreateMacroButtons()
    CreateMacroFrame()
    if #macroButtons > 0 then return end

    for i = 1, 5 do
        local btn = CreateFrame("Button", "MFMGH_MacroButton"..i, macroFrame, "SecureActionButtonTemplate,BackdropTemplate")
        btn:SetSize(36, 36)
        btn:SetPoint("LEFT", macroFrame, "LEFT", 10 + (i - 1) * 44, 0)

        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            edgeSize = 12,
        })
        btn:SetBackdropColor(0, 0, 0, 0.7)

        local icon = btn:CreateTexture(nil, "OVERLAY")
        icon:SetAllPoints(btn)
        icon:SetTexture(chatMsgs[i] .. ".tga")
        btn.icon = icon

        btn:RegisterForClicks("AnyUp", "AnyDown")
        btn:SetAttribute("useOnKeyDown", false)

        btn:SetAttribute("type1", "macro")
        btn:SetAttribute("macrotext1", "/raid " .. chatMsgs[i])

        macroButtons[i] = btn
    end
end

local function ToggleMacroButtons()
    CreateMacroButtons()

    macrosVisible = not macrosVisible

    if macrosVisible then
        macroFrame:Show()
        macroFrame:EnableMouse(true)
    else
        macroFrame:Hide()
        macroFrame:EnableMouse(false)
    end
end

local function ClearIcons()
    for _, fs in ipairs(icons) do
        fs:Hide()
    end
    wipe(icons)

    if tankIcon then
        tankIcon:Hide()
    end
end

local function EnsureTankIcon()
    if tankIcon then return tankIcon end

    local tex = frame:CreateTexture(nil, "OVERLAY")
    tex:SetSize(32, 32)
    tex:SetTexture(TANK_ICON_PATH)
    tex:SetAtlas("groupfinder-icon-role-large-tank")

    tankIcon = tex
    return tex
end

local function PositionTankIcon()
    local p1 = pentagramPoints[1]
    local p2 = pentagramPoints[5]

    local midX = (p1[1] + p2[1]) / 2
    local midY = (p1[2] + p2[2]) / 2 - 25

    local tex = EnsureTankIcon()
    tex:SetPoint("CENTER", frame, "CENTER", midX, midY)
    tex:Show()
end

local function ParseMessage(msg)
    if #icons >= MAX_ICONS then return end

    local index = #icons + 1
    local point = pentagramPoints[index]

    local fs = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetPoint("CENTER", frame, "CENTER", point[1], point[2])

    fs:SetText("|T" .. msg .. ":48|t")
    fs:Show()

    table.insert(icons, fs)

    PositionTankIcon()

    C_Timer.After(22, function()
        ClearIcons()
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
listener:RegisterEvent("CHAT_MSG_RAID")
listener:RegisterEvent("CHAT_MSG_RAID_LEADER")

listener:SetScript("OnEvent", function(self, event, msg)
    ParseMessage(msg)
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
    elseif msg == "rl" then
        ToggleMacroButtons()
    else
        Toggle()
    end
end

Toggle()

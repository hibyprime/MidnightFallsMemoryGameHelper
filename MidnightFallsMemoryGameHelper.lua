local addonName = "MidnightFallsMemoryGameHelper"
local FRAME_WIDTH  = 200
local FRAME_HEIGHT = 210
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

local icons = {}
local MAX_ICONS = 5

local pentagramPoints = {
    {  35,  50 },
    {  57, -18 },
    {   0, -60 },
    { -57, -18 },
    { -35,  50 },
}

local tankIcon = nil
local TANK_ICON_PATH = "Interface\\LFGFrame\\UI-LFG-ICON-ROLES"

local function ClearIcons()
    for _, tex in ipairs(icons) do
        tex:Hide()
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

    local tex = frame:CreateTexture(nil, "ARTWORK")
    tex:SetSize(48, 48)
    tex:SetPoint("CENTER", frame, "CENTER", point[1], point[2])
    tex:SetTexture(msg)

    table.insert(icons, tex)

    if #icons >= 1 then
        PositionTankIcon()
    end

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
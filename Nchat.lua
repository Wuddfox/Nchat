-- Nchat.lua - Classic Era
-- v2.6:

local ADDON_NAME = ...
local fCore = CreateFrame("Frame")

--============================
-- Defaults
--============================
local DEFAULTS = {
  bubbleWidth   = 300,
  textSize      = 10,
  livePortraits = true,
  theme         = "dark",
  debug         = false,
  lock          = false,
  afkOnly       = false,
  decorativeBorder = false,
  newMessageGlow = false,
  newMessageAnimation = "none", -- "none", "slide", or "pop"
  showTimestamps = false,
  pos           = { point="TOPLEFT", relativeTo="ChatFrame1", relativePoint="TOPRIGHT", x=14, y=0 },
  history       = {},
}

--============================
-- Bubble Registry
--============================
NchatBubbles = {}

--============================
-- Themes
--============================
do
  local THEMES = {
    dark       = { bg={0.05,0.05,0.07,0.95}, border={0.20,0.20,0.25,1}, name={0.80,0.85,0.95,1}, text={0.90,0.92,0.95,1}, container={ bg={0,0,0,0.15}, border={0,0,0,0.25} } },
    ios        = { bg={1,1,1,0.96},           border={0.75,0.75,0.80,0.6}, name={0.15,0.15,0.17,1}, text={0.05,0.05,0.07,1}, container={ bg={0.9,0.9,0.95,0.2}, border={0.6,0.6,0.7,0.3} } },
    light      = { bg={0.96,0.98,1,0.96},     border={0.55,0.60,0.70,0.7}, name={0.12,0.15,0.20,1}, text={0.10,0.12,0.15,1}, container={ bg={0.85,0.9,1,0.2}, border={0.55,0.6,0.7,0.4} } },
    solarized  = { bg={0,0.169,0.212,0.95},   border={0.027,0.212,0.259,1},name={0.710,0.537,0,1}, text={0.933,0.910,0.835,1},container={ bg={0,0.169,0.212,0.15}, border={0.027,0.212,0.259,0.25} } },
    nord       = { bg={0.180,0.204,0.251,0.95},border={0.298,0.337,0.416,1},name={0.533,0.753,0.816,1},text={0.847,0.871,0.914,1},container={ bg={0.180,0.204,0.251,0.15}, border={0.298,0.337,0.416,0.25} } },
    dracula    = { bg={0.157,0.165,0.212,0.95},border={0.267,0.278,0.353,1},name={0.545,0.576,0.976,1},text={0.973,0.973,0.949,1},container={ bg={0.157,0.165,0.212,0.15}, border={0.267,0.278,0.353,0.25} } },
    gruvbox    = { bg={0.235,0.219,0.212,0.95},border={0.314,0.286,0.271,1},name={0.843,0.600,0.129,1},text={0.922,0.859,0.698,1},container={ bg={0.235,0.219,0.212,0.15}, border={0.314,0.286,0.271,0.25} } },
    monokai    = { bg={0.180,0.180,0.180,0.95},border={0.475,0.475,0.475,1},name={0.651,0.886,0.180,1},text={0.839,0.839,0.839,1},container={ bg={0.180,0.180,0.180,0.15}, border={0.475,0.475,0.475,0.25} } },
	tokyonight = { bg={0.11,0.16,0.28,0.95}, border={0.25,0.30,0.50,1}, name={0.50,0.70,1,1}, text={0.85,0.90,1,1}, container={ bg={0.11,0.16,0.28,0.15}, border={0.25,0.30,0.50,0.25} } },
    onedark    = { bg={0.16,0.18,0.22,0.95}, border={0.28,0.31,0.38,1}, name={0.80,0.50,0.50,1}, text={0.85,0.85,0.85,1}, container={ bg={0.16,0.18,0.22,0.15}, border={0.28,0.31,0.38,0.25} } },
    everforest = { bg={0.18,0.22,0.20,0.95}, border={0.25,0.30,0.25,1}, name={0.60,0.75,0.55,1}, text={0.85,0.85,0.80,1}, container={ bg={0.18,0.22,0.20,0.15}, border={0.25,0.30,0.25,0.25} } },
    catppuccin = { bg={0.22,0.20,0.27,0.95}, border={0.45,0.40,0.55,1}, name={0.85,0.75,0.95,1}, text={0.95,0.90,0.98,1}, container={ bg={0.22,0.20,0.27,0.15}, border={0.45,0.40,0.55,0.25} } },
    ayu        = { bg={0.16,0.16,0.16,0.95}, border={0.35,0.35,0.35,1}, name={0.95,0.65,0.25,1}, text={0.90,0.90,0.85,1}, container={ bg={0.16,0.16,0.16,0.15}, border={0.35,0.35,0.35,0.25} } },
    material   = { bg={0.13,0.15,0.17,0.95}, border={0.30,0.35,0.40,1}, name={0.25,0.65,0.90,1}, text={0.85,0.90,0.95,1}, container={ bg={0.13,0.15,0.17,0.15}, border={0.30,0.35,0.40,0.25} } },
    highcontrast = { bg={0,0,0,1},           border={0.9,0.9,0.9,1},    name={1,1,0,1},         text={1,1,1,1},         container={ bg={0,0,0,0.15}, border={0.9,0.9,0.9,0.25} } },
    paperwhite = { bg={0.97,0.97,0.95,0.96}, border={0.80,0.80,0.75,1}, name={0.20,0.20,0.25,1}, text={0.05,0.05,0.07,1}, container={ bg={0.97,0.97,0.95,0.2}, border={0.80,0.80,0.75,0.3} } },
    rosepine   = { bg={0.20,0.18,0.22,0.95}, border={0.35,0.30,0.40,1}, name={0.90,0.60,0.70,1}, text={0.95,0.90,0.92,1}, container={ bg={0.20,0.18,0.22,0.15}, border={0.35,0.30,0.40,0.25} } },
    nightowl   = { bg={0.10,0.14,0.20,0.95}, border={0.20,0.28,0.40,1}, name={0.45,0.80,1,1},    text={0.85,0.92,1,1},   container={ bg={0.10,0.14,0.20,0.15}, border={0.20,0.28,0.40,0.25} } },
  }
  _G.NCHAT_THEMES = THEMES
end

--============================
-- Reset helper
--============================
local function Nchat_ResetDefaults()
  NChatDB = {}
  copyDefaults(NChatDB, DEFAULTS)
  RestyleAll()
  print("|cff55ccffNchat|r reset to defaults.")
  if NchatOptionsFrame and NchatOptionsFrame.themeDropdown then
    UIDropDownMenu_SetSelectedValue(NchatOptionsFrame.themeDropdown, NChatDB.theme)
    UIDropDownMenu_SetText(NchatOptionsFrame.themeDropdown, NChatDB.theme)
  end
end

--============================

local function clamp(n, lo, hi) if n<lo then return lo elseif n>hi then return hi else return n end end
local function copyDefaults(dst, src)
  for k,v in pairs(src) do
    if type(v)=="table" then
      dst[k]=dst[k] or {}
      copyDefaults(dst[k], v)
    elseif dst[k]==nil then
      dst[k]=v
    end
  end
end

--============================

local function onlyName(fullName)
  if not fullName then return nil end
  local n = fullName:match("^[^-]+")
  return n or fullName
end

--============================

local function findUnitByName(name)
  name = onlyName(name)
  if not name then return nil end
  local function matches(u)
    if not UnitExists(u) then return false end
    local n = UnitName(u)
    return n and onlyName(n) == name
  end
  if matches("player") then return "player" end
  if matches("target") then return "target" end
  for i=1,4 do local u="party"..i if matches(u) then return u end end
  for i=1,40 do local u="raid"..i if matches(u) then return u end end
  return nil
end

--============================
-- Portrait Upgrade
--============================
local function TryUpgradePortraits()
  for _, b in ipairs(NchatContainer.bubbles or {}) do
    if b.__awaitingUnit and not b.__released then
      local u = findUnitByName(b.__awaitingUnit)
      if u and UnitExists(u) then
        if b.portrait and b.portrait.SetTexture then
          b.portrait:Hide()
        end
        local portrait = CreateFrame("PlayerModel", nil, b)
        portrait:SetSize(32,32)
        portrait:SetPoint("TOPLEFT", 8, -8)
        portrait:SetUnit(u)
        portrait:SetCamera(1)
        portrait:SetPortraitZoom(0.8)
        portrait:SetPosition(0,0,-0.1)
        b.portrait = portrait
        b.__awaitingUnit = nil
      end
    end
  end
end

--============================
-- Twitch Emotes addon / Chat filter passthrough with debug
--============================
local function Nchat_RunFilters(event, msg, sender)
  if not msg then return "" end
  if ChatFrame_GetMessageEventFilters then
    local filters = ChatFrame_GetMessageEventFilters(event)
    if NChatDB and NChatDB.debug then
      local count = filters and #filters or 0
      DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0Nchat Debug:|r "..event.." filters="..count)
    end
    if filters then
      for _, filter in ipairs(filters) do
        local ok, block, newMsg = pcall(filter, nil, event, msg, sender or "", "", "", "", "", "", "", "", "")
        if ok and type(newMsg) == "string" and newMsg ~= msg then
          if NChatDB and NChatDB.debug then
            DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0Nchat Debug:|r filter changed text → " .. newMsg)
          end
          msg = newMsg
        end
      end
    end
  end
  return msg
end

--============================
-- Container
--============================
local Container = CreateFrame("Frame","NchatContainer",UIParent,"BackdropTemplate")
_G.NchatContainer = Container
Container:SetSize(320,400)
Container:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=1 })
Container:EnableMouse(true)
Container:RegisterForDrag("LeftButton")
Container:SetMovable(true)
Container.bubbles = {}
Container.bubbleBySender = {}

-- Delay initial backdrop color to avoid Classic Era bug
C_Timer.After(0.1, function()
  if Container.backdropInfo then
    Container:SetBackdropColor(0,0,0,0)
    Container:SetBackdropBorderColor(0,0,0,0)
  end
end)

Container:SetScript("OnDragStart", function(self)
  if not NChatDB.lock then self:StartMoving() end
end)
Container:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
  local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
  NChatDB.pos = { point=point, relativeTo=relativeTo and relativeTo:GetName() or "UIParent", relativePoint=relativePoint, x=xOfs, y=yOfs }
end)

function Container:Layout()
  for i=#self.bubbles,1,-1 do
    if not self.bubbles[i] or self.bubbles[i].__released then table.remove(self.bubbles,i) end
  end
  local y=-6
  for i=1,#self.bubbles do
    local b=self.bubbles[i]
    local xOffset = b.__slideOffset or 0
    b:ClearAllPoints()
    b:SetPoint("TOPLEFT", 6 + xOffset, y)
    y=y-(b:GetHeight()+11)
    b:Show()
  end
end
Container:Hide()

local function ApplyContainerLock()
  local t = NCHAT_THEMES[NChatDB.theme] or NCHAT_THEMES.dark
  if NChatDB.lock then
    Container:SetMovable(false)
    Container:EnableMouse(false)
    -- Safeguard against Classic Era backdrop bug
    if Container.SetBackdropColor and Container.backdropInfo then
      Container:SetBackdropColor(0,0,0,0)
      Container:SetBackdropBorderColor(0,0,0,0)
    end
  else
    Container:SetMovable(true)
    Container:EnableMouse(true)
    -- Safeguard against Classic Era backdrop bug
    if Container.SetBackdropColor and Container.backdropInfo then
      Container:SetBackdropColor(unpack(t.container.bg))
      Container:SetBackdropBorderColor(unpack(t.container.border))
    end
  end
end
_G.ApplyContainerLock = ApplyContainerLock

--============================
-- AFK handling
--============================
local isAFK=false
local function UpdateAFK()
  isAFK = UnitIsAFK("player") or false
  if NChatDB.afkOnly then
    if isAFK then
      Container:Show()
    else
      if #Container.bubbles==0 then Container:Hide() end
    end
  else
    Container:Show()
  end
end

--============================
-- Friend-aware AFK/Online/Offline Tracker
--============================
local NchatStatusCache = {}

-- Poll every 10 seconds
local function Nchat_UpdateFriendStatus()
  local numFriends = C_FriendList.GetNumFriends()
  if not numFriends or numFriends == 0 then return end

  for i = 1, numFriends do
    local info = C_FriendList.GetFriendInfoByIndex(i)
    -- Defensive checks as info was nil or incomplete during login
    if info and type(info) == "table" and info.name then
      local name = info.name:match("^[^-]+") -- strip realm
      if info.connected then
        if info.afk then
          NchatStatusCache[name] = "AFK"
        else
          NchatStatusCache[name] = "ONLINE"
        end
      else
        NchatStatusCache[name] = "OFFLINE"
      end
    end
  end

  -- Refresh all existing bubbles immediately
  for _, b in ipairs(NchatBubbles) do
    if b.UpdateStatus then
      b:UpdateStatus()
    end
  end
end

-- Initial update + timer
C_Timer.After(2, Nchat_UpdateFriendStatus)
C_Timer.NewTicker(10, Nchat_UpdateFriendStatus)

--============================
-- Bubble stuff
--============================
-- Helper: Format message with optional timestamp
local function FormatMessage(text)
  if NChatDB.showTimestamps then
    local timestamp = date("%H:%M")
    return text .. " |cff888888[" .. timestamp .. "]|r"
  end
  return text
end

local function CreateBubble(parent,text,sender,classFile,isBN,unit,displayName,isNewMessage)
  local theme = NCHAT_THEMES[NChatDB.theme] or NCHAT_THEMES.dark
  local bubble=CreateFrame("Button",nil,parent,"BackdropTemplate")
  bubble:EnableMouse(true)
  bubble:RegisterForClicks("AnyUp")
  
  -- Choose border style based on decorativeBorder setting
  if NChatDB.decorativeBorder then
    -- Adjust insets to remove top and bottom/right tiny gap (top 12 -> 11)
    bubble:SetBackdrop({ 
      bgFile="Interface\\Buttons\\WHITE8x8", 
      edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", 
      tile=false,
      edgeSize=32,
      insets = { left=11, right=11, top=11, bottom=10 }
    })
  else
    bubble:SetBackdrop({ 
      bgFile="Interface\\Buttons\\WHITE8x8", 
      edgeFile="Interface\\Buttons\\WHITE8x8", 
      edgeSize=2,
      insets = { left=1, right=1, top=1, bottom=1 }
    })
  end
  
  bubble:SetBackdropColor(unpack(theme.bg))
  bubble:SetBackdropBorderColor(unpack(theme.border))
  bubble:SetFrameStrata("DIALOG")
  bubble.__sender=sender

  local nameFS=bubble:CreateFontString(nil,"OVERLAY","GameFontNormal")
  -- Adjust for changed insets: move 1px up (was -11) to keep balanced spacing
  local topPadding = NChatDB.decorativeBorder and -10 or -4
  nameFS:SetPoint("TOPLEFT",48,topPadding)
  nameFS:SetJustifyH("LEFT")
  -- Use displayName if provided (for BN friends), otherwise use sender
  nameFS:SetText(displayName or sender or "Unknown")
  local r,g,b=unpack(theme.name); if isBN then r,g,b=0.2,0.7,1 end
  nameFS:SetTextColor(r,g,b)

  local bw=clamp(NChatDB.bubbleWidth,160,480)
  local msgFS=bubble:CreateFontString(nil,"OVERLAY","GameFontHighlight")
  -- Move message text down 2px extra when decorative border is active by increasing negative offset
  local msgYOffset = NChatDB.decorativeBorder and -6 or -4
  msgFS:SetPoint("TOPLEFT",nameFS,"BOTTOMLEFT",0,msgYOffset)
  msgFS:SetJustifyH("LEFT")
  msgFS:SetWidth(bw-60)
  local f,_,s=msgFS:GetFont()
  msgFS:SetFont(f,clamp(NChatDB.textSize,10,24),s)
  msgFS:SetTextColor(unpack(theme.text))
  local eventForFilters = isBN and "CHAT_MSG_BN_WHISPER" or "CHAT_MSG_WHISPER"
  local filteredText = Nchat_RunFilters(eventForFilters, text or "", sender)
  msgFS:SetText(FormatMessage(filteredText))
  
  -- Store msgFS reference for later use
  bubble.msgFS = msgFS
  bubble.nameFS = nameFS

  -- Portrait logic
  if NChatDB.livePortraits then
    local portrait
    local used=false

    if unit and UnitExists(unit) then
      portrait = CreateFrame("PlayerModel", nil, bubble)
      portrait:SetSize(32,32)
      portrait:SetPoint("TOPLEFT", 8, -8)
      portrait:SetUnit(unit); used=true
      portrait:SetCamera(1)
      portrait:SetPortraitZoom(0.8)
      portrait:SetPosition(0,0,-0.1)
    else
      local guessed=findUnitByName(sender)
      if guessed and UnitExists(guessed) then
        portrait = CreateFrame("PlayerModel", nil, bubble)
        portrait:SetSize(32,32)
        portrait:SetPoint("TOPLEFT", 8, -8)
        portrait:SetUnit(guessed); used=true
        portrait:SetCamera(1)
        portrait:SetPortraitZoom(0.8)
        portrait:SetPosition(0,0,-0.1)
      end
    end

    if not used then
      portrait = bubble:CreateTexture(nil,"ARTWORK")
      portrait:SetSize(32,32)
      portrait:SetPoint("TOPLEFT",8,-8)
     if isBN then
  portrait:SetTexture("Interface\\FriendsFrame\\UI-Toast-FriendOnlineIcon")
  
  -- Mark BN friend to try upgrade later
  bubble.__awaitingUnit = sender

      elseif classFile and CLASS_ICON_TCOORDS[classFile] then
        portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
        portrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFile]))
      else
        portrait:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
      end
      bubble.__awaitingUnit = sender
    end

    bubble.portrait = portrait
  end

  --============================
  -- Status indicator (round)
  --============================
  local status = bubble:CreateTexture(nil, "OVERLAY")
  status:SetSize(12, 12)
  status:SetPoint("RIGHT", nameFS, "LEFT", -4, 0)
  status:SetTexture("Interface\\COMMON\\Indicator-Yellow")  -- circular built-in texture
  status:SetTexCoord(0, 1, 0, 1)
  bubble.statusIcon = status

  -- dark border behind dot for contrast
  local border = bubble:CreateTexture(nil, "BACKGROUND")
  border:SetSize(14, 14)
  border:SetPoint("CENTER", status)
  border:SetTexture("Interface\\Buttons\\WHITE8x8")
  border:SetColorTexture(0, 0, 0, 0.6)
  border:SetTexCoord(0.15, 0.85, 0.15, 0.85)
  bubble.statusBorder = border

  -- Status update function
  local function UpdateStatus()
    local u = findUnitByName(sender)
    local statusColor = {1, 0, 0} -- default red

    -- Try visible unit first
    if u and UnitExists(u) then
      if UnitIsAFK(u) then
        statusColor = {1, 0.5, 0} -- orange
      else
        statusColor = {0, 1, 0}   -- green
      end
    elseif sender then
  local cleanName = sender:match("^[^-]+")  -- strip realm
  local s = NchatStatusCache[cleanName]
  if s == "ONLINE" then
    statusColor = {0, 1, 0}
  elseif s == "AFK" then
    statusColor = {1, 0.5, 0}
  else
    statusColor = {1, 0, 0}
  end
end


    bubble.statusIcon:SetVertexColor(unpack(statusColor))
  end

  bubble.UpdateStatus = UpdateStatus
  UpdateStatus()
  
  bubble.msgFS=msgFS; bubble.nameFS=nameFS
  -- Add extra padding for decorative border (5px top + 5px bottom = 10px total)
  -- Increase bottom padding when decorative border enabled (was 30, now 35)
  local heightPadding = NChatDB.decorativeBorder and 35 or 20
  bubble:SetSize(bw, math.max(54,(nameFS:GetStringHeight() or 12)+(msgFS:GetStringHeight() or 12)+heightPadding))

  bubble:SetScript("OnClick", function(self, btn)
    if btn=="RightButton" then
      self.__released = true
      self:Hide()
      if self.__sender and NchatContainer.bubbleBySender[self.__sender] == self then
        NchatContainer.bubbleBySender[self.__sender] = nil
      end
      if self.__sender then
        NChatDB.history[self.__sender] = nil
      end
      NchatContainer:Layout()
      if #NchatContainer.bubbles == 0 and not UnitIsAFK("player") then
        NchatContainer:Hide()
      end
    end
  end)
  
  -- Flat-style hover buttons (Reply / Invite)
  local theme = NCHAT_THEMES[NChatDB.theme] or NCHAT_THEMES.dark
  local btnAlpha = 0.15           -- background transparency
  local btnHoverAlpha = 0.35      -- on hover
  local textColor = theme.name or {1,1,1,1}

    local function MakeFlatButton(parent, label)
  local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
  b:SetSize(50, 18)

  b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  b.text:SetPoint("CENTER")
  b.text:SetText(label)
  b.text:SetTextColor(1, 1, 1, 0.9)

  b:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
  })

  -- Use solid alpha so the red shows
  local buttonAlpha = 0.9

  -- dark red fill + slightly brighter red border
  b:SetBackdropColor(0.25, 0.02, 0.02, buttonAlpha)
  b:SetBackdropBorderColor(0.5, 0.05, 0.05, 1)

  -- brighten slightly on hover
  b:SetScript("OnEnter", function(self)
    self:SetBackdropColor(0.35, 0.06, 0.06, buttonAlpha)
  end)
  b:SetScript("OnLeave", function(self)
    self:SetBackdropColor(0.25, 0.02, 0.02, buttonAlpha)
  end)

  b:SetAlpha(0)  -- hidden until hovered by Nchat logic
  return b
end

 -- Create buttons first
  local replyBtn  = MakeFlatButton(bubble, "Reply")
  local inviteBtn = MakeFlatButton(bubble, "Invite")

-- === Position buttons on bottom right-hand side of bubble ===
replyBtn:ClearAllPoints()
replyBtn:SetPoint("BOTTOMRIGHT", bubble, "BOTTOMRIGHT", -6, -13)

inviteBtn:ClearAllPoints()
inviteBtn:SetPoint("RIGHT", replyBtn, "LEFT", -4, 0)

 -- Button actions
  replyBtn:SetScript("OnClick", function()
    ChatFrame_OpenChat("/w " .. sender .. " ", ChatFrame1)
  end)

  inviteBtn:SetScript("OnClick", function()
    local u = findUnitByName(sender)
    if u and UnitExists(u) then
      InviteUnit(UnitName(u))
    else
      InviteUnit(sender)
    end
  end)

  -- Show/Hide logic
  local function ShowButtons()
    replyBtn:SetAlpha(1)
    inviteBtn:SetAlpha(1)
  end

  local function HideButtons()
    replyBtn:SetAlpha(0)
    inviteBtn:SetAlpha(0)
    replyBtn:SetScale(0.95)
    inviteBtn:SetScale(0.95)
  end

  bubble:SetScript("OnEnter", ShowButtons)
  bubble:SetScript("OnLeave", function()
    if not (MouseIsOver(replyBtn) or MouseIsOver(inviteBtn)) then
      HideButtons()
    end
  end)
  for _,b in ipairs({replyBtn, inviteBtn}) do
    b:SetScript("OnLeave", function()
      if not (MouseIsOver(bubble) or MouseIsOver(replyBtn) or MouseIsOver(inviteBtn)) then
        HideButtons()
      end
    end)
  end

  -- Add glow effect for new messages (only if this is a new message, not from history)
  if NChatDB.newMessageGlow and isNewMessage then
    local glow = bubble:CreateTexture(nil, "OVERLAY")
    glow:SetTexture("Interface\\Buttons\\WHITE8x8")
    glow:SetAllPoints(bubble)
    glow:SetVertexColor(0.3, 0.6, 1, 0.5)
    glow:SetBlendMode("ADD")
    bubble.__glow = glow
    bubble.__glowElapsed = 0
  end
  
  -- Add animation for new messages (only if this is a new message, not from history)
  local animType = NChatDB.newMessageAnimation or "none"
  if animType == "slide" and isNewMessage then
    bubble.__slideOffset = -80
    bubble.__slideElapsed = 0
  elseif animType == "pop" and isNewMessage then
    bubble.__popScale = 0.3
    bubble.__popElapsed = 0
  end
  
  -- Combined animation OnUpdate (handles glow, slide, and pop)
  if (NChatDB.newMessageGlow or (animType ~= "none" and animType)) and isNewMessage then
    bubble:SetScript("OnUpdate", function(self, delta)
      local allDone = true
      
      -- Handle glow fade
      if self.__glow and self.__glowElapsed ~= nil then
        self.__glowElapsed = self.__glowElapsed + delta
        local alpha = math.max(0, 0.5 - (self.__glowElapsed / 2 * 0.5))
        self.__glow:SetAlpha(alpha)
        if self.__glowElapsed < 2 then
          allDone = false
        else
          self.__glowElapsed = nil
        end
      end
      
      -- Handle slide animation
      if self.__slideOffset and self.__slideElapsed ~= nil then
        self.__slideElapsed = self.__slideElapsed + delta
        local progress = math.min(1, self.__slideElapsed / 0.3)
        self.__slideOffset = -80 + (80 * progress)
        
        if progress < 1 then
          allDone = false
        else
          self.__slideOffset = 0
          self.__slideElapsed = nil
        end
        
        -- Update position during slide
        parent:Layout()
      end
      
      -- Handle pop animation (scale from 0.3 to 1.0 with bounce)
      if self.__popScale and self.__popElapsed ~= nil then
        self.__popElapsed = self.__popElapsed + delta
        local progress = math.min(1, self.__popElapsed / 0.3)
        
        -- Elastic ease-out for bounce effect
        local scale
        if progress < 1 then
          local p = 1 - progress
          scale = 1 - (p * p * p)
          scale = 0.3 + (scale * 0.7)
          -- Add slight overshoot at the end
          if progress > 0.7 then
            scale = scale + (progress - 0.7) * 0.15
          end
          allDone = false
        else
          scale = 1.0
          self.__popScale = nil
          self.__popElapsed = nil
        end
        
        self:SetScale(scale)
      end
      
      -- Stop animation when everything is done
      if allDone then
        self:SetScript("OnUpdate", nil)
        -- Ensure scale is reset
        if not self.__popElapsed then
          self:SetScale(1.0)
        end
      end
    end)
  end

table.insert(NchatBubbles, bubble)

  return bubble
end

--============================
-- Restyle
--============================
local function RestyleAll()
  local t = NCHAT_THEMES[NChatDB.theme] or NCHAT_THEMES.dark
  for _,b in ipairs(NchatContainer.bubbles) do
    if b and not b.__released then
      -- Update backdrop based on decorativeBorder setting
      if NChatDB.decorativeBorder then
        b:SetBackdrop({ 
          bgFile="Interface\\Buttons\\WHITE8x8", 
          edgeFile="Interface\\DialogFrame\\UI-DialogBox-Border", 
          tile=false,
          edgeSize=32,
          insets = { left=11, right=11, top=11, bottom=10 }
        })
      else
        b:SetBackdrop({ 
          bgFile="Interface\\Buttons\\WHITE8x8", 
          edgeFile="Interface\\Buttons\\WHITE8x8", 
          edgeSize=2,
          insets = { left=1, right=1, top=1, bottom=1 }
        })
      end
      
      b:SetBackdropColor(unpack(t.bg))
      b:SetBackdropBorderColor(unpack(t.border))
      if b.nameFS then 
        b.nameFS:SetTextColor(unpack(t.name))
  -- Update nameFS position for new top inset (balanced spacing)
  local topPadding = NChatDB.decorativeBorder and -10 or -4
        b.nameFS:ClearAllPoints()
        b.nameFS:SetPoint("TOPLEFT",48,topPadding)
      end
      if b.msgFS  then
        b.msgFS:SetTextColor(unpack(t.text))
        local bw = clamp(NChatDB.bubbleWidth,160,480)
        b.msgFS:SetWidth(bw-60)
        local f,_,s=b.msgFS:GetFont()
        b.msgFS:SetFont(f,clamp(NChatDB.textSize,10,24),s)
        b:SetWidth(bw)
        -- Add extra padding for decorative border
  local heightPadding = NChatDB.decorativeBorder and 35 or 20
        b:SetHeight(math.max(54,(b.nameFS:GetStringHeight() or 12)+(b.msgFS:GetStringHeight() or 12)+heightPadding))
      end
    end
  end
  ApplyContainerLock()
  NchatContainer:Layout()
end
_G.NchatRestyleAll = RestyleAll

--============================
-- Flow
--============================
local function upsertBubble(text,sender,classFile,isBN,unit,displayName)
  NChatDB.history = NChatDB.history or {}
  if NChatDB.afkOnly and not UnitIsAFK("player") then return end
  if not sender then return end

  NChatDB.history[sender]=NChatDB.history[sender] or { isBN=isBN, classFile=classFile, displayName=displayName }
  local old=NChatDB.history[sender].text or ""
  NChatDB.history[sender].text = (old=="" and text) or (old.."\n"..text)
  -- Update displayName if provided (in case it changed)
  if displayName then
    NChatDB.history[sender].displayName = displayName
  end

  local existing=NchatContainer.bubbleBySender[sender]
  if existing and not existing.__released then
    local eventForFilters = isBN and "CHAT_MSG_BN_WHISPER" or "CHAT_MSG_WHISPER"
    local newText = Nchat_RunFilters(eventForFilters, text or "", sender)
    existing.msgFS:SetText((existing.msgFS:GetText() or "").."\n"..FormatMessage(newText))
  -- Add extra padding for decorative border
  local heightPadding = NChatDB.decorativeBorder and 35 or 20
    existing:SetHeight(math.max(54,(existing.nameFS:GetStringHeight() or 12)+(existing.msgFS:GetStringHeight() or 12)+heightPadding))
    NchatContainer:Layout()
    return
  end

  local b=CreateBubble(NchatContainer,text,sender,classFile,isBN,unit,displayName,true)
  table.insert(NchatContainer.bubbles,b)
  NchatContainer.bubbleBySender[sender]=b
  NchatContainer:Layout()
  NchatContainer:Show()
end

--============================
-- Events
--============================
fCore:RegisterEvent("ADDON_LOADED")
fCore:RegisterEvent("CHAT_MSG_WHISPER")
fCore:RegisterEvent("CHAT_MSG_BN_WHISPER")
fCore:RegisterEvent("PLAYER_FLAGS_CHANGED")
fCore:RegisterEvent("PLAYER_ENTERING_WORLD")
fCore:RegisterEvent("GROUP_ROSTER_UPDATE")
fCore:RegisterEvent("PLAYER_TARGET_CHANGED")
fCore:RegisterEvent("NAME_PLATE_UNIT_ADDED")

fCore:SetScript("OnEvent",function(_,event,...)
  if event=="ADDON_LOADED" then
    local name=...
    if name==ADDON_NAME then
      NChatDB=NChatDB or {}
      copyDefaults(NChatDB,DEFAULTS)
      
      -- Migrate old boolean animation setting to new string format
      if type(NChatDB.newMessageAnimation) == "boolean" then
        NChatDB.newMessageAnimation = NChatDB.newMessageAnimation and "slide" or "none"
      end
      
      -- Debug: verify theme is loaded
      if NChatDB.debug then
        print("Nchat: Loaded theme setting = " .. tostring(NChatDB.theme))
      end

      if NChatDB.pos then
        local p=NChatDB.pos
        local rel=_G[p.relativeTo] or UIParent
        NchatContainer:ClearAllPoints()
        NchatContainer:SetPoint(p.point or "TOPLEFT", rel, p.relativePoint or "TOPLEFT", p.x or 0, p.y or 0)
      else
        NchatContainer:ClearAllPoints()
        NchatContainer:SetPoint("TOPLEFT", ChatFrame1, "TOPRIGHT", 14, 0)
      end

      ApplyContainerLock()

      local hasHistory=false
      for sender,info in pairs(NChatDB.history or {}) do
        local b=CreateBubble(NchatContainer,info.text or "",sender,info.classFile,info.isBN,nil,info.displayName,false)
        table.insert(NchatContainer.bubbles,b)
        NchatContainer.bubbleBySender[sender]=b
        hasHistory=true
      end
      NchatContainer:Layout()
      if hasHistory then NchatContainer:Show() end

      -- Apply saved theme after history is loaded to ensure correct styling
      C_Timer.After(0.5, function()
        if NChatDB.theme and NCHAT_THEMES[NChatDB.theme] then
          if NChatDB.debug then
            print("Nchat: Applying theme = " .. tostring(NChatDB.theme))
          end
          RestyleAll()
        end
      end)

      UpdateAFK()
      print("|cff55ccffNchat|r loaded. /nchat options")
    end

  elseif event=="CHAT_MSG_WHISPER" then
    local text, sender, _, _, _, _, _, _, _, _, _, guid = ...
    local _, classFile = GetPlayerInfoByGUID(guid or "")
    local unit = findUnitByName(sender)
    upsertBubble(text, sender, classFile, false, unit)
    TryUpgradePortraits()

	elseif event=="CHAT_MSG_BN_WHISPER" then
  -- Classic Era Battle.net whisper handling
  -- arg1 = message text, arg2 = sender name (consistent per friend)
  local text, sender, languageName, channelName, playerName, specialFlags, zoneChannelID, channelIndex, channelBaseName, unused, lineID, guid = ...
  if NChatDB.debug then
    print("NChat Debug - BNet Whisper Info:")
    for i=1,12 do
      print("arg"..i..":", select(i, ...))
    end
  end

  -- Use sender (arg2) as the display name - it's consistent per Battle.net friend
  local displayName = sender and tostring(sender):gsub("^%s+", ""):gsub("%s+$", "") or "Battle.net"
  
  -- Create stable key directly from sender name (arg2 is always the same for a given friend)
  -- Just normalize it to lowercase and trim spaces
  local key = "BN_" .. displayName:lower():gsub("^%s+", ""):gsub("%s+$", "")

  -- Try to resolve to a unit (may be nil for BN friends)
  local unit = findUnitByName(displayName)

  -- Create or update the correct bubble using the unique key, pass displayName for visible label
  upsertBubble(text, key, nil, true, unit, displayName)

  -- Note: No need to manually set nameFS - CreateBubble/upsertBubble handles it now

  TryUpgradePortraits()

	elseif event=="PLAYER_FLAGS_CHANGED" or event=="PLAYER_ENTERING_WORLD" then
    UpdateAFK()

    elseif event=="GROUP_ROSTER_UPDATE" or event=="PLAYER_TARGET_CHANGED" or event=="NAME_PLATE_UNIT_ADDED" or event=="PLAYER_FLAGS_CHANGED" then
    TryUpgradePortraits()
    for _, b in ipairs(NchatContainer.bubbles) do
      if b.UpdateStatus then b:UpdateStatus() end
    end
end
end)

--============================
-- Slash commands
--============================
SLASH_NCHAT1="/nchat"
SlashCmdList["NCHAT"]=function(msg)
  msg = tostring(msg or ""):lower()
  local cmd,arg = msg:match("^(%S+)%s*(.*)$")
  if cmd=="test" then
    local me = UnitName("player")
    upsertBubble("Normal whisper example.", me, select(2,UnitClass("player")), false, "player")
    upsertBubble("This is a Battle.net whisper.", "Battle.net Friend", nil, true, nil)

  elseif cmd=="options" then
    if NchatOptionsFrame then
      if NchatOptionsFrame:IsShown() then NchatOptionsFrame:Hide() else NchatOptionsFrame:Show() end
    else
      print("|cff55ccffNchat|r options window not available.")
    end

  elseif cmd=="debug" then
    NChatDB.debug = not NChatDB.debug
    print("|cff55ccffNchat|r debug: " .. (NChatDB.debug and "ON" or "OFF"))

  elseif cmd=="afk" then
    NChatDB.afkOnly=not NChatDB.afkOnly
    print("|cff55ccffNchat|r AFK-only mode:", NChatDB.afkOnly and "ON" or "OFF")
    UpdateAFK()

  elseif cmd=="lock" then
    NChatDB.lock=not NChatDB.lock
    ApplyContainerLock()
    print("|cff55ccffNchat|r container lock:", NChatDB.lock and "ON" or "OFF")

  elseif cmd=="theme" and arg and arg~="" then
    if NCHAT_THEMES[arg] then
      NChatDB.theme=arg
      RestyleAll()
      print("|cff55ccffNchat|r theme:", arg)
    else
      local keys={} for k in pairs(NCHAT_THEMES) do table.insert(keys,k) end table.sort(keys)
      print("|cff55ccffNchat|r unknown theme. choose: "..table.concat(keys,", "))
    end

    elseif cmd=="refresh" then
  if Nchat_UpdateFriendStatus then
    Nchat_UpdateFriendStatus()
    print("|cff55ccffNchat:|r friend status cache refreshed.")
  else
    print("|cffff5555Nchat:|r refresh unavailable (function missing).")
  end

  else
    print("|cff55ccffNchat|r commands:")
    print("  /nchat options  - open options window")
    print("  /nchat theme X  - change theme (dark, ios, light, etc.)")
    print("  /nchat afk      - toggle AFK-only mode")
    print("  /nchat lock     - toggle container lock")
    print("  /nchat debug    - toggle debug logging")
    print("  /nchat reset    - reset to defaults")
    print("  /nchat test     - spawn test bubbles")
	print("  /nchat refresh  - refresh friend status now")
  end
end




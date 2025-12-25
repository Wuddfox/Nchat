-- Nchat.lua - Classic Era
-- Whisper bubble UI addon
-- v2.92

local ADDON_NAME = ...
local fCore = CreateFrame("Frame")

--------------------------------------------------------------------------------
-- Configuration
--------------------------------------------------------------------------------

local DEFAULTS = {
  bubbleWidth = 300,
  textSize = 10,
  livePortraits = true,
  useCustomPortraits = false,
  theme = "dark",
  showExtraInfo = true,
  showPlayerRealm = false,
  useUnicodeFont = true,
  whoResolve = true,
  debug = false,
  lock = false,
  afkOnly = false,
  decorativeBorder = false,
  newMessageGlow = true,
  newMessageAnimation = "none",
  showTimestamps = false,
  useDefaultWhisperColor = false,
  unreadBorderHighlight = false,
  enableInlineReply = true,
  pos = { point="TOPLEFT", relativeTo="ChatFrame1", relativePoint="TOPRIGHT", x=14, y=0 },
  history = {},
}

NchatBubbles = {}

--------------------------------------------------------------------------------
-- Themes
--------------------------------------------------------------------------------

do
  local THEMES = {
    dark = {
      bg={0.05,0.05,0.07,0.95}, border={0.20,0.20,0.25,1},
      name={0.80,0.85,0.95,1}, text={0.90,0.92,0.95,1},
      container={bg={0,0,0,0.15}, border={0,0,0,0.25}}
    },
    ios = {
      bg={1,1,1,0.96}, border={0.75,0.75,0.80,0.6},
      name={0.15,0.15,0.17,1}, text={0.05,0.05,0.07,1},
      container={bg={0.9,0.9,0.95,0.2}, border={0.6,0.6,0.7,0.3}}
    },
    light = {
      bg={0.96,0.98,1,0.96}, border={0.55,0.60,0.70,0.7},
      name={0.12,0.15,0.20,1}, text={0.10,0.12,0.15,1},
      container={bg={0.85,0.9,1,0.2}, border={0.55,0.6,0.7,0.4}}
    },
    solarized = {
      bg={0,0.169,0.212,0.95}, border={0.027,0.212,0.259,1},
      name={0.710,0.537,0,1}, text={0.933,0.910,0.835,1},
      container={bg={0,0.169,0.212,0.15}, border={0.027,0.212,0.259,0.25}}
    },
    nord = {
      bg={0.180,0.204,0.251,0.95}, border={0.298,0.337,0.416,1},
      name={0.533,0.753,0.816,1}, text={0.847,0.871,0.914,1},
      container={bg={0.180,0.204,0.251,0.15}, border={0.298,0.337,0.416,0.25}}
    },
    dracula = {
      bg={0.157,0.165,0.212,0.95}, border={0.267,0.278,0.353,1},
      name={0.545,0.576,0.976,1}, text={0.973,0.973,0.949,1},
      container={bg={0.157,0.165,0.212,0.15}, border={0.267,0.278,0.353,0.25}}
    },
    gruvbox = {
      bg={0.235,0.219,0.212,0.95}, border={0.314,0.286,0.271,1},
      name={0.843,0.600,0.129,1}, text={0.922,0.859,0.698,1},
      container={bg={0.235,0.219,0.212,0.15}, border={0.314,0.286,0.271,0.25}}
    },
    monokai = {
      bg={0.180,0.180,0.180,0.95}, border={0.475,0.475,0.475,1},
      name={0.651,0.886,0.180,1}, text={0.839,0.839,0.839,1},
      container={bg={0.180,0.180,0.180,0.15}, border={0.475,0.475,0.475,0.25}}
    },
    tokyonight = {
      bg={0.11,0.16,0.28,0.95}, border={0.25,0.30,0.50,1},
      name={0.50,0.70,1,1}, text={0.85,0.90,1,1},
      container={bg={0.11,0.16,0.28,0.15}, border={0.25,0.30,0.50,0.25}}
    },
    onedark = {
      bg={0.16,0.18,0.22,0.95}, border={0.28,0.31,0.38,1},
      name={0.80,0.50,0.50,1}, text={0.85,0.85,0.85,1},
      container={bg={0.16,0.18,0.22,0.15}, border={0.28,0.31,0.38,0.25}}
    },
    everforest = {
      bg={0.18,0.22,0.20,0.95}, border={0.25,0.30,0.25,1},
      name={0.60,0.75,0.55,1}, text={0.85,0.85,0.80,1},
      container={bg={0.18,0.22,0.20,0.15}, border={0.25,0.30,0.25,0.25}}
    },
    catppuccin = {
      bg={0.22,0.20,0.27,0.95}, border={0.45,0.40,0.55,1},
      name={0.85,0.75,0.95,1}, text={0.95,0.90,0.98,1},
      container={bg={0.22,0.20,0.27,0.15}, border={0.45,0.40,0.55,0.25}}
    },
    ayu = {
      bg={0.16,0.16,0.16,0.95}, border={0.35,0.35,0.35,1},
      name={0.95,0.65,0.25,1}, text={0.90,0.90,0.85,1},
      container={bg={0.16,0.16,0.16,0.15}, border={0.35,0.35,0.35,0.25}}
    },
    material = {
      bg={0.13,0.15,0.17,0.95}, border={0.30,0.35,0.40,1},
      name={0.25,0.65,0.90,1}, text={0.85,0.90,0.95,1},
      container={bg={0.13,0.15,0.17,0.15}, border={0.30,0.35,0.40,0.25}}
    },
    highcontrast = {
      bg={0,0,0,1}, border={0.9,0.9,0.9,1},
      name={1,1,0,1}, text={1,1,1,1},
      container={bg={0,0,0,0.15}, border={0.9,0.9,0.9,0.25}}
    },
    paperwhite = {
      bg={0.97,0.97,0.95,0.96}, border={0.80,0.80,0.75,1},
      name={0.20,0.20,0.25,1}, text={0.05,0.05,0.07,1},
      container={bg={0.97,0.97,0.95,0.2}, border={0.80,0.80,0.75,0.3}}
    },
    rosepine = {
      bg={0.20,0.18,0.22,0.95}, border={0.35,0.30,0.40,1},
      name={0.90,0.60,0.70,1}, text={0.95,0.90,0.92,1},
      container={bg={0.20,0.18,0.22,0.15}, border={0.35,0.30,0.40,0.25}}
    },
    nightowl = {
      bg={0.10,0.14,0.20,0.95}, border={0.20,0.28,0.40,1},
      name={0.45,0.80,1,1}, text={0.85,0.92,1,1},
      container={bg={0.10,0.14,0.20,0.15}, border={0.20,0.28,0.40,0.25}}
    },
  }
  _G.NCHAT_THEMES = THEMES
end

--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------

local function clamp(n, lo, hi)
  if n < lo then return lo
  elseif n > hi then return hi
  else return n end
end

local function copyDefaults(dst, src)
  for k, v in pairs(src) do
    if type(v) == "table" then
      dst[k] = dst[k] or {}
      copyDefaults(dst[k], v)
    elseif dst[k] == nil then
      dst[k] = v
    end
  end
end

local function stripRealm(name)
  if not name then return nil end
  return name:match("^[^-]+") or name
end

local function findUnitByName(name)
  name = stripRealm(name)
  if not name then return nil end
  
  local function matches(unit)
    if not UnitExists(unit) then return false end
    local unitName = UnitName(unit)
    return unitName and stripRealm(unitName) == name
  end
  
  if matches("player") then return "player" end
  if matches("target") then return "target" end
  for i = 1, 4 do
    if matches("party"..i) then return "party"..i end
  end
  for i = 1, 40 do
    if matches("raid"..i) then return "raid"..i end
  end
  return nil
end

--------------------------------------------------------------------------------
-- Player Info Cache
--------------------------------------------------------------------------------

local WhoCache = {}
local WhoCache_TTL = 300

local RACE_DISPLAY_NAMES = {
  ["Scourge"] = "Undead",
  ["Human"] = "Human",
  ["Orc"] = "Orc",
  ["Dwarf"] = "Dwarf",
  ["NightElf"] = "Night Elf",
  ["Tauren"] = "Tauren",
  ["Gnome"] = "Gnome",
  ["Troll"] = "Troll",
  --
  ["BloodElf"] = "Blood Elf",
  ["Draenei"] = "Draenei",
}

local function GetRaceDisplayName(race)
  if not race or race == "" then return "" end
  return RACE_DISPLAY_NAMES[race] or race
end

local function TryGetPlayerInfo(playerName, guid)
  local shortName = stripRealm(playerName)
  
  if WhoCache[shortName] then
    local cached = WhoCache[shortName]
    if (time() - cached.timestamp) < WhoCache_TTL then
      return cached.level, cached.race, cached.class
    end
  end
  
  if guid and guid ~= "" then
    local _, class, _, race = GetPlayerInfoByGUID(guid)
    if class then
      local level = -1
      WhoCache[shortName] = {
        level = level,
        race = race,
        class = class,
        timestamp = time()
      }
      return level, race, class
    end
  end
  
  return nil, nil, nil
end

local function CacheTargetInfo()
  if not (UnitExists("target") and UnitIsPlayer("target")) then return end
  
  local name = UnitName("target")
  if not name then return end
  
  local shortName = stripRealm(name)
  local level = UnitLevel("target") or -1
  local race = UnitRace("target") or ""
  local _, class = UnitClass("target")
  
  WhoCache[shortName] = {
    level = level,
    race = race,
    class = class,
    timestamp = time()
  }
  
  for _, b in ipairs(NchatContainer.bubbles or {}) do
    if not b.__released then
      local bName = b.__displayName or b.__sender
      local bShort = stripRealm(bName)
      if bShort and bShort:lower() == shortName:lower() then
        b.__whoLevel = level
        b.__whoRace = race
        b.__whoClass = class
        if b.UpdateNameText then
          pcall(b.UpdateNameText, b)
        end
      end
    end
  end
end

--------------------------------------------------------------------------------
-- Message Formatting
--------------------------------------------------------------------------------

local function FormatMessage(text)
  local prefix = "-- "
  if NChatDB.showTimestamps then
    local timestamp = date("%H:%M")
    return prefix .. text .. " |cff888888[" .. timestamp .. "]|r"
  end
  return prefix .. text
end

local function FormatMultilineMessage(text)
  if not text or text == "" then return "" end
  local lines = {}
  for line in string.gmatch(text, "[^\n]+") do
    table.insert(lines, FormatMessage(line))
  end
  return table.concat(lines, "\n")
end

local function RunChatFilters(event, msg, sender)
  if not msg then return "" end
  if not ChatFrame_GetMessageEventFilters then return msg end
  
  local filters = ChatFrame_GetMessageEventFilters(event)
  if not filters then return msg end
  
  for _, filter in ipairs(filters) do
    local ok, block, newMsg = pcall(filter, nil, event, msg, sender or "", "", "", "", "", "", "", "", "")
    if ok and type(newMsg) == "string" and newMsg ~= msg then
      msg = newMsg
    end
  end
  
  return msg
end

--------------------------------------------------------------------------------
-- Inline Reply
--------------------------------------------------------------------------------

local InlineReplyBox
local InlineReplyTarget

local function ShowInlineReplyBox(bubble, sender)
  if InlineReplyBox then
    InlineReplyBox:Hide()
    if InlineReplyTarget and InlineReplyTarget.__replyHighlight then
      InlineReplyTarget.__replyHighlight:Hide()
    end
  end
  
  if not InlineReplyBox then
    local eb = CreateFrame("EditBox", "NchatInlineReply", UIParent, "BackdropTemplate")
    eb:SetAutoFocus(false)
    eb:SetHeight(24)
    eb:SetFontObject(ChatFontNormal)
    eb:SetTextInsets(6, 6, 2, 2)
    eb:SetFrameStrata("TOOLTIP")
    eb:SetFrameLevel(1000)
    
    eb:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8x8",
      edgeFile = "Interface\\Buttons\\WHITE8x8",
      edgeSize = 1,
      insets = {left=2, right=2, top=2, bottom=2}
    })
    eb:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
    eb:SetBackdropBorderColor(0.4, 0.6, 0.9, 1)
    
    eb:SetScript("OnEnterPressed", function(self)
      local text = self:GetText()
      if text and text ~= "" then
        SendChatMessage(text, "WHISPER", nil, InlineReplyTarget.__sender)
        self:SetText("")
      end
      self:Hide()
      if InlineReplyTarget and InlineReplyTarget.__replyHighlight then
        InlineReplyTarget.__replyHighlight:Hide()
      end
    end)
    
    eb:SetScript("OnEscapePressed", function(self)
      self:SetText("")
      self:Hide()
      if InlineReplyTarget and InlineReplyTarget.__replyHighlight then
        InlineReplyTarget.__replyHighlight:Hide()
      end
    end)
    
    eb:SetScript("OnTextChanged", function(self)
      local text = self:GetText()
      if not text or text == "" then
        if not self.__clickFrame then
          local cf = CreateFrame("Frame", nil, UIParent)
          cf:SetAllPoints()
          cf:SetFrameStrata("BACKGROUND")
          cf:EnableMouse(true)
          cf:SetScript("OnMouseDown", function()
            if InlineReplyBox and InlineReplyBox:IsShown() then
              local text = InlineReplyBox:GetText()
              if not text or text == "" then
                InlineReplyBox:Hide()
                if InlineReplyTarget and InlineReplyTarget.__replyHighlight then
                  InlineReplyTarget.__replyHighlight:Hide()
                end
              end
            end
            cf:Hide()
          end)
          self.__clickFrame = cf
        end
        self.__clickFrame:Show()
      else
        if self.__clickFrame then
          self.__clickFrame:Hide()
        end
      end
    end)
    
    eb:SetScript("OnHide", function(self)
      self:ClearFocus()
      if self.__clickFrame then
        self.__clickFrame:Hide()
      end
    end)
    
    InlineReplyBox = eb
  end
  
  InlineReplyBox:ClearAllPoints()
  InlineReplyBox:SetPoint("TOPLEFT", bubble, "BOTTOMLEFT", 8, -4)
  InlineReplyBox:SetPoint("TOPRIGHT", bubble, "BOTTOMRIGHT", -8, -4)
  InlineReplyBox:SetWidth(bubble:GetWidth() - 16)
  
  if not bubble.__replyHighlight then
    local hl = bubble:CreateTexture(nil, "OVERLAY")
    hl:SetAllPoints(bubble)
    hl:SetTexture("Interface\\Buttons\\WHITE8x8")
    hl:SetVertexColor(0.4, 0.6, 0.9, 0.15)
    hl:SetBlendMode("ADD")
    bubble.__replyHighlight = hl
  end
  bubble.__replyHighlight:Show()
  
  InlineReplyTarget = bubble
  InlineReplyBox:Show()
  InlineReplyBox:SetFocus()
end

--------------------------------------------------------------------------------
-- Container Frame
--------------------------------------------------------------------------------

local Container = CreateFrame("Frame", "NchatContainer", UIParent, "BackdropTemplate")
_G.NchatContainer = Container
Container:SetSize(320, 400)
Container:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  edgeSize = 1
})
Container:EnableMouse(true)
Container:RegisterForDrag("LeftButton")
Container:SetMovable(true)
Container.bubbles = {}
Container.bubbleBySender = {}

C_Timer.After(0.1, function()
  if Container.backdropInfo then
    Container:SetBackdropColor(0, 0, 0, 0)
    Container:SetBackdropBorderColor(0, 0, 0, 0)
  end
end)

Container:SetScript("OnDragStart", function(self)
  if not NChatDB.lock then self:StartMoving() end
end)

Container:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
  local point, relativeTo, relativePoint, xOfs, yOfs = self:GetPoint()
  NChatDB.pos = {
    point = point,
    relativeTo = relativeTo and relativeTo:GetName() or "UIParent",
    relativePoint = relativePoint,
    x = xOfs,
    y = yOfs
  }
end)

function Container:Layout()
  for i = #self.bubbles, 1, -1 do
    if not self.bubbles[i] or self.bubbles[i].__released then
      table.remove(self.bubbles, i)
    end
  end
  
  local y = -6
  for i = 1, #self.bubbles do
    local b = self.bubbles[i]
    local xOffset = b.__slideOffset or 0
    b:ClearAllPoints()
    b:SetPoint("TOPLEFT", 6 + xOffset, y)
    y = y - (b:GetHeight() + 11)
    b:Show()
  end
end

Container:Hide()

local function ApplyContainerLock()
  local theme = NCHAT_THEMES[NChatDB.theme] or NCHAT_THEMES.dark
  if NChatDB.lock then
    Container:SetMovable(false)
    Container:EnableMouse(false)
    if Container.SetBackdropColor and Container.backdropInfo then
      Container:SetBackdropColor(0, 0, 0, 0)
      Container:SetBackdropBorderColor(0, 0, 0, 0)
    end
  else
    Container:SetMovable(true)
    Container:EnableMouse(true)
    if Container.SetBackdropColor and Container.backdropInfo then
      Container:SetBackdropColor(unpack(theme.container.bg))
      Container:SetBackdropBorderColor(unpack(theme.container.border))
    end
  end
end
_G.ApplyContainerLock = ApplyContainerLock

--------------------------------------------------------------------------------
-- AFK Tracking
--------------------------------------------------------------------------------

local function UpdateAFK()
  local isAFK = UnitIsAFK("player") or false
  if NChatDB.afkOnly then
    if isAFK then
      Container:Show()
    elseif #Container.bubbles == 0 then
      Container:Hide()
    end
  else
    Container:Show()
  end
end

--------------------------------------------------------------------------------
-- Friend Status (placeholder for future use)
--------------------------------------------------------------------------------

local NchatStatusCache = {}

local function UpdateFriendStatus()
  local numFriends = C_FriendList.GetNumFriends()
  if not numFriends or numFriends == 0 then return end
  
  for i = 1, numFriends do
    local info = C_FriendList.GetFriendInfoByIndex(i)
    if info and type(info) == "table" and info.name then
      local name = stripRealm(info.name)
      if info.connected then
        NchatStatusCache[name] = info.afk and "AFK" or "ONLINE"
      else
        NchatStatusCache[name] = "OFFLINE"
      end
    end
  end
end

C_Timer.After(2, UpdateFriendStatus)
C_Timer.NewTicker(10, UpdateFriendStatus)

--------------------------------------------------------------------------------
-- Portrait Upgrade
--------------------------------------------------------------------------------

local function TryUpgradePortraits()
  if not NChatDB.livePortraits then return end
  
  for _, b in ipairs(NchatContainer.bubbles or {}) do
    if b.__awaitingUnit and not b.__released then
      local unit = findUnitByName(b.__awaitingUnit)
      if unit and UnitExists(unit) then
        if b.portrait and b.portrait.SetTexture then
          b.portrait:Hide()
        end
        
        local portrait = CreateFrame("PlayerModel", nil, b)
        portrait:SetSize(32, 32)
        portrait:SetPoint("TOPLEFT", 8, -8)
        portrait:SetUnit(unit)
        portrait:SetCamera(1)
        portrait:SetPortraitZoom(0.8)
        portrait:SetPosition(0, 0, -0.05)
        
        b.portrait = portrait
        b.__awaitingUnit = nil
        b.__unit = unit
        
        if b.UpdateNameText then
          pcall(b.UpdateNameText, b)
        end
      end
    end
  end
end

--------------------------------------------------------------------------------
-- Bubble Creation
--------------------------------------------------------------------------------

local function CreateBubble(parent, text, sender, classFile, isBN, unit, displayName, isNewMessage, isPreformatted)
  local theme = NCHAT_THEMES[NChatDB.theme] or NCHAT_THEMES.dark
  local bubble = CreateFrame("Button", nil, parent, "BackdropTemplate")
  
  bubble:EnableMouse(true)
  bubble:RegisterForClicks("AnyUp")
  
  if NChatDB.decorativeBorder then
    bubble:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8x8",
      edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
      tile = false,
      edgeSize = 32,
      insets = {left=11, right=11, top=11, bottom=10}
    })
  else
    bubble:SetBackdrop({
      bgFile = "Interface\\Buttons\\WHITE8x8",
      edgeFile = "Interface\\Buttons\\WHITE8x8",
      edgeSize = 2,
      insets = {left=1, right=1, top=1, bottom=1}
    })
  end
  
  bubble:SetBackdropColor(unpack(theme.bg))
  bubble:SetBackdropBorderColor(unpack(theme.border))
  bubble:SetFrameStrata("DIALOG")
  
  bubble.__sender = sender
  bubble.__displayName = displayName or sender
  bubble.__isBN = isBN
  bubble.__classFile = classFile
  bubble.__unit = unit
  
  -- Unread border
  if NChatDB.unreadBorderHighlight and isNewMessage then
    bubble.__unread = true
    
    local unreadBorder = bubble:CreateTexture(nil, "OVERLAY")
    unreadBorder:SetTexture("Interface\\Buttons\\WHITE8x8")
    unreadBorder:SetVertexColor(1, 1, 1, 1)
    unreadBorder:SetAllPoints(bubble)
    unreadBorder:SetDrawLayer("OVERLAY", 5)
    
    local mask = bubble:CreateTexture(nil, "OVERLAY")
    mask:SetTexture("Interface\\Buttons\\WHITE8x8")
    mask:SetVertexColor(0, 0, 0, 1)
    mask:SetPoint("TOPLEFT", bubble, "TOPLEFT", 2, -2)
    mask:SetPoint("BOTTOMRIGHT", bubble, "BOTTOMRIGHT", -2, 2)
    mask:SetDrawLayer("OVERLAY", 6)
    
    bubble.__unreadBorder = unreadBorder
    bubble.__unreadMask = mask
  end
  
  -- Name text
  local topPadding = NChatDB.decorativeBorder and -10 or -4
  local nameFS = bubble:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  nameFS:SetPoint("TOPLEFT", 48, topPadding)
  nameFS:SetJustifyH("LEFT")
  
  local function GetClassColor(class)
    if not class then return "ffffff" end
    local colors = _G.RAID_CLASS_COLORS and _G.RAID_CLASS_COLORS[class]
    if colors then
      return string.format("%02x%02x%02x", colors.r * 255, colors.g * 255, colors.b * 255)
    end
    return "ffffff"
  end
  
  local function BuildNameText()
    local base = bubble.__displayName or sender or "Unknown"
    
    -- Strip realm if option is disabled
    if not NChatDB.showPlayerRealm then
      base = stripRealm(base) or base
    end
    
    if not NChatDB.showExtraInfo then
      return base
    end
    
    if bubble.__whoLevel and bubble.__whoLevel ~= 0 then
      local race = GetRaceDisplayName(bubble.__whoRace) or ""
      local lvl = bubble.__whoLevel == -1 and "??" or tostring(bubble.__whoLevel)
      local class = bubble.__whoClass or bubble.__classFile or ""
      
      if class ~= "" then
        local color = GetClassColor(class)
        local localizedClass = (_G.LOCALIZED_CLASS_NAMES_MALE and _G.LOCALIZED_CLASS_NAMES_MALE[class]) or class
        race = race ~= "" and (race .. " |cff" .. color .. localizedClass .. "|r") or ("|cff" .. color .. localizedClass .. "|r")
      end
      
      return string.format("%s %s %s", base, lvl, race)
    end
    
    if bubble.__whoRace and bubble.__whoRace ~= "" then
      local race = GetRaceDisplayName(bubble.__whoRace)
      local class = bubble.__whoClass or bubble.__classFile or ""
      
      if class ~= "" then
        local color = GetClassColor(class)
        local localizedClass = (_G.LOCALIZED_CLASS_NAMES_MALE and _G.LOCALIZED_CLASS_NAMES_MALE[class]) or class
        race = race .. " |cff" .. color .. localizedClass .. "|r"
      end
      
      return string.format("%s %s", base, race)
    end
    
    local shortName = stripRealm(bubble.__displayName or sender)
    local directLevel = UnitLevel(shortName)
    local directRace = directLevel and UnitRace(shortName)
    
    if directLevel and directLevel ~= 0 and directRace then
      local lvl = directLevel == -1 and "??" or tostring(directLevel)
      return string.format("%s %s %s", base, lvl, directRace)
    end
    
    local u = bubble.__unit or findUnitByName(bubble.__displayName or sender)
    if u and UnitExists(u) then
      local lvl = UnitLevel(u)
      local race = UnitRace and (select(1, UnitRace(u)) or "") or ""
      if lvl and type(lvl) == "number" then
        if lvl == -1 then
          return string.format("%s ?? %s", base, race)
        elseif lvl >= 0 then
          return string.format("%s %d %s", base, lvl, race)
        end
      end
    elseif bubble.__classFile then
      local color = GetClassColor(bubble.__classFile)
      local localizedClass = (_G.LOCALIZED_CLASS_NAMES_MALE and _G.LOCALIZED_CLASS_NAMES_MALE[bubble.__classFile]) or bubble.__classFile
      return string.format("%s |cff%s%s|r", base, color, localizedClass)
    end
    
    return base
  end
  
  nameFS:SetText(BuildNameText())
  bubble.UpdateNameText = function(self)
    nameFS:SetText(BuildNameText())
  end
  
  local r, g, b = isBN and 0.4 or 0.5, isBN and 0.6 or 0.65, isBN and 0.9 or 0.85
  nameFS:SetTextColor(r, g, b)
  
  -- Message text
  local bw = clamp(NChatDB.bubbleWidth, 160, 480)
  local msgYOffset = NChatDB.decorativeBorder and -6 or -4
  local msgFS = bubble:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  msgFS:SetPoint("TOPLEFT", nameFS, "BOTTOMLEFT", 0, msgYOffset)
  msgFS:SetJustifyH("LEFT")
  msgFS:SetWidth(bw - 60)
  
  local fontPath = (NChatDB.useUnicodeFont == nil or NChatDB.useUnicodeFont) and "Fonts\\ARIALN.TTF" or nil
  local f, _, s = msgFS:GetFont()
  if fontPath then
    msgFS:SetFont(fontPath, clamp(NChatDB.textSize, 10, 24), s)
    nameFS:SetFont(fontPath, clamp(NChatDB.textSize, 10, 24) + 2, s)
  else
    msgFS:SetFont(f, clamp(NChatDB.textSize, 10, 24), s)
  end
  
  if NChatDB.useDefaultWhisperColor and ChatTypeInfo and ChatTypeInfo["WHISPER"] then
    local whisperColor = ChatTypeInfo["WHISPER"]
    msgFS:SetTextColor(whisperColor.r, whisperColor.g, whisperColor.b)
  else
    msgFS:SetTextColor(unpack(theme.text))
  end
  
  local eventForFilters = isBN and "CHAT_MSG_BN_WHISPER" or "CHAT_MSG_WHISPER"
  local filteredText = RunChatFilters(eventForFilters, text or "", sender)
  msgFS:SetText(isPreformatted and filteredText or FormatMessage(filteredText))
  
  bubble.msgFS = msgFS
  bubble.nameFS = nameFS
  
  -- Portrait
  local portrait
  if NChatDB.livePortraits then
    local used = false
    
    if unit and UnitExists(unit) then
      portrait = CreateFrame("PlayerModel", nil, bubble)
      portrait:SetSize(32, 32)
      portrait:SetPoint("TOPLEFT", 8, -8)
      portrait:SetFrameLevel(bubble:GetFrameLevel() + 10)
      portrait:SetUnit(unit)
      portrait:SetCamera(1)
      portrait:SetPortraitZoom(0.8)
      portrait:SetPosition(0, 0, -0.1)
      used = true
    else
      local guessed = findUnitByName(sender)
      if guessed and UnitExists(guessed) then
        portrait = CreateFrame("PlayerModel", nil, bubble)
        portrait:SetSize(32, 32)
        portrait:SetPoint("TOPLEFT", 8, -8)
        portrait:SetFrameLevel(bubble:GetFrameLevel() + 10)
        portrait:SetUnit(guessed)
        portrait:SetCamera(1)
        portrait:SetPortraitZoom(0.8)
        portrait:SetPosition(0, 0, -0.1)
        used = true
      end
    end
    
    if not used then
      portrait = bubble:CreateTexture(nil, "OVERLAY")
      portrait:SetDrawLayer("OVERLAY", 7)
      portrait:SetSize(32, 32)
      portrait:SetPoint("TOPLEFT", 8, -8)
      
      if isBN then
        portrait:SetTexture("Interface\\FriendsFrame\\UI-Toast-FriendOnlineIcon")
      elseif classFile and CLASS_ICON_TCOORDS[classFile] then
        portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
        portrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFile]))
      else
        portrait:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
      end
      
      bubble.__awaitingUnit = sender
    end
    
    bubble.portrait = portrait
  else
    portrait = bubble:CreateTexture(nil, "OVERLAY")
    portrait:SetDrawLayer("OVERLAY", 7)
    portrait:SetSize(32, 32)
    portrait:SetPoint("TOPLEFT", 8, -8)
    
    if isBN then
      portrait:SetTexture("Interface\\FriendsFrame\\UI-Toast-FriendOnlineIcon")
      bubble.__awaitingUnit = sender
    elseif classFile then
      if NChatDB.useCustomPortraits then
        local classLower = string.lower(classFile)
        portrait:SetTexCoord(0, 1, 0, 1)
        portrait:SetTexture("Interface\\AddOns\\Nchat\\portraits\\" .. classLower)
      elseif CLASS_ICON_TCOORDS[classFile] then
        portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
        portrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[classFile]))
      else
        portrait:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
      end
    else
      portrait:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
    end
    
    bubble.__awaitingUnit = sender
    bubble.portrait = portrait
  end
  
  local heightPadding = NChatDB.decorativeBorder and 35 or 20
  bubble:SetSize(bw, math.max(54, (nameFS:GetStringHeight() or 12) + (msgFS:GetStringHeight() or 12) + heightPadding))
  
  -- Click handlers
  bubble:SetScript("OnClick", function(self, btn)
    if btn == "RightButton" then
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
    elseif btn == "LeftButton" then
      if self.__unread and NChatDB.unreadBorderHighlight then
        self.__unread = false
        if self.__unreadBorder then
          self.__unreadBorder:Hide()
          self.__unreadBorder = nil
        end
        if self.__unreadMask then
          self.__unreadMask:Hide()
          self.__unreadMask = nil
        end
      end
      
      if IsShiftKeyDown() and NChatDB.enableInlineReply then
        ShowInlineReplyBox(bubble, sender)
      elseif IsAltKeyDown() then
        local u = findUnitByName(sender)
        if u and UnitExists(u) then
          InviteUnit(UnitName(u))
        else
          InviteUnit(sender)
        end
      else
        ChatFrame_OpenChat("/w " .. sender .. " ", ChatFrame1)
      end
    end
  end)
  
  -- Animations
  if NChatDB.newMessageGlow and isNewMessage then
    local glow = bubble:CreateTexture(nil, "OVERLAY")
    glow:SetTexture("Interface\\Buttons\\WHITE8x8")
    glow:SetAllPoints(bubble)
    glow:SetVertexColor(0.3, 0.6, 1, 0.5)
    glow:SetBlendMode("ADD")
    bubble.__glow = glow
    bubble.__glowElapsed = 0
  end
  
  local animType = NChatDB.newMessageAnimation or "none"
  if animType == "slide" and isNewMessage then
    bubble.__slideOffset = -80
    bubble.__slideElapsed = 0
  elseif animType == "pop" and isNewMessage then
    bubble.__popScale = 0.3
    bubble.__popElapsed = 0
  end
  
  if (NChatDB.newMessageGlow or (animType ~= "none" and animType)) and isNewMessage then
    bubble:SetScript("OnUpdate", function(self, delta)
      local allDone = true
      
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
        
        parent:Layout()
      end
      
      if self.__popScale and self.__popElapsed ~= nil then
        self.__popElapsed = self.__popElapsed + delta
        local progress = math.min(1, self.__popElapsed / 0.3)
        
        local scale
        if progress < 1 then
          local p = 1 - progress
          scale = 1 - (p * p * p)
          scale = 0.3 + (scale * 0.7)
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
      
      if allDone then
        self:SetScript("OnUpdate", nil)
        if not self.__popElapsed then
          self:SetScale(1.0)
        end
      end
    end)
  end
  
  table.insert(NchatBubbles, bubble)
  return bubble
end

--------------------------------------------------------------------------------
-- Restyle All Bubbles
--------------------------------------------------------------------------------

local function RestyleAll()
  local theme = NCHAT_THEMES[NChatDB.theme] or NCHAT_THEMES.dark
  
  for _, b in ipairs(NchatContainer.bubbles) do
    if b and not b.__released then
      if NChatDB.decorativeBorder then
        b:SetBackdrop({
          bgFile = "Interface\\Buttons\\WHITE8x8",
          edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
          tile = false,
          edgeSize = 32,
          insets = {left=11, right=11, top=11, bottom=10}
        })
      else
        b:SetBackdrop({
          bgFile = "Interface\\Buttons\\WHITE8x8",
          edgeFile = "Interface\\Buttons\\WHITE8x8",
          edgeSize = 2,
          insets = {left=1, right=1, top=1, bottom=1}
        })
      end
      
      b:SetBackdropColor(unpack(theme.bg))
      b:SetBackdropBorderColor(unpack(theme.border))
      
      local nr, ng, nb = b.__isBN and 0.4 or 0.5, b.__isBN and 0.6 or 0.65, b.__isBN and 0.9 or 0.85
      b.nameFS:SetTextColor(nr, ng, nb)
      
      local topPadding = NChatDB.decorativeBorder and -10 or -4
      b.nameFS:ClearAllPoints()
      b.nameFS:SetPoint("TOPLEFT", 48, topPadding)
      
      local fontPath = (NChatDB.useUnicodeFont == nil or NChatDB.useUnicodeFont) and "Fonts\\ARIALN.TTF" or nil
      if fontPath then
        local f, _, s = b.nameFS:GetFont()
        b.nameFS:SetFont(fontPath, clamp(NChatDB.textSize, 10, 24) + 2, s)
      end
      
      if b.msgFS then
        if NChatDB.useDefaultWhisperColor and ChatTypeInfo and ChatTypeInfo["WHISPER"] then
          local whisperColor = ChatTypeInfo["WHISPER"]
          b.msgFS:SetTextColor(whisperColor.r, whisperColor.g, whisperColor.b)
        else
          b.msgFS:SetTextColor(unpack(theme.text))
        end
        
        local bw = clamp(NChatDB.bubbleWidth, 160, 480)
        b.msgFS:SetWidth(bw - 60)
        
        local f, _, s = b.msgFS:GetFont()
        local fontPath = (NChatDB.useUnicodeFont == nil or NChatDB.useUnicodeFont) and "Fonts\\ARIALN.TTF" or nil
        if fontPath then
          b.msgFS:SetFont(fontPath, clamp(NChatDB.textSize, 10, 24), s)
        else
          b.msgFS:SetFont(f, clamp(NChatDB.textSize, 10, 24), s)
        end
        
        b:SetWidth(bw)
        
        local heightPadding = NChatDB.decorativeBorder and 35 or 20
        b:SetHeight(math.max(54, (b.nameFS:GetStringHeight() or 12) + (b.msgFS:GetStringHeight() or 12) + heightPadding))
        
        if b.UpdateNameText then
          pcall(b.UpdateNameText, b)
        end
      end
    end
  end
  
  ApplyContainerLock()
  NchatContainer:Layout()
end
_G.NchatRestyleAll = RestyleAll

--------------------------------------------------------------------------------
-- Bubble Management
--------------------------------------------------------------------------------

local function upsertBubble(text, sender, classFile, isBN, unit, displayName)
  NChatDB.history = NChatDB.history or {}
  if NChatDB.afkOnly and not UnitIsAFK("player") then return end
  if not sender then return end
  
  NChatDB.history[sender] = NChatDB.history[sender] or {
    isBN = isBN,
    classFile = classFile,
    displayName = displayName
  }
  
  local old = NChatDB.history[sender].text or ""
  NChatDB.history[sender].text = (old == "" and text) or (old .. "\n" .. text)
  
  if displayName then
    NChatDB.history[sender].displayName = displayName
  end
  
  local existing = NchatContainer.bubbleBySender[sender]
  if existing and not existing.__released then
    if existing.__whoLevel then
      NChatDB.history[sender].whoLevel = existing.__whoLevel
    end
    if existing.__whoRace then
      NChatDB.history[sender].whoRace = existing.__whoRace
    end
    if existing.__whoClass then
      NChatDB.history[sender].whoClass = existing.__whoClass
    end
    
    local eventForFilters = isBN and "CHAT_MSG_BN_WHISPER" or "CHAT_MSG_WHISPER"
    local newText = RunChatFilters(eventForFilters, text or "", sender)
    existing.msgFS:SetText((existing.msgFS:GetText() or "") .. "\n" .. FormatMessage(newText))
    
    local heightPadding = NChatDB.decorativeBorder and 35 or 20
    existing:SetHeight(math.max(54, (existing.nameFS:GetStringHeight() or 12) + (existing.msgFS:GetStringHeight() or 12) + heightPadding))
    
    NchatContainer:Layout()
    return existing
  end
  
  local b = CreateBubble(NchatContainer, text, sender, classFile, isBN, unit, displayName, true)
  
  if NChatDB.history[sender].whoLevel then
    b.__whoLevel = NChatDB.history[sender].whoLevel
  end
  if NChatDB.history[sender].whoRace then
    b.__whoRace = NChatDB.history[sender].whoRace
  end
  if NChatDB.history[sender].whoClass then
    b.__whoClass = NChatDB.history[sender].whoClass
    if not b.__classFile then
      b.__classFile = NChatDB.history[sender].whoClass
    end
  end
  if NChatDB.history[sender].classFile and not b.__classFile then
    b.__classFile = NChatDB.history[sender].classFile
  end
  
  -- Update portrait if we have class info from history and using custom portraits
  if NChatDB.useCustomPortraits and not NChatDB.livePortraits and b.portrait and b.__classFile then
    local classLower = string.lower(b.__classFile)
    if b.portrait.SetTexCoord and b.portrait.SetTexture then
      b.portrait:SetTexCoord(0, 1, 0, 1)
      b.portrait:SetTexture("Interface\\AddOns\\Nchat\\portraits\\" .. classLower)
    end
  end
  
  table.insert(NchatContainer.bubbles, b)
  NchatContainer.bubbleBySender[sender] = b
  NchatContainer:Layout()
  NchatContainer:Show()
  return b
end

--------------------------------------------------------------------------------
-- Event Handlers
--------------------------------------------------------------------------------

fCore:RegisterEvent("ADDON_LOADED")
fCore:RegisterEvent("CHAT_MSG_WHISPER")
fCore:RegisterEvent("CHAT_MSG_BN_WHISPER")
fCore:RegisterEvent("PLAYER_FLAGS_CHANGED")
fCore:RegisterEvent("PLAYER_ENTERING_WORLD")
fCore:RegisterEvent("GROUP_ROSTER_UPDATE")
fCore:RegisterEvent("PLAYER_TARGET_CHANGED")
fCore:RegisterEvent("NAME_PLATE_UNIT_ADDED")

fCore:SetScript("OnEvent", function(_, event, ...)
  if event == "ADDON_LOADED" then
    local name = ...
    if name ~= ADDON_NAME then return end
    
    NChatDB = NChatDB or {}
    copyDefaults(NChatDB, DEFAULTS)
    
    if type(NChatDB.newMessageAnimation) == "boolean" then
      NChatDB.newMessageAnimation = NChatDB.newMessageAnimation and "slide" or "none"
    end
    
    if NChatDB.pos then
      local p = NChatDB.pos
      local rel = _G[p.relativeTo] or UIParent
      NchatContainer:ClearAllPoints()
      NchatContainer:SetPoint(p.point or "TOPLEFT", rel, p.relativePoint or "TOPLEFT", p.x or 0, p.y or 0)
    else
      NchatContainer:ClearAllPoints()
      NchatContainer:SetPoint("TOPLEFT", ChatFrame1, "TOPRIGHT", 14, 0)
    end
    
    ApplyContainerLock()
    
    local hasHistory = false
    for sender, info in pairs(NChatDB.history or {}) do
      local formattedText = FormatMultilineMessage(info.text or "")
      local b = CreateBubble(NchatContainer, formattedText, sender, info.classFile, info.isBN, nil, info.displayName, false, true)
      
      if info.whoLevel then b.__whoLevel = info.whoLevel end
      if info.whoRace then b.__whoRace = info.whoRace end
      if info.whoClass then b.__whoClass = info.whoClass end
      
      if b.UpdateNameText then
        pcall(b.UpdateNameText, b)
      end
      
      table.insert(NchatContainer.bubbles, b)
      NchatContainer.bubbleBySender[sender] = b
      hasHistory = true
    end
    
    NchatContainer:Layout()
    if hasHistory then NchatContainer:Show() end
    
    C_Timer.After(0.1, function()
      RestyleAll()
      
      if NChatDB.useCustomPortraits and not NChatDB.livePortraits then
        for _, b in ipairs(NchatContainer.bubbles) do
          if b and b.portrait and b.__classFile then
            local classLower = string.lower(b.__classFile)
            b.portrait:SetTexCoord(0, 1, 0, 1)
            b.portrait:SetTexture("Interface\\AddOns\\Nchat\\portraits\\" .. classLower)
          end
        end
      end
    end)
    
    UpdateAFK()
    print("|cff55ccffNchat|r loaded. /nchat options")
  
  elseif event == "PLAYER_TARGET_CHANGED" then
    CacheTargetInfo()
  
  elseif event == "CHAT_MSG_WHISPER" then
    local text, sender, _, _, _, _, _, _, _, _, _, guid = ...
    
    local _, classFile = GetPlayerInfoByGUID(guid or "")
    
    local guidRace
    if guid and guid ~= "" then
      local _, _, _, race = GetPlayerInfoByGUID(guid)
      guidRace = race
    end
    
    local unit = findUnitByName(sender)
    local shortName = stripRealm(sender)
    local level = UnitLevel(shortName)
    local race = level and UnitRace(shortName)
    
    local bubble = upsertBubble(text, sender, classFile, false, unit)
    
    if bubble then
      if guid then bubble.__guid = guid end
      
      if level and level > 0 then
        bubble.__whoLevel = level
        bubble.__whoRace = race or guidRace or ""
        bubble.__whoClass = classFile
        if classFile and not bubble.__classFile then
          bubble.__classFile = classFile
          -- Save to history
          if NChatDB.history[sender] then
            NChatDB.history[sender].classFile = classFile
            NChatDB.history[sender].whoClass = classFile
          end
        end
        -- Save race to history
        if NChatDB.history[sender] and bubble.__whoRace ~= "" then
          NChatDB.history[sender].whoRace = bubble.__whoRace
        end
      elseif guidRace and guidRace ~= "" then
        bubble.__whoRace = guidRace
        bubble.__whoLevel = nil
        -- Save race to history even without level
        if NChatDB.history[sender] then
          NChatDB.history[sender].whoRace = guidRace
        end
      end
      
      if not bubble.__whoLevel or bubble.__whoLevel == 0 then
        local cachedLevel, cachedRace, cachedClass = TryGetPlayerInfo(sender, guid)
        if cachedLevel and cachedLevel > 0 then
          bubble.__whoLevel = cachedLevel
          bubble.__whoRace = cachedRace or guidRace or bubble.__whoRace
          bubble.__whoClass = cachedClass or classFile
          if (cachedClass or classFile) and not bubble.__classFile then
            bubble.__classFile = cachedClass or classFile
            -- Save to history
            if NChatDB.history[sender] then
              NChatDB.history[sender].classFile = bubble.__classFile
              NChatDB.history[sender].whoClass = bubble.__classFile
            end
          end
          -- Save level and race to history
          if NChatDB.history[sender] then
            NChatDB.history[sender].whoLevel = bubble.__whoLevel
            if bubble.__whoRace and bubble.__whoRace ~= "" then
              NChatDB.history[sender].whoRace = bubble.__whoRace
            end
          end
        elseif cachedRace and not bubble.__whoRace then
          bubble.__whoRace = cachedRace
          -- Save race to history
          if NChatDB.history[sender] then
            NChatDB.history[sender].whoRace = cachedRace
          end
        end
      end
      
      if bubble.UpdateNameText then
        pcall(bubble.UpdateNameText, bubble)
      end
      
      -- Update portrait if we now have class info and using custom portraits
      if NChatDB.useCustomPortraits and not NChatDB.livePortraits and bubble.portrait and bubble.__classFile then
        local classLower = string.lower(bubble.__classFile)
        if bubble.portrait.SetTexCoord and bubble.portrait.SetTexture then
          bubble.portrait:SetTexCoord(0, 1, 0, 1)
          bubble.portrait:SetTexture("Interface\\AddOns\\Nchat\\portraits\\" .. classLower)
        end
      end
    end
    
    TryUpgradePortraits()
  
  elseif event == "CHAT_MSG_BN_WHISPER" then
    local text, sender = ...
    local displayName = sender and tostring(sender):gsub("^%s+", ""):gsub("%s+$", "") or "Battle.net"
    local key = "BN_" .. displayName:lower():gsub("^%s+", ""):gsub("%s+$", "")
    local unit = findUnitByName(displayName)
    
    upsertBubble(text, key, nil, true, unit, displayName)
    TryUpgradePortraits()
  
  elseif event == "PLAYER_FLAGS_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
    UpdateAFK()
  
  elseif event == "GROUP_ROSTER_UPDATE" or event == "PLAYER_TARGET_CHANGED" or event == "NAME_PLATE_UNIT_ADDED" or event == "PLAYER_FLAGS_CHANGED" then
    TryUpgradePortraits()
    for _, b in ipairs(NchatContainer.bubbles) do
      if b.UpdateNameText then
        pcall(b.UpdateNameText, b)
      end
    end
  end
end)

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------

SLASH_NCHAT1 = "/nchat"
SlashCmdList["NCHAT"] = function(msg)
  msg = tostring(msg or ""):lower()
  local cmd, arg = msg:match("^(%S+)%s*(.*)$")
  
  if cmd == "test" then
    local me = UnitName("player")
    upsertBubble("Normal whisper example.", me, select(2, UnitClass("player")), false, "player")
    upsertBubble("This is a Battle.net whisper.", "Battle.net Friend", nil, true, nil)
  
  elseif cmd == "options" then
    if NchatOptionsFrame then
      if NchatOptionsFrame:IsShown() then
        NchatOptionsFrame:Hide()
      else
        NchatOptionsFrame:Show()
      end
    else
      print("|cff55ccffNchat|r options window not available.")
    end
  
  elseif cmd == "debug" then
    NChatDB.debug = not NChatDB.debug
    print("|cff55ccffNchat|r debug: " .. (NChatDB.debug and "ON" or "OFF"))
  
  elseif cmd == "afk" then
    NChatDB.afkOnly = not NChatDB.afkOnly
    print("|cff55ccffNchat|r AFK-only mode:", NChatDB.afkOnly and "ON" or "OFF")
    UpdateAFK()
  
  elseif cmd == "lock" then
    NChatDB.lock = not NChatDB.lock
    ApplyContainerLock()
    print("|cff55ccffNchat|r container lock:", NChatDB.lock and "ON" or "OFF")
  
  elseif cmd == "theme" and arg and arg ~= "" then
    if NCHAT_THEMES[arg] then
      NChatDB.theme = arg
      RestyleAll()
      print("|cff55ccffNchat|r theme:", arg)
    else
      local keys = {}
      for k in pairs(NCHAT_THEMES) do
        table.insert(keys, k)
      end
      table.sort(keys)
      print("|cff55ccffNchat|r unknown theme. choose: " .. table.concat(keys, ", "))
    end
  
  elseif cmd == "refresh" then
    if UpdateFriendStatus then
      UpdateFriendStatus()
      print("|cff55ccffNchat:|r friend status cache refreshed.")
    else
      print("|cffff5555Nchat:|r refresh unavailable (function missing).")
    end
  
  elseif cmd == "reset" then
    NChatDB = {}
    copyDefaults(NChatDB, DEFAULTS)
    RestyleAll()
    print("|cff55ccffNchat|r reset to defaults.")
    if NchatOptionsFrame and NchatOptionsFrame.themeDropdown then
      UIDropDownMenu_SetSelectedValue(NchatOptionsFrame.themeDropdown, NChatDB.theme)
      UIDropDownMenu_SetText(NchatOptionsFrame.themeDropdown, NChatDB.theme)
    end
  
  else
    print("|cff55ccffNchat|r commands:")
    print("  /nchat options  - open options")
    print("  /nchat theme X  - change theme")
    print("  /nchat afk      - toggle AFK-only mode")
    print("  /nchat lock     - toggle container lock")
    print("  /nchat debug    - toggle debug")
    print("  /nchat reset    - reset to defaults")
    print("  /nchat test     - spawn test bubbles")
    print("  /nchat refresh  - refresh friend status")
  end
end

-- NchatConfig.lua
-- Options panel

--------------------------------------------------------------------------------
-- Main Panel
--------------------------------------------------------------------------------

local panel = CreateFrame("Frame", "NchatOptionsFrame", UIParent, "BackdropTemplate")
panel:SetSize(480, 500)
panel:SetPoint("CENTER")
panel:SetBackdrop({
  bgFile = "Interface\\Buttons\\WHITE8x8",
  edgeFile = "Interface\\Buttons\\WHITE8x8",
  edgeSize = 1
})
panel:SetBackdropColor(0, 0, 0, 0.7)
panel:SetBackdropBorderColor(0, 0, 0, 0.35)
panel:EnableMouse(true)
panel:SetMovable(true)
panel:RegisterForDrag("LeftButton")
panel:SetScript("OnDragStart", function(self) self:StartMoving() end)
panel:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
panel:Hide()

local title = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
title:SetPoint("TOPLEFT", 12, -12)
title:SetText("Nchat Options")
title:SetScale(0.9)

local close = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", 2, 2)

--------------------------------------------------------------------------------
-- Scrollable Content
--------------------------------------------------------------------------------

local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 8, -40)
scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)

local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetSize(450, 600)
scrollFrame:SetScrollChild(scrollChild)

--------------------------------------------------------------------------------
-- Slider Helper
--------------------------------------------------------------------------------

local function MakeSlider(label, minVal, maxVal, step, setFunc, getFunc)
  local slider = CreateFrame("Slider", nil, scrollChild, "OptionsSliderTemplate")
  slider:SetWidth(260)
  slider:SetMinMaxValues(minVal, maxVal)
  slider:SetValueStep(step)
  slider:SetObeyStepOnDrag(true)
  slider:SetScale(0.9)
  
  local y = scrollChild._nextY or 0
  slider:SetPoint("TOPLEFT", 8, y)
  slider.Text:SetText(label)
  slider.Low:SetText(minVal)
  slider.High:SetText(maxVal)
  
  local valText = slider:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  valText:SetPoint("LEFT", slider, "RIGHT", 8, 0)
  
  slider:SetScript("OnValueChanged", function(self, val)
    setFunc(val)
    valText:SetText(string.format("%d", getFunc()))
  end)
  
  scrollChild._nextY = y - 50
  return slider
end

--------------------------------------------------------------------------------
-- Sliders
--------------------------------------------------------------------------------

MakeSlider("Bubble Width", 160, 480, 10,
  function(v)
    NChatDB.bubbleWidth = v
    local bw = math.max(160, math.min(v, 480))
    for _, b in ipairs(NchatContainer.bubbles or {}) do
      b:SetWidth(bw)
      if b.msgFS then
        b.msgFS:SetWidth(bw - 60)
      end
      local nameH = b.nameFS and b.nameFS:GetStringHeight() or 12
      local msgH = b.msgFS and (b.msgFS:GetStringHeight() or b.msgFS:GetHeight()) or 12
      local heightPadding = NChatDB.decorativeBorder and 35 or 20
      b:SetHeight(math.max(54, nameH + msgH + heightPadding))
    end
    if NchatContainer.Layout then
      NchatContainer:Layout()
    end
  end,
  function() return NChatDB.bubbleWidth or 300 end
)

MakeSlider("Text Size", 10, 24, 1,
  function(v)
    NChatDB.textSize = v
    for _, b in ipairs(NchatContainer.bubbles or {}) do
      if b.msgFS then
        local f, _, st = b.msgFS:GetFont()
        b.msgFS:SetFont(f, v, st)
      end
      local nameH = b.nameFS and b.nameFS:GetStringHeight() or 12
      local msgH = b.msgFS and (b.msgFS:GetStringHeight() or b.msgFS:GetHeight()) or 12
      local heightPadding = NChatDB.decorativeBorder and 35 or 20
      b:SetHeight(math.max(54, nameH + msgH + heightPadding))
    end
    if NchatContainer.Layout then
      NchatContainer:Layout()
    end
  end,
  function() return NChatDB.textSize or 14 end
)

--------------------------------------------------------------------------------
-- Theme Dropdown
--------------------------------------------------------------------------------

local themeLabel = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
themeLabel:SetPoint("TOPLEFT", 8, -110)
themeLabel:SetText("Theme")
themeLabel:SetScale(0.9)

local themeDrop = CreateFrame("Frame", "NchatThemeDropDown", scrollChild, "UIDropDownMenuTemplate")
themeDrop:SetPoint("LEFT", themeLabel, "RIGHT", -10, -5)
themeDrop:SetScale(0.9)
UIDropDownMenu_SetWidth(themeDrop, 140)
UIDropDownMenu_SetText(themeDrop, (NChatDB and NChatDB.theme) or DEFAULTS.theme or "dark")

UIDropDownMenu_Initialize(themeDrop, function(self, level, menuList)
  if not NCHAT_THEMES then return end
  
  local keys = {}
  for k in pairs(NCHAT_THEMES) do
    table.insert(keys, k)
  end
  table.sort(keys)
  
  local cur = (NChatDB and NChatDB.theme) or "dark"
  for _, k in ipairs(keys) do
    local info = UIDropDownMenu_CreateInfo()
    info.text = k
    info.checked = (k == cur)
    info.func = function()
      NChatDB = NChatDB or {}
      NChatDB.theme = k
      UIDropDownMenu_SetText(themeDrop, k)
      
      local t = NCHAT_THEMES[k]
      if t and NchatContainer and NchatContainer.bubbles then
        for _, b in ipairs(NchatContainer.bubbles) do
          if b and not b.__released then
            b:SetBackdropColor(unpack(t.bg))
            b:SetBackdropBorderColor(unpack(t.border))
            
            local nr, ng, nb = b.__isBN and 0.4 or 0.5, b.__isBN and 0.6 or 0.65, b.__isBN and 0.9 or 0.85
            if b.nameFS then
              b.nameFS:SetTextColor(nr, ng, nb)
            end
            
            if b.msgFS then
              if NChatDB.useDefaultWhisperColor and ChatTypeInfo and ChatTypeInfo["WHISPER"] then
                local whisperColor = ChatTypeInfo["WHISPER"]
                b.msgFS:SetTextColor(whisperColor.r, whisperColor.g, whisperColor.b)
              else
                b.msgFS:SetTextColor(unpack(t.text))
              end
            end
          end
        end
        if NchatContainer.Layout then
          NchatContainer:Layout()
        end
      end
    end
    UIDropDownMenu_AddButton(info)
  end
end)

--------------------------------------------------------------------------------
-- Animation Dropdown
--------------------------------------------------------------------------------

local animLabel = scrollChild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
animLabel:SetPoint("TOPLEFT", 8, -145)
animLabel:SetText("Animation:")
animLabel:SetScale(0.9)

local animDrop = CreateFrame("Frame", "NchatAnimationDropDown", scrollChild, "UIDropDownMenuTemplate")
animDrop:SetPoint("LEFT", animLabel, "RIGHT", -15, -3)
animDrop:SetScale(0.9)
UIDropDownMenu_SetWidth(animDrop, 110)
UIDropDownMenu_SetText(animDrop, (NChatDB and NChatDB.newMessageAnimation) or "none")

UIDropDownMenu_Initialize(animDrop, function(self, level, menuList)
  local options = {"none", "slide", "pop"}
  local current = (NChatDB and NChatDB.newMessageAnimation) or "none"
  
  for _, option in ipairs(options) do
    local info = UIDropDownMenu_CreateInfo()
    info.text = option
    info.checked = (option == current)
    info.func = function()
      NChatDB = NChatDB or {}
      NChatDB.newMessageAnimation = option
      UIDropDownMenu_SetText(animDrop, option)
    end
    UIDropDownMenu_AddButton(info)
  end
end)

--------------------------------------------------------------------------------
-- Checkboxes
--------------------------------------------------------------------------------

local checkY = -195

local function MakeCheckbox(x, y, label, getFunc, setFunc, reloadUI)
  local cb = CreateFrame("CheckButton", nil, scrollChild, "ChatConfigCheckButtonTemplate")
  cb:SetPoint("TOPLEFT", x, y)
  cb:SetScale(0.9)
  cb.Text:SetText(label)
  cb:SetScript("OnShow", function(self)
    self:SetChecked(getFunc())
  end)
  cb:SetScript("OnClick", function(self)
    setFunc(self:GetChecked())
    if reloadUI then
      ReloadUI()
    end
  end)
  return cb
end

-- Left column
MakeCheckbox(8, checkY, "Decorative Border",
  function() return NChatDB.decorativeBorder end,
  function(v)
    NChatDB.decorativeBorder = v
    if NchatRestyleAll then NchatRestyleAll() end
  end
)

MakeCheckbox(8, checkY - 35, "New Message Glow",
  function() return NChatDB.newMessageGlow end,
  function(v) NChatDB.newMessageGlow = v end
)

MakeCheckbox(8, checkY - 70, "Enable 3D Portraits (reloads UI)",
  function() return NChatDB.livePortraits end,
  function(v)
    NChatDB.livePortraits = v
    if v then NChatDB.useCustomPortraits = false end
  end,
  true
)

MakeCheckbox(8, checkY - 87, "Use Custom Class Portraits (reloads UI)",
  function() return NChatDB.useCustomPortraits end,
  function(v)
    NChatDB.useCustomPortraits = v
    if v then NChatDB.livePortraits = false end
  end,
  true
)

MakeCheckbox(8, checkY - 122, "Show Level & Race",
  function() return NChatDB.showExtraInfo end,
  function(v)
    NChatDB.showExtraInfo = v
    if NchatRestyleAll then NchatRestyleAll() end
  end
)

MakeCheckbox(180, checkY - 122, "Show Player's Realm",
  function() return NChatDB.showPlayerRealm end,
  function(v)
    NChatDB.showPlayerRealm = v
    if NchatRestyleAll then NchatRestyleAll() end
  end
)

MakeCheckbox(8, checkY - 157, "Use Unicode/Cyrillic Font",
  function() return NChatDB.useUnicodeFont == nil and true or NChatDB.useUnicodeFont end,
  function(v)
    NChatDB.useUnicodeFont = v
    if NchatRestyleAll then NchatRestyleAll() end
  end
)

MakeCheckbox(8, checkY - 192, "Use Default Whisper Color",
  function() return NChatDB.useDefaultWhisperColor end,
  function(v)
    NChatDB.useDefaultWhisperColor = v
    if NchatRestyleAll then NchatRestyleAll() end
  end
)

MakeCheckbox(8, checkY - 227, "White Border on Unread",
  function() return NChatDB.unreadBorderHighlight end,
  function(v) NChatDB.unreadBorderHighlight = v end
)

MakeCheckbox(8, checkY - 262, "Shift-Left Click to Reply on Bubbles",
  function() return NChatDB.enableInlineReply end,
  function(v) NChatDB.enableInlineReply = v end
)

-- Right column
MakeCheckbox(180, checkY, "Lock Container",
  function() return NChatDB.lock end,
  function(v)
    NChatDB.lock = v
    if v then
      NchatContainer:SetMovable(false)
      NchatContainer:EnableMouse(false)
      NchatContainer:SetBackdropColor(0, 0, 0, 0)
      NchatContainer:SetBackdropBorderColor(0, 0, 0, 0)
    else
      NchatContainer:SetMovable(true)
      NchatContainer:EnableMouse(true)
      NchatContainer:SetBackdropColor(0, 0, 0, 0.15)
      NchatContainer:SetBackdropBorderColor(0, 0, 0, 0.25)
    end
  end
)

MakeCheckbox(180, checkY - 35, "Show Timestamps",
  function() return NChatDB.showTimestamps end,
  function(v)
    NChatDB.showTimestamps = v
    if NchatRestyleAll then NchatRestyleAll() end
  end
)

--------------------------------------------------------------------------------
-- Panel Refresh
--------------------------------------------------------------------------------

panel:HookScript("OnShow", function()
  if themeDrop then
    local currentTheme = (NChatDB and NChatDB.theme) or DEFAULTS.theme or "dark"
    UIDropDownMenu_SetText(themeDrop, currentTheme)
  end
  
  if animDrop then
    local animType = (NChatDB and NChatDB.newMessageAnimation) or "none"
    UIDropDownMenu_SetText(animDrop, animType)
  end
end)

--------------------------------------------------------------------------------
-- Reset Button
--------------------------------------------------------------------------------

local resetBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
resetBtn:SetSize(140, 22)
resetBtn:SetPoint("BOTTOM", 150, 16)
resetBtn:SetText("Reset to Defaults")
resetBtn:SetScale(0.9)
resetBtn:SetScript("OnClick", function()
  NChatDB = {}
  if copyDefaults then
    copyDefaults(NChatDB, DEFAULTS)
  end
  
  for _, b in ipairs(NchatContainer.bubbles or {}) do
    b:Hide()
    b.__released = true
  end
  
  wipe(NchatContainer.bubbles or {})
  wipe(NchatContainer.bubbleBySender or {})
  
  if NchatContainer.Layout then
    NchatContainer:Layout()
  end
  if NchatRestyleAll then
    NchatRestyleAll()
  end
  
  print("|cff55ccffNchat|r reset to defaults.")
end)

--------------------------------------------------------------------------------
-- Global Reference
--------------------------------------------------------------------------------

_G.NchatOptionsFrame = panel

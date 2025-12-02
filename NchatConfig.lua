-- NchatConfig.lua - Options 

local panel = CreateFrame("Frame","NchatOptionsFrame",UIParent,"BackdropTemplate")
panel:SetSize(380,450)
panel:SetPoint("CENTER")
panel:SetBackdrop({ bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=1 })
panel:SetBackdropColor(0,0,0,0.7)
panel:SetBackdropBorderColor(0,0,0,0.35)
panel:EnableMouse(true); panel:SetMovable(true); panel:RegisterForDrag("LeftButton")
panel:SetScript("OnDragStart",function(self) self:StartMoving() end)
panel:SetScript("OnDragStop",function(self) self:StopMovingOrSizing() end)
panel:Hide()

local title=panel:CreateFontString(nil,"OVERLAY","GameFontHighlightLarge")
title:SetPoint("TOPLEFT",12,-12)
title:SetText("Nchat Options")

local close=CreateFrame("Button",nil,panel,"UIPanelCloseButton")
close:SetPoint("TOPRIGHT",2,2)

local function MakeSlider(label,minVal,maxVal,step,setFunc,getFunc)
  local s=CreateFrame("Slider",nil,panel,"OptionsSliderTemplate")
  s:SetWidth(260)
  s:SetMinMaxValues(minVal,maxVal)
  s:SetValueStep(step)
  s:SetObeyStepOnDrag(true)
  local y=panel._nextY or -40
  s:SetPoint("TOPLEFT",16,y)
  s.Text:SetText(label)
  s.Low:SetText(minVal)
  s.High:SetText(maxVal)
  local valText=s:CreateFontString(nil,"OVERLAY","GameFontHighlightSmall")
  valText:SetPoint("LEFT",s,"RIGHT",8,0)
  s:SetScript("OnValueChanged",function(self,val)
    setFunc(val)
    valText:SetText(string.format("%d",getFunc()))
  end)
  panel._nextY=y-50; return s
end

-- Bubble Width slider
MakeSlider("Bubble Width",160,480,10,
  function(v)
    NChatDB.bubbleWidth=v
    local bw = math.max(160, math.min(v, 480))
    for _, b in ipairs(NchatContainer.bubbles or {}) do
      -- Keep text width logic consistent with CreateBubble (bw - 60)
      b:SetWidth(bw)
      if b.msgFS then b.msgFS:SetWidth(bw - 60) end
      -- Recalculate heights with decorative border padding
      local nameH = b.nameFS and b.nameFS:GetStringHeight() or 12
      local msgH  = b.msgFS and (b.msgFS:GetStringHeight() or b.msgFS:GetHeight()) or 12
      local heightPadding = (NChatDB.decorativeBorder and 35) or 20
      b:SetHeight(math.max(54, nameH + msgH + heightPadding))
    end
    if NchatContainer.Layout then NchatContainer:Layout() end
  end,
  function() return NChatDB.bubbleWidth or 300 end)

-- Text Size slider
MakeSlider("Text Size",10,24,1,
  function(v)
    NChatDB.textSize=v
    for _, b in ipairs(NchatContainer.bubbles or {}) do
      if b.msgFS then local f,_,st=b.msgFS:GetFont(); b.msgFS:SetFont(f, v, st) end
      local nameH = b.nameFS and b.nameFS:GetStringHeight() or 12
      local msgH  = b.msgFS and (b.msgFS:GetStringHeight() or b.msgFS:GetHeight()) or 12
      local heightPadding = (NChatDB.decorativeBorder and 35) or 20
      b:SetHeight(math.max(54, nameH + msgH + heightPadding))
    end
    if NchatContainer.Layout then NchatContainer:Layout() end
  end,
  function() return NChatDB.textSize or 14 end)

-- Initialize Y position for checkboxes grid (more space from sliders and theme)
local checkY = -280

-- Left column: Decorative Border, New Message Glow, Enable 3D Portraits
local cbBorder = CreateFrame("CheckButton", nil, panel, "ChatConfigCheckButtonTemplate")
cbBorder:SetPoint("TOPLEFT", 16, checkY)
cbBorder.Text:SetText("Decorative Border")
cbBorder:SetScript("OnShow", function(self) self:SetChecked(NChatDB.decorativeBorder) end)
cbBorder:SetScript("OnClick", function(self)
  NChatDB.decorativeBorder = self:GetChecked() and true or false
  if NchatRestyleAll then NchatRestyleAll() end
end)

local cbGlow = CreateFrame("CheckButton", nil, panel, "ChatConfigCheckButtonTemplate")
cbGlow:SetPoint("TOPLEFT", 16, checkY - 35)
cbGlow.Text:SetText("New Message Glow")
cbGlow:SetScript("OnShow", function(self) self:SetChecked(NChatDB.newMessageGlow) end)
cbGlow:SetScript("OnClick", function(self)
  NChatDB.newMessageGlow = self:GetChecked() and true or false
end)

local cb3DPortraits = CreateFrame("CheckButton", nil, panel, "ChatConfigCheckButtonTemplate")
cb3DPortraits:SetPoint("TOPLEFT", 16, checkY - 70)
cb3DPortraits.Text:SetText("Enable 3D Portraits")
cb3DPortraits:SetScript("OnShow", function(self) self:SetChecked(NChatDB.livePortraits) end)
cb3DPortraits:SetScript("OnClick", function(self) NChatDB.livePortraits = self:GetChecked() end)

-- Right column: Lock Container, Show Timestamps, Slide-in Animation
local cbLock = CreateFrame("CheckButton", nil, panel, "ChatConfigCheckButtonTemplate")
cbLock:SetPoint("TOPLEFT", 200, checkY)
cbLock.Text:SetText("Lock Container")
cbLock:SetScript("OnShow", function(self) self:SetChecked(NChatDB.lock) end)
cbLock:SetScript("OnClick", function(self)
  NChatDB.lock = self:GetChecked() and true or false
  if NChatDB.lock then
    NchatContainer:SetMovable(false)
    NchatContainer:EnableMouse(false)
    NchatContainer:SetBackdropColor(0,0,0,0)
    NchatContainer:SetBackdropBorderColor(0,0,0,0)
  else
    NchatContainer:SetMovable(true)
    NchatContainer:EnableMouse(true)
    NchatContainer:SetBackdropColor(0,0,0,0.15)
    NchatContainer:SetBackdropBorderColor(0,0,0,0.25)
  end
end)

local cbTimestamps = CreateFrame("CheckButton", nil, panel, "ChatConfigCheckButtonTemplate")
cbTimestamps:SetPoint("TOPLEFT", 200, checkY - 35)
cbTimestamps.Text:SetText("Show Timestamps")
cbTimestamps:SetScript("OnShow", function(self) self:SetChecked(NChatDB.showTimestamps) end)
cbTimestamps:SetScript("OnClick", function(self)
  NChatDB.showTimestamps = self:GetChecked() and true or false
  if NchatRestyleAll then NchatRestyleAll() end
end)

-- Animation dropdown instead of checkbox
local animLabel = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
animLabel:SetPoint("TOPLEFT", 200, checkY - 68)
animLabel:SetText("Animation:")

local animDrop = CreateFrame("Frame", "NchatAnimationDropDown", panel, "UIDropDownMenuTemplate")
animDrop:SetPoint("LEFT", animLabel, "RIGHT", -15, -3)
UIDropDownMenu_SetWidth(animDrop, 90)
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

--============================
-- Theme dropdown (nil-safe)
--============================
local themeLabel = panel:CreateFontString(nil,"OVERLAY","GameFontNormal")
themeLabel:SetPoint("TOPLEFT", 16, -160)
themeLabel:SetText("Theme")

local themeDrop = CreateFrame("Frame","NchatThemeDropDown",panel,"UIDropDownMenuTemplate")
themeDrop:SetPoint("LEFT", themeLabel, "RIGHT", -10, -5)

UIDropDownMenu_SetWidth(themeDrop, 140)
UIDropDownMenu_SetText(themeDrop, (NChatDB and NChatDB.theme) or DEFAULTS.theme or "dark")

-- Update both dropdowns when panel is shown to reflect current settings
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

UIDropDownMenu_Initialize(themeDrop, function(self, level, menuList)
  if not NCHAT_THEMES then return end
  local keys = {}
  for k in pairs(NCHAT_THEMES) do table.insert(keys, k) end
  table.sort(keys)

  local cur = (NChatDB and NChatDB.theme) or "dark"
  for _,k in ipairs(keys) do
    local info = UIDropDownMenu_CreateInfo()
    info.text = k
    info.checked = (k == cur)
    info.func = function()
      NChatDB = NChatDB or {}
      NChatDB.theme = k
      UIDropDownMenu_SetText(themeDrop, k)

      -- restyle existing bubbles immediately
      local t = NCHAT_THEMES[k]
      if t and NchatContainer and NchatContainer.bubbles then
        for _,b in ipairs(NchatContainer.bubbles) do
          if b and not b.__released then
            b:SetBackdropColor(unpack(t.bg))
            b:SetBackdropBorderColor(unpack(t.border))
            if b.nameFS then b.nameFS:SetTextColor(unpack(t.name)) end
            if b.msgFS  then b.msgFS:SetTextColor(unpack(t.text))  end
          end
        end
        if NchatContainer.Layout then NchatContainer:Layout() end
      end
    end
    UIDropDownMenu_AddButton(info)
  end
end)

-- Reset button
local resetBtn=CreateFrame("Button",nil,panel,"UIPanelButtonTemplate")
resetBtn:SetSize(140,22); resetBtn:SetPoint("BOTTOMLEFT",16,16)
resetBtn:SetText("Reset to Defaults")
resetBtn:SetScript("OnClick",function()
  NChatDB = {}
  if copyDefaults then copyDefaults(NChatDB, DEFAULTS) end
  for _,b in ipairs(NchatContainer.bubbles or {}) do b:Hide(); b.__released=true end
  wipe(NchatContainer.bubbles or {}); wipe(NchatContainer.bubbleBySender or {})
  if NchatContainer.Layout then NchatContainer:Layout() end
  print("|cff55ccffNchat|r reset to defaults.")
  
  --============================
-- Ensure global reference for /nchat options
--============================
if NchatOptionsFrame then
  _G.NchatOptionsFrame = NchatOptionsFrame
elseif NchatOptionsPanel then
  _G.NchatOptionsFrame = NchatOptionsPanel
end
_G.NchatOptionsFrame = panel
end)

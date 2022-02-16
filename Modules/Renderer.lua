local R = {}

R.styleColors = 0
R.styleVars = 0

R.Colors = {
  Gray = { 0.2, 0.2, 0.2, 1 },
  Red = {  0.85, 0.15, 0.15, 1 },
  Redish = {  0.65, 0.15, 0.25, 1 },
  Green = {  0.25, 0.55, 0.25, 1 },
  Blue = {  0.25, 0.25, 0.80, 1 },
  White = {  1, 1, 1, 1 },
  Yellow = { 0.6, 0.55, 0.05, 1 },
}

local function PushStyleColor(...)
  ImGui.PushStyleColor(...)
  R.styleColors = R.styleColors + 1
end
local function PopStyleColor(n)
  if n == nil or n == 0 then
    return
  end

  ImGui.PopStyleColor(n)
  R.styleColors = math.max(0, R.styleColors - n)
end
local function PushStyleVar(...)
  ImGui.PushStyleVar(...)
  R.styleVars = R.styleColors + 1
end
local function PopStyleVar(n)
  if n == nil or n == 0 then
    return
  end
  ImGui.PopStyleVar(n)
  R.styleVars = math.max(0, R.styleColors - n)
end

----- 

local ButtonDisabled = {
  { ImGuiCol.Button, 0.25, 0.35, 0.45, 0.3 },
  { ImGuiCol.ButtonHovered, 0.25, 0.35, 0.45, 0.3 },
  { ImGuiCol.ButtonActive, 0.25, 0.35, 0.45, 0.3 },
}
local ButtonSelected = {
  { ImGuiCol.Button, 0.25, 0.35, 0.45, 0.8 },
  { ImGuiCol.ButtonHovered, 0.25, 0.35, 0.45, 0.8 },
  { ImGuiCol.ButtonActive, 0.25, 0.35, 0.45, 0.8 },
}

local DebouncedOutputs = {}
function DebounceOutput(output, delay)
  local now = os.time()
  if DebouncedOutputs[output] and DebouncedOutputs[output] < now then
    print(output)
    DebouncedOutputs[output] = now + delay
  elseif DebouncedOutputs[output] == nil then
    DebouncedOutputs[output] = now + delay
    print(output)
  end

end

function WrapColVars(cb, colors, vars)
  local styleColors = 0
  local styleVars = 0

  if colors == nil then colors = {} end
  if vars == nil then vars = {} end

  for _, color in pairs(colors) do
    if type(color) =="table" then
      local ok, res = pcall(function()
        PushStyleColor(unpack(color))
        styleColors = styleColors + 1
      end)
      if not ok then
        DebounceOutput(string.format('[AdaptiveGraphicsQuality] %s', res), 7)
      end
    end
  end

  for _, var in pairs(vars) do
    if type(var) =="table" then
      pcall(function()
        PushStyleVar(unpack(var))
        styleVars = styleVars + 1
      end)
    end
  end

  local ok, resA, resB = pcall(cb)

  if not ok then
    DebounceOutput(string.format('[AdaptiveGraphicsQuality] %s', resA), 7)
    R.Text("Component couldn't be rendered. Check console output and report an issue.", { colors = {{ ImGuiCol.Text, unpack(R.Colors.Red) }} })
  end

  PopStyleColor(styleColors)
  PopStyleVar(styleVars)

  return resA, resB
end

----------------
-- PUBLIC API
----------------

local scrollPositions = {}

---@class RWindowParams
---@field isChild boolean
---@field colors table[]
---@field vars table[]
---@field minH integer
---@field maxH integer
---@field minW integer
---@field maxW integer
---@field saveScroll boolean
---@field restoreScroll boolean
RWindowParams = {}
---@param title string
---@param cb function
---@param p RWindowParams
function R.Window(title, cb, p)
  if p == nil then p = {} end
  if p.colors == nil then p.colors = {} end
  if p.vars == nil then p.vars = {} end

  local function render()
    if p.minH and p.maxH and p.minW and p.maxW then
      ImGui.SetNextWindowSizeConstraints(p.minW, p.minH, p.maxW, p.maxH)
    end

    if p.isChild then
      ImGui.BeginChild(title, ImGuiWindowFlags.AlwaysAutoResize)
    else
      ImGui.Begin(title, ImGuiWindowFlags.AlwaysAutoResize)
    end

    -- Save scroll position on onverlay toggle
    if p.saveScroll then
      local curY = ImGui.GetScrollY()
      if ImGui.IsWindowAppearing() and curY ~= scrollPositions[title] and scrollPositions[title] ~= nil then
        ImGui.SetScrollY(scrollPositions[title])
      end
      if curY ~= 0 then
        scrollPositions[title] = curY
      end
    end

    local ok, resA, resB = pcall(cb)

    if not ok then
      DebounceOutput(string.format('[AdaptiveGraphicsQuality] %s', resA), 7)
      -- This thing should NEVER fail --
      ImGui.PushStyleColor(ImGuiCol.Text, 1, 0.35, 0.35, 1)
      ImGui.Text("Something went wrong while rendering a window...")
      ImGui.PopStyleColor()
      ----------------------------------
    end

    if p.isChild then
      ImGui.EndChild()
    else
      ImGui.End()
    end

    return resA, resB
  end

  return WrapColVars(
    render,
    p.colors,
    p.vars
  )
end

-- ALWAYS call at the end of the onDraw callback
function R.Asserts()
  PopStyleColor(R.styleColors)
  PopStyleVar(R.styleVars)
end

---@class RComboParams
---@field colors table[]
---@field vars table[]
RComboParams = {}
---@param label string
---@param previewValue string
---@param cb function
---@param p RComboParams
function R.Combo(label, previewValue, cb, p)
  if p == nil then p = {} end
  if p.colors == nil then p.colors = {} end
  if p.vars == nil then p.vars = {} end

  local function render()
    local shouldDraw = ImGui.BeginCombo(label, previewValue)

    local ok, resA, resB = pcall(cb)

    if not ok then
      DebounceOutput(string.format('[AdaptiveGraphicsQuality] %s', resA), 7)
      -- This thing should NEVER fail --
      ImGui.PushStyleColor(ImGuiCol.Text, 1, 0.35, 0.35, 1)
      ImGui.Text("Something went wrong while rendering a combo...")
      ImGui.PopStyleColor()
      ----------------------------------
    end
    if shouldDraw then
      ImGui.EndCombo()
    end


    return resA, resB
  end

  return WrapColVars(
    render,
    p.colors,
    p.vars
  )
end


---@class RComboItemParams
---@field colors table[]
---@field vars table[]
RComboItemParams = {}
---@param label string
---@param currentItem integer
---@param items table
---@param itemsCount integer
---@param p RComboItemParams
---@return integer, boolean
function R.ComboItem(label, currentItem, items, itemsCount, p)
  if p == nil then p = {} end
  if p.colors == nil then p.colors = {} end
  if p.vars == nil then p.vars = {} end

  local function render()
    local resA, resB = ImGui.Combo(label, currentItem, items, itemsCount)

    return resA, resB
  end

  return WrapColVars(
    render,
    p.colors,
    p.vars
  )
end


---@class RButtonParams
---@field disabled boolean
---@field selected boolean
---@field small boolean
---@field colors table[]
---@field id string
---@field tooltip string
---@field sameLine boolean
RButtonParams = {}
---@param text string
---@param p RButtonParams
---@return boolean
function R.Button(text, p)
  if p == nil then p = {} end

  local function render()
    if p.id then
      ImGui.PushID(p.id)
    end

    local clicked = false
    if p.small then
      clicked =  ImGui.SmallButton(text)
    else
      clicked = ImGui.Button(text)
    end
    if p.id then
      ImGui.PopID()
    end

    if p.sameLine then
      R.SameLine()
    end

    return clicked
  end

  local colors = {}

  if p.disabled then colors = {unpack(ButtonDisabled)} end
  if p.selected then colors = {unpack(ButtonSelected)} end
  if p.colors then
    for _, color in pairs(p.colors) do
      table.insert(colors, color)
    end
  end

  local resA, resB = WrapColVars(render, colors)

  if p.tooltip and ImGui.IsItemHovered() then
    ImGui.BeginTooltip()
    ImGui.SetTooltip(p.tooltip)
    ImGui.EndTooltip()
  end

  return resA, resB
end

function R.SameLine()
  ImGui.SameLine()
end
function R.Space(n)
  if n == nil then n = 1 end
  for i=1,n do 
    R.Text(" ")
    R.SameLine()
  end
end
function R.NewLine(n)
  if n == nil then n = 1 end

  for i=1,n do
    ImGui.TextWrapped("")
  end
end
function R.Separator()
  ImGui.Separator()
end

---@param width integer
---@param cb function
function R.ItemWidth(width, cb)
  ImGui.PushItemWidth(width)
  local ok, res = pcall(cb)
  if not ok then
    DebounceOutput(string.format('[AdaptiveGraphicsQuality] %s', res), 7)
    R.Text("Something went wrong while rendering a tab bar", { colors = {{ ImGuiCol.Text, unpack(R.Colors.Red) }} })
  end
  ImGui.PopItemWidth()
  return res
end


---@class RTextParams
---@field colors table
---@field vars table
---@field notWrapped boolean
RTextParams = {}
---@param text string
---@param p RTextParams
---@return nil
function R.Text(text, p)
  if p == nil then p = {} end

  if p.colors == nil then p.colors = {} end
  if p.vars == nil then p.vars = {} end

  return WrapColVars(
  function()
    if p.notWrapped then
      ImGui.Text(text)
    else
      ImGui.TextWrapped(text)
    end
  end,
  p.colors
  )
end

---@class RCheckBoxParams
---@field colors table
---@field vars table
---@field tooltip string
RCheckBoxParams = {}
---@param text string
---@param p RCheckBoxParams
---@return boolean, boolean
function R.CheckBox(text, state, p)
  if p == nil then p = {} end

  if p.colors == nil then p.colors = {} end
  if p.vars == nil then p.vars = {} end

  return WrapColVars(
  function()
    local value, pressed = ImGui.Checkbox(text, state)
    if p.tooltip and ImGui.IsItemHovered() then
      ImGui.BeginTooltip()
      ImGui.SetTooltip(p.tooltip)
      ImGui.EndTooltip()
    end

    return value, pressed
  end,
  p.colors
  )
end

---@class RInputIntParams
---@field colors table
---@field vars table
---@field id table
---@field step integer
---@field stepFast integer
RInputIntParams = {}
---@param label string
---@param value integer
---@param p RInputIntParams
---@return integer, boolean
function R.InputInt(label, value, p)
  if p == nil then p = {} end

  if p.colors == nil then p.colors = {} end
  if p.vars == nil then p.vars = {} end

  return WrapColVars(
  function()
    local val = 100
    local used = false
    if p.id then
      ImGui.PushID(p.id)
    end
    if p.step and p.stepFast then
      val, used = ImGui.InputInt(label, value, p.step, p.stepFast)
    else
      val, used = ImGui.InputInt(label, value)
    end
    if p.id then
      ImGui.PopID()
    end
    return val, used
  end,
  p.colors
  )
end

---@class RDragFloatParams
---@field colors table
---@field vars table
---@field id table
---@field valueSpeed number
RDragFloatParams = {}
---@param label string
---@param value number
---@param p RDragFloatParams
---@return integer, boolean
function R.DragFloat(label, value, p)
  if p == nil then p = {} end

  if p.colors == nil then p.colors = {} end
  if p.vars == nil then p.vars = {} end

  return WrapColVars(
  function()
    local val = 100
    local used = false
    if p.id then
      ImGui.PushID(p.id)
    end
    if p.valueSpeed then
      val, used = ImGui.DragFloat(label, value, p.valueSpeed)
    else
      val, used = ImGui.DragFloat(label, value)
    end
    if p.id then
      ImGui.PopID()
    end
    return val, used
  end,
  p.colors
  )
end

---@class RInputFloatParams
---@field colors table
---@field vars table
---@field id table
---@field step integer
---@field stepFast integer
RInputFloatParams = {}
---@param label string
---@param value number
---@param p RInputFloatParams
---@return number, boolean
function R.InputFloat(label, value, p)
  if p == nil then p = {} end

  if p.colors == nil then p.colors = {} end
  if p.vars == nil then p.vars = {} end

  return WrapColVars(
  function()
    local val = 100
    local used = false
    if p.id then
      ImGui.PushID(p.id)
    end
    if p.step and p.stepFast then
      val, used = ImGui.InputFloat(label, value, p.step, p.stepFast)
    else
      val, used = ImGui.InputFloat(label, value)
    end
    if p.id then
      ImGui.PopID()
    end
    return val, used
  end,
  p.colors
  )
end

---@class RInputTextParams
---@field colors table
---@field vars table
---@field id table
---@field flag integer
RInputTextParams = {}
---@param label string
---@param value string
---@param p RInputTextParams
---@param bufferSize integer
---@return string, boolean
function R.InputText(label, value, bufferSize, p)
  if p == nil then p = {} end

  if p.colors == nil then p.colors = {} end
  if p.vars == nil then p.vars = {} end

  return WrapColVars(
  function()
    local val = ""
    local selected = false
    if p.id then
      ImGui.PushID(p.id)
    end

    local params = {}
    if p.flag then table.insert(params, p.flag) end

    val, selected = ImGui.InputText(label, value, bufferSize, unpack(params))
    if p.id then
      ImGui.PopID()
    end
    return val, selected
  end,
  p.colors
  )
end

---@class RTabBarParams
---@field colors table[]
RTabBarParams = {}
---@param id string
---@param cb function
---@param p RTabBarParams
---@return nil
function R.TabBar(id, cb, p)
  if p == nil then p = {} end

  if p.colors == nil then p.colors = {} end

  local function render()
    ImGui.BeginTabBar(id)
    local ok, res = pcall(function() return cb() end)
    if not ok then
      DebounceOutput(string.format('[AdaptiveGraphicsQuality] %s', res), 7)
      R.Text("Something went wrong while rendering a tab bar", { colors = {{ ImGuiCol.Text, unpack(R.Colors.Red) }} })
    end

    ImGui.EndTabBar()
  end
  return WrapColVars(render, p.colors)
end

---@class RTabParams
---@field colors table[]
RTabParams = {}
---@param text string
---@param cb function
---@param p RTabBarParams
---@return nil
function R.Tab(text, cb, p)
  if p == nil then p = {} end
  if p.colors == nil then p.colors = {} end

  local function render()
    local result = nil
    if ImGui.BeginTabItem(text) then
      local ok, res = pcall(function() return cb() end)
      if not ok then
        DebounceOutput(string.format('[AdaptiveGraphicsQuality] %s', res), 7)
        R.Text("Something went wrong while rendering a tab", { colors = {{ ImGuiCol.Text, unpack(R.Colors.Red) }} })
      else
        result = res
      end
      ImGui.EndTabItem()
    end

    return result
  end

  return WrapColVars(render, p.colors)
end


return R

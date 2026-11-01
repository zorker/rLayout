local A, L = ...

local addedRoleSets = {}

---------------------------------------------------------------------
-- AddRoleset(frame, name)
---------------------------------------------------------------------

local function AddRoleset(frame, name)
  if not frame then return end
  if frame:IsProtected() and InCombatLockdown() then return end
  frame:AddRoleset(name)
  UIModeUtil.RegisterMode(name.."Scene", {
    rolesetBlocklist = {
      name,
    },
  })
  addedRoleSets[name] = true
end

---------------------------------------------------------------------
-- GetRolesetSceneName(frame)
---------------------------------------------------------------------

local function GetRolesetSceneName(frame)
  if not frame then return end
  local name = L.name..frame:GetName()
  if not addedRoleSets[name] then
    AddRoleset(frame, name)
  end
  return name.."Scene"
end

---------------------------------------------------------------------
-- EvaluateState()
---------------------------------------------------------------------

local function EvaluateState()

    local inCombat        = UnitAffectingCombat("player")
    local inPetBattle     = C_PetBattles and C_PetBattles.IsInBattle()

    local hasVehicleUI    = UnitHasVehicleUI("player")
    local vehicleExists   = UnitExists("vehicle")

    local overrideBar     = C_ActionBar.HasOverrideActionBar()
    local possessBar      = C_ActionBar.IsPossessBarVisible()
    local tempShapeshift  = C_ActionBar.HasTempShapeshiftActionBar()

    local isShiftDown     = IsShiftKeyDown()
    local isCtrlDown      = IsControlKeyDown()
    local isAltDown       = IsAltKeyDown()

    local validTarget     = UnitExists("target") and not UnitIsDead("target")
    local inShapeshift    = GetNumShapeshiftForms() > 0 and GetShapeshiftForm() > 0

    local otherUI         = inPetBattle or hasVehicleUI or overrideBar

    ---------------------------------------------------------------------------
    -- 1. MainActionBar
    -- Macro: [petbattle][vehicleui][overridebar] hide; [combat][mod:shift][@target,exists,nodead][@vehicle,exists][shapeshift][possessbar] show; hide
    ---------------------------------------------------------------------------
    UIModeUtil.SetModeActive(GetRolesetSceneName(MainActionBar), not (not otherUI and (inCombat or isShiftDown or validTarget or vehicleExists or tempShapeshift or possessBar)))

    ---------------------------------------------------------------------------
    -- 2. StanceBar
    -- Macro: [mod:alt] show; hide
    ---------------------------------------------------------------------------
    UIModeUtil.SetModeActive(GetRolesetSceneName(StanceBar), not (isAltDown))

    ---------------------------------------------------------------------------
    -- 3. BagsBar
    -- Macro: [mod:ctrl] show; hide
    ---------------------------------------------------------------------------
    UIModeUtil.SetModeActive(GetRolesetSceneName(BagsBar), not (isCtrlDown))

    ---------------------------------------------------------------------------
    -- 4. MicroMenuContainer
    -- Macro: [mod:ctrl] show; hide
    ---------------------------------------------------------------------------
    UIModeUtil.SetModeActive(GetRolesetSceneName(MicroMenuContainer), not (isCtrlDown))

    ---------------------------------------------------------------------------
    -- 5. MicroButtonAndBagsBar
    -- Macro: [mod:ctrl] show; hide
    ---------------------------------------------------------------------------
    UIModeUtil.SetModeActive(GetRolesetSceneName(MicroButtonAndBagsBar), not (isCtrlDown))

    ---------------------------------------------------------------------------
    -- 6. MainStatusTrackingBarContainer
    -- Macro: [mod:alt] show; hide
    ---------------------------------------------------------------------------
    UIModeUtil.SetModeActive(GetRolesetSceneName(MainStatusTrackingBarContainer), not (isAltDown))

    ---------------------------------------------------------------------------
    -- 7. PetActionBar
    -- Macro: [petbattle][vehicleui][overridebar] hide; [mod:shift] show; hide
    ---------------------------------------------------------------------------
    UIModeUtil.SetModeActive(GetRolesetSceneName(PetActionBar), not (not otherUI and isShiftDown))

    ---------------------------------------------------------------------------
    -- 8. MultiBarBottomLeft
    -- Macro: [petbattle][vehicleui][overridebar] hide; [combat][mod:shift] show; hide
    ---------------------------------------------------------------------------
    UIModeUtil.SetModeActive(GetRolesetSceneName(MultiBarBottomLeft), not (not otherUI and (inCombat or isShiftDown)))

    ---------------------------------------------------------------------------
    -- 9. MultiBarRight
    -- Macro: [petbattle][vehicleui][overridebar] hide; [mod:shift] show; hide
    ---------------------------------------------------------------------------
    UIModeUtil.SetModeActive(GetRolesetSceneName(MultiBarRight), not (not otherUI and isShiftDown))

end

---------------------------------------------------------------------
-- LoadModuleStateDriver()
---------------------------------------------------------------------

local function LoadModuleStateDriver()

  local ef = CreateFrame("Frame")

  ef:RegisterEvent("PLAYER_LOGIN")
  ef:RegisterEvent("PLAYER_ENTERING_WORLD")
  ef:RegisterEvent("PLAYER_REGEN_DISABLED")
  ef:RegisterEvent("PLAYER_REGEN_ENABLED")
  ef:RegisterEvent("PLAYER_TARGET_CHANGED")
  ef:RegisterEvent("UNIT_ENTERED_VEHICLE")
  ef:RegisterEvent("UNIT_EXITED_VEHICLE")
  ef:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
  ef:RegisterEvent("UPDATE_POSSESS_BAR")
  ef:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
  ef:RegisterEvent("PET_BATTLE_OPENING_START")
  ef:RegisterEvent("PET_BATTLE_CLOSE")
  ef:RegisterEvent("MODIFIER_STATE_CHANGED")

  ef:SetScript("OnEvent", function(self, event, ...)
    EvaluateState()
  end)

end

L.F.LoadModuleStateDriver = LoadModuleStateDriver
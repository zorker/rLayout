local A, L = ...

---------------------------------------------------------------------
-- UpdateRoleSet(frame, show)
---------------------------------------------------------------------

local function UpdateRoleSet(frame, show)
  if not frame then return end
  if show then
    frame:AddRoleset("alwaysIncluded")
    frame:RemoveRoleset("alwaysBlocked")
  else
    frame:AddRoleset("alwaysBlocked")
    frame:RemoveRoleset("alwaysIncluded")
  end
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
    UpdateRoleSet(MainActionBar, not otherUI and (inCombat or isShiftDown or validTarget or vehicleExists or tempShapeshift or possessBar))

    ---------------------------------------------------------------------------
    -- 2. StanceBar
    -- Macro: [mod:alt] show; hide
    ---------------------------------------------------------------------------
    UpdateRoleSet(StanceBar, isAltDown)

    ---------------------------------------------------------------------------
    -- 3. BagsBar
    -- Macro: [mod:ctrl] show; hide
    ---------------------------------------------------------------------------
    UpdateRoleSet(BagsBar, isCtrlDown)

    ---------------------------------------------------------------------------
    -- 4. MicroMenuContainer
    -- Macro: [mod:ctrl] show; hide
    ---------------------------------------------------------------------------
    UpdateRoleSet(MicroMenuContainer, isCtrlDown)

    ---------------------------------------------------------------------------
    -- 5. MicroButtonAndBagsBar
    -- Macro: [mod:ctrl] show; hide
    ---------------------------------------------------------------------------
    UpdateRoleSet(MicroButtonAndBagsBar, isCtrlDown)

    ---------------------------------------------------------------------------
    -- 6. MainStatusTrackingBarContainer
    -- Macro: [mod:alt] show; hide
    ---------------------------------------------------------------------------
    UpdateRoleSet(MainStatusTrackingBarContainer, isAltDown)

    ---------------------------------------------------------------------------
    -- 7. PetActionBar
    -- Macro: [petbattle][vehicleui][overridebar] hide; [mod:shift] show; hide
    ---------------------------------------------------------------------------
    UpdateRoleSet(PetActionBar, not otherUI and isShiftDown)

    ---------------------------------------------------------------------------
    -- 8. MultiBarBottomLeft
    -- Macro: [petbattle][vehicleui][overridebar] hide; [combat][mod:shift] show; hide
    ---------------------------------------------------------------------------
    UpdateRoleSet(MultiBarBottomLeft, not otherUI and (inCombat or isShiftDown))

    ---------------------------------------------------------------------------
    -- 9. MultiBarRight
    -- Macro: [petbattle][vehicleui][overridebar] hide; [mod:shift] show; hide
    ---------------------------------------------------------------------------
    UpdateRoleSet(MultiBarRight, not otherUI and isShiftDown)

    --apply filter
    C_Roleset.ApplyRolesetFilters(C_Roleset.GetActiveBlockedRolesets(), C_Roleset.GetActiveAllowedRolesets())

end

---------------------------------------------------------------------
-- LoadModuleStateDriver()
---------------------------------------------------------------------

local function LoadModuleStateDriver()

  local ef = CreateFrame("Frame")

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
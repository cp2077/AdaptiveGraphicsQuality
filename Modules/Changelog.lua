local Changelog = {
  {
    version = "1.2.0",
    changes = {
      ' - Potential stability improvements',
      ' - Simple API for modders:',
      '   * GetMod("AdaptiveGraphicsQuality").api.IsEnabled()',
      '   * GetMod("AdaptiveGraphicsQuality").api.Enable()',
      '   * GetMod("AdaptiveGraphicsQuality").api.Disable()',
      '   * GetMod("AdaptiveGraphicsQuality").api.DisableAndSetToNormal()',
    }
  },
  {
    version = "1.1.1",
    changes = {
      'Fix: Remove forgotten logger',
      'Fix: One of the options (Auto switch on hotkey) not working properly'
    }
  },
  {
    version = "1.1.0",
    changes = {
      'Feature: "Menu" preset is now "Inventory/Character Creation" preset. It will only be active in the inventory and character creation menu. This is mainly useful for DLSS.',
      'Feature: Added "Max FPS" option'
    }
  },
  {
    version = "1.0.4",
    changes = {
      "Patch 1.3 support"
    }
  },
  {
    version = "1.0.3",
    changes = {
      "Fixed hotkeys not working properly",
      "Feature: Highlight currently active preset",
    }
  },
  {
    version = "1.0.2",
    changes = {
      "Fixed a bug that caused the mod to work incorrectly the first time it's loaded."
    }
  },
  {
    version = "1.0.1",
    changes = {
      "Fixed a small issue that could spam the log"
    }
  },
  {
    version = "1.0.0",
    changes = {
      "Release"
    }
  }
}

return Changelog

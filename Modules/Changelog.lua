local Changelog = {
  {
    version = "1.5.0",
    changes = {
      ' - Better detection of combat preset (combat when unholstered is more consistent)',
      ' - Custom presets with shortcuts',
      ' - New option to mark specific settings as inactive',
      ' - Slight UI improvements',
    }
  },
  {
    version = "1.4.0",
    changes = {
      ' - Ray Reconstruction (DLSSD) support',
      ' - New option: Combat Mode when unholstered'
      ' - New Tweak parameters: BounceNumber and RayNumber for Path Tracing',
      ' - Slight stability improvements',
    }
  },
  {
    version = "1.3.4",
    changes = {
      ' - RT Overdrive support',
      ' - DLAA support',
      ' - Slight UI changes',
    }
  },
  {
    version = "1.3.3",
    changes = {
      ' - DLSS 3 support'
    }
  },
  {
    version = "1.3.2",
    changes = {
      ' - Fix for 1.61'
    }
  },
  {
    version = "1.3.1",
    changes = {
      ' - Possible workaround for the issue resulting in crashes for some people',
    }
  },
  {
    version = "1.3.0",
    changes = {
      ' - v1.5 support',
      ' - New option: AMD FSR',
      ' - Proper settings sorting',
      ' - Worked around an issue with DistantShadowsResolution',
    }
  },
  {
    version = "1.2.0",
    changes = {
      ' - Potential stability improvements',
      ' - Basic API for modders:',
      '   * GetMod("AdaptiveGraphicsQuality").api.IsEnabled()',
      '   * GetMod("AdaptiveGraphicsQuality").api.Enable()',
      '   * GetMod("AdaptiveGraphicsQuality").api.Disable()',
      '   * GetMod("AdaptiveGraphicsQuality").api.DisableAndSetToNormal()',
    }
  },
  {
    version = "1.1.1",
    changes = {
      ' - One of the options (Auto switch on hotkey) now works properly',
      ' - Remove logger that spammed the console'
    }
  },
  {
    version = "1.1.0",
    changes = {
      ' - "Menu" preset is now "Inventory/Character Creation" preset. It will only be active in the inventory and character creation menu. This is mainly useful for DLSS.',
      ' - Added "Max FPS" option'
    }
  },
  {
    version = "1.0.4",
    changes = {
      " - Patch 1.3 support"
    }
  },
  {
    version = "1.0.3",
    changes = {
      " - Fixed hotkeys not working properly",
      " - Highlight currently active preset",
    }
  },
  {
    version = "1.0.2",
    changes = {
      " - Fixed a bug that caused the mod to work incorrectly the first time it's loaded."
    }
  },
  {
    version = "1.0.1",
    changes = {
      " - Fixed a small issue that could spam the log"
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

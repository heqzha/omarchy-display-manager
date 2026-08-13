# Changelog

## 1.0.1

- Bound the popup to a responsive 760-pixel viewport instead of scaling its
  design dimensions with the global text-size preference.
- Reworked header, settings, action, and confirmation rows with responsive
  layouts so controls remain balanced and readable at large text sizes.
- Fixed preview completion handling so successful scale and layout changes
  present the confirmation controls instead of silently rolling back.
- Apply monitor changes through Hyprland's current Lua `hl.monitor` API; the
  legacy `keyword monitor` path could report success without changing state.
- Present a display's sole advertised resolution as its disabled native mode,
  while keeping distinct refresh rates selectable.
- Normalize EDID mode labels before calling Hyprland so values such as
  `3440x1440@59.97Hz` apply as native modes instead of silently falling back.
- Removed the illustrative preview while an accurate application screenshot is
  prepared.

## 1.0.0

- Initial release with visual display arrangement, per-display mode, rotation,
  scale, mirroring, safe rollback, identification, and topology profiles.

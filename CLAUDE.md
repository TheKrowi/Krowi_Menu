# CLAUDE.md

Krowi_Menu (`Krowi_Menu_2`) is a World of Warcraft library in Lua 5.1 that Krowi's addons embed to build dropdown and context menus with one API on every client: Blizzard's menu system (`Blizzard_Menu`) on Retail, `UIDropDownMenu` on the Classic clients. The workspace-wide rules (tooling traps, the game loop, taint, LibStub minors, git, release safety) load from `../../CLAUDE.md` and `Krowi_ClaudeKit/WowAddons.md`; this file adds only what is specific to this repo.

There is no build, lint or test step: a consumer addon in the game is the test harness. The `krowi` plugin (enabled in `.claude/settings.json`) syntax-checks every edited `.lua` with Lua 5.1 and guards the known tooling traps. The repo is public, but the settings point at the private kit by absolute path, so the plugin loads only on Krowi's machine; that is intended.

## Clients and loading

- `Krowi_Menu.toc` loads `Krowi_Menu.xml`, which loads `Krowi_Menu.lua`, `Krowi_MenuItem.lua`, `Krowi_MenuUtil.lua` and `Krowi_MenuBuilder.lua` in that order. No saved variables, no declared dependencies.
- `## Interface: 120000, 110207, 50503, 20505, 11508` is behind the live clients (12.1.5, 5.5.4, 2.5.6, 1.15.9). It only matters for a standalone install, the README badges and the upload's game versions; update it at the next release.
- It needs `KROWI_LIBMAN` (Krowi_Util's `LibMan.lua`) and LibStub loaded first. Every consumer includes `Krowi_Util.xml` before `Krowi_Menu.xml` in its `Libs/Files.xml`, and runs `Libs/Libs.lua` after it.
- Client split: `if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE then return end` in `Krowi_Menu.lua:228`, `Krowi_MenuUtil.lua:40` and `Krowi_MenuBuilder.lua:275`. Retail stops there; every other client runs the code below it, which redefines the methods for `UIDropDownMenu`. The Classic clients ship `Blizzard_Menu` and `WowStyle1FilterDropdownTemplate` too (wow-ui-source `classic`, `classic_era`, `classic_anniversary`), so the split is a choice, not a client limit.

## Versioning

Each Lua file registers its own LibStub entry through LibMan, and LibStub keeps the highest minor of each entry separately. Bump the minor of every file you change, in that file:

| File | LibStub entry | Registration | Minor |
|---|---|---|---|
| `Krowi_Menu.lua` | `Krowi_Menu_2` | `KROWI_LIBMAN:NewLibrary('Krowi_Menu_2', 1, {...})`, line 8 | 1 |
| `Krowi_MenuItem.lua` | `Krowi_Menu_2_MenuItem` | `KROWI_LIBMAN:NewSubmodule('MenuItem', 0)`, line 8 | 0 |
| `Krowi_MenuUtil.lua` | `Krowi_Menu_2_MenuUtil` | `KROWI_LIBMAN:NewSubmodule('MenuUtil', 0)`, line 11 | 0 |
| `Krowi_MenuBuilder.lua` | `Krowi_Menu_2_MenuBuilder` | `KROWI_LIBMAN:NewSubmodule('MenuBuilder', 1)`, line 11 | 1 |

- `NewSubmodule` registers `<parent>_<name>` (`Krowi_Util/LibMan.lua:71`) under the current library, which `NewLibrary` sets to the loaded `Krowi_Menu_2` even when this copy did not win (`LibMan.lua:23-25`). So a submodule bump alone carries a submodule change, and a `Krowi_Menu_2` bump does not carry a change to a submodule file. 2.1 bumped both for a MenuBuilder-only change; that is harmless.
- The TOC and XML register nothing. A new file needs its own `NewSubmodule` call.
- Before a release, check every Lua file changed since the last tag (`git diff --stat <tag>`) against the table.
- `## Version:` in the TOC is the release version and must match the top changelog entry; it is unrelated to the minors.
- A breaking API change needs a new major name (`Krowi_Menu_3`), as 2.0 did for `Krowi_Menu-1.0`. Krowi_Util hard-codes `'Krowi_Menu_2'` for `SetMenuBuilder` (`LibMan.lua:107`), so a rename also needs a Krowi_Util release.

## Consumers

A change reaches players only after a release here and, in each consumer, a `Libs/Krowi_Menu` submodule bump and a release. With equal minors the copy loaded first wins, and addons load alphabetically, so Krowi_AchievementFilter's copy is the one in use whenever it is enabled.

| Consumer | Pinned | Uses |
|---|---|---|
| Krowi_AchievementFilter | 2.1 | `addon.MenuBuilder` (`SetMenuBuilder = true` in `Libs/Libs.lua`): the filter button (`SetupMenuForModern`, `Show` on Classic), the achievement and event reminder right-click menus, reward preview, search options and tutorial menus (`ShowPopup`). `Tests/Menu.lua` builds a `MenuItem` on Classic. It hands the builder to plugins (`KrowiAF.UtilApi.MenuBuilder`, `PluginsApi:AddAchievementRightClickMenuItems`), so the MenuBuilder methods are also a contract with third-party plugins. |
| Krowi_ExtendedVendorUI | 2.1 | MenuBuilder on the merchant filter and options buttons (`SetupMenuForModern`, `Show`, `ShowPopup`); the only user of `CreateSubmenuRadio` (filter button). |
| Krowi_Brokers_Currency, Krowi_Brokers_System, Krowi_Brokers_Time | 2.0 | MenuBuilder `ShowPopup` broker menus; `SetElementEnabled` only in Brokers_System, `CreateButton` in Brokers_Currency. |
| Krowi_Brokers (library) | none | Gets a consumer's builder in `Integrations/ElvUI.lua` and `Titan.lua`: `CreateCustomCheckbox`, `CreateDivider`, `CreateSubmenuButton`, `AddChildMenu`, `CreateButton`. |
| Krowi_Vendorer | 2.1 | Loads it and never uses it. |

Nothing outside `Libs/` uses `Krowi_MenuUtil.lua`, whatever its header says.

## Architecture

- `Krowi_Menu.lua` is one shared menu: a file-level `menu` list and one `UIDropDownMenuTemplate` frame named `Krowi_Menu` (line 16, created on every client) behind `Clear`, `Add`, `AddFull`, `AddTitle`, `AddSeparator`, `Open`, `Toggle`, `Close` and `SetSelectedName`. `Convert` turns the PascalCase item fields (`Text`, `Func`, `Checked`, `Children`, ...) into `UIDropDownMenu` info tables when an item is added; `NotCheckable` defaults to true. `lib:UIDropDownMenu_Refresh` and `RefreshAll` are copies of Blizzard's that keep the selection in `selectedName2`; they are methods on `lib`, not overrides of the globals.
- `Krowi_MenuItem.lua` is the item class (`New`, `Add`, `AddFull`, `AddTitle`, `AddSeparator`) that builds the `Children` tree.
- `Krowi_MenuBuilder.lua` is what the consumers use. `New(config)` takes `config.callbacks` (`KeyIsTrue`, `KeyEqualsText`, `OnCheckboxSelect`, `OnRadioSelect`, `OnAllSelect`, `GetCheckBoxStateText`; the first two default to `Krowi_Util_2.ReadNestedKeys`) and `config.translations`. Every method is written twice: the Retail half drives Blizzard menu descriptions, the Classic half fills the one `Krowi_Menu_2` menu with `MenuItem`s, shared by every builder instance (`self.rootMenu = parent`, line 283). `Show`, `Close` and `AddChildMenu` do nothing on Retail and consumers call `SetupMenuForModern` only there. On Classic a submenu from `CreateSubmenuButton` must be attached with `AddChildMenu`; on Retail the button is the submenu.
- The API reference is `_Packaging/Description.md`; `README.md` is generated from it. Where it is wrong: Known debt.

## Taint-sensitive areas

Run the `krowi:taint-reviewer` agent after changing any of these:

- Classic: `UIDropDownMenu_Initialize`, `ToggleDropDownMenu`, `UIDropDownMenu_RefreshAll(UIDROPDOWNMENU_OPEN_MENU)` and `lib:UIDropDownMenu_Refresh` run from addon code on Blizzard's shared `DropDownList1..N` frames and `UIDROPDOWNMENU_*` globals. On Mists Classic, Blizzard's own PvP honor queue dropdowns (`Blizzard_PVPUI/Mists`) use the same frames.
- `hooksecurefunc('ToggleDropDownMenu', ...)` (`Krowi_Menu.lua:232`, not on Retail) runs for every dropdown, Blizzard's and other addons', and re-anchors `DropDownList<level>` with `ClearAllPoints` and `SetPoint` when a submenu leaves the screen. Every copy that upgrades adds another hook, and hooks cannot be removed.
- Retail: `MenuUtil.CreateContextMenu` followed by `SetPoint` on the returned Blizzard menu (`Krowi_MenuBuilder.lua:144`), `SetupMenu` on the consumer's dropdown button, and `SetTag` on each menu.
- The only global the library creates is the frame name `Krowi_Menu`.

## Localization

None. `InitLocalization = true` (`Krowi_Menu.lua:11`) creates `lib.Localization`, but there are no locale files and `lib.L` is never set. MenuBuilder's own strings, `Select All` and `Deselect All`, come from the consumer's `config.translations` with English fallbacks (`Krowi_MenuBuilder.lua:46-50`); the `Version` key there is unused since 2.1.

## Code style

Match the file you are editing:

- Tabs in `Krowi_Menu.lua` (a few lines use 4 spaces); 4 spaces in `Krowi_MenuBuilder.lua`, `Krowi_MenuItem.lua` and `Krowi_MenuUtil.lua`.
- No semicolons. Single quotes in Lua and in XML attributes.
- Each Lua file starts with the copyright block (`--[[`, `    Copyright (c) 2023 Krowi` (2025 in `Krowi_MenuBuilder.lua`), `    Licensed under the terms of the LICENSE file in this repository.`, `]]`), a blank line, `---@diagnostic disable: undefined-global` (plus `duplicate-set-field` where methods are defined twice), a blank line, then the registration and `if not lib then return end`. The TOC and XML carry the same notice as `#` and `<!-- -->` comments.
- Methods on `lib` and `sub` are PascalCase; file-local functions PascalCase (`Convert`, `SetupDefaultCallbacks`); locals camelCase.
- CRLF on disk (LF in git, `core.autocrlf=true`, no `.gitattributes` or `.editorconfig`), no BOM, no final newline.

## Testing in game

Test through a consumer. Do not deploy this repo on its own: `Deploy.ps1` here would add an `AddOns\Krowi_Menu` folder, which is not installed today and loads after Krowi_AchievementFilter, the Brokers and ExtendedVendorUI.

1. Bump the minors first; at equal minors Krowi_AchievementFilter's copy wins and the test proves nothing.
2. In a consumer worktree made with `New-Worktree.ps1`, point the submodule at the change: `git -C Libs\Krowi_Menu fetch "E:\World of Warcraft Addon Development\Krowi_Libraries\Krowi_Menu" <branch>`, then `git -C Libs\Krowi_Menu checkout FETCH_HEAD`. Deploy that worktree and `/reload`. Commit the new pointer only after this library is released.
3. A MenuBuilder change reaches only builders made after the winning copy loaded (Known debt): check it in the consumer that carries the change.

What exercises what:
- Retail MenuBuilder: Krowi_AchievementFilter's filter button and achievement right-click menu; ExtendedVendorUI's filter and options buttons at a merchant; a broker's right-click menu.
- Classic code (`Krowi_Menu.lua`, `MenuItem`, the Classic MenuBuilder): Krowi_AchievementFilter on `_classic_`; ExtendedVendorUI on `_classic_`, `_classic_era_` and `_anniversary_`. A submenu opened near the bottom of the screen runs the `ToggleDropDownMenu` hook.
- `SetElementEnabled`: Krowi_Brokers_System's AddOn options with CPU profiling off. `CreateSubmenuRadio`: ExtendedVendorUI's filter button (Appearances, Custom).

## Git and release

- `main` is the only branch and the release branch: every `Release x.y` commit and its tag `x.y` are on `main` (2.0 at `c21be73`, 2.1 at `be0595a`). Branch from `main` and open PRs against it. `origin/right-click-menu-on-target` (one unmerged 2023 commit on `Krowi_Menu-1.0.lua`, a file that no longer exists) is stale.
- Release only with `krowi:release`, from the main checkout `Krowi_Libraries\Krowi_Menu` (it is in the addon manager's `LIBRARY_NAMES`). Every upload is a full release: `--stability stable`.
- The changelog is for addon authors: entries name the part they touch (`MenuBuilder: ...`, `Menu (Classic): ...`), and 2.1 used `### Removed` for an API removal. `README.md` (the TOC's client badges plus `_Packaging/Description.md`) and `_Packaging/ReleaseNotes.md` are generated at release.

## Known debt (verified 2026-10-17)

- On Classic, `lib:UIDropDownMenu_Refresh` writes a field on Blizzard's `DropDownList<level>` frame (`listFrame.numButtons = listFrame.numButtons or 0`, `Krowi_Menu.lua:158`), against the workspace taint rule. Nothing breaks today because Blizzard's next open rewrites it securely; read it into a local instead (and use that at line 163).
- A MenuBuilder upgrade does not reach builders made before it: every copy makes a fresh class table (`local menuBuilder = {}`, `Krowi_MenuBuilder.lua:14`) that `New` sets as the metatable (line 53), and consumers make builders at file load (Krowi_AchievementFilter `Gui/RightClickMenu/AchievementMenu/AchievementMenu.lua:6`). Nothing shows today because the first-loaded copy is also the newest.
- On Classic, the root menu converts an item the moment it is added (`Krowi_Menu.lua:53-55`) and `AddFull` returns nothing (57-59). So the `Create*` methods return nil for root-level items, `SetElementEnabled` on them does nothing, and a submenu must be complete before it is attached to the root.
- `MenuBuilder:New()` without a config errors: `config.callbacks` is read from the argument, not from the `config or {}` default (`Krowi_MenuBuilder.lua:54-56`).
- `_Packaging/Description.md`, and so `README.md`, names libraries that do not exist: `Krowi_MenuItem_2`, `Krowi_MenuUtil_2` and `Krowi_MenuBuilder_2` (lines 61, 85, 255, 272, 291); the real entries are `Krowi_Menu_2_MenuItem` and so on, and consumers use `KROWI_LIBMAN:GetLibrary('Krowi_Menu_2').MenuBuilder`. It also promises popup dialog links in MenuItem (line 17), which has none. The 2.0 changelog repeats the wrong names.
- `Krowi_MenuUtil.lua` is unused, and its Retail `AddChildMenu` is empty.
- `lib:Toggle` hides `DropDownList1` when any dropdown is open, another addon's too, instead of opening this menu (`Krowi_Menu.lua:105-111`).
- The TOC `## Interface:` is behind the live clients (see Clients and loading).
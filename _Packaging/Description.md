A lightweight menu library for World of Warcraft addon development that simplifies creating dropdown menus with support for titles, separators, nested items, and custom styling.

## Features

### Menu System (`Krowi_Menu-1.0`)
- **Simple API**: Easy-to-use methods for building menus programmatically
- **Flexible Menu Items**: Support for titles, separators, checkable items, and disabled states
- **Nested Menus**: Create hierarchical menu structures with children
- **Custom Styling**: Control menu positioning, frame strata, and frame levels
- **Selection State**: Track and refresh selected menu items
- **LibStub Support**: Standard LibStub library structure for dependency management

### Menu Item Builder (`Krowi_MenuItem-1.0`)
- **Item Creation**: Build menu items with custom properties
- **External Links**: Integration with popup dialogs for displaying external links
- **Child Items**: Support for nested menu structures
- **Flexible Options**: Checkable, disabled, and title items

### Menu Utilities (`Krowi_MenuUtil-1.0`)
- **Cross-Version Compatibility**: Unified API for both modern (Mainline) and Classic WoW versions
- **Automatic Detection**: Detects game version and uses appropriate menu system
- **Simplified Interface**: Consistent methods across all WoW versions

### Menu Builder (`Krowi_MenuBuilder-1.0`)
- **High-Level Abstraction**: Simplified API for building complex menus with checkboxes, radio buttons, and filters
- **Callback-Based Architecture**: Flexible callback system for handling menu interactions
- **Smart Defaults**: Automatic integration with Krowi_Util for common operations
- **Callback Helper**: `BindCallbacks` utility eliminates boilerplate when binding object methods
- **Build Version Filters**: Built-in support for creating version filter menus
- **Cross-Version Support**: Works seamlessly on both Modern and Classic WoW
- **Instance-Based**: Create multiple independent menu builders with isolated state

## Usage Examples

### Basic Menu Setup

```lua
local menu = LibStub("Krowi_Menu-1.0");
local pages = {}; -- Table with data

menu:Clear(); -- Reset menu

menu:AddFull({Text = "View Pages", IsTitle = true});
for i, _ in next, pages do
  menu:AddFull({
    Text = (pages[i].IsViewed and "" or "|T132049:0|t") .. pages[i].SubTitle,
    Func = function()
      -- Some function here
    end
  });
end

menu:Open();
```

### Advanced Example with Nested Menus

```lua
local menu = LibStub("Krowi_Menu-1.0");
local menuItem = LibStub("Krowi_MenuItem-1.0");

menu:Clear();

-- Create a parent item with children
local parent = menuItem:New({Text = "Settings"});
parent:AddFull({
  Text = "Enable Feature",
  Checked = true,
  Func = function() print("Feature toggled") end
});
parent:AddSeparator();
parent:AddFull({
  Text = "Reset to Defaults",
  Func = function() print("Reset") end
});

menu:Add(parent);
menu:Open("cursor");
```

### MenuBuilder Example

```lua
local MenuBuilder = LibStub("Krowi_MenuBuilder-1.0");

-- Configure MenuBuilder with callbacks
local config = {
    callbacks = MenuBuilder.BindCallbacks(self, {
        GetCheckBoxStateText = "GetCheckBoxStateText",
        OnCheckboxSelect = "OnCheckboxSelect",
        OnRadioSelect = "OnRadioSelect"
    }),
    translations = {
        ["Select All"] = "Select All",
        ["Deselect All"] = "Deselect All"
    }
};

local builder = MenuBuilder:New(config);

-- Build menu with checkboxes and radio buttons
local menu = builder:GetMenu();
builder:CreateTitle(menu, "Filter Options");
builder:CreateCheckbox(menu, "Show Completed", filters, {"Completed"}, true);
builder:CreateCheckbox(menu, "Show In Progress", filters, {"InProgress"}, true);
builder:CreateDivider(menu);

local sortMenu = builder:CreateSubmenuButton(menu, "Sort By");
builder:CreateRadio(sortMenu, "Name", filters, {"SortBy", "Criteria"}, true);
builder:CreateRadio(sortMenu, "Date", filters, {"SortBy", "Criteria"}, true);
builder:AddChildMenu(menu, sortMenu);

-- Show the menu
builder:Show(frameAnchor, 0, 0);
```

## API Reference

### Krowi_Menu-1.0

#### Creating a Menu
```lua
local menu = LibStub("Krowi_Menu-1.0")
```

#### Menu Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `Clear()` | - | Resets the menu, removing all items |
| `Add(item)` | `item` (MenuItem) | Adds a converted menu item to the menu |
| `AddFull(info)` | `info` (table) | Creates and adds a menu item from info table |
| `AddTitle(text)` | `text` (string) | Adds a title item to the menu |
| `AddSeparator()` | - | Adds a separator line to the menu |
| `Open(anchor, offsetX, offsetY, point, relativePoint, frameStrata, frameLevel)` | See below | Opens and displays the menu |
| `Toggle(...)` | Same as Open | Toggles menu visibility (opens if closed, closes if open) |
| `Close()` | - | Closes the menu if it's currently open |
| `SetSelectedName(name)` | `name` (string) | Sets the selected menu item by name and refreshes display |
| `GetSelectedName(frame)` | `frame` (frame) | Returns the currently selected item name |

#### Open() Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `anchor` | string/frame | "cursor" | Anchor point for menu positioning |
| `offsetX` | number | 0 | Horizontal offset |
| `offsetY` | number | 0 | Vertical offset |
| `point` | string | nil | Point on menu frame |
| `relativePoint` | string | nil | Point on anchor frame |
| `frameStrata` | string | "FULLSCREEN_DIALOG" | Frame strata level |
| `frameLevel` | number | nil | Frame level (auto-raised if strata set without level) |

#### Menu Item Info Table

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `Text` | string | "INFO TEXT" | Display text for the menu item |
| `Checked` | boolean | nil | Whether the item is checked |
| `Func` | function | nil | Function to call when item is clicked |
| `IsTitle` | boolean | nil | Whether this item is a title (non-clickable) |
| `Disabled` | boolean | nil | Whether the item is disabled |
| `IsNotRadio` | boolean | nil | Use checkbox instead of radio button |
| `NotCheckable` | boolean | true | Whether the item can be checked/unchecked |
| `KeepShownOnClick` | boolean | nil | Keep menu open after clicking this item |
| `IgnoreAsMenuSelection` | boolean | nil | Don't update selection state when checked |
| `Children` | table | nil | Array of child menu items for nested menus |
| `IsSeparator` | boolean | nil | Whether this item is a separator line |

### Krowi_MenuItem-1.0

#### Creating Menu Items
```lua
local menuItem = LibStub("Krowi_MenuItem-1.0")
```

#### MenuItem Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `New(info, hideOnClick)` | `info` (table/string), `hideOnClick` (boolean) | MenuItem | Creates a new menu item. If info is string, uses it as Text |
| `Add(item)` | `item` (MenuItem) | MenuItem | Adds a child item to this menu item |
| `AddFull(info)` | `info` (table) | MenuItem | Creates and adds a child from info table |
| `AddTitle(text)` | `text` (string) | - | Adds a title child to this menu item |
| `AddSeparator()` | - | MenuItem | Adds a separator child to this menu item |

### Krowi_MenuUtil-1.0

#### Creating Utilities Instance
```lua
local menuUtil = LibStub("Krowi_MenuUtil-1.0")
```

#### MenuUtil Functions

| Function | Parameters | Description |
|----------|------------|-------------|
| `CreateTitle(menu, text)` | `menu` (menu), `text` (string) | Creates a title in the menu (adapts to game version) |
| `CreateButton(menu, text, func, isEnabled)` | `menu` (menu), `text` (string), `func` (function), `isEnabled` (boolean) | Creates a menu button (adapts to game version) |
| `CreateDivider(menu)` | `menu` (menu) | Creates a divider/separator (adapts to game version) |
| `AddChildMenu(menu, child)` | `menu` (menu), `child` (MenuItem) | Adds a child to the menu (Classic only) |
| `CreateButtonAndAdd(menu, text, func, isEnabled)` | `menu` (menu), `text` (string), `func` (function), `isEnabled` (boolean) | Creates and adds a button in one call |

**Note:** MenuUtil automatically detects whether the game is running Mainline or Classic and uses the appropriate menu system. On Mainline, it uses the modern menu API. On Classic versions, it uses the `Krowi_MenuItem-1.0` library.

### Krowi_MenuBuilder-1.0

#### Creating a MenuBuilder Instance
```lua
local MenuBuilder = LibStub("Krowi_MenuBuilder-1.0")
local builder = MenuBuilder:New(config)
```

#### Configuration Object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `callbacks` | table | Yes | Table of callback functions (see Callback Reference) |
| `translations` | table | No | Table of localized strings (defaults to English) |
| `uniqueTag` | string | No | Unique identifier for this instance (auto-generated if not provided) |

#### Callback Reference

**Checkbox Callbacks:**
- `GetCheckBoxStateText(text, filters, keys)` - Returns modified text with state indicators
- `KeyIsTrue(filters, keys)` - Returns whether a filter key is true (defaults to `Krowi_Util.ReadNestedKeys`)
- `OnCheckboxSelect(filters, keys, ...)` - Called when checkbox is clicked

**Radio Callbacks:**
- `KeyEqualsText(text, filters, keys)` - Returns whether key equals text (defaults to `Krowi_Util.ReadNestedKeys`)
- `OnRadioSelect(text, filters, keys, ...)` - Called when radio button is selected

**Build Version Filter Callbacks:**
- `IsMinorVersionChecked(filters, minor)` - Returns whether all patches in minor version are checked
- `OnMinorVersionSelect(filters, minor)` - Called when minor version is clicked
- `IsMajorVersionChecked(filters, major)` - Returns whether all versions in major are checked
- `OnMajorVersionSelect(filters, major)` - Called when major version is clicked
- `OnAllVersionsSelect(filters, value)` - Called when Select/Deselect All is clicked
- `CreateBuildVersionFilterGroups(version, filters)` - Builds the version filter menu structure

**Other Callbacks:**
- `SetRewardsFilters(filters, value)` - Called for reward filter Select/Deselect All
- `SetFactionFilters(filters, value)` - Called for faction filter Select/Deselect All

#### MenuBuilder Utility Functions

| Function | Parameters | Returns | Description |
|----------|------------|---------|-------------|
| `BindCallbacks(obj, methodNames)` | `obj` (table), `methodNames` (table) | table | Creates callback table by binding object methods. `methodNames` maps callback names to method names |

#### MenuBuilder Methods

**Menu Management:**
| Function | Parameters | Description |
|----------|------------|-------------|
| `GetMenu()` | - | Returns the current menu object |
| `Show(anchor, offsetX, offsetY)` | `anchor` (frame), `offsetX` (number), `offsetY` (number) | Shows menu attached to anchor frame (Modern only) |
| `ShowPopup(createFunc, anchor)` | `createFunc` (function), `anchor` (frame) | Shows popup menu, calling createFunc(builder) to build it (Classic only) |
| `SetupMenuForModern(filterFrame)` | `filterFrame` (frame) | Sets up Modern WoW dropdown menu on filter frame |

**Menu Building (Standardized Parameter Order: `menu, text, filters, keys, ...`):**
| Function | Parameters | Description |
|----------|------------|-------------|
| `CreateTitle(menu, text)` | `menu`, `text` (string) | Creates a title (non-clickable header) |
| `CreateDivider(menu)` | `menu` | Creates a separator line |
| `CreateButton(menu, text, func)` | `menu`, `text` (string), `func` (function) | Creates a simple button |
| `CreateCheckbox(menu, text, filters, keys, checkTabs)` | `menu`, `text` (string), `filters` (table), `keys` (table), `checkTabs` (boolean) | Creates a checkbox item. `keys` is array path to filter value |
| `CreateRadio(menu, text, filters, keys, checkTabs)` | `menu`, `text` (string), `filters` (table), `keys` (table), `checkTabs` (boolean) | Creates a radio button item |
| `CreateSubmenuButton(menu, text, func, isEnabled)` | `menu`, `text` (string), `func` (function), `isEnabled` (boolean) | Creates a button that opens a submenu |
| `AddChildMenu(menu, child)` | `menu`, `child` (menu/MenuItem) | Adds child menu to parent |
| `CreateButtonAndAdd(menu, text, func, isEnabled)` | `menu`, `text` (string), `func` (function), `isEnabled` (boolean) | Creates and adds button in one call |

**Specialized Menu Builders:**
| Function | Parameters | Description |
|----------|------------|-------------|
| `CreateBuildVersionFilter(filters, menu)` | `filters` (table), `menu` | Creates build/patch version filter submenu |
| `CreateSelectDeselectAllVersions(version, filters)` | `version` (menu), `filters` (table) | Adds Select/Deselect All buttons for versions |
| `CreateSelectDeselectAllRewards(menu, text, filters, value)` | `menu`, `text` (string), `filters` (table), `value` (boolean) | Creates reward filter toggle button |
| `CreateSelectDeselectAllFactions(menu, text, filters, value)` | `menu`, `text` (string), `filters` (table), `value` (boolean) | Creates faction filter toggle button |
| `CreateMinorVersionGroup(majorGroup, filters, major, minor)` | `majorGroup` (menu), `filters` (table), `major` (table), `minor` (table) | Creates minor version submenu group |
| `CreateMajorVersionGroup(version, filters, major)` | `version` (menu), `filters` (table), `major` (table) | Creates major version submenu group |

## Use Cases
- Right-click context menus
- Dropdown selection menus
- Settings and options menus
- Action selection menus
- Navigation menus
- Custom frame menus
- Any scenario requiring dropdown menu functionality

## Requirements
- LibStub
- Krowi_Util-1.0 (optional, for default MenuBuilder callbacks)
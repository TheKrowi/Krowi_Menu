A lightweight menu library for World of Warcraft addon development that simplifies creating dropdown menus with support for titles, separators, nested items, and custom styling.

## Features

- **Simple API**: Easy-to-use methods for building menus programmatically
- **Flexible Menu Items**: Support for titles, separators, checkable items, and disabled states
- **Nested Menus**: Create hierarchical menu structures with children
- **Custom Styling**: Control menu positioning, frame strata, and frame levels
- **Selection State**: Track and refresh selected menu items
- **Utility Functions**: Helper functions for both modern (Mainline) and Classic WoW versions

## Components

### `Krowi_Menu-1.0.lua`
The main menu library providing dropdown menu functionality with Blizzard's UIDropDownMenu system.

**Main Methods:**
- `Clear()` - Reset the menu
- `Add(item)` - Add a converted menu item
- `AddFull(info)` - Add a menu item from info table
- `AddTitle(text)` - Add a title to the menu
- `AddSeparator()` - Add a separator line
- `Open(anchor, offsetX, offsetY, point, relativePoint, frameStrata, frameLevel)` - Display the menu
- `Toggle(...)` - Toggle menu visibility
- `Close()` - Close the menu
- `SetSelectedName(name)` - Set the selected item by name
- `GetSelectedName(frame)` - Get the currently selected item name

### `Krowi_MenuItem-1.0.lua`
Menu item builder with support for nested structures and external links.

**Main Methods:**
- `New(info, hideOnClick)` - Create a new menu item
- `NewExtLink(text, externalLink)` - Create an external link menu item
- `Add(item)` - Add a child item
- `AddFull(info)` - Add a child from info table
- `AddTitle(text)` - Add a title child
- `AddSeparator()` - Add a separator child
- `AddExtLinkFull(text, externalLink)` - Add an external link child

### `Krowi_MenuUtil-1.0.lua`
Compatibility layer providing unified menu API for both modern (Mainline) and Classic WoW versions.

**Main Methods:**
- `CreateTitle(menu, text)` - Create a title (modern) or add title (classic)
- `CreateButton(menu, text, func, isEnabled)` - Create a menu button
- `CreateDivider(menu)` - Create a divider/separator
- `AddChildMenu(menu, child)` - Add a child to the menu (classic only)
- `CreateButtonAndAdd(menu, text, func, isEnabled)` - Create and add a button in one call

## Usage Example

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

## Requirements
- LibStub
- Krowi_PopopDialog-1.0 (for external links in `Krowi_MenuItem`)
- Krowi_Util-1.0 (for version detection in `Krowi_MenuUtil`)
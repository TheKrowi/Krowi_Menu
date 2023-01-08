## Support me
<a href="https://www.paypal.com/donate/?hosted_button_id=NYWTBA4XM6ZS6" alt="Paypal">
  <img src="https://www.paypalobjects.com/en_US/BE/i/btn/btn_donateCC_LG.gif" />
</a>
<a href="https://www.patreon.com/Krowi" alt="Patreon">
  <img src="https://raw.githubusercontent.com/codebard/patron-button-and-widgets-by-codebard/master/images/become_a_patron_button.png" />
</a>
<a href='https://ko-fi.com/E1E6G64LS' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi2.png?v=3' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

## Purpose
This library was created to make drop down menus easier to implement. This library was initially created for personal use so documentation is lacking.

## Example
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
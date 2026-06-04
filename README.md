# BasinHD
Lua library for Tom's Peripherals; ComputerCraft: Tweaked
***
* Graphics library made to be similar to Basalt, but for Tom's Peripherals HD monitors
* similar functionality, more lightweight
* full LuaLS support
<br/>
___
**Code Example**
```lua
local gpu = peripheral.find('tm_gpu')
local basinhd = require('basinhd')

local mainFrame = basinhd:getMainFrame(gpu)

local button = mainFrame:addButton()
    :setSize(140, 75)
    :setPosition(30, 20)
    :setBackground('#3fc7cc') -- or in hexadecimal 0xRRGGBB
    :setText('I am a button')
    :onClick(function()
        print("I was clicked")
    end)

basinhd:run()
```

KittyClient
=============================

This is an iOS client for [PyKitty](https://github.com/SimonJakubowski/pyKitty) written by Simon Jakubowski. It can be used to scan EAN or QR codes associated with certain drinks and to pay those drinks.

##Installation
###Manual
1. Check out project.

2. Open `KittyClient.xcodeproj` with a current Xcode version.

3. Build the project and install it on your iPhone (developer certificate required) or test it in iPhone Simulator.

##Usage
###Basic
In the client:

1. Go to settings.

2. Check the server URL if it matches the URL of your server.

3. Add a new Kitty. (If the URL of your Kitty is `http://www.server.de/ABC12` then you need to enter `ABC12`)

5. Select a user in your newly added Kitty.

6. Close settings.

Now you can scan EAN codes of your drinks.

## Limitations
Currently, scanning codes is unsupported in the simulator. You need to run the app on an actual device to test that.

## Requirements
Works with:

* Xcode 5
* iOS 7 SDK
* ARC (You can turn it on and off on a per file basis)

May also work with previous Xcode and iOS SDK versions.

## License (MIT License)
Copyright (c) 2013 Roland Moers

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

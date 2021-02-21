# Pre-work - *Tip Calculator*

**Tippr** is a tip calculator application for iOS.

Submitted by: **Jackson Cooley**

Time spent: **4** hours spent in total

## User Stories

The following **required** functionality is complete:

* [x] User can enter a bill amount, choose a tip percentage, and see the tip and total values.
* [x] User can select between tip percentages by tapping different values on the segmented control and the tip value is updated accordingly

The following **optional** features are implemented:

* [x] UI animations (sort of; see "scrolling number labels" below)
* [x] Remembering the bill amount across app restarts (if <10mins)
* [x] Using locale-specific currency and currency thousands separators.
* [x] Making sure the keyboard is always visible and the bill amount is always the first responder. This way the user doesn't have to tap anywhere to use this app. Just launch the app and start typing.

The following **additional** features are implemented:

- [x] General UI improvements (bigger labels, rounded corners), dark mode support
- [x] Valid bill amount string checking
- [x] Tip slider for precise percentages
- [x] Saved bill amount and tip percentage across restarts (reset after >20 minutes)
- [x] Haptic feedback on bill amount and tip percentage changes
- [x] "Scrolling" number labels (using some code from [this article](https://toplayoutguide.medium.com/swift-3-so-i-wanted-to-animate-a-label-14dd2b332ef9))

## Video Walkthrough

Here's a walkthrough of implemented user stories:

<img src='https://i.imgur.com/OV8sEnQ.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

## Notes

- Adding currency symbols was somewhat difficult since I had to add and remove the symbol when calculating the total amounts
- Rounding results correctly (2 decimal places) was also difficult since I did not want to truncate

## License

    Copyright 2021 Jackson Cooley

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.

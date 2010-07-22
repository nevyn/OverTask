OverTask
================

OverTask is for keeping track of a short-term hierarchical todo while you code, as an overlay over your entire screen.

<a href="http://dl.dropbox.com/u/6775/OverTask1.0.jpeg"><img src="http://dl.dropbox.com/u/6775/OverTask1.0.jpeg" width="885" border="none"/></a>

Each task is a block, in a tree going upwards from the bottom of the screen. The blocks overlay the screen, whichever app you are in, and global hotkeys let you modify the tree while you are working in another app. To toggle between working and managing the task tree, holding the global hotkeys and moving the cursor up and down changes the opacity of the task overlay.

Usage
------------------------
**Basics**

* Arrow keys: Navigate between tasks
* Left/right while at an edge: Create sibling tasks
* Up, while at the top of a branch: Create dependencies (child tasks)
* Return: Rename the selected task
* Space or backspace: Complete/remove the selected task

**Global access**

* Command+control+key: The global shortcut. Hold these two keys together with any other shortcut to perform the corresponding action while in any app
* Command+control+mouse: Change opacity of task overlay

**Focus**

* F: Focus on the selected task, showing only it and its dependencies
* D: Defocus, showing the entire task tree again (or the previously focused task, if you have focused while in focus)

**Advanced**

* Y: Yank (remove) the selected task from the tree, keeping its dependencies and assigning them as siblings to the yanked task.

You can see all of these shortcuts from "Cheat Sheet" under the Help menu

Version history
-----------------
1.1 (2010-07-22): Yank and Focus

1.0 (2010-07-18): Initial release

Contact
-----------------
OverTask is made by <a href="mailto:joachimb@gmail.com">Joachim Bengtsson</a> (<a href="http://twitter.com/nevyn">@nevyn</a>)
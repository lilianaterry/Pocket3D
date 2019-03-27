*** Contributions: ***

	Dylan Bottoms: 
		- Files Screen UI/UX
		- Initial IB elements for Status, Login, and Files screens

	Chris Day:
		- The API framework
		- The websocket framework and observer system
		- Connected most of the UI to the API

	Jonathan Ray:
		- Setup/debugged virtual printer for testing purposes
		- Added/improved core data functionality for saving inputs
		- Assisted with API calls for interacting with Octoprint
		- Pair programmed with Dylan to create Files screen UI and View Controller

	Liliana Terry:
		- Global UI elements, colors, and fonts
		- Login Screen UI/UX
		- Status Screen UI/UX
		- Controls Screen UI/UX 
		- Settings Screen UI/UX
		- Navigation Control + UI/UX
		- Loading animation for Files Screen 
		- Core Data storage for Settings information/Login information


*** Notes for running: ***

	1. Simulator Phone:
		- We created and tested our UI with the iPhone XR. 
		- Behavior/layouts on other screens may work but not all have been tested.
	2. The Controls screen UIScrollView works on a real phone, but it sometimes misbehaves on 
		one of our simulators.
	3. WARNING: yes the print buttons on the Files screen work. 
		- If you select one, the printer will start printing. At the moment there is no way to 
		stop the current print job so it would be nice if Chris did not wake up to multiple new 
		printer objects :)


*** Deviations: ***

	1. Navigation changed from a slide out menu to a tab bar at the top of every screen. 
		- The slide out menu required 2 clicks by the user and the tab bar requires only 1 click 
		so it’s more efficient UX design. 
	2. No custom GCODE buttons on the Controls screen.
		- It was more challenging than expected to dynamically size the Controls view controller 
		depending on the user. To ensure we turned in a substantial amount of work for the Alpha 
		release, we created the Settings and Login screens instead which were our Beta release 
		goals.
	3. Vertical Z slider on Controls screen is horizontal. 
		- Apparently it is incredibly difficult to make a vertical slider. Liliana used the 
		transform method, many github examples, and a couple CocoaPods but nothing worked AND 
		looked like we wanted so for now it’s horizontal.
	4. File screen does not have a read time for each file.
		- The OctoPrint API returns read/modify time as one value instead of two so our Status 
		screen only has a Modify Time label, not a Read Time label (not really a deviation, more 
		of a clarification).
	5. Control screen xy coordinate does not update to the current head position when the screen 
		loads initially because
		- Getting the absolute head position with the API was trickier than we thought. 
		- It does move the head of the printer when dragged though!
	6. Settings screen is not complete for dark/light mode, but this was not promised for Alpha.

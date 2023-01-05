import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class BRMCadenceApp extends Application.AppBase {

	var dataField;
	
	function initialize() {
		AppBase.initialize();
	}

	// onStart() is called on application start up
	function onStart(state as Dictionary?) as Void {
	}

	// onStop() is called when your application is exiting
	function onStop(state as Dictionary?) as Void {
	}

	//! Return the initial view of your application here
	function getInitialView() as Array<Views or InputDelegates>? {
		dataField = new BRMCadenceView() as Array<Views>;
		return [ dataField ];
	}

	function onSettingsChanged() as Void{
		dataField.getLoc();
		dataField.setLoc();
	}
}

function getApp() as BRMCadenceApp {
	return Application.getApp() as BRMCadenceApp;
}
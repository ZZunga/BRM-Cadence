import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class BRMCadenceApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state) {
    }

    // onStop() is called when your application is exiting
    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        return [ new BRMCadenceView() ];
    }

	function onSettingsChanged() {
		WatchUi.requestUpdate();
	}
}

function getApp() as BRMCadenceApp {
    return Application.getApp() as BRMCadenceApp;
}
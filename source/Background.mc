import Toybox.Graphics;
import Toybox.WatchUi;

class Background extends WatchUi.Drawable {

    hidden var mColor;

    function initialize() {
        var dictionary = {
            :identifier => "Background"
        };

        Drawable.initialize(dictionary);

        mColor = Graphics.COLOR_WHITE;
    }

    function setColor(color) {
        mColor = color;
    }

    function draw(dc) {
        dc.setColor(Graphics.COLOR_TRANSPARENT, mColor);
        dc.clear();
    }

}

import Toybox.Graphics;
import Toybox.Math;
import Toybox.WatchUi;
import Toybox.System;

class BRMCadenceView extends WatchUi.DataField {

    protected var currentCadence;
    protected var averageCadence;
    protected var maxCadence;
    protected var personalCadence;
    
    protected var themedItems;

	hidden var loc;
	hidden var fnt;
	
	hidden var fullhalf = 140;  			// 화면 크기

	const VALUE_DISABLED = 0;
	
    enum {
        THEME_NONE,
        THEME_RED,
        THEME_RED_INVERT,
        INDICATE_HIGH,
        INDICATE_LOW,
        INDICATE_NORMAL
    }

    enum {
        MODE_AVERAGE,
        MODE_PERSONAL
    }

    function initialize() {
        DataField.initialize();
        currentCadence = VALUE_DISABLED;
        averageCadence = VALUE_DISABLED;
        maxCadence = VALUE_DISABLED;
    }

    function onLayout(dc) {

    	var width = dc.getWidth();
    	var smallFont = (Application.Properties.getValue("fontSize") == 0);
    	var fontHeight = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);

		fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_TINY, Graphics.FONT_NUMBER_MILD];

        switch (width) {
        	// width(0), title(y1), cad S(x2,y3), cad L(x4,y5) 
        	// avgF(x6,y7), avg S(x6,y7), avg L(x8,y9)
        	// metric(x10,y11), metric2(x12,y13), label(x14,y15), arrow(x16,y17)
        	case 140: //Edge 1030, 1030 plus
        		if ( fontHeight != 48 ) {
	        		loc = [140, 2, 100,38, 78,38, 136,25, 138,17, 104,56, 82,56, 0,0,0,0]; 
   	    		} else {
	        		loc = [140, 2, 100,25, 82,37, 133,30, 135,20, 102,58, 86,58, 0,0,0,0];  
					fnt = [Graphics.FONT_NUMBER_HOT, Graphics.FONT_NUMBER_MILD, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_NUMBER_MEDIUM];
				}
        		break;
        	case 282: //Edge 1030, 1030 plus
        		if ( fontHeight != 48 ) {
					loc = [140, 2, 100,38, 0,0, 240,38, 0,0, 105,56, 245,56, 245,33, 141,48];  
   	    		} else {
    	    		loc = [140, 2, 115,25, 0,0, 245,25, 0,0, 118,58, 248,58, 248,33, 141,45];
					fnt = [Graphics.FONT_NUMBER_HOT, Graphics.FONT_NUMBER_MILD, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_NUMBER_HOT];
				}
        		break;
        	case 119: //Edge 1000, Edge Explorer, Edge Explorer2
        		if ( fontHeight != 48 ) {
        			loc = [119, 2, 85,33, 68,33, 112,25, 115,18, 88,50, 72,50, 0,0,0,0];
   	    		} else {
        			loc = [119, 2, 80,29, 72,29, 114,24, 118,18, 84,51, 74,51, 0,0,0,0];
				}
        		break;
        	case 240: //Edge 1000, Edge Explorer, Edge Explorer2
        		if ( fontHeight != 48 ) {
        			loc = [119, 2, 85,32, 0,0, 204,32, 0,0, 89,49, 210,49, 210,28, 119,41];  
   	    		} else {
        			loc = [119, 2, 85,29, 0,0, 205,29, 0,0, 89,51, 210,51, 210,32, 118,45];
				}
        		break;
        	case 114: //Edge 130
        	case 115: //Edge 130 plus
        		loc = [115, 1, 73,25, 65,25, 110,21, 110,20, 76,47, 66,47];
				fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_LARGE, Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_NUMBER_MEDIUM];
        		break;
        	case 230: //Edge 130 plus
        		loc = [115, 1, 81,25, 0,0, 195,25, 0,0, 83,47, 196,47, 196,26, 114,39];
				fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_LARGE, Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_NUMBER_MEDIUM];
        		break;
        	case 99: //Edge 520, 520 plus
        		loc = [99, 0, 65,19, 55,19, 92,16, 98,9, 68,33, 56,33];
        		fnt[4] = Graphics.FONT_NUMBER_MILD;
        		break;
        	case 200: //Edge 520, 520 plus
        		loc = [99, 0, 67,19, 0,0, 169,19, 0,0, 70,33, 171,33, 171,17, 100,27];  
        		break;
        	case 122: //Edge 530, 830
        		loc = [122, 1, 87,23, 68,23, 119,19, 120,12, 91,40, 71,40, 0,0,0,0];  
        		break;
        	case 246: //Edge 530, 830
        		loc = [122, 1, 84,23, 0,0, 208,23, 0,0, 88,40, 212,40, 212,20, 122,33];
        		break;
        	default:
        		loc = [140, 2, 100,38, 78,38, 136,25, 138,17, 104,56, 82,56, 0,0,0,0]; 
        }

		// 화면 모드에 따른 Layout 설정
        var fullWidth = dc.getWidth() > loc[0];

        View.setLayout(Rez.Layouts.MainLayout(dc));

        themedItems = {
            :cadence => View.findDrawableById("cadence"),
            :average => View.findDrawableById("average"),
            :averageF => View.findDrawableById("averageF"),
            :metric  => View.findDrawableById("metric"),
            :metric2  => View.findDrawableById("metric2"),
            :label  => View.findDrawableById("label"),
            :title   => View.findDrawableById("title")
        };

		var title = loadResource(Rez.Strings.title);
		var title2;
		var averagemode = Application.Properties.getValue("averageMode");
		
		switch(averagemode) {
			case 0:
				title2 = loadResource(Rez.Strings.modeAvg);
				break;
			case 1:
				title2 = loadResource(Rez.Strings.modeMax);
				break;
			default:
				title2 = "Avg";
		}
		
		if (width==114 || width == 115 || width == 99) {
	        themedItems[:title].setText(title);
		} else {
        	themedItems[:title].setText(title+"/"+title2);
        }

        themedItems[:metric].setText(Rez.Strings.metric);
        themedItems[:metric2].setText(Rez.Strings.metric);

        // Full 화면모드에서 평균값을 화면 오른쪽으로 크게 표시
        if (fullWidth) {
            var mode = Application.Properties.getValue("cadenceMode");
            themedItems[:label].setText(mode == MODE_AVERAGE ? Rez.Strings.labelAvg : Rez.Strings.labelPersonal);

        	// width(0), title(y1), cad S(x2,y3), cad L(x4,y5) 
        	// avgF(x6,y7), avg S(x6,y7), avg L(x8,y9)
        	// metric(x10,y11), metric2(x12,y13), label(x14,y15), arrow(x16,y17)
			themedItems[:title].locY = loc[1];
			themedItems[:metric].setLocation(loc[10],loc[11]);
			themedItems[:metric2].setLocation(loc[12],loc[13]);
			themedItems[:label].setLocation(loc[14],loc[15]);

			themedItems[:cadence].setLocation(loc[2],loc[3]);
			themedItems[:cadence].setFont(fnt[0]);
			themedItems[:averageF].setLocation(loc[6],loc[7]);
			
        } else {

			themedItems[:title].locY = loc[1];

			if (!smallFont) {
				themedItems[:cadence].setLocation(loc[4],loc[5]);
				themedItems[:cadence].setFont(fnt[0]);
				if (width==140&&fontHeight==48) {themedItems[:cadence].setFont(fnt[4]);}
				themedItems[:average].setLocation(loc[8],loc[9]);
				themedItems[:average].setFont(fnt[1]);
				themedItems[:metric].setLocation(loc[12],loc[13]);
			} else {
				themedItems[:cadence].setLocation(loc[2],loc[3]);
				themedItems[:cadence].setFont(fnt[0]);
				themedItems[:average].setLocation(loc[6],loc[7]);
				themedItems[:average].setFont(fnt[2]);
				themedItems[:metric].setLocation(loc[10],loc[11]);
			}
		}
		themedItems[:averageF].setFont(fnt[0]);
		themedItems[:title].setFont(fnt[3]);
		themedItems[:metric].setFont(fnt[3]);
		themedItems[:metric2].setFont(fnt[3]);
		themedItems[:label].setFont(fnt[3]);
        return true;
    }

    function compute(info) {
    	if (info has :currentCadence) {
        	if (info.currentCadence != null) {
            	currentCadence = info.currentCadence;
            } else {
            	currentCadence = VALUE_DISABLED;
            }
        }

    	if (info has :averageCadence) {
        	if (info.averageCadence != null) {
            	averageCadence = info.averageCadence;
            } else {
            	averageCadence = VALUE_DISABLED;
            }
        }
        
    	if (info has :maxCadence) {
        	if (info.maxCadence != null) {
            	maxCadence = info.maxCadence;
            } else {
            	maxCadence = VALUE_DISABLED;
            }
        }
    }  

    function onUpdate(dc) {
    
        var fullWidth = dc.getWidth() > loc[0];

        var colors = {
            :background => getBackgroundColor(),
            :color => null
        };
        var background = View.findDrawableById("Background");

        if (currentCadence != null) {
            var variations = getVariations();
			
            if (currentCadence > variations[:max]) {
                colors = themed(themedItems, INDICATE_HIGH);
            } else if (currentCadence < variations[:min]) {
                colors = themed(themedItems, INDICATE_LOW);
            } else {
                colors = themed(themedItems, INDICATE_NORMAL);
            }

			if (currentCadence <= 0) {
				currentCadence = 0;
			}
			themedItems[:cadence].setText(currentCadence.format("%d"));
						
        } else {
            // not initialized yet
            colors = themed(themedItems, INDICATE_NORMAL);
            themedItems[:cadence].setText("_");
        }

        background.setColor(colors[:background]);
        /////////////////////////
        //averageCadence = 135;

		var averagemode = Application.Properties.getValue("averageMode");
		switch(averagemode) {
			case 0:
				if (fullWidth) {
					themedItems[:averageF].setText(averageCadence.format("%d"));
			    } else {
					themedItems[:average].setText(averageCadence.format("%d"));
				}
				break;
			case 1:
				if (fullWidth) {
					themedItems[:averageF].setText(maxCadence.format("%d"));
			    } else {
					themedItems[:average].setText(maxCadence.format("%d"));
				}
				break;
			default:
				if (fullWidth) {
					themedItems[:averageF].setText("__");
			    } else {
					themedItems[:average].setText("__");
				}
		}
        View.onUpdate(dc);

		// Full 화면모드에서 화살포 그리기
        if (!fullWidth) {
            return;
        }
        drawArrows(dc, colors);
    }

    /**
     * render colors for items based on theme and indication.
     *
     * @return themed colors
     */
    function themed(itemsDict, indication) {
        var theme = Application.Properties.getValue("theme");
        var backgroundColor = getBackgroundColor();
        var defaultColor = backgroundColor == Graphics.COLOR_BLACK ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
        var items = itemsDict.values();
        var itemCount = itemsDict.size();
        var color = defaultColor;

		// 테마설정 시작
		// 평균값보다 크거나 작을 경우 녹색 또는 붉은색으로 글자색 적용
        switch (theme) {
            case THEME_RED:
                for (var i = 0; i < itemCount; i++ ) {
                    // implicit: only make first item red/green
                    var item = items[i];
                    if (null == item) {
                        continue;
                    }
                    var indicate = (item == themedItems[:cadence]);
                    if (indicate && indication == INDICATE_HIGH) {
                        color = Graphics.COLOR_DK_GREEN;
                        item.setColor(Graphics.COLOR_DK_GREEN);
                    } else if (indicate && indication == INDICATE_LOW) {
                        color = Graphics.COLOR_DK_RED;
                        item.setColor(Graphics.COLOR_DK_RED);
                    } else {
                        // others get default coloring
                        item.setColor(defaultColor);
                    }
                }
                break;

            case THEME_RED_INVERT:
                for (var j = 0; j < itemCount; j++ ) {
                    // explicit: make all items red/green/default
                    var item = items[j];
                    if (null == item) {
                        continue;
                    }

                    if (indication == INDICATE_HIGH) {
                        color = Graphics.COLOR_WHITE;
                        item.setColor(Graphics.COLOR_WHITE);
                        backgroundColor = Graphics.COLOR_DK_GREEN;
                    } else if (indication == INDICATE_LOW) {
                        color = Graphics.COLOR_WHITE;
                        item.setColor(Graphics.COLOR_WHITE);
                        backgroundColor = Graphics.COLOR_DK_RED;
                    } else {
                        item.setColor(defaultColor);
                    }
                }
                break;

            default:
            case THEME_NONE:
                // all get default coloring
                for (var k = 0; k < itemCount; k++ ) {
                    if (null != items[k]) {
                        items[k].setColor(defaultColor);
                    }
                }
                break;
        }
		// 테마 설정 끝

        return {
            :background => backgroundColor,
            :color => color,
            :indication => indication
        };
    }

    function getComparableCadence() {
        var mode = Application.Properties.getValue("cadenceMode");

        if (mode == MODE_PERSONAL) {
            return Application.Properties.getValue("personalCadence");
        }

        return averageCadence;
    }

    function getVariations() {
        var threshold = Application.Properties.getValue("threshold").toFloat();
        var compareable = getComparableCadence();
        var control = compareable * (threshold/100);

        return {
            :min => compareable - control,
            :max => compareable + control
        };
    }

	// Full 화면 모드에서 화살표 그리기 함수
    function drawArrows(dc, colors) {
        var center = loc[16];
        var vcenter = loc[17];

        // up arrow, 13x7
        dc.setColor(colors[:indication] == INDICATE_HIGH ? colors[:color] : Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[center - 6, vcenter + 6], [center, vcenter], [center + 6, vcenter + 6]]);

        // down arrow, 13x7
        dc.setColor(colors[:indication] == INDICATE_LOW ? colors[:color] : Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon([[center - 6, vcenter + 10], [center, vcenter + 16], [center + 6, vcenter + 10]]);
    }
}
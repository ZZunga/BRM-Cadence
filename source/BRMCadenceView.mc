import Toybox.Activity;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Math;
import Toybox.WatchUi;
import Toybox.System;

class BRMCadenceView extends WatchUi.DataField {

	hidden var currentCadence as Number or Null;
	hidden var averageCadence as Number or Null;
	hidden var personalCadence as Number or Null;
    
	hidden var themedItems;

	hidden var loc as Array or Null;
	hidden var fnt as Array or Null;
	
	hidden var width as Number or Null;
	hidden var fontHeight as Number or Null;

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
		currentCadence = 0;
		averageCadence = 0;
	}

	function onLayout(dc as Dc) as Void {
		width = dc.getWidth();
		fontHeight = dc.getFontHeight(Graphics.FONT_NUMBER_MEDIUM);
		fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_LARGE, Graphics.FONT_MEDIUM, Graphics.FONT_TINY, Graphics.FONT_NUMBER_MILD];
		getLoc();
		View.setLayout(Rez.Layouts.MainLayout(dc));
		setLoc();
	}

	function getLoc() as Void{
		switch (width) {
		// 풀필드 width(0), 타이틀(y1), 케이던스F(x2,y3), 평균F(x4,y5)
		// 단위1F(x6,y7), 단위2F(x8,y9), 라벨(x8,y11), 화살표(x12,y13)
		// 하프필드 width(0), 타이틀(y1), 케이던스S(x2,y3), 케이던스B(x4,y5)
		// 평균S(x6,y7), 평균B(x8,y9), 단위S(x10,y11), 단위B(x12,y13)
		case 140: //Edge 1030, 1030 plus
			if ( fontHeight != 48 ) {
				loc = [140, 2, 100,38, 78,38, 136,25, 138,17, 104,56, 82,56]; 
			} else {
				loc = [140, 2, 100,25, 82,37, 133,30, 135,20, 102,58, 86,58];  
				fnt = [Graphics.FONT_NUMBER_HOT, Graphics.FONT_NUMBER_MILD, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_NUMBER_MEDIUM];
			}
			break;
		case 282: //Edge 1030, 1030 plus
			if ( fontHeight != 48 ) {
				loc = [140, 2, 100,38, 240,38, 105,56, 245,56, 245,33, 141,48];  
			} else {
				loc = [140, 2, 115,25, 245,25, 118,58, 248,58, 248,33, 141,45];
				fnt = [Graphics.FONT_NUMBER_HOT, Graphics.FONT_NUMBER_MILD, Graphics.FONT_MEDIUM, Graphics.FONT_SMALL, Graphics.FONT_NUMBER_HOT];
			}
			break;
		case 119: //Edge 1000, Edge Explorer, Edge Explorer2
			if ( fontHeight != 48 ) {
				loc = [119, 2, 85,33, 68,33, 112,25, 115,18, 88,50, 72,50];
			} else {
				loc = [119, 2, 80,29, 72,29, 114,24, 118,18, 84,51, 74,51];
			}
			break;
		case 240: //Edge 1000, Edge Explorer, Edge Explorer2
			if ( fontHeight != 48 ) {
				loc = [119, 2, 85,32, 204,32, 89,49, 210,49, 210,28, 119,41];  
			} else {
				loc = [119, 2, 85,29, 205,29, 89,51, 210,51, 210,32, 118,45];
			}
			break;
		case 114: //Edge 130
		case 115: //Edge 130 plus
			loc = [115, 1, 73,25, 65,25, 110,21, 110,20, 76,47, 66,47];
			fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_LARGE, Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_NUMBER_MEDIUM];
			break;
		case 230: //Edge 130 plus
			loc = [115, 1, 73,25, 188,25, 76,47, 191,47, 191,26, 115,42];
			fnt = [Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_LARGE, Graphics.FONT_SMALL, Graphics.FONT_TINY, Graphics.FONT_NUMBER_MEDIUM];
			break;
		case 99: //Edge 520, 520 plus
			loc = [99, 0, 65,19, 55,19, 92,16, 97,9, 68,33, 56,33];
			fnt[4] = Graphics.FONT_NUMBER_MILD;
			break;
		case 200: //Edge 520, 520 plus
			loc = [99, 0, 67,19, 169,19, 70,33, 171,33, 171,17, 100,27];  
			break;
		case 122: //Edge 530, 830
			loc = [122, 1, 87,23, 68,23, 119,19, 120,12, 91,40, 71,40];  
			break;
		case 246: //Edge 530, 830
			loc = [122, 1, 84,23, 208,23, 88,40, 212,40, 212,20, 122,33];
			break;
		default:
			loc = [140, 2, 100,38, 78,38, 136,25, 138,17, 104,56, 82,56]; 
		}
	}

	function setLoc() {
		// 화면 모드에 따른 Layout 설정
		var fullWidth = width > loc[0];
		var bigFont = (Application.Properties.getValue("fontSize") == 1);
	
		themedItems = {
			:background => View.findDrawableById("Background") as Text,
			:cadence => View.findDrawableById("cadence") as Text,
			:average => View.findDrawableById("average") as Text,
			:metric  => View.findDrawableById("metric") as Text,
			:metric2  => View.findDrawableById("metric2") as Text,
			:label  => View.findDrawableById("label") as Text,
			:title   => View.findDrawableById("title") as Text
		};

		var title1 = loadResource(Rez.Strings.title) as String or Null;
		var title2;

		var averagemode = Application.Properties.getValue("averageMode") as Number;
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
			themedItems[:title].setText(title1);
		} else {
			themedItems[:title].setText(title1+"/"+title2);
		}
		themedItems[:metric].setText(Rez.Strings.metric);
		themedItems[:metric2].setText(Rez.Strings.metric);

		// Full 화면모드에서 평균값을 화면 오른쪽으로 크게 표시
		if (fullWidth) {
			var cadenceMode = Application.Properties.getValue("cadenceMode");
			themedItems[:label].setText(cadenceMode == MODE_AVERAGE ? Rez.Strings.labelAvg : Rez.Strings.labelPersonal);
			themedItems[:title].locY = loc[1];
			themedItems[:metric].setLocation(loc[6],loc[7]);
			themedItems[:metric2].setLocation(loc[8],loc[9]);
			themedItems[:label].setLocation(loc[8],loc[11]);
			themedItems[:cadence].setLocation(loc[2],loc[3]);
			themedItems[:cadence].setFont(fnt[0]);
			themedItems[:average].setLocation(loc[4],loc[5]);
			themedItems[:average].setFont(fnt[0]);
		} else {
			themedItems[:title].locY = loc[1];
			if (!bigFont) {
				themedItems[:cadence].setLocation(loc[2],loc[3]);
				themedItems[:cadence].setFont(fnt[0]);
				themedItems[:average].setLocation(loc[6],loc[7]);
				themedItems[:average].setFont(fnt[2]);
				themedItems[:metric].setLocation(loc[10],loc[11]);
			} else {
				themedItems[:cadence].setLocation(loc[4],loc[5]);
				themedItems[:cadence].setFont(fnt[0]);
				if (width==140&&fontHeight==48) {themedItems[:cadence].setFont(fnt[4]);}
				themedItems[:average].setLocation(loc[8],loc[9]);
				themedItems[:average].setFont(fnt[1]);
				themedItems[:metric].setLocation(loc[12],loc[13]);
			}
		}
		themedItems[:title].setFont(fnt[3]);
		themedItems[:metric].setFont(fnt[3]);
		themedItems[:metric2].setFont(fnt[3]);
		themedItems[:label].setFont(fnt[3]);
	}
	
	function compute(info as Activity.Info) as Void {
		if (info has :currentCadence) {
			if (info.currentCadence != null) {
				currentCadence = info.currentCadence as Number;
			} else {
				currentCadence = 0;
			}
		}
		var AVERAGEMODE = Application.Properties.getValue("averageMode");
		switch(AVERAGEMODE) {
		case 0:
			if (info has :averageCadence) {
				if (info.averageCadence != null) {
					averageCadence = info.averageCadence as Number;
				} else {
					averageCadence = 0;
				}
			}
			break;
		default:
			if (info has :maxCadence) {
				if (info.maxCadence != null) {
					averageCadence = info.maxCadence as Number;
				} else {
					averageCadence = 0;
				}
			}
		}
	}  

	function onUpdate(dc) {
		width = dc.getWidth();
		var fullWidth = width > loc[0];
		var backgroundColor = getBackgroundColor();
		var defaultColor = backgroundColor == Graphics.COLOR_BLACK ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
		var colors = {
			:background => backgroundColor,
			:color => defaultColor
		};
		dc.setColor(colors[:color], colors[:background]);
		dc.clear();
		dc.setColor(colors[:color], -1);
		if (currentCadence != null) {
			var variations = getVariations();
			if (currentCadence > variations[:max]) {
				colors = themed(themedItems, INDICATE_HIGH);
			} else if (currentCadence < variations[:min]) {
				colors = themed(themedItems, INDICATE_LOW);
			} else {
				colors = themed(themedItems, INDICATE_NORMAL);
			}
			if (currentCadence < 0) {
				currentCadence = 0;
			}
			themedItems[:cadence].setText(currentCadence.format("%d"));
		} else {
			// not initialized yet
			colors = themed(themedItems, INDICATE_NORMAL);
			themedItems[:cadence].setText("_");
		}
		themedItems[:background].setColor(colors[:background]);
		themedItems[:average].setText(averageCadence.format("%d"));
		View.onUpdate(dc);

		// Full 화면모드에서 화살포 그리기
		if (!fullWidth) {	return;	}
		drawArrows(dc, colors);
	}

	// 테마 설정
	function themed(itemsDict, indication) {
		var theme = Application.Properties.getValue("theme");
		var backgroundColor = getBackgroundColor();
		var defaultColor, fastColor, slowColor;
		var backgroundIsBlack = backgroundColor == Graphics.COLOR_BLACK;
		defaultColor = backgroundIsBlack ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
        // 컬러 순서 변경시 Resource의 Properties 값도 같이 변경해야함. 
		var LightFontColor = [
			Graphics.COLOR_RED,
			Graphics.COLOR_ORANGE,
			Graphics.COLOR_YELLOW,
			Graphics.COLOR_GREEN,
			Graphics.COLOR_BLUE,
			Graphics.COLOR_PURPLE,
			Graphics.COLOR_PINK,
			Graphics.COLOR_LT_GRAY
		];
		var DarkFontColor = [
			Graphics.COLOR_DK_RED,
			Graphics.COLOR_ORANGE,
			Graphics.COLOR_YELLOW,
			Graphics.COLOR_DK_GREEN,
			Graphics.COLOR_DK_BLUE,
			Graphics.COLOR_PURPLE,
			Graphics.COLOR_PINK,
			Graphics.COLOR_DK_GRAY
		];
        
		var items = itemsDict.values();
		var itemCount = itemsDict.size();
		var color = defaultColor;

		var fastColorValue = Application.Properties.getValue("colorHigh");
		if (backgroundIsBlack) {
			fastColor = LightFontColor[fastColorValue];
		} else {
			fastColor = DarkFontColor[fastColorValue];
		}
				
		var slowColorValue = Application.Properties.getValue("colorLow");
		if (backgroundIsBlack) {
			slowColor = LightFontColor[slowColorValue];
		} else {
			slowColor = DarkFontColor[slowColorValue];
		}
		LightFontColor = null;
		DarkFontColor = null;

		// 테마설정 시작
		// 평균값보다 크거나 작을 경우 녹색 또는 붉은색으로 글자색 적용
		switch (theme) {
		case THEME_RED:
			for (var i = 0; i < itemCount; i++ ) {
				// 케이던스와 화살표를 적/녹색으로 설정
				var item = items[i];
				if (null == item) {
					continue;
				}
				var indicate = (item == themedItems[:cadence]);
				if (indicate && indication == INDICATE_HIGH) {
					color = fastColor;
					item.setColor(color);
				} else if (indicate && indication == INDICATE_LOW) {
					color = slowColor;
					item.setColor(color);
				} else {
					// 나머지는 기본 색상
					item.setColor(defaultColor);
				}
			}
			break;
		case THEME_RED_INVERT:
			for (var j = 0; j < itemCount; j++ ) {
				// 배경색을 적/녹색으로 설정(반전)
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
			// 기본컬러로 설정
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
		var cadenceMode = Application.Properties.getValue("cadenceMode");
		if (cadenceMode == MODE_PERSONAL) {
			return Application.Properties.getValue("personalCadence");
		}
		return averageCadence;
	}

	function getVariations() {
		var threshold = Application.Properties.getValue("threshold").toFloat();
		var compareable = getComparableCadence();
		var control = compareable * (threshold/100.0);
		return {
			:min => compareable - control,
			:max => compareable + control
		};
	}

	// Full 화면 모드에서 화살표 그리기 함수
	function drawArrows(dc as Dc, colors) {
		var center = loc[12];
		var vcenter = loc[13];

		// up arrow, 13x7
		dc.setColor(colors[:indication] == INDICATE_HIGH ? colors[:color] : Graphics.COLOR_LT_GRAY, -1);
		if (loc[0]==115) {
			dc.setColor(Graphics.COLOR_BLACK, -1);
			if (colors[:indication] == INDICATE_HIGH) {
				dc.fillPolygon([[center - 6, vcenter + 6], [center, vcenter], [center + 6, vcenter + 6]]);
			} else {
				dc.drawLine(center - 6, vcenter + 6, center, vcenter);
				dc.drawLine(center - 6, vcenter + 6, center + 6, vcenter + 6);
				dc.drawLine(center, vcenter, center + 6, vcenter + 6);
			}
		} else {        	
			dc.fillPolygon([[center - 6, vcenter + 6], [center, vcenter], [center + 6, vcenter + 6]]);
		}

		// down arrow, 13x7
		dc.setColor(colors[:indication] == INDICATE_LOW ? colors[:color] : Graphics.COLOR_LT_GRAY, -1);
		if (loc[0]==115) {
			dc.setColor(Graphics.COLOR_BLACK, -1);
			if ( colors[:indication] == INDICATE_LOW) {
				dc.fillPolygon([[center - 6, vcenter + 10], [center, vcenter + 16], [center + 6, vcenter + 10]]);
			} else if (loc[0] == 115) {
				dc.drawLine(center - 6, vcenter + 10, center, vcenter + 16);
				dc.drawLine(center - 6, vcenter + 10, center + 6, vcenter + 10);
				dc.drawLine(center, vcenter + 16, center + 6, vcenter + 10);
			}
		} else {
			dc.fillPolygon([[center - 6, vcenter + 10], [center, vcenter + 16], [center + 6, vcenter + 10]]);
		}	    
	}
}
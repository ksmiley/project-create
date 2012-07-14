﻿package edu.uky.comm.rcap{	import flash.text.TextFormat;	import flash.text.TextFormatAlign;	import flash.text.Font;		public class Config	{		//public static const serverBase:String = "http://192.168.1.109/RCAP";		public static const serverBase:String = "http://comm.uky.edu/RCAP";		public static const xmlBase = serverBase + "/defs";		public static const fontBase = serverBase + "/assets/fonts";		public static const imageBase = serverBase + "/assets/images";		public static const uploadUrl = serverBase + "/gateway.php";		public static const surveyUrl = serverBase + "/survey.php";		public static const stageSize:Object = {			width: 980, height: 600		};		public static const thumbPosition:Object = {			x: 11, y: 0, width: 130, height: 575		};		//public static const previewPosition:Object = {  // with zoom buttons		//	x: 155, y: 40, width: 450, height: 440		//};		public static const previewPosition:Object = {  // without zoom buttons			x: 155, y: 40, width: 500, height: 510		};		public static const inputPosition:Object = {			x: 660, y: 75, width: 300, height: 470		};		public static const confirmPreviewPosition:Object = {			x: 21, y: 48, width: 560, height: 500		};				public static const renderWidth:Number  = 450;		public static const renderHeight:Number = 410;				public static const startInstructions:Class = StartInstructions;		public static const inputScrollerSkin:Class = InputScrollerSkin;		public static const inputScrollerGutter:Number = 10;				public static const loaderStartText:String = "Please wait…";		public static const inputPanelMessage:String = "Please choose a Tagline and a Statistic:";		//public static const inputPanelMessage:String = "";				public static const jpegCompression:Number = 80;				public static const allowUserMessages:Boolean = false;		public static const allowPreviewZoom:Boolean = false;		public static const usePreviewSmoothing:Boolean = false;		public static const useThumbSmoothing:Boolean = false;		public static const defaultQuantity:int = 1;				private static const _regularFontClass:Class = Helvetica;		private static var _regularFont:Font;		public static function get regularFont():Font		{			if (_regularFont == null)			{				_regularFont = new _regularFontClass();			}			return _regularFont;		}				private static const _boldFontClass:Class = HelveticaBold;		private static var _boldFont:Font;		public static function get boldFont():Font		{			if (_boldFont == null)			{				_boldFont = new _boldFontClass();			}			return _boldFont;		}		private static var _textFormats:Object;		public static function get textFormats():Object		{			if (_textFormats == null)			{				var mainFont:Font = Config.regularFont;				var boldFont:Font = Config.boldFont;				_textFormats = new Object();				_textFormats.embedFonts    = true;				_textFormats.empty         = new TextFormat(mainFont.fontName, 13, 0x666666, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0);				_textFormats.default       = new TextFormat(mainFont.fontName, 13, 0x000000, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 2);				_textFormats.title         = new TextFormat(boldFont.fontName, 13, 0x000000, true , false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0);				_textFormats.tabLabel      = _textFormats.title;				_textFormats.paperSelector = _textFormats.default;				_textFormats.questions     = _textFormats.default;				_textFormats.questionEcho  = new TextFormat(mainFont.fontName, 14, 0x000000, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0);				_textFormats.loader        = _textFormats.default;				_textFormats.orderEcho     = _textFormats.default;				_textFormats.quantity      = new TextFormat(mainFont.fontName, 13, 0x000000, false, false, false, "", "", TextFormatAlign.CENTER, 0, 0, 0, 0)				_textFormats.helpMsg       = new TextFormat(mainFont.fontName, 15, 0x000000, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0);			}			return _textFormats;		}	}}
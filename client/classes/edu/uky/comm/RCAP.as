package edu.uky.comm
{
	import flash.display.SimpleButton;
	
	import flash.accessibility.AccessibilityProperties;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ProgressEvent;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.KeyboardEvent;
	import flash.display.MovieClip;
	import flash.display.LoaderInfo;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	import flash.external.ExternalInterface;
	
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import fl.controls.ComboBox;
	import fl.controls.NumericStepper;
	import fl.core.InvalidationType;
	
	import edu.uky.comm.rcap.PosterMaker;
	import edu.uky.comm.rcap.TemplateLoader;
	import edu.uky.comm.rcap.Config;
	import edu.uky.comm.rcap.ThumbPanel;
	import edu.uky.comm.rcap.PreviewBitmap;
	import edu.uky.comm.rcap.CustomCellRenderer;
	import edu.uky.comm.rcap.PosterTemplateSet;
	import edu.uky.comm.rcap.PosterTemplate;
	import edu.uky.comm.rcap.PosterTextArea;
	
	import edu.uky.comm.net.UploadPostHelper;  // for uploading the image data
	import com.adobe.images.JPGEncoder;     // used to compress the preview
	
	public class RCAP extends MovieClip
	{
		///////////////////////////
		// Declare stage instances
		//
		// various buttons
		public var Next_Button0:SimpleButton;   // Welcome next (goes to questions)
		public var Next_Button1:SimpleButton;   // Questions next (goes to designer)
		public var Next_Button2:SimpleButton;   // Designer next (goes to order)
		public var Next_Button3:SimpleButton;   // Order submit (goes to thankyou)
		public var Back_Button2:SimpleButton;   // Designer back (goes to questions)
		public var Back_Button3:SimpleButton;   // Order change (goes to designer)
		public var Restart_Button0:SimpleButton; // Used to go back to the questions screen
		public var Survey_Button0:SimpleButton;       // this button and the next occupy the same space, 
		public var ViewPosters_Button0:SimpleButton;  // and only one will be shown at once. both leave the program
		
		// radio buttons on the questions screen

		// group: HIVorSTD
		public var STDs_Radio:RadioButton;
		public var HIV_Radio:RadioButton;
		// group: GROUP
		public var MSM_Radio:RadioButton;
		public var Heterosexual_Radio:RadioButton;
		public var IVDrugUsers_Radio:RadioButton;
		public var Youth_Radio:RadioButton;
		
		// group: RACEorETHNIC
		public var Caucasian_Radio:RadioButton;
		public var AfricanAmerican_Radio:RadioButton;
		public var Hispanic_Radio:RadioButton;
		public var NativeAmerican_Radio:RadioButton;
		public var Other_Radio:RadioButton;

		// labels to display user's selection
		public var HIVorSTD_text:TextField;
		public var GROUP_text:TextField;
		public var RACEorETHNIC_text:TextField;
		
		// text fields and input on the order screen
		public var Confirm_Size:TextField;
		public var Confirm_Name:TextField;
		public var Confirm_Email:TextField;
		public var Confirm_Affiliation:TextField;
		public var Confirm_Address:TextField;
		public var Confirm_Phone:TextField;
		public var PaperType:ComboBox;
		public var Quantity:NumericStepper;
	
		// text field on the thank you screen
		public var ThankYou_Text:TextField;
	
		//////////////////////////
		// Private class variables
		private var curLoad:PreloadSpinner;
		private var loaderText:TextField;
		private var loaderLeftMargin:Number;   // used to center the loader in a subarea of the stage
		private var designer:PosterMaker;
		private var orderPreview:PreviewBitmap;
		private var tmplLoader:TemplateLoader;
		private var uploader:URLLoader;
		private var sets:Array;   // loaded data from TemplateLoader
		private var msgs:Array;   // loader data from TemplateLoader
		private var userInfo:Object;
		private var paperTypeIndex:int;
		private var quantityValue:int;
		private var questionsInitialized:Boolean = false;
		private var postersOrdered:Array;
		
		// function queue used by runLater() to dispatch functions during RENDER
		private var queuedFunctions:Array;
		
		// hold the user selections from the questions screen
		private var HIVorSTD_string:String     = ""; // Initializes strings to handle the user's choices
		private var GROUP_string:String        = "";
		private var RACEorETHNIC_string:String = "";
		private var FileName:String            = ""; // Filepath needed for XML template definitions
		private var prevFileName:String        = ""; // Filepath of the user's last selections, to prevent re-downloading

		private var prev_HIVorSTD:String;
		private var prev_GROUP:String;
		private var prev_RACEorETHNIC:String;
		
		// constructor
		public function RCAP():void
		{
			queuedFunctions = new Array();
			_gatherUserInfo();
			
			// user starts on a welcome screen where they just have to click "Next".
			// the handler will advance to the next frame and set it up
			Next_Button0.addEventListener(MouseEvent.CLICK, welcomeNextHandler);
		}
		
		// user clicked Next on the welcome screen, so move to the questions screen 
		// and setup the formatting and listeners on the radio buttons
		private function welcomeNextHandler(e:MouseEvent):void
		{
			Next_Button0.removeEventListener(MouseEvent.CLICK, welcomeNextHandler);
			gotoAndStop('questionsScreen');
			runLater(_enterQuestionScreen);
		}
		
		// user has made selections at the radio buttons and clicked next, so move to
		// the poster maker screen and start loading the content
		private function questionsNextHandler(e:MouseEvent):void
		{
			Next_Button1.removeEventListener(MouseEvent.CLICK, questionsNextHandler);
			_setupQuestionRadios_RemoveListeners();
			prev_HIVorSTD     = HIVorSTD_string;
			prev_GROUP        = GROUP_string;
			prev_RACEorETHNIC = RACEorETHNIC_string;
			gotoAndStop('designerScreen');
			runLater(_enterDesignerScreen);			
		}

		private function designerBackHandler(e:MouseEvent):void
		{
			Back_Button2.removeEventListener(MouseEvent.CLICK, designerBackHandler);
			removeChild(designer);
			gotoAndStop('questionsScreen');
			runLater(_enterQuestionScreen);
		}
		
		private function designerNextHandler(e:MouseEvent):void
		{
			Next_Button2.removeEventListener(MouseEvent.CLICK, designerNextHandler);
			removeChild(designer);
			gotoAndStop('orderScreen');
			runLater(_enterOrderScreen);
		}
		
		private function orderBackHandler(e:MouseEvent):void
		{
			Back_Button3.removeEventListener(MouseEvent.CLICK, orderBackHandler);
			removeChild(orderPreview);
			gotoAndStop('designerScreen');
			runLater(_enterDesignerScreen);
		}
		
		private function orderNextHandler(e:MouseEvent):void
		{
			Next_Button3.removeEventListener(MouseEvent.CLICK, orderNextHandler);
			gotoAndStop('thankyouScreen');
			runLater(_enterThankyouScreen);
			
			var tmpl:PosterTemplate = designer.selectedTemplate;
			var sendData:Object = {
				'tmplset': tmpl.templateSet.id,
				'size': tmpl.label,
				//'quality': tmpl.paperOptions[paperTypeIndex],
				//'quantity': quantityValue,
				'sessionid': userInfo.sessionid,
				'id': userInfo.id,
				'group1': HIVorSTD_string,
				'group2': GROUP_string,
				'group3': RACEorETHNIC_string
			};
			for each (var area:PosterTextArea in tmpl.textAreas)
			{
				var msgMap:Object = tmpl.templateSet.messageMap;
				if (area.id in msgMap && msgMap[area.id].current != null)
				{
					sendData['text' + area.id] = msgMap[area.id].current.text;
				}
			}
			
			// prepare the upload. first compress the preview image into a ByteArray that can
			// be uploaded as a file
			var jpgEncoder:JPGEncoder = new JPGEncoder(Config.jpegCompression);
			var compressed:ByteArray = jpgEncoder.encode(orderPreview.bitmapData);
			
			var req:URLRequest = new URLRequest();
			req.url = Config.uploadUrl;
			req.contentType = 'multipart/form-data; boundary=' + UploadPostHelper.getBoundary();
			req.method = URLRequestMethod.POST;
			req.data = UploadPostHelper.getPostData('image.jpg', compressed, 'imagePreview', sendData);
			
			uploader = new URLLoader();
			uploader.dataFormat = URLLoaderDataFormat.BINARY;
			uploader.addEventListener(Event.COMPLETE, uploadedHandler);
			uploader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			uploader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			uploader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			uploader.load(req);
		}
		
		private function startOverHandler(e:MouseEvent):void
		{
			Restart_Button0.removeEventListener(MouseEvent.CLICK, startOverHandler);
			Survey_Button0.removeEventListener(MouseEvent.CLICK, takeSurveyHandler);
			ViewPosters_Button0.removeEventListener(MouseEvent.CLICK, takeSurveyHandler);
			designer = null;
			removeChild(orderPreview);
			gotoAndStop('questionsScreen');
			runLater(_enterQuestionScreen);
		}
		
		private function takeSurveyHandler(e:MouseEvent):void
		{
			//Restart_Button0.removeEventListener(MouseEvent.CLICK, startOverHandler);
			//Survey_Button0.removeEventListener(MouseEvent.CLICK, takeSurveyHandler);
			var variables:URLVariables = new URLVariables();
			variables.PosterID = postersOrdered.join(',');
            var request:URLRequest = new URLRequest(Config.surveyUrl);
			request.data = variables;
            navigateToURL(request, "_top");
		}
		
		private function loadedHandler(e:Event):void
		{
			removeChild(loaderText);
			removeChild(curLoad);
			Next_Button2.visible = true;
			Back_Button2.addEventListener(MouseEvent.CLICK, designerBackHandler);
			activateButton(Back_Button2);
			Back_Button2.visible = true;
			
			sets = tmplLoader.parsedTemplates;
			msgs = tmplLoader.parsedMessages;

			designer = new PosterMaker(sets, msgs);
			designer.x = designer.y = 0;
			designer.addEventListener(ThumbPanel.POSTER_CHANGE, _designerSelectionHandler);
			addChild(designer);
		}
		
		private function uploadedHandler(e:Event):void
		{
			var uploader:URLLoader = e.target as URLLoader;
			trace(uploader.data);
			var response:String = String(uploader.data);
			var parts:Array = response.split(' ');
			if (parts.length > 1 && parts[0] == "OK")
			{
				postersOrdered.push(parseInt(parts[1]));
			}
			
			removeChild(loaderText);
			removeChild(curLoad);
			ThankYou_Text.visible = true;
			Restart_Button0.addEventListener(MouseEvent.CLICK, startOverHandler);
			Restart_Button0.visible = true;
			if (userInfo.ordered.toUpperCase() == "YES")
			{
				ViewPosters_Button0.addEventListener(MouseEvent.CLICK, takeSurveyHandler);
				ViewPosters_Button0.visible = true;
			}
			else
			{
				Survey_Button0.addEventListener(MouseEvent.CLICK, takeSurveyHandler);
				Survey_Button0.visible = true;
			}

			// send a message to the containing page that a poster is no longer 
			// in progress, so the user doesn't need to be warned before trying 
			// to navigate away from the page
			if (ExternalInterface.available)
			{
				ExternalInterface.call("posterStopped");
			}
		}
		
		private function progressHandler(e:ProgressEvent):void
		{
			var percentLoad:Number = Math.floor((e.bytesLoaded / e.bytesTotal) * 100);
			if (percentLoad < 100)
			{
				loaderText.text = percentLoad.toString() + "%";
			}
			_centerLoader();
		}
		
		private function errorHandler(e:Event):void
		{
			trace(e);
		}
		
		private function _enterThankyouScreen():void
		{
			// orderNextHandler actually starts the upload instead of waiting for the frame
			// to change, so all this needs to do is place the loader progress display
			ThankYou_Text.visible = false;
			Restart_Button0.visible = false;
			Survey_Button0.visible = false;
			ViewPosters_Button0.visible = false;
			loaderText.text = Config.loaderStartText;
			_centerLoader();
			addChild(curLoad);
			addChild(loaderText);
			addChild(orderPreview);
		}
		
		private function _enterOrderScreen():void
		{
			/* UPDATED Oct. 2010: Because of a workflow change, the order
			   screen doesn't actually handle ordering. It's just a confirmation
			   step before saving. The form has been moved off the stage,
			   so all the code for the form is commented out below. */
			
			// setup the controls on the page by applying text formats and filling in
			// the information (for the text fields, user info that was loaded in the
			// constructor; for the paper selector, available types from the template)
			/*
			var fieldMap:Object = {
				'name'       : Confirm_Name,
				'email'      : Confirm_Email,
				'affiliation': Confirm_Affiliation,
				'fullAddress': Confirm_Address,
				'phone'      : Confirm_Phone
			};
			userInfo.fullAddress = userInfo.address + "\n" 
				+ userInfo.city + ", " + userInfo.state + " " + userInfo.zip;
			
			var formats:Object = Config.textFormats;
			var tf:TextFormat = ('orderEcho' in formats)  ? formats.orderEcho  : null;
			var embed:Boolean = ('embedFonts' in formats) ? formats.embedFonts : false;
			for (var key:String in fieldMap)
			{
				fieldMap[key].embedFonts = embed;
				fieldMap[key].defaultTextFormat = tf;
				fieldMap[key].text = userInfo[key];
			}
			Confirm_Size.embedFonts = embed;
			Confirm_Size.defaultTextFormat = tf;
			Confirm_Size.text = designer.selectedTemplate.label;
			
			PaperType.setStyle('embedFonts', embed);
			PaperType.dropdown.setStyle('embedFonts', embed);
			PaperType.textField.setStyle('embedFonts', embed);
			Quantity.setStyle('embedFonts', embed);
			Quantity.textField.setStyle('embedFonts', embed);
			if ('paperSelector' in formats)
			{
				PaperType.setStyle('textFormat', formats.paperSelector);
				PaperType.dropdown.setStyle('textFormat', formats.paperSelector);
				PaperType.textField.setStyle('textFormat', formats.paperSelector);
				PaperType.dropdown.setStyle('cellRenderer', CustomCellRenderer);
			}
			if ('quantity' in formats)
			{
				Quantity.setStyle('textFormat', formats.quantity);
				Quantity.textField.setStyle('textFormat', formats.quantity);
			}
			PaperType.removeAll();
			for each (var paper:String in designer.selectedTemplate.paperOptions)
			{
				PaperType.addItem({label: paper, data: paper});
			}
			if (PaperType.length == 1)
			{
				PaperType.selectedIndex = 0;
				paperTypeIndex = 0;
			}
			else
			{
				PaperType.addEventListener(Event.CHANGE, _paperTypeSelectedHandler);
				deactivateButton(Next_Button3);
				//Next_Button3.visible = false;
			}
			Quantity.value = quantityValue = Config.defaultQuantity;
			Quantity.addEventListener(Event.CHANGE, _quantityChangeHandler);
			*/
			
			// rasterize the preview and display it on the side
			var previewPos:Object = Config.confirmPreviewPosition;
			orderPreview = new PreviewBitmap(designer.selectedRenderer, previewPos.width, previewPos.height);
			if ('usePreviewSmoothing' in Config)
			{
				orderPreview.useSmoothing = Config.usePreviewSmoothing;
			}
			// center the preview image within the area defined for it
			orderPreview.x = previewPos.x + Math.floor((previewPos.width - orderPreview.width) / 2);
			orderPreview.y = previewPos.y + Math.floor((previewPos.height - orderPreview.height) / 2);
			addChild(orderPreview);

			// not actually needed until the next screen, but set it now while the position
			// object is already fetched
			loaderLeftMargin = previewPos.x + previewPos.width;
			
			Back_Button3.addEventListener(MouseEvent.CLICK, orderBackHandler);
			Next_Button3.addEventListener(MouseEvent.CLICK, orderNextHandler);
		}
		
		private function _enterDesignerScreen():void
		{
			// The user can arrive at the designer screen in five ways:
			//
			// (1) Case: From questions, on the first run through.
			//     Vars: designer == null, prevFileName == null (so FileName != prevFileName)
			//     Outcome: Create a new PosterMaker object, and start fetching data
			// 
			// (2) Case: From questions, after user went back but didn't change answers
			//     Vars: designer != null, FileName == prevFileName
			//     Outcome: Reuse existing PosterMaker object
			// 
			// (3) Case: From questions, after user went back and changed answers
			//     Vars: designer != null, FileName != prevFileName
			//     Outcome: Create a new PosterMaker object, and start fetching data
			// 
			// (4) Case: From questions, after user has already created one poster,
			//           but used same answers as previous run
			//     Vars: designer == null, FileName == prevFileName
			//     Outcome: Create a new PosterMaker object, but use existing data
			// 
			// (5) Case: From questions, after user has already created one poster,
			//           but chose different answers
			//     Vars: designer == null, FileName != prevFileName
			//     Outcome: Create a new PosterMaker object, and start fetching data
			// 
			// (6) Case: From order screen, after user clicks Back
			//           designer != null, FileName == prevFileName
			//     Outcome: Reuse existing PosterMaker object
			
			// Handle case 4
			if (designer == null && FileName === prevFileName && sets != null && msgs != null)
			{
				designer = new PosterMaker(sets, msgs);
				designer.x = designer.y = 0;
				designer.addEventListener(ThumbPanel.POSTER_CHANGE, _designerSelectionHandler);
				Next_Button2.addEventListener(MouseEvent.CLICK, designerNextHandler);
				Back_Button2.addEventListener(MouseEvent.CLICK, designerBackHandler);
				deactivateButton(Next_Button2);  // deactivate until they choose an image
				addChild(designer);
			}
			// Handle cases 1, 3 and 5
			else if (designer == null || FileName !== prevFileName)
			{
				deactivateButton(Next_Button2);
				Next_Button2.visible = false;   // don't show it during the load
				deactivateButton(Back_Button2);
				Back_Button2.visible = false;   // don't show it during the load
				prevFileName = FileName;
				sets = msgs = null;
				
				// now sitting on a basically blank screen. put the loader symbol on the screen
				// and a text label for it, then start the load
				loaderLeftMargin = 0;
				curLoad = new PreloadSpinner();
				//curLoad.x = 400;
				//curLoad.y = 250;
				addChild(curLoad);
				
				loaderText = new TextField();
				loaderText.selectable = false;
				loaderText.defaultTextFormat = Config.textFormats.loader;
				loaderText.embedFonts = Config.textFormats.embedFonts;
				loaderText.text = Config.loaderStartText;
				addChild(loaderText);
				_centerLoader();
				
				// setup the loader with the various handlers (most of the errors are unlikely,
				// but the handlers are in place just in case)
				var xmlFile:URLRequest = new URLRequest(Config.xmlBase + '/' + FileName);
				tmplLoader = new TemplateLoader();
				tmplLoader.addEventListener(Event.COMPLETE, loadedHandler);
				tmplLoader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
				tmplLoader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				tmplLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				tmplLoader.addEventListener(ErrorEvent.ERROR, errorHandler);
				tmplLoader.load(xmlFile)
			}
			// Handle cases 2 and 6
			else
			{
				if (designer.selectedIndex == -1)
				{
					deactivateButton(Next_Button2);
				}
				else
				{
					activateButton(Next_Button2);
					Next_Button2.addEventListener(MouseEvent.CLICK, designerNextHandler);
				}
				Back_Button2.addEventListener(MouseEvent.CLICK, designerBackHandler);
				addChild(designer);
			}
			
			// send a message to the containing page that a poster is in-progress, so
			// the user should be warned before trying to navigate away from the page
			if (ExternalInterface.available)
			{
				ExternalInterface.call("posterStarted");
			}
		}
		
		private function _designerSelectionHandler(e:Event):void
		{
			removeEventListener(ThumbPanel.POSTER_CHANGE, _designerSelectionHandler);
			activateButton(Next_Button2);
			//Next_Button2.visible = true;
			Next_Button2.addEventListener(MouseEvent.CLICK, designerNextHandler);
		}
		
		private function _enterQuestionScreen():void
		{
			deactivateButton(Next_Button1);
			Next_Button1.addEventListener(MouseEvent.CLICK, questionsNextHandler);
			if (!questionsInitialized)
			{
				_setupQuestionRadios();
				questionsInitialized = true;
			}
			else
			{
				// wiping out and rebuilding the RadioButtonGroups with these two calls seems to 
				// be the only way to consistently have the remembered choices show up.
				//_setupQuestionRadios_RemoveListeners();
				//_setupQuestionRadios_AddListeners();
				_setupQuestionRadios();
				RadioButtonGroup.getGroup("HIVorSTD").selectedData     = prev_HIVorSTD;
				RadioButtonGroup.getGroup("GROUP").selectedData        = prev_GROUP;
				RadioButtonGroup.getGroup("RACEorETHNIC").selectedData = prev_RACEorETHNIC;
			}
		}
		
		private function _setupQuestionRadios():void
		{
			var buttons:Array = [
				STDs_Radio, HIV_Radio,
				MSM_Radio, Heterosexual_Radio, IVDrugUsers_Radio, Youth_Radio,
				Caucasian_Radio, AfricanAmerican_Radio, Hispanic_Radio, NativeAmerican_Radio, Other_Radio
			];

			var embed:Boolean = Config.textFormats.embedFonts;
			var tf:TextFormat = Config.textFormats.questions;
			var dtf:TextFormat = Config.textFormats.empty;
			for each (var oneBtn:RadioButton in buttons)
			{
				oneBtn.setStyle('embedFonts', embed);
				oneBtn.setStyle('textFormat', tf);
				oneBtn.setStyle('disabledTextFormat', dtf);
			}

			tf = Config.textFormats.questionEcho;
			HIVorSTD_text.defaultTextFormat = tf;
			HIVorSTD_text.embedFonts = embed;
			GROUP_text.defaultTextFormat = tf;
			GROUP_text.embedFonts = embed;
			RACEorETHNIC_text.defaultTextFormat = tf;
			RACEorETHNIC_text.embedFonts = embed;
			RACEorETHNIC_text.multiline = true;
			RACEorETHNIC_text.wordWrap = true;

			// make a blank slate, then reset everything
			_setupQuestionRadios_RemoveListeners();
			_setupQuestionRadios_AddListeners();
		}
		
		private function _setupQuestionRadios_AddListeners():void
		{
			var gHIVorSTD:RadioButtonGroup     = RadioButtonGroup.getGroup("HIVorSTD");
			gHIVorSTD.addRadioButton(STDs_Radio);
			gHIVorSTD.addRadioButton(HIV_Radio);
			gHIVorSTD.addEventListener(Event.CHANGE, _update_HIVorSTD);

			var gGROUP:RadioButtonGroup        = RadioButtonGroup.getGroup("GROUP");
			gGROUP.addRadioButton(MSM_Radio);
			gGROUP.addRadioButton(Heterosexual_Radio);
			gGROUP.addRadioButton(IVDrugUsers_Radio);
			gGROUP.addRadioButton(Youth_Radio);
			gGROUP.addEventListener(Event.CHANGE, _update_GROUP);

			var gRACEorETHNIC:RadioButtonGroup = RadioButtonGroup.getGroup("RACEorETHNIC");
			gRACEorETHNIC.addRadioButton(Caucasian_Radio);
			gRACEorETHNIC.addRadioButton(AfricanAmerican_Radio);
			gRACEorETHNIC.addRadioButton(Hispanic_Radio);
			gRACEorETHNIC.addRadioButton(NativeAmerican_Radio);
			gRACEorETHNIC.addRadioButton(Other_Radio);
			gRACEorETHNIC.addEventListener(Event.CHANGE, _update_RACEorETHNIC);
		}

		private function _setupQuestionRadios_RemoveListeners():void
		{
			var gHIVorSTD:RadioButtonGroup     = RadioButtonGroup.getGroup("HIVorSTD");
			var gGROUP:RadioButtonGroup        = RadioButtonGroup.getGroup("GROUP");
			var gRACEorETHNIC:RadioButtonGroup = RadioButtonGroup.getGroup("RACEorETHNIC");
			for each (var g:RadioButtonGroup in [gHIVorSTD, gGROUP, gRACEorETHNIC])
			{
				while (g.numRadioButtons > 0)
				{
					g.removeRadioButton(g.getRadioButtonAt(0));
				}
			}
			gHIVorSTD.removeEventListener(Event.CHANGE, _update_HIVorSTD);
			gGROUP.removeEventListener(Event.CHANGE, _update_GROUP);
			gRACEorETHNIC.removeEventListener(Event.CHANGE, _update_RACEorETHNIC);
		}
		
		//function for updating the 'HIVorSTD' group of radio buttons
		private function _update_HIVorSTD(e:Event):void
		{
			HIVorSTD_text.text = e.target.selection.label; // sets dynamic text to radio label
			HIVorSTD_string =  e.target.selection.value; // sets string for filepath calc.
			_updateFilePath() //update the filepath. In each function incase the user changes an answer.
		}
		
		//function for updating the 'GROUP' group of radio buttons (uses same methods as previous)
		private function _update_GROUP(e:Event):void
		{
			GROUP_text.text = e.target.selection.label;
			GROUP_string = e.target.selection.value;
			_updateFilePath()
		}
		//function for updating the 'RACEorETHNIC' group of radio buttons (uses same methods as previous)
		private function _update_RACEorETHNIC(e:Event):void
		{
			RACEorETHNIC_text.text = e.target.selection.label;
			RACEorETHNIC_string = e.target.selection.value;
			_updateFilePath()
		}
		
		private function _paperTypeSelectedHandler(e:Event):void
		{
			//PaperType.removeEventListener(Event.CHANGE, _paperTypeSelectedHandler);
			paperTypeIndex = PaperType.selectedIndex;
			activateButton(Next_Button3);
			//Next_Button3.visible = true;
		}
		
		private function _quantityChangeHandler(e:Event):void
		{
			quantityValue = Quantity.value;
		}
		
		private function _updateFilePath()
		{
			//creates the filepath string.
			FileName = HIVorSTD_string + "_" + GROUP_string + "_" + RACEorETHNIC_string + ".xml";
			// The following is used to make the next button visible once the user makes a selection from each group.
			if (HIVorSTD_string == "" || GROUP_string == "" || RACEorETHNIC_string == "")
			{
				deactivateButton(Next_Button1);
				//Next_Button1.visible = false;
			}
			else
			{
				activateButton(Next_Button1);
				//trace(FileName);
				//Next_Button1.visible = true;
			}
		}

		private function _centerLoader():void
		{
			curLoad.x = loaderLeftMargin + Math.floor(((Config.stageSize.width - loaderLeftMargin) - curLoad.width) / 2);
			curLoad.y = 225;
			loaderText.x = loaderLeftMargin + Math.floor(((Config.stageSize.width - loaderLeftMargin) - loaderText.textWidth) / 2);
			loaderText.y = 260;
		}
		
		private function _gatherUserInfo():void
		{
			// populate the userInfo object with the needed fields. if one wasn't passed in the 
			// FlashVars, put a blank string in its place
			userInfo = new Object();
			var neededKeys:Array = ['name', 'id', 'address', 'city', 'state', 'zip', 'email', 'affiliation', 'phone', 'ordered', 'surveydone', 'sessionid'];
			var flashVars:Object = LoaderInfo(this.root.loaderInfo).parameters;
			for each (var key:String in neededKeys)
			{
				userInfo[key] = (key in flashVars) ? flashVars[key] : "";
			}
			postersOrdered = new Array();
		}
		
		private function activateButton(b:SimpleButton):void
		{
			b.enabled = true;
			b.mouseEnabled = true;
			b.useHandCursor = true;
			b.alpha = 1;
		}
		
		private function deactivateButton(b:SimpleButton):void
		{
			b.enabled = false;
			b.mouseEnabled = false;
			b.useHandCursor = false;
			b.alpha = 0.6;
		}
		
		private function runLater(func:Function):void
		{
			if (func != null)
			{
				queuedFunctions.push(func);
				if (stage != null)
				{
					addEventListener(Event.RENDER, _runLaterDispatcher);
					stage.invalidate();
				}
				else
				{
					addEventListener(Event.ADDED_TO_STAGE, _runLaterStageHandler);
				}
			}
		}
		
		private function _runLaterStageHandler(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, _runLaterStageHandler);
			addEventListener(Event.RENDER, _runLaterDispatcher);
			stage.invalidate();
		}
		
		private function _runLaterDispatcher(e:Event):void
		{
			removeEventListener(Event.RENDER, _runLaterDispatcher);
			
			var toRun:Array = new Array();
			while (queuedFunctions.length > 0)
			{
				toRun.push(queuedFunctions.shift());
			}
			
			for each (var func:Function in toRun)
			{
				func();
			}
		}
	}
}
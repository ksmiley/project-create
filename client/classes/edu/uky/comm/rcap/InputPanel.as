package edu.uky.comm.rcap
{
	import flash.display.Sprite;
	import flash.display.Shape;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.text.TextField;
	
	import fl.containers.ScrollPane;
	import fl.controls.ScrollPolicy;
	import fl.controls.ComboBox;
	import fl.controls.RadioButtonGroup;
	import fl.events.ComponentEvent;
	import fl.data.DataProvider;
	
	import com.yahoo.astra.fl.controls.TabBar;
	
	import edu.uky.comm.rcap.PosterTemplateSet;
	import edu.uky.comm.rcap.PosterTemplate;
	import edu.uky.comm.rcap.PosterTextArea;
	import edu.uky.comm.rcap.MessageRadioCluster;
	import edu.uky.comm.rcap.Message;
	import edu.uky.comm.rcap.MessageSource;
	import edu.uky.comm.rcap.MessageChangeEvent;
	import edu.uky.comm.rcap.CustomCellRenderer;
	
	public class InputPanel extends Sprite
	{
		private static const PAPER_PROMPT:String = "Select paper size…";
		private static const MESSAGE_PROMPT:String = "Enter custom text…";
		private static const COMBO_SPACING:Number = 15;
		private static const SCROLLER_GUTTER:Number = 5;
		
		// custom events. first is dispatched when the user changes the poster size,
		// second is dispatched when the user changes one of the text areas, either
		// by typing or by clicking a radio button
		public static const SIZE_CHANGE:String = "rcapSizeChange";
		public static const TEXT_CHANGE:String = "rcapTextChange";
		
		var _sizeCombo:ComboBox;
		var _scroller:ScrollPane;
		var _tabBar:TabBar;
		var _tabData:DataProvider;
		var _tabState:Dictionary;
		var _helpText:TextField;
		var _clusters:Array;
		var _clusterId:Array;
		var _textFormats:Object;
		var _contentWidth:Number;
		var _originalWidth:Number;
		var _originalHeight:Number;
		
		var _curSet:PosterTemplateSet;
		//var _messages:Array;
		
		public function InputPanel():void
		{
			_clusters = new Array();
			_clusterId = new Array();
			//_messages = new Array();
			_textFormats = new Object();
			_tabState = new Dictionary(true);   // using weak keys
			
			_createComponents();
		}
		
		public function get templateSet():PosterTemplateSet
		{
			return _curSet;
		}
		
		public function set templateSet(value:PosterTemplateSet):void
		{
			if (value !== _curSet)
			{
				_saveTabState();   // before changing, record which panes are open in the current set
				_curSet = value;
				// remove the paper options in the combo box and put in new ones
				_sizeCombo.removeAll();
				for each (var poster:PosterTemplate in _curSet.templates)
				{
					_sizeCombo.addItem({label: poster.label, data: poster});
				}
				_sizeCombo.selectedIndex = _curSet.currentIndex;

				// the size combo should only be displayed if there is more than
				// one option for paper size. add the combo if this template set
				// has multiple options and the combo isn't on the stage. or, 
				// remove it if this template set has only one option and the
				// combo is currently on the stage. if either happens, calling
				// setSize() will adjust component placement.
				if (_curSet.templates.length > 1 && !contains(_sizeCombo))
				{
					addChild(_sizeCombo);
					_repositionComponents();
				}
				else if (_curSet.templates.length == 1 && contains(_sizeCombo))
				{
					removeChild(_sizeCombo);
					_repositionComponents();
				}
				
				// this will match MessageGroup objects to the textareas in the poster template
				// and create all the associated radio buttons and accordian panes
				_rebuildMessageDisplay();
			}
		}
		
		public function get textFormats():Object
		{
			return _textFormats;
		}
		
		public function set textFormats(value:Object):void
		{
			if (value != null && value !== _textFormats)
			{
				_textFormats = value;
				// format the combo box. if the number of steps it takes to apply the text formatting
				// seems ridiculous, it's because it is.
				if ('embedFonts' in _textFormats)
				{
					_sizeCombo.setStyle('embedFonts', _textFormats.embedFonts);
					_sizeCombo.dropdown.setStyle('embedFonts', _textFormats.embedFonts);
					_sizeCombo.textField.setStyle('embedFonts', _textFormats.embedFonts);
					_tabBar.setRendererStyle('embedFonts', _textFormats.embedFonts);
					if (_helpText)
					{
						_helpText.embedFonts = _textFormats.embedFonts;
					}
				}
				if ('paperSelector' in _textFormats)
				{
					_sizeCombo.setStyle('textFormat', _textFormats.paperSelector);
					_sizeCombo.dropdown.setStyle('textFormat', _textFormats.paperSelector);
					_sizeCombo.textField.setStyle('textFormat', _textFormats.paperSelector);
					_sizeCombo.dropdown.setStyle('cellRenderer', CustomCellRenderer);
					//setSize(width, height);  // reposition components, in case the combo box changed size
				}
				if ('tabLabel' in _textFormats)
				{
					_tabBar.setStyle('textFormat', _textFormats.tabLabel);
					_tabBar.setStyle('selectedTextFormat', _textFormats.tabLabel);
				}
				if ('helpMsg' in _textFormats && _helpText)
				{
					_helpText.setTextFormat(_textFormats.helpMsg);
					_helpText.defaultTextFormat = _textFormats.helpMsg;
				}
				
				for each (var cluster:MessageRadioCluster in _clusters)
				{
					cluster.textFormats = _textFormats;
				}
				
				_updateScrollerLater();
			}
		}
		
		override public function set width(value:Number):void
		{
			if (value != width)  setSize(value, height);
		}
		
		override public function set height(value:Number):void
		{
			if (value != height)  setSize(width, value);
		}
		
		public function setSize(newWidth:Number, newHeight:Number):void
		{
			if (newWidth > 0 && newHeight > 0)
			{
				// stash away the calling values for height and width, so they 
				// can be used by _respositionComponents() without altering
				// the dimensions on accident.
				_originalWidth = newWidth;
				_originalHeight = newHeight;

				var curY:Number = 0;
				
				// resize the combo box, if it's currently shown
				if (contains(_sizeCombo))
				{
					_sizeCombo.width = newWidth; // - _scroller.verticalScrollBar.width;
					_sizeCombo.x = 0;
					_sizeCombo.y = curY;
					curY = _sizeCombo.height + COMBO_SPACING;
				}
				
				if (_helpText && contains(_helpText))
				{
					_helpText.width = newWidth;
					_helpText.x = 0;
					_helpText.y = curY;
					curY = curY + _helpText.textHeight + COMBO_SPACING;
				}

				_tabBar.width = newWidth - 10;
				_tabBar.x = 5;
				_tabBar.y = curY;
				curY = curY + _tabBar.height;
				
				// resize the scrollpane
				_scroller.width = newWidth;
				_scroller.x = 0;
				_scroller.y = curY;
				_scroller.height = newHeight - _scroller.y;
				
				// resize everything inside the scrollpane, and save the width for when new
				// panes and clusters are created
				var gutter:Number = SCROLLER_GUTTER;
				if ('inputScrollerGutter' in Config)
				{
					gutter = Config.inputScrollerGutter * 3;
				}
				_contentWidth = newWidth - _scroller.verticalScrollBar.width - gutter;
				for each (var cluster:MessageRadioCluster in _clusters)
				{
					cluster.width = _contentWidth;
				}
			}
		}

		private function _repositionComponents():void
		{
			setSize(_originalWidth, _originalHeight);
		}

		private function _createComponents():void
		{
			_scroller = new ScrollPane();
			_scroller.scrollDrag = false;
			if ('inputScrollerSkin' in Config)
			{
				var scrollerSkin:DisplayObject = new (Config.inputScrollerSkin)();
				_scroller.setStyle("skin", scrollerSkin);
				_scroller.setStyle("upSkin", scrollerSkin);
			}
			if ('inputScrollerGutter' in Config)
			{
				_scroller.setStyle("contentPadding", Config.inputScrollerGutter);
			}
			_scroller.horizontalScrollPolicy = ScrollPolicy.OFF;
			_scroller.verticalScrollPolicy = ScrollPolicy.AUTO;
			addChild(_scroller);
			
			_tabData = new DataProvider();
			
			_tabBar = new TabBar();
			_tabBar.autoSizeTabsToTextWidth = false;
			_tabBar.dataProvider = _tabData;
			_tabBar.addEventListener(Event.CHANGE, _tabChangeHandler);
			addChild(_tabBar);
			
			// create the size selector, but don't add until we know it's needed
			_sizeCombo = new ComboBox();
			_sizeCombo.prompt = PAPER_PROMPT;
			_sizeCombo.editable = false;
			_sizeCombo.addEventListener(Event.CHANGE, _sizeComboChangeHandler);
			//addChild(_sizeCombo);
			
			if ('inputPanelMessage' in Config && Config.inputPanelMessage != "")
			{
				_helpText = new TextField();
				_helpText.text = Config.inputPanelMessage;
				_helpText.selectable = false;
				_helpText.mouseEnabled = false;
				addChild(_helpText);
			}
		}
		
		// clear out existing MessageRadioClusters and the accordian structure and rebuild it using the
		// settings in the current template set. mostly called when the template set changes, but 
		// might be called after a size change if the text areas changed between sizes
		private function _rebuildMessageDisplay():void
		{
			// clear out the existing radio clusters and reset tabs
			_clusters.splice(0);  // delete all the radio clusters
			_clusterId.splice(0);
			_tabData.removeAll();
			_scroller.source = null;
			
			// make sure there's something to add. if no current template is defined,
			// there are no textareas to match against
			if (_curSet == null || _curSet.current == null)
			{
				_updateScrollerLater();  // still need to do this, since the pane changed
				return;
			}
			
			// look at each textarea in the template, then look at the template set for the MessageGroup
			// associated with the id of that textarea
			for each (var area:PosterTextArea in _curSet.current.textAreas)
			{
				// every text area in the PosterTemplateSet should be in the messageMap, but check
				// just to be safe
				if (area.id in _curSet.messageMap && _curSet.messageMap[area.id].group != null)
				{
					// duplicate the message list from the associated group so a user-supplied message
					// can be added to the end, if one is defined
					var msgList:Array = _curSet.messageMap[area.id].group.messages.slice();
					var current:Message = _curSet.messageMap[area.id].current;
					var userMsg:Message = _curSet.messageMap[area.id].user;
					if (userMsg != null)  msgList.push(userMsg);
					
					// pass the message list to a MessageRadioCluster, which will format the messages 
					// into radio buttons. this is where the user will change poster text, so listen for
					// the change events
					var newCluster:MessageRadioCluster = new MessageRadioCluster(msgList);
					newCluster.defaultLabel = MESSAGE_PROMPT;
					newCluster.textFormats = _textFormats;
					newCluster.width = _contentWidth
					// selection has to be set before adding the event listener. otherwise, the change triggers
					// the event, which is likely to fail because the data structures aren't filled yet
					if (current != null)  newCluster.selection = current;
					newCluster.addEventListener(Event.CHANGE, _clusterChangeHandler);
					//newCluster.addEventListener(ComponentEvent.LABEL_CHANGE, _clusterLabelChangeHandler);
					_clusters.push(newCluster);
					_clusterId.push(area.id);
					
					_tabData.addItem({label: area.label, data: newCluster});
				}
			}
			// select one of the tabs and put the associated radios into the
			// scrollpane. if state is saved for this template set, use the
			// user's previous selection, or default to the first textarea.
			if (_curSet in _tabState)
			{
				_tabBar.selectedIndex = _tabState[_curSet];
			}
			else
			{
				_tabBar.selectedIndex = 0;
			}
			_scroller.source = _tabData.getItemAt(_tabBar.selectedIndex).data;
			
			// make the scroll bar update
			_updateScrollerLater();
		}

		// this should be called before _rebuildMessageDisplay, but before the template set changes,
		// to save the open/close state of the accordian panes. the state will be used if the 
		// template set is loaded again, so that the same panes are expanded
		private function _saveTabState():void
		{
			_tabState[_curSet] = _tabBar.selectedIndex;
		}
		
		// When the height of the content inside the scrollpane changes (which it does
		// anytime the selected tab changes), the pane has to be told to update its 
		// scrollbars. but if it's told to do that too early, it gets it wrong, maybe
		// because the content hasn't settled on a final size yet.
		// About the only way I've found to make the scrollpane reliably find the size is to
		// delay the update by a frame, so the content gets rendered at the right size during
		// the RENDER event of this frame, then the scrollbar gets updated during ENTER_FRAME
		// of the next one. this introduced a slight delay in the update, but unless the frame
		// rate is set low, it's barely noticable. One catch: this whole process only works
		// if the stage is available.
		// This function starts this delayed update, by registering for RENDER if there is a
		// stage, or otherwise waiting for the stage
		private function _updateScrollerLater():void
		{
			if (stage != null)
			{
				stage.addEventListener(Event.RENDER, _renderHandler);
				stage.invalidate();
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, _stageAddedHandler);
			}
		}
		
		private function _sizeComboChangeHandler(e:Event):void
		{
			var prevIndex:int = _curSet.currentIndex;
			_curSet.currentIndex = _sizeCombo.selectedIndex;
			// check to see if the message radio buttons need to be rebuilt. usually, they won't need to,
			// since most template sets should have the same textareas in every template. that's not a 
			// requirement, though, so check that the textareas in the previous and current selection
			// match up in size and in the ID of the textareas at each position
			var needRebuild:Boolean = false;
			if (_curSet.templates[prevIndex].textAreas.length != _curSet.current.textAreas.length)
			{
				needRebuild = true;
			}
			else
			{
				var oldAreas:Array = _curSet.templates[prevIndex].textAreas;
				var newAreas:Array = _curSet.current.textAreas;
				for (var i:int = 0; i < newAreas.length; i++)
				{
					if (oldAreas[i].id != newAreas[i].id)
					{
						needRebuild = true;
						break;
					}
				}
			}
			// if something didn't match up, rebuild the message radios and accordian
			if (needRebuild)
			{
				_saveTabState();
				_rebuildMessageDisplay();
			}
			
			dispatchEvent(new Event(InputPanel.SIZE_CHANGE, true));
		}
		
		// user changed the selected message in one of the clusters, either by clicking a different
		// radio button or but typing something in a textfield. figure out which cluster it was
		// and what textArea id is associated with it and send out the new message as a MessageChangeEvent
		private function _clusterChangeHandler(e:Event):void
		{
			// the radio button CHANGE events bubble, so they get caught by this handler and need to be filtered out
			//if (e.target !== e.currentTarget)  return;
			var cluster:MessageRadioCluster = e.currentTarget as MessageRadioCluster;
			var idx:int;
			for (idx = 0; idx < _clusters.length; idx++)
			{
				if (_clusters[idx] === cluster)  break;
			}
			// update the template set to reflect the message choice
			_curSet.messageMap[ _clusterId[idx] ].current = cluster.selection;
			dispatchEvent(new MessageChangeEvent(InputPanel.TEXT_CHANGE, true, false, _clusterId[idx], cluster.selection));
		}
		
		/*private function _clusterLabelChangeHandler(e:ComponentEvent):void
		{
			
		}*/
		
		private function _tabChangeHandler(e:Event):void
		{
			//if (e.target !== e.currentTarget)  return;
			_scroller.source = _tabData.getItemAt(_tabBar.selectedIndex).data;
			_updateScrollerLater();
		}

		// the panel is now on the stage, so register for the RENDER handler, when the
		// scrollpane content will get updapted
		private function _stageAddedHandler(e:Event):void
		{
			if (stage != null)
			{
				removeEventListener(Event.ADDED_TO_STAGE, _stageAddedHandler);
				stage.addEventListener(Event.RENDER, _renderHandler);
				stage.invalidate();
			}
		}
		
		// during the render event, the content is probably updating itself. since its
		// size might not be finalized yet, the scrollbars will get updated in the next
		// frame, so stop listening for RENDER and start listening for ENTER_FRAME
		private function _renderHandler(e:Event):void
		{
			if (stage != null)
			{
				stage.removeEventListener(Event.RENDER, _renderHandler);
				stage.addEventListener(Event.ENTER_FRAME, _frameHandler);
			}
			else
			{
				addEventListener(Event.ADDED_TO_STAGE, _stageAddedHandler);
			}
		}
		
		// new frame is being drawn, finally time to update the scrollpane
		private function _frameHandler(e:Event):void
		{
			if (stage != null)  stage.removeEventListener(Event.ENTER_FRAME, _frameHandler);
			if (_scroller != null)  _scroller.update();
		}
	}
}
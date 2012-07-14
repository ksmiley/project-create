package edu.uky.comm.rcap
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import edu.uky.comm.rcap.ThumbPanel;
	import edu.uky.comm.rcap.PreviewPanel;
	import edu.uky.comm.rcap.InputPanel;
	import edu.uky.comm.rcap.RenderPreview;
	import edu.uky.comm.rcap.PosterTemplateSet;
	import edu.uky.comm.rcap.PosterTemplate;
	import edu.uky.comm.rcap.Config;
	import edu.uky.comm.rcap.Message;
	import edu.uky.comm.rcap.MessageGroup;
	import edu.uky.comm.rcap.MessageSource;
	import edu.uky.comm.rcap.MessageChangeEvent;
	
	public class PosterMaker extends Sprite
	{
		private var _thumbs:ThumbPanel;
		private var _preview:PreviewPanel;
		private var _input:InputPanel;
		private var _renderers:Array;
		private var _instructions:DisplayObject;
		
		private var _tmplSets:Array;
		private var _messages:Array;
		private var _curIdx:int;
		
		public function PosterMaker(templates:Array, messages:Array):void
		{
			_tmplSets = templates;
			_messages = messages;
			
			if (Config.allowUserMessages)  _addUserMessages();
			
			_curIdx = -1;
			_renderers = new Array();
			_createRenderers();
			_createPanels();
		}
		
		public function get selectedIndex():int
		{
			return _curIdx;
		}
		
		public function get selectedRenderer():RenderPreview
		{
			return (_curIdx >= 0) ? _renderers[_curIdx] : null;
		}
		
		public function get selectedTemplate():PosterTemplate
		{
			return (_curIdx >= 0) ? _tmplSets[_curIdx].current : null;
		}
		
		private function _addUserMessages():void
		{
			for each (var tmplSet:PosterTemplateSet in _tmplSets)
			{
				for each (var msgSetting:Object in tmplSet.messageMap)
				{
					msgSetting.user = new Message("", MessageSource.USER);
				}
			}
		}
		
		private function _createRenderers():void
		{
			for each (var set:PosterTemplateSet in _tmplSets)
			{
				set.currentIndex = 0;
				var newRend:RenderPreview = new RenderPreview(Config.renderWidth, Config.renderHeight, set.templates[0]);
				_renderers.push(newRend);
			}
		}
		
		private function _createPanels():void
		{
			_thumbs = new ThumbPanel();
			_thumbs.x = Config.thumbPosition.x;
			_thumbs.y = Config.thumbPosition.y;
			_thumbs.height = Config.thumbPosition.height;
			_thumbs.renderers = _renderers;
			_thumbs.addEventListener(ThumbPanel.POSTER_CHANGE, _posterChangeHandler);
			addChild(_thumbs);
			
			_preview = new PreviewPanel();
			_preview.zoomable = Config.allowPreviewZoom;
			_preview.x = Config.previewPosition.x;
			_preview.y = Config.previewPosition.y;
			_preview.setSize(Config.previewPosition.width, Config.previewPosition.height);
			//addChild(_preview);
			
			_input = new InputPanel();
			_input.x = Config.inputPosition.x;
			_input.y = Config.inputPosition.y;
			_input.setSize(Config.inputPosition.width, Config.inputPosition.height);
			_input.textFormats = Config.textFormats;
			//_input.setMessages(_messages);
			//_input.templateSet = _tmplSets;
			_input.addEventListener(InputPanel.SIZE_CHANGE, _sizeChangeHandler);
			_input.addEventListener(InputPanel.TEXT_CHANGE, _textChangeHandler);
			//addChild(_input);
			
			// initially the preview and input panels won't be displayed. instead, show some
			// be some text telling the user to select a thumbnail. the text will be centered 
			// in the space where the panels will go, but to calculate that, the stage
			// needs to be available
			_instructions = new (Config.startInstructions)();
			addEventListener(Event.ADDED_TO_STAGE, _stageAddedHandler);
			addChild(_instructions);
		}
		
		private function _stageAddedHandler(e:Event):void
		{
			// stage is available, so center the instructions
			removeEventListener(Event.ADDED_TO_STAGE, _stageAddedHandler);
			if (contains(_instructions))
			{
				var shiftedX:Number = _thumbs.x + _thumbs.width;
				var availWidth:Number = stage.stageWidth - shiftedX;
				_instructions.x = Math.floor((availWidth - _instructions.width) / 2) + shiftedX;
				_instructions.y = Math.floor((stage.stageHeight - _instructions.height) / 2);
			}
		}
		
		private function _posterChangeHandler(e:Event):void
		{
			// the first time the user picks a thumbnail, hide the instructions and display
			// the preview and input panels
			if (contains(_instructions))
			{
				removeChild(_instructions);
				addChild(_preview);
				addChild(_input);
			}
			_curIdx = _thumbs.selection;
			_preview.renderer = _renderers[_curIdx];
			_input.templateSet = _tmplSets[_curIdx];
		}
		
		private function _sizeChangeHandler(e:Event):void
		{
			_renderers[_curIdx].source = _tmplSets[_curIdx].current;
			_preview.renderer = _renderers[_curIdx];
			_thumbs.updateSelected();
		}
		
		private function _textChangeHandler(e:MessageChangeEvent):void
		{
			_renderers[_curIdx].updateText(e.textId);
			_thumbs.updateSelected();
		}
	}
}

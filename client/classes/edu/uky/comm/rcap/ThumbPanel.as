﻿package edu.uky.comm.rcap{	import flash.display.DisplayObject;	import flash.display.InteractiveObject;	import flash.display.Sprite;	import flash.events.MouseEvent;	import flash.events.Event;		import edu.uky.comm.rcap.PreviewThumbnail;	import edu.uky.comm.rcap.RenderPreview;		public class ThumbPanel extends Sprite	{		public static const POSTER_CHANGE:String = "rcapPosterChange";				private static const DEFAULT_THUMBS_PER_PAGE:Number = 4;		private static const DEFAULT_GUTTER:Number = 5;		private static const DEFAULT_BACKER_REGULAR:Class  = ThumbBacker;		private static const DEFAULT_BACKER_SELECTED:Class = ThumbBackerSelected;		private static const UP_ARROW_CLASS:Class = ThumbUpArrow;		private static const DOWN_ARROW_CLASS:Class = ThumbDownArrow;				private var _renderers:Array;  // holds RenderPreview instances				private var _selection:int;		private var _thumbsPerPage:int;		private var _curPage:int;				private var _regBackerClass:Class;		private var _selBackerClass:Class;				private var _regThumbs:Array;  // holds PreviewThumbnail instances		private var _selThumb:PreviewThumbnail;		private var _selThumbPos:int;		private var _upArrow:InteractiveObject;		private var _downArrow:InteractiveObject;		private var _gutter:Number;		private var _yOffset:Number = 0;				public function ThumbPanel(gutter:Number = DEFAULT_GUTTER, regularBacker:Class = null, selectedBacker:Class = null):void		{			_gutter = gutter;			_regBackerClass = (regularBacker  == null) ? DEFAULT_BACKER_REGULAR  : regularBacker;			_selBackerClass = (selectedBacker == null) ? DEFAULT_BACKER_SELECTED : selectedBacker;						_upArrow = new UP_ARROW_CLASS();			_upArrow.addEventListener(MouseEvent.CLICK, _arrowClickHandler);			_downArrow = new DOWN_ARROW_CLASS();			_downArrow.addEventListener(MouseEvent.CLICK, _arrowClickHandler);						_thumbsPerPage = DEFAULT_THUMBS_PER_PAGE;			_curPage  = 0;			_selection = -1;						_regThumbs = new Array();			_renderers = new Array();						_makeThumbBackers();		}				public function get selection():int		{			return _selection;		}				public function set selection(value:int):void		{			if (value != _selection)			{				_selection = value;				var page:int = Math.floor(_selection / _thumbsPerPage);				if (value >= 0 && _curPage == page)				{					var pos:int = _selection - (page * _thumbsPerPage);					_swapSelThumb(pos);					_selThumb.source = _renderers[_selection];				}				dispatchEvent(new Event(ThumbPanel.POSTER_CHANGE, true));			}		}				public function get renderers():Array		{			return _renderers;		}				public function set renderers(sets:Array):void		{			if (sets != null)			{				// renderer list is changing, so reset page counts and clear the old				// render objects from the various thumbnails				_curPage = 0;				_selection = -1;				for each (var thumb:PreviewThumbnail in _regThumbs)				{					thumb.source = null;				}				_swapSelThumb(-1);				_selThumb.source = null;				// now pull in the new list and populate the thumbs from it				_renderers = sets;				_populateThumbs();			}		}				override public function set height(value:Number):void		{			if (value != height)			{				var thumbHeight:Number = _selThumb.height;				var maxThumbsPerPage:Number = Math.floor((value - _gutter - 2 * _upArrow.height) / (thumbHeight + _gutter));				if (_thumbsPerPage != Math.min(_thumbsPerPage, maxThumbsPerPage))				{					_thumbsPerPage = Math.min(_thumbsPerPage, maxThumbsPerPage);					_makeThumbBackers();   // number of needed objects changed, so rebuild them				}				var totalHeight:Number = _thumbsPerPage * (thumbHeight + _gutter) + _gutter + 2 * _upArrow.height;				_yOffset = Math.round((value - totalHeight) / 2);				this.y = this.y + _yOffset;				_placeObjects();				super.height = totalHeight;			}		}				// instructs ThumbPanel to call update() on the PreviewThumbnail object that's currently selected.		// used when the text changes, or the template size changes		public function updateSelected():void		{			if (_selection >= 0)  _selThumb.update();		}				private function _placeObjects():void		{			// make a blank slate			while (numChildren > 0)			{				removeChildAt(0);			}									// calculate initial coordinates			var curY = _yOffset;			var curX = _gutter;			var arrowX = Math.round((_selThumb.width - _upArrow.width) / 2);						// start putting objects down			addChild(_upArrow);			_upArrow.x = arrowX;			_upArrow.y = curY;			curY += _upArrow.height + _gutter;			for each (var thumb:PreviewThumbnail in _regThumbs)			{				thumb.x = curX;				thumb.y = curY;				addChild(thumb);				curY += thumb.height + _gutter;			}			_downArrow.x = arrowX;			_downArrow.y = curY;			addChild(_downArrow);						width = _selThumb.width + _gutter * 2;		}				private function _populateThumbs():void		{			// first determine which if either (or both) of the arrows need to be displayed			var totalPages:Number = Math.ceil(_renderers.length / _thumbsPerPage);			_upArrow.visible   = (_curPage != 0);			_downArrow.visible = (_curPage != totalPages - 1);						for (var i:int = 0; i < _thumbsPerPage; i++)			{				// figure out the _renderers array index corresponding to this thumb position				var curIdx:int = (_curPage * _thumbsPerPage) + i;								// selected thumb is displayed in the current position and shouldn't be, so swap out				if (i == _selThumbPos && curIdx != _selection)				{					_swapSelThumb(-1);  // -1 means remove it, don't place in a new position				}								if (curIdx < _renderers.length)				{					if (curIdx == _selection)					{						_swapSelThumb(i);  // make the current thumb position have the selected thumb						_selThumb.source = _renderers[curIdx];					}					else					{						_regThumbs[i].visible = true;					}					// place the renderer into the regular thumb regardless of whether it's visible					// because it'll get swapped in if the user changes the selection					_regThumbs[i].source = _renderers[curIdx];				}				else				{					_regThumbs[i].visible = false;					_regThumbs[i].source  = null;				}			}		}				private function _swapSelThumb(pos:int):void		{			// selected thumb is already in another position, so first remove it from there			if (_selThumbPos >= 0 && _selThumbPos != pos)			{				removeChild(_selThumb);				addChild(_regThumbs[_selThumbPos]);				_regThumbs[_selThumbPos].update();				_selThumbPos = -1;			}			// if a new thumb is selected, swap it in			if (pos >= 0 && pos < _thumbsPerPage)			{				_selThumbPos = pos;				_selThumb.x = _regThumbs[pos].x;				_selThumb.y = _regThumbs[pos].y;				removeChild(_regThumbs[pos]);				addChild(_selThumb);			}		}				private function _makeThumbBackers():void		{			// delete references to any previous backer objects			_regThumbs.splice();			_selThumb = null;						// now make new ones			for (var i = 0; i < _thumbsPerPage; i++)			{				var newThumb:PreviewThumbnail = new PreviewThumbnail(new _regBackerClass());				newThumb.addEventListener(MouseEvent.CLICK, _thumbClickHandler);				_regThumbs.push(newThumb);			}			_selThumb = new PreviewThumbnail(new _selBackerClass());			_selThumb.mouseEnabled = false;			_selThumb.buttonMode = false;			_selThumbPos = -1;						width = _selThumb.width + 2 * _gutter;		}				private function _arrowClickHandler(e:MouseEvent):void		{			var clickedArrow:InteractiveObject = e.target as InteractiveObject;			var lastPage:Number = Math.ceil(_renderers.length / _thumbsPerPage) - 1;			switch (clickedArrow)			{				case _upArrow:					if (_curPage > 0)  _curPage--;					_populateThumbs();					break;				case _downArrow:					if (_curPage < lastPage)  _curPage++;					_populateThumbs();					break;			}			e.updateAfterEvent();		}				private function _thumbClickHandler(e:MouseEvent):void		{			var clicked:PreviewThumbnail = e.currentTarget as PreviewThumbnail;			var clickedPos:int;			for (var i:int = 0; i < _regThumbs.length; i++)			{				if (clicked === _regThumbs[i])				{					clickedPos = i;					break;				}			}			selection = (_curPage * _thumbsPerPage) + clickedPos;			e.updateAfterEvent();		}	}}
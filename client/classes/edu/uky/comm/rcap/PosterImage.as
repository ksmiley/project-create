﻿package edu.uky.comm.rcap{	import flash.display.BitmapData;	import flash.geom.Matrix;		import edu.uky.comm.rcap.PosterTemplate;	import edu.uky.comm.rcap.PosterImageCrop;		public class PosterImage	{		public var id:String;		public var x:Number;		public var y:Number;		public var width:Number;		public var height:Number;		public var crop:String;		public var sourceFile:String;		public var sourceWidth:String;		public var sourceHeight:String;		public var previewFile:String;		public var previewData:BitmapData;				public var template:PosterTemplate;				public function PosterImage(page:PosterTemplate):void		{			template = page;						crop = PosterImageCrop.NONE;		}				public function clone(page:PosterTemplate = null):PosterImage		{			var cloned:PosterImage = new PosterImage((page == null ? template : page));			var cloneProps:Array = ['id', 'x', 'y', 'width', 'height', 'crop',									'sourceFile', 'sourceWidth', 'sourceHeight', 									'previewFile', 'previewData'];			for each (var prop:* in cloneProps)			{				cloned[prop] = this[prop];			}			return cloned;		}				public function destroy():void		{			template = null;  // prevent circular reference			if (previewData)			{				previewData.dispose();				previewData = null;			}		}				public function get previewX():Number		{			return Math.floor(x * this.template.scaleFactor);		}				public function get previewY():Number		{			return Math.floor(y * this.template.scaleFactor);		}				public function get previewWidth():Number		{			return Math.floor(width * this.template.scaleFactor);		}				public function get previewHeight():Number		{			return Math.floor(height * this.template.scaleFactor);		}				// calculates how much the preview image has to be scaled to make it fit in the preview area, based		// on the current template's scaling factor. the preview image most likely is not the same size		// as the PosterImage height and width properties (since those are the size on the completed poster),		// so the template's scaleFactor won't work.		// previewData must be set to a valid image for this to work. if it isn't, throws an ArgumentError		public function get bitmapScaleFactor():Number		{			// to be safe, make sure the data property has something in it			if (previewData is BitmapData)			{				// these two scales should be the same, if the data was loaded in correctly.				// but again, just to be safe, use the smaller of the two				var xScale:Number = this.previewWidth / previewData.width;				var yScale:Number = this.previewHeight / previewData.height;				return (xScale < yScale) ? xScale : yScale;			}			else			{				// throw an exception if there's no data to work with				throw new ArgumentError("Image's previewData property must be set to calculate bitmap scale factor");			}		}				// returns a scaling matrix already loaded with this image's bitmapScaleFactor.		// previewData must be set to a valid image for this to work. if it isn't, throws an ArgumentError		public function get bitmapScaleMatrix():Matrix		{			var scaleFactor:Number = this.bitmapScaleFactor;			return new Matrix(scaleFactor, 0, 0, scaleFactor);		}	}}
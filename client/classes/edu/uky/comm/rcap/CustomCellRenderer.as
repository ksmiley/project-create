﻿package edu.uky.comm.rcap{	import flash.text.TextFormat;	import fl.controls.listClasses.CellRenderer;	import edu.uky.comm.rcap.Config;	public class CustomCellRenderer extends CellRenderer	{		public function CustomCellRenderer()		{			super();			var embed:Boolean = ('embedFonts'    in Config.textFormats) ? Config.textFormats.embedFonts    : false;			var tf:TextFormat = ('paperSelector' in Config.textFormats) ? Config.textFormats.paperSelector : null;			this.setStyle("embedFonts", embed);			this.setStyle("textFormat", tf);		}	}}
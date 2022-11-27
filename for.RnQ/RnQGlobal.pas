﻿{
  This file is part of R&Q.
  Under same license
}
unit RnQGlobal;
{$I ForRnQConfig.inc}
{$I NoRTTI.inc}

 { $ DEFINE RNQ_PLAYER}

interface
uses
  Forms, Classes, Messages, ExtCtrls, Types,
 {$IFDEF RNQ_PLAYER}
  BASSplayer,
 {$ENDIF RNQ_PLAYER}
//  fxRegistryFile,
//  RQThemes,
//  SXZipUtils,
  Graphics;

const
  eventslogFilename = 'events.log';
  defaultThemePrefix = 'RQ.';
  defaultThemePostfix = 'theme.ini';
  // paths
  themesPath = 'themes\';
  pluginsPath = 'plugins\';
  accountsPath = 'Accounts\';
 {$IFDEF CPUX64}
  modulesPath = 'modules.x64\';
 {$ELSE}
  modulesPath = 'modules\';
 {$ENDIF CPUX64}

  maxPICAVTW = 200;
  maxPICAVTH = 200;
  maxSWFAVTW = 100;
  maxSWFAVTH = 100;

  RnQImageTag = AnsiString('<RnQImage>');
  RnQImageUnTag = AnsiString('</RnQImage>');
  RnQImageExTag = AnsiString('<RnQImageEx>');
  RnQImageExUnTag = AnsiString('</RnQImageEx>');
//  RnQTrayIconGUID: TGUID = '{0629FFDF-0F1A-40A1-BB6F-32942AD6DF17}';

var
  timeformat: record
    chat,
    info,
    clock,
    log,
    automsg: string;
   end;
  logpref: record
    pkts, evts: record
      onFile, onWindow, clear: Boolean;
      end;
    writehistory: Boolean;
   end;


var
  myPath           : String;
  logPath          : String;
  RnQUser          : String;
  RnQMainPath      : String;
//  rqSmiles         : TRQTheme;
  ShowSmileCaption,
  MenuHeightPerm,
  MenuDrawExt,
  bringInfoFrgd,
//  MakeBakups,
 {$IFDEF LANGDEBUG}
  lang_debug,
 {$ENDIF LANGDEBUG}
  disableSounds,
  playSounds,
  showBalloons: Boolean;
  audioPresent     : Boolean = false;
  picDrawFirstLtr  : Boolean = false;
  TranslitList     : TStringList;
  SoundVolume      : Integer;
  TextBGColor      : TColor;

var
 {$IFDEF RNQ_PLAYER}
  RnQbPlayer: TBASSplayer;
 {$ELSE RNQ_PLAYER}
  Soundhndl: THandle;
 {$ENDIF RNQ_PLAYER}

const
  EMAILCHARS      = ['a'..'z','A'..'Z','0'..'9','-','_','.'];

type
  TGroupAction = (GA_None = 0, GA_Add, GA_Rename, GA_Remove);


implementation
   uses
     Windows, Controls;


end.

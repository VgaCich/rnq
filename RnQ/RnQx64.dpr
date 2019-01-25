program RnQx64;

{$WEAKLINKRTTI ON}
{$RTTI EXPLICIT METHODS([]) FIELDS([]) PROPERTIES([])}

{ $I Compilers.inc}
{$I NoRTTI.inc}
{$I RnQConfig.inc}


{$R 'WinXP2.res' 'Res\WinXP2.rc'}
{$R 'stickers.res' 'ICQ\stickers.rc'}

uses
  Windows,
  Forms,
  sysutils,
  controls,
  mainDlg in 'mainDlg.pas' {RnQmain},
  RDGlobal in '..\For.rnq\RTL\RDGlobal.pas',
  RnQBinUtils in '..\For.rnq\RTL\RnQBinUtils.pas',
  RnQGraphics32 in '..\For.rnq\RTL\RnQGraphics32.pas',
  RnQGlobal in '..\For.rnq\RnQGlobal.pas',
  RQUtil in '..\For.rnq\RQUtil.pas',
  RnQLangs in '..\For.rnq\RnQLangs.pas',
  RnQStrings in '..\For.rnq\RnQStrings.pas',
  RQThemes in '..\For.rnq\RQThemes.pas',
  RQmsgs in '..\For.rnq\RQmsgs.pas' {msgsFrm},
  RnQNet in '..\For.rnq\RnQNet.pas',
  RQMenuItem in '..\For.rnq\RQMenuItem.pas',
  RQlog in '..\For.rnq\RQlog.pas' {logFrm},
  RnQDialogs in '..\For.rnq\RnQDialogs.pas',
  RnQPrefsLib in '..\For.rnq\RnQPrefsLib.pas',
  addContactDlg in 'addContactDlg.pas' {addContactFrm},
  roasterLib in 'roasterLib.pas',
  ThemesLib in 'ThemesLib.pas',
  globalLib in 'globalLib.pas',
  history in 'history.pas',
  events in 'events.pas',
  aboutDlg in 'aboutDlg.pas' {aboutFrm},
  selectcontactsDlg in 'selectcontactsDlg.pas' {selectCntsFrm},
  usersDlg in 'usersDlg.pas' {usersFrm},
  iniLib in 'iniLib.pas',
  utilLib in 'utilLib.pas',
  authreqDlg in 'authreqDlg.pas' {authreqFrm},
  changepwddlg in 'changepwddlg.pas' {changePwdFrm},
  {$IFNDEF CHAT_CEF}
  {$IFNDEF CHAT_SCI}
  historyVCL in 'historyVCL.pas' {HistoryData: TDataModule},
  {$ENDIF CHAT_SCI}
  {$ENDIF CHAT_CEF}
  chatDlg in 'chatDlg.pas' {chatFrm},
  pluginLib in 'pluginLib.pas',
  outboxLib in 'outboxLib.pas',
  outboxDlg in 'outboxDlg.pas' {outboxFrm},
  lockDlg in 'lockDlg.pas' {lockFrm},
  uinlistlib in 'uinlistlib.pas',
  automsgDlg in 'automsgDlg.pas' {automsgFrm},
  groupsLib in 'groupsLib.pas',
  langLib in 'langLib.pas',
  pwdDlg in 'pwdDlg.pas' {msgFrm},
  RnQdbDlg in 'RnQdbDlg.pas' {RnQdbFrm},
  menusUnit in 'menusUnit.pas',
  RnQMacros in 'RnQMacros.pas',
  prefDlg in 'prefDlg.pas' {prefFrm},
  connection_fr in 'Prefs\connection_fr.pas' {connectionFr: TFrame},
  start_fr in 'Prefs\start_fr.pas' {startFr: TFrame},
  design_fr in 'Prefs\design_fr.pas' {designFr: TFrame},
  autoaway_fr in 'Prefs\autoaway_fr.pas' {autoawayFr: TFrame},
  security_fr in 'Prefs\security_fr.pas' {securityFr: TFrame},
  hotkeys_fr in 'Prefs\hotkeys_fr.pas' {hotkeysFr: TFrame},
  other_fr in 'Prefs\other_fr.pas' {otherFr: TFrame},
  antispam_fr in 'Prefs\antispam_fr.pas' {antispamFr: TFrame},
  events_fr in 'Prefs\events_fr.pas' {eventsFr: TFrame},
  plugins_fr in 'Prefs\plugins_fr.pas' {pluginsFr: TFrame},
  chat_frOld in 'Prefs\chat_frOld.pas' {chatFr: TFrame},
  update_fr in 'Prefs\update_fr.pas' {updateFr: TFrame},
  tips_fr in 'Prefs\tips_fr.pas' {TipsFr: TFrame},
  themedit_fr in 'Prefs\themedit_fr.pas' {themeditFr: TFrame},
  RnQ_Avatars in 'RnQ_Avatars.pas',
  hook in 'hook.pas',
  RnQTips in 'RnQTips.pas',
  HistAllSearch in 'HistAllSearch.pas' {AllHistSrchForm},
  RnQProtocol in 'RnQProtocol.pas',
  visibilityDlg in 'visibilityDlg.pas' {visibilityFrm},
  Protocols_all in 'Protocols_all.pas',
  NewAccount in 'NewAccount.pas' {NewAccFrm},
  RnQtrayLib in '..\for.RnQ\RnQtrayLib.pas',
  Vcl.Themes,
  Vcl.Styles,
  tipDlg in '..\For.rnq\tipDlg.pas',
  RnQLangFrm in '..\For.rnq\RnQLangFrm.pas' {FrmLangs},
  RDUtils in '..\for.RnQ\RTL\RDUtils.pas',
  {$IFDEF PROTOCOL_ICQ}
  {$ENDIF PROTOCOL_ICQ}
  ViewHEventDlg in 'ViewHEventDlg.pas' {HEventFrm},
  MenuSmiles in '..\for.RnQ\MenuSmiles.pas' {FSmiles},
  RnQConst in 'RnQConst.pas';

{$R *.RES}

//The UnicodeString in Delphi can contain Unicode or ANSI data at any given time,
//  and in order to ensure that C++Builder code can correctly index the items,
//  a hidden call to UniqueStringX is being made.
//If you only create Delphi stand-alone applications,
//  you can avoid these calls with the STRINGCHECKS OFF compiler option:
(* $STRINGCHECKS OFF*)
{$STRINGCHECKS OFF}
// JCL_DEBUG_EXPERT_GENERATEJDBG ON

 { $IFDEF NO_WIN98}
   { $SetPEFlags IMAGE_FILE_RELOCS_STRIPPED}
 { $ENDIF NO_WIN98}
// { $DYNAMICBASE ON}      // ASLR
// { $SETPEOPTFLAGS $100}  //NX
 {$SETPEOPTFLAGS $140} // NX + ASLR
{ $R 'Res\WinXP.res' 'Res\WinXP.rc'}

   { $SetPEFlags IMAGE_FILE_RELOCS_STRIPPED or IMAGE_FILE_DEBUG_STRIPPED
     or IMAGE_FILE_LINE_NUMS_STRIPPED or IMAGE_FILE_LOCAL_SYMS_STRIPPED}
{
IMAGE_FILE_RELOCS_STRIPPED - ������� ������
IMAGE_FILE_DEBUG_STRIPPED - �������� �� ��� Debug ����������
IMAGE_FILE_LINE_NUMS_STRIPPED - �������� �� exe ���������� � ������� �����
IMAGE_FILE_LOCAL_SYMS_STRIPPED - �������� local symbols
IMAGE_FILE_REMOVABLE_RUN_FROM_SWAP - ��� ������� exe � ��������, ������, ������ ����������� ���������, ������� exe � ���� � ��������� ������.
  �������, ���� ����� ��������� ��������� � ��������, � ����� ��������� �������� ������...
IMAGE_FILE_NET_RUN_FROM_SWAP - ���������� ����������, ������ ��� ������� ������
}
begin
//   logpref.evts.onwindow := False;
//   logpref.evts.onfile := True;
  Application.MainFormOnTaskBar := False;
  randomize;

//  TStyleManager.LoadFromFile('RubyGraphite.vsf');
  //  SetCurrentThreadName('RnQMain');
//  NameThreadForDebugging('RnQMain');
  beforeWindowsCreation;
  Application.Title := 'R&Q';
  theme.addHIco('rnq', application.Icon.Handle, True);
//   loggaEvt('Before main');
  Application.CreateForm(TRnQmain, RnQmain);
  Application.CreateForm(THistoryData, HistoryData);
  //  loggaEvt('Before chat');
  Application.CreateForm(TchatFrm, chatFrm);
//   loggaEvt('Before msgs');
  Application.CreateForm(TmsgsFrm, msgsFrm);
//   loggaEvt('Before log');
  Application.CreateForm(TLogFrm, LogFrm);
//   loggaEvt('Before after');
  Application.ShowMainForm := False;
  afterWindowsCreation;
//  if startminimized and formvisible(RnQmain) then RnQmain.toggleVisible;
//   loggaEvt('Before user');
  startUser;
//  SetDliFailureHook(DelayedFailureHook);
//    SetDliFailureHook(DelayLoadFailureHook);
  application.Run;
end.

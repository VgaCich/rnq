﻿{
  This file is part of R&Q.
  Under same license
}
unit chatDlg;
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  ComCtrls, StdCtrls, Menus, ExtCtrls, ToolWin, ActnList, RnQButtons,
  VirtualTrees, StrUtils, System.Actions,
  history,
 {$IFDEF CHAT_CEF} // Chromium
  ceflib,
  historyCEF,
 {$ELSE ~CHAT_CEF} // old
  {$IFDEF CHAT_WEBV2} // WebView2
     WebView2,
     historyWV2,
   {$ELSE ~CHAT_WV2} //
     {$IFDEF CHAT_SCI} // Sciter
      historySCI,
     {$ELSE ~CHAT_CEF and ~CHAT_SCI} // old
      historyVCL,
     {$ENDIF CHAT_SCI}
   {$ENDIF CHAT_WV2}
 {$ENDIF CHAT_CEF}
  Commctrl, selectContactsDlg,
 {$IFDEF FLASH_AVATARS}
  ShockwaveFlashObjects_TLB,
//    FlashPlayerControl,
 {$ENDIF FLASH_AVATARS}
  RDGlobal,
  {$IFDEF USE_GDIPLUS}
    RnQGraphics,
  {$ELSE}
    RnQGraphics32,
  {$ENDIF USE_GDIPLUS}
 {$IFDEF CHAT_SPELL_CHECK}
  SpellCheck,
 {$ENDIF CHAT_SPELL_CHECK}
  RnQProtocol,
  RnQPrefsLib,
  incapsulate, events,
  pluginLib, RQMenuItem;

const
  HintTimer = 1;

type
  TAvatr = record
      AvtPBox: TPaintBox;
//      Pic: TRnQBitmap;
      PicAni: TRnQAni;
 {$IFDEF FLASH_AVATARS}
      swf: TShockwaveFlash;
 {$ENDIF FLASH_AVATARS}
//      swf: TFlashPlayerControl;
//      swf: TTransparentFlashPlayerControl;
    end;

  TPanel = class(ExtCtrls.TPanel)
  private
    procedure WMEraseBkgnd(var msg: TWMEraseBkgnd); message WM_ERASEBKGND;
  end;

  TChatType = (CT_IM, CT_PLUGING);

  PChatInfo = ^TchatInfo;

  TchatInfo = class
   public
    ID: IntPtr;
    chatType: TChatType;
//    panelID: Integer;
//    who: Tcontact;
    who: TRnQContact;
    single: boolean;        // single-message
//    whole: boolean;         // see whole history
//    autoscroll: boolean;    // auto scrolls along messages
//    newSession: integer;    // where, in the history, does start new session
//    simpleMsg: Boolean;
    lastInputText: String;  // last input.text before quoting sequence
    quoteIdx: Integer;
    wasTyped: boolean; // input was not clear?
    historyBox: ThistoryBox;
    splitter: Tsplitter;
    inputPnl: TPanel;
 {$IFDEF CHAT_SPELL_CHECK}
    input: TMemoEx;
 {$ELSE CHAT_SPELL_CHECK}
    input: TMemo;
 {$ENDIF CHAT_SPELL_CHECK}
    btnPnl: TPanel;
    avtsplitr: Tsplitter;
    avtPic: TAvatr;

    constructor create;
    procedure setAutoscroll(v: boolean);
    procedure repaint();
    procedure repaintAndUpdateAutoscroll();
    procedure updateAutoscroll(Sender: TObject);
    procedure CheckTypingTime;
   end; // TchatInfo

  Tchats = class(Tlist)
  protected
    function Get(Index: Integer): TchatInfo; OverLoad;
    procedure Put(Index: Integer; Item: TchatInfo); OverLoad;
  public
    function validIdx(i: Integer): Boolean;
    function idxOf(c: TRnQcontact): Integer;
    function idxOfUIN(const uin: TUID): Integer;
    function byIdx(i: Integer): TchatInfo;
    function byContact(c: TRnQContact): TchatInfo;
    procedure CheckTypingTimeAll;
    property Items[Index: Integer]: TchatInfo read Get write Put; default;
   end; // Tchats
{
  TPageControl = class(ComCtrls.TPageControl)
  protected
    procedure CNDrawitem(var Message: TWMDrawItem); message CN_DRAWITEM;
  end;
}
  TchatFrm = class(TForm)
    pagectrl: TPageControl;
    panel: TPanel;
    sbar: TStatusBar;
    sendBtn: TRnQToolButton;
    closeBtn: TRnQToolButton;
    toolbar: TToolBar;
    historyBtn: TRnQSpeedButton;
    findBtn: TRnQSpeedButton;
    smilesBtn: TRnQSpeedButton;
    prefBtn: TRnQSpeedButton;
    autoscrollBtn: TRnQSpeedButton;
    infoBtn: TRnQSpeedButton;
    quoteBtn: TRnQSpeedButton;
    singleBtn: TRnQSpeedButton;
    btnContacts: TRnQSpeedButton;
    RnQPicBtn: TRnQSpeedButton;
    RnQFileBtn: TRnQSpeedButton;
    tb0: TToolBar;
    fp: TBevel;
    caseChk: TCheckBox;
    reChk: TCheckBox;
    directionGrp: TComboBox;
    w2sBox: TEdit;
    SBSearch: TRnQButton;
    CLPanel: TPanel;
    CLSplitter: TSplitter;
    stickersBtn: TRnQSpeedButton;
    BuzzBtn: TRnQSpeedButton;
    emojiBtn: TRnQSpeedButton;
    procedure closemenuPopup(Sender: TObject);
    procedure prefBtnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure w2sBoxKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SBSearchClick(Sender: TObject);
    procedure FormHide(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure RnQFileBtnClick(Sender: TObject);
    procedure RnQPicBtnClick(Sender: TObject);
    procedure RnQFileUploadClick(Sender: TObject);
    procedure RnQFileUploadRClick(Sender: TObject);
    procedure RnQFileUploadMClick(Sender: TObject);
    procedure CloseallandAddtoIgnorelist1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure SplitterMoved(Sender: TObject);
    procedure splitterMoving(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    procedure AvtSplitterMoved(Sender: TObject);
    procedure AvtsplitterMoving(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure sendBtnClick(Sender: TObject);
    procedure pagectrl00MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pagectrlChange(Sender: TObject);
    procedure Close1Click(Sender: TObject);
    procedure Viewinfo1Click(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure infoBtnClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure findBtnClick(Sender: TObject);
    procedure quoteBtnClick(Sender: TObject);
    procedure smilesBtnClick(Sender: TObject);
    procedure autoscrollBtnClick(Sender: TObject);
    procedure singleBtnClick(Sender: TObject);
    procedure btnContactsClick(Sender: TObject);
    procedure chatDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
    procedure chatDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure historyBtnClick(Sender: TObject);
    procedure sbarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure sbarMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure Sendwhenimvisibletohimher1Click(Sender: TObject);
    procedure Sendmultiple1Click(Sender: TObject);
    procedure Closeall1Click(Sender: TObject);
    procedure Closeallbutthisone1Click(Sender: TObject);
    procedure CloseallOFFLINEs1Click(Sender: TObject);
    procedure pagectrlChanging(Sender: TObject; var AllowChange: Boolean);
    procedure chatsendmenuopen1Click(Sender: TObject);
    procedure chatcloseignore1Click(Sender: TObject);
    procedure closeBtnClick(Sender: TObject);
    procedure prefBtnClick(Sender: TObject);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure pagectrl00MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure pagectrlDrawTab(Control: TCustomTabControl;
      TabIndex: Integer; const Rect: TRect; Active: Boolean);
    procedure ANothingExecute(Sender: TObject);
    procedure pagectrlDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure pagectrlMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure pagectrlDragDrop(Sender, Source: TObject; X, Y: Integer);
    procedure pagectrlMouseLeave(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CLPanelDockDrop(Sender: TObject; Source: TDragDockObject; X,
      Y: Integer);
    procedure CLPanelDockOver(Sender: TObject; Source: TDragDockObject; X,
      Y: Integer; State: TDragState; var Accept: Boolean);
    procedure CLPanelUnDock(Sender: TObject; Client: TControl;
      NewTarget: TWinControl; var Allow: Boolean);
    procedure quoteBtnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure findBtnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure smilesBtnMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
 {$IFDEF USE_SECUREIM}
    procedure EncryptSendInit(Sender: TObject);
 {$ENDIF USE_SECUREIM}
    procedure EncryptSetPWD(Sender: TObject);
    procedure EncryptClearPWD(Sender: TObject);
    procedure sbarDblClick(Sender: TObject);
    procedure StopTimer(ID: Integer);
    procedure stickersBtnClick(Sender: TObject);
    procedure ShowStickersExecute(Sender: TObject);
    procedure BuzzBtnClick(Sender: TObject);
    procedure RnQFileBtnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer);
    procedure OnUploadSendData(Sender: TObject; Buffer: Pointer; Len: Integer);
    procedure RnQSpeedButton1Click(Sender: TObject);
    procedure InitScale(Sender: TObject; NewDPI: Integer);
    procedure FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
      NewDPI: Integer);
    procedure emojiBtnClick(Sender: TObject);
  {$IFDEF usesDC}
    procedure WMDROPFILES(var Message: TWMDROPFILES);  message WM_DROPFILES;
  {$ENDIF usesDC}
  protected
    procedure WndProc(var Message: TMessage); override;
//    procedure StartWheelPanning(Position: TPoint); virtual;
//    procedure StopWheelPanning; virtual;
//    procedure CNVScroll(var Message: TWMVScroll); message CN_VSCROLL;
    procedure WMEXITSIZEMOVE(var Message: TMessage);
         message WM_EXITSIZEMOVE;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure ShowTabHint(X, Y: integer);
//    procedure WMEraseBkgnd(var Msg: TWmEraseBkgnd); message WM_ERASEBKGND;

    procedure historyAllShowChange(ch: TchatInfo; histBtnDown: Boolean);
    procedure WMWINDOWPOSCHANGING(Var Msg: TWMWINDOWPOSCHANGING);
             message WM_WINDOWPOSCHANGING;
//    procedure showSmilePanel(p : TPoint);

    procedure WMAppCommand(var msg: TMessage); message WM_APPCOMMAND;
    procedure OnSmileSelect(const S: string);
    function  OnGetHNDL: HWND;

  private
    lastClick: Tdatetime;
    lastClickIdx: Integer;
//    lastContact: Tcontact;
    lastContact: TRnQContact;
  //окно хинта для отображения на закладках окна чата
//  hintwnd: TVirtualTreeHintWindow = nil;
   	hintwnd: TVirtualTreeHintWindow;
  //будем запоминать параметры хинта, чтобы не создавать несколько раз один и тот же хинт
    LastMousePos: TPoint;
//	hintTab: Integer;
    last_tabindex: Integer;
    FAniTimer: TTimer;
    PagesEnumStr: RawByteString;
    procedure TickAniTimer(Sender: TObject);

//    procedure checkGifTime;
//    tZers : TShockwaveFlash;
//    procedure process_tZers(ASender: TObject; percentDone: Integer);
//    procedure state_tZers(ASender: TObject; newState: Integer);
//    procedure BooButton1Click(Sender: TObject);
    procedure inputChange(Sender: TObject);
    procedure inputPopup(Sender: TObject; MousePos: TPoint; var Handled: Boolean);
    procedure inputKeydown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure inputKeyup(Sender: TObject; var Key: Word; Shift: TShiftState);
{$IFDEF CHAT_CEF}
    procedure preKeyEvent(Sender: TObject; const browser: ICefBrowser; const event: PCefKeyEvent;
                          osEvent: TCefEventHandle; out isKeyboardShortcut: Boolean; out Result: Boolean);
    procedure showHistMenu(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
                           const params: ICefContextMenuParams; const model: ICefMenuModel);
    procedure customBrowsing(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
                             const request: ICefRequest; isRedirect: Boolean; out Result: Boolean);
{$ELSE ~CHAT_CEF}
  {$IFNDEF CHAT_SCI}
    procedure onHistoryRepaint(Sender: TObject);
  {$ENDIF ~CHAT_SCI}
{$ENDIF CHAT_CEF}
  public
    chats: Tchats;
//    poppedup: TPoint;
    selectedUIN: TUID;
    plugBtns: TPlugButtons;
    histPM: TPopupMenu;
    sendMenuExt: TPopupMenu;
    closeMenuExt: TPopupMenu;
 { $IFDEF USE_SECUREIM}
    EncryptMenuExt: TPopupMenu;
 { $ENDIF USE_SECUREIM}
    enterCount: integer;
  {$IFDEF USE_SMILE_MENU}
    smile_theme_token: Integer;
    smileMenuExt: TRnQPopupMenu;
  {$ENDIF USE_SMILE_MENU}
    MainFormWidth: Integer;
//    favMenuExt: TPopupMenu;
    FileSendMenu: TPopupMenu;

    procedure SetSmilePopup(pIsMenu: Boolean);
{$IFDEF CHAT_SCI}
    procedure UpdateChatSettings;
    procedure UpdateChatSmiles;
{$ENDIF CHAT_SCI}
    procedure UpdatePluginPanel;
    function  isChatOpen(otherHand: TRnQContact): Boolean;
    function  openchat(otherHand: TRnQContact; ForceActive: Boolean = false;
                       isAuto: Boolean = false): boolean;
    function  addEvent_openchat(otherhand: TRnQcontact; ev: Thevent): Boolean; // opens chat if not already open
//    function  addEvent(uin: TUID; ev: Thevent): Boolean; overload;// tells if ev has been inserted in a list, or can be freed
    function  addEvent(c: TRnQcontact; ev: Thevent): Boolean; overload; // tells if ev has been inserted in a list, or can be freed
    procedure openOn(c: TRnQContact; focus: Boolean = True; pShow: Boolean = True);
//    procedure openOn(uid : TUID; focus: Boolean = True);
    procedure open(focus: Boolean = True);
    function  newIMchannel(c: TRnQContact): Integer;
    function  thisChat: TchatInfo;
    function  thisChatUID: TUID;
    procedure setTab(idx: Integer);
    procedure userChanged(c: TRnQContact);
    procedure redrawTab(c: TRnQcontact);
    function  pageIndex: integer;
    procedure closeThisPage;
    procedure closeAllPages(isAuto: Boolean = false);
    procedure closePageAt(idx: Integer);
    procedure closeChatWith(c: TRnQContact);
    function  sawAllhere: Boolean;
    function  isVisible: Boolean;
    procedure applyFormXY;
    procedure updateContactStatus;
    procedure quote(qs: String = ''; MakeCarret: Boolean = False);
    procedure quoteCallback(selected: String = ''; AddToInput: boolean = true; MakeCarret: boolean = false);
    function  pageIdxAt(x, y: Integer): Integer;
    procedure setCaptionFor(c: TRnQcontact);
    procedure setCaption(idx: Integer);
    procedure updateChatfrmXY;
    procedure setStatusbar(s: String);
    function  moveToTime(c: TRnQContact; time: Tdatetime; NeedOpen: Boolean = True): boolean;
    function  moveToTimeOrEnd(c: TRnQContact; time: Tdatetime; NeedOpen: Boolean = True): Boolean;
    procedure sendMessageAction(Sender: TObject);
    procedure send; overload;
    procedure send(flags_: Integer; msg: string = ''); overload;
    procedure select(c: TRnQContact);
    function  thisContact: TRnQContact;
    procedure flash;
    procedure shake;
    function  grabThisText: String;
    function  Pages2String: RawByteString;
//    procedure savePages;
    procedure InitPrefs(pp: TRnQPref);
    procedure loadPages(proto: TRnQProtocol; const s: RawByteString); OverLoad;
    procedure loadPages(const cl: TRnQCList); OverLoad;
    procedure updateGraphics;
    procedure addSmileAction(Sender: TObject);
    procedure AvtPBoxPaint(Sender: TObject);
    procedure onTimer;
    property  currentPPI: Integer read GetParentCurrentDpi;
  {$IFDEF CHAT_SPELL_CHECK}
    procedure InitSpellCheck;
    procedure SpellCheck;
    procedure RefreshThisInput;
  {$ENDIF CHAT_SPELL_CHECK}
  end; // TchatFrm

  function  CHAT_TAB_ADD(Control: Integer; iIcon: HIcon; const TabCaption: string): Integer;
  procedure CHAT_TAB_MODIFY(Control: Integer; iIcon: HIcon; const TabCaption: string);
  procedure CHAT_TAB_DELETE(Control: Integer);

var
  chatFrm: TchatFrm;


implementation

uses
  Clipbrd, ShellAPI, Themes, DateUtils,
  math, Types, System.Threading,
  Base64,
  RDFileUtil, RQUtil, RDUtils, RDSysUtils,
  RnQConst, globalLib, //searchhistDlg,
  outboxlib, utilLib, outboxDlg, RnQTips, RnQPics,
  langLib, roasterLib,
//  ViewPicDimmedDlg,
  RnQNet.Uploads,
//  prefDlg,
 {$IFDEF RNQ_AVATARS}
  RnQ_Avatars, UxTheme,
 {$ENDIF}
  Protocols_all,
  RnQCrypt,
 {$IFDEF PROTOCOL_WIM}
  WIM.MenuStickers, WIM, WIMContacts, WIMConsts,
 {$ENDIF PROTOCOL_WIM}
 {$IFDEF PROTOCOL_ICQ}
  MenuStickers,
  ICQConsts, ICQContacts, ICQv9,
 {$ENDIF PROTOCOL_ICQ}
  RQThemes, themesLib,
 {$IFDEF USE_SECUREIM}
  cryptoppWrap,
 {$ENDIF USE_SECUREIM}
 {$IFDEF UNICODE}
   AnsiStrings,
   Character,
 {$ENDIF UNICODE}
  RnQMenu, RnQLangs, RnQDialogs, menusUnit, RnQGlobal,
  MenuSmiles, menuEmoji, mainDlg;
 {$IFDEF SEND_FILE}
uses
    RnQ_FAM;
 {$ENDIF}

{$R *.DFM}

(*procedure TPageControl.CNDrawitem(var Message: TWMDrawItem);
var
{  Color1: TColor;
  Color2: TColor;
  c: TRnQContact;
  ci: TchatInfo;
  hnd: HDC;
  ev: Thevent;
  pic, p: TPicName;
  ss: String;
}
  Rgn: HRGN;
  Rect: TRect;


  R : Trect;
  c:TRnQcontact;
  ev:Thevent;
  themePage: TThemedTab;
//  themePage: TThemedButton;
  Details: TThemedElementDetails;
//  oldMode: Integer;
  ci : TchatInfo;
  ss  : String;
  p : TPicName;
  fl : Cardinal;
  hnd : HDC;
//  ImElm  : TRnQThemedElementDtls;
  Pic : TPicName;
  Active : Boolean;
  str : WideString;
begin
  hnd := Message.DrawItemStruct.HDC;
  Rect := Message.DrawItemStruct.rcItem;
  SelectClipRgn(hnd, 0);

  ci := chatFrm.chats.byIdx(Message.DrawItemStruct.itemID);
  if ci = nil then
    exit;

  r := Rect;
  Active := Message.DrawItemStruct.itemState = 1;
  c := ci.who;

  if StyleServices.Enabled then
    begin
      inc(r.Top, 1);
      if not active then
        inc(r.Right, 1);

//      inc(r.Top, 1);
      fl := BF_LEFT or BF_RIGHT or BF_TOP;
      if Active then
        begin
          themePage := ttTopTabItemSelected; //ttTabItemSelected
        end
       else
        begin
          themePage := ttTopTabItemNormal; //ttTabItemNormal;
          inc(fl, BF_BOTTOM);
          dec(r.Left, 2);
          inc(r.Bottom, 3);
        end;
;
      Details := StyleServices.GetElementDetails(themePage);
      StyleServices.DrawElement(hnd, Details, r);
      StyleServices.DrawEdge(hnd, Details, r, 1, fl);//BF_RECT );
    end
   else
    begin
      fillrect(hnd, r, CreateSolidBrush(clGray));
    end;
  inc(r.left,4);
  inc(r.top, 4);
  dec(r.right); //dec(r.bottom);

//  oldMode:=
 SetBKMode(hnd, TRANSPARENT);
  if ci.chatType = CT_IM then
  begin
    ev := eventQ.firstEventFor(c);
    if (ev<>NIL) //then
//      begin
//      if
      and ((blinking or c.fProto.getStatusDisable.blinking) or not blinkWithStatus) then
       begin
        if (blinking or c.fProto.getStatusDisable.blinking) then
          inc(R.left, 1 + ev.Draw(hnd, R.left,R.top).cx)
        else
          inc(R.left, 1 + ev.PicSize.cx);
       end
    else
     begin
       {$IFDEF RNQ_FULL}
        if c.typing.bIsTyping then
//          inc(R.left, 1+theme.drawPic(hnd, R.left,R.top, PIC_TYPING).cx)
          pic := PIC_TYPING
        else
       {$ENDIF}
        if showStatusOnTabs then
         begin
          {$IFDEF RNQ_FULL}
           {$IFDEF CHECK_INVIS}
           if c.isInvisible and c.isOffline then
             pic := status2imgName(byte(SC_ONLINE), True)
  //         with theme.GetPicSize('')
//            inc(R.left, 1+ statusDrawExt(hnd, R.left,R.top, byte(SC_ONLINE), True).cx)
           else
  //           theme.drawPic(control.canvas, R.left,R.top, status2imgName(SC_ONLINE, True)).cx);
           {$ENDIF}
          {$ENDIF}
             pic := c.statusImg;
         end;
       inc(R.left, 1 + theme.drawPic(hnd, R.left,R.top, Pic).cx)
     end;
    if active then
      p := 'chat.tab.active'
     else
      p := 'chat.tab.inactive';
    theme.ApplyFont(p, Self.Canvas.Font);

    if UseContactThemes and Assigned(ContactsTheme) then
     begin
      ContactsTheme.ApplyFont(TPicName('group.') + TPicName(AnsiLowerCase(c.getGroupName)) + '.'+p, Self.Canvas.Font);
      ContactsTheme.ApplyFont(TPicName(c.UID2cmp) + '.'+p, Self.Canvas.Font);
     end;

// hnd := Self.Canvas.Handle;

  //  Font.Style := Font.Style + [fsStrikeOut];
//    inc(r.top, 2);
    dec(r.Right);

      if active then
       begin
//        inc(r.top, 2);
//        inc(R.left,2);
         dec(R.Bottom, 2);
       end
      else
       ;

        ss := dupAmperstand(c.displayed);
      DrawText(hnd, PChar(ss), Length(ss), r,
              DT_LEFT or DT_SINGLELINE or DT_VCENTER);// or DT_ DT_END_ELLIPSIS);
  end
  else
    begin
      inc(R.left, 1+theme.drawPic(hnd, R.left,R.top, 'plugintab' + IntToStrA(chatFrm.chats.byIdx(tabindex).id)).cx);
      inc(r.top, 2);
      str := ci.lastInputText;
      TextOut(hnd, r.Left, r.Top, @str[1], Length(ci.lastInputText));
    end;

  Message.Result := 1;
//  inherited;

end;
*)

procedure TPanel.WMEraseBkgnd(var msg: TWMEraseBkgnd);
begin
  msg.Result := 1;
  msg.msg := 0;
end;

constructor TchatInfo.create;
begin
  inherited;
  quoteIdx := -1;
end;

procedure TchatInfo.setAutoscroll(v: boolean);
begin
  chatFrm.autoscrollBtn.down := v;
//  historyBox.autoscroll := v;
//  historyBox.setAutoScrollForce(v);
  historyBox.autoScrollVal := v;
end;

procedure TchatInfo.repaint();
begin
  if not Assigned(self) then
    Exit;

  if chatType = CT_IM then
  begin
//    if historyBox.autoscroll then historyBox.go2end
//     else
      if chatFrm.visible {and not IsIconic(chatFrm.handle)} then
        begin
//          needRepaint:= False;
          historyBox.repaint;
        end
//       else
//         needRepaint:= True;
  end;
end;

procedure TchatInfo.repaintAndUpdateAutoscroll();
begin
  repaint;
  updateAutoscroll(historyBox)
end;

/////////////////////////// Tchats /////////////////////////////////

    {$WARN UNSAFE_CAST OFF}
function Tchats.idxOfUIN(const uin: TUID): Integer;
begin
  result := 0;
  while result < count do
  begin
    if TchatInfo(items[result]).chatType = CT_IM then
     if TchatInfo(items[result]).who.equals(uin) then
      exit;
    inc(result);
  end;
  result := -1;
end; // idxOfUIN

function Tchats.idxOf(c: TRnQcontact): Integer;
begin
  result := 0;
  while result < count do
   begin
    if Assigned(items[Result]) then
      if TchatInfo(items[result]).chatType = CT_IM then
       if TchatInfo(items[result]).who.equals(c) then
         exit;
    inc(result);
   end;
  result := -1;
end; // idxOf

function Tchats.byIdx(i: Integer): TchatInfo;
begin
  result := NIL;
  if validIdx(i) then
    result := TchatInfo(items[i])
end; // byIdx

function Tchats.Get(Index: Integer): TchatInfo;
begin
  Result := Inherited get(Index);
end;

procedure Tchats.Put(Index: Integer; Item: TchatInfo);
begin
  inherited Put(Index, Item);
end;

    {$WARN UNSAFE_CAST ON}

function Tchats.byContact(c: TRnQcontact): TchatInfo;
begin
  result := byIdx(idxOf(c))
end;

function Tchats.validIdx(i: Integer): boolean;
begin
  result := (i >= 0) and (i < count)
end;

procedure Tchats.CheckTypingTimeAll;
var
  i: Integer;
begin
  if Assigned(Account.AccProto) then
 {$WARN UNSAFE_CAST OFF}

  if (Account.AccProto.SupportTypingNotif) and (Account.AccProto.isSendTypingNotif) then
   if count > 0 then
    for i := count-1 downto 0 do
     if TchatInfo(items[i]).chatType = CT_IM then
       if Assigned(TchatInfo(items[i]).who) then
         TchatInfo(items[i]).CheckTypingTime;
 {$WARN UNSAFE_CAST ON}
end;

/////////////////////////////////////////////////////////////////

procedure TchatFrm.FormResize(Sender: TObject);
var
  ch: TchatInfo;
begin
  if (w2sBox.Left + w2sBox.Width + 6) > directionGrp.Left then
    w2sBox.Width := Max(directionGrp.Left - w2sBox.Left - 6, 10);

  updateChatfrmXY;
  ch := thisChat;
  if ch = NIL then
    exit;
  if ch.chatType = CT_PLUGING then
    plugins.castEv(PE_SELECTTAB, ch.id)
   else
    begin
      if Assigned(ch.inputPnl) then
       begin
        if (ch.inputPnl.height > pagectrl.ActivePage.ClientHeight)
           and (ch.inputPnl.height > 32) then
          ch.inputPnl.height := pagectrl.ActivePage.ClientHeight - 30
       end
       else
        if Assigned(ch.input) and (ch.input.height > pagectrl.ActivePage.ClientHeight)
           and (ch.input.height > 32) then
          ch.input.height := pagectrl.ActivePage.ClientHeight - 30;
//   updatea
      ch.repaint; // AndUpdateAutoscroll();
//   ch.repaintAndUpdateAutoscroll();
    end;
end; // formResize

function TchatFrm.addEvent_openchat(otherhand: TRnQcontact; ev: Thevent): Boolean;
begin
  openchat(otherHand);
  result := addEvent(otherhand, ev);
end; // addEvent_openchat

{function TchatFrm.addEvent(uin: TUID; ev:Thevent):boolean;
var
  i:integer;
  ch : TchatInfo;
begin
  result:=FALSE;
  i:=chats.idxOfUIN(uin);
  ch:=chats.byIdx(i);
  if ch=NIL then
   ev.free
  else
   begin
    result:=TRUE;
    ch.historyBox.history.add(ev);
    if i = pageIndex then
      ch.repaint();
//    ch.repaintAndUpdateAutoscroll();
   end
end; // addEvent }
function TchatFrm.addEvent(c: TRnQcontact; ev: Thevent): Boolean;
// tells if ev has been inserted in a list, or can be freed
var
  i: Integer;
  ch: TchatInfo;
begin
  result := False;
  i := chats.idxOf(c);
  ch := chats.byIdx(i);
  if ch = NIL then
   ev.free
  else
   begin
    result := True;
    ch.historyBox.addEvent(ev);
{    if i = pageIndex then
      ch.repaint();
}
//    ch.repaintAndUpdateAutoscroll();
   end
end; // addEvent

function TchatFrm.pageIndex: Integer;
begin
  if pageCtrl.activePage = NIL then
    result := -1
   else
    result := pageCtrl.activePage.pageIndex
end;

// pageIndex

function TchatFrm.openchat(otherHand: TRnQContact; ForceActive: Boolean = false;
                           isAuto: Boolean = false): Boolean;
const
  MaxNILpages = 101;
var
  i, k: integer;
  wasEmpty, alreadyThere: Boolean;
  cnt: TRnQContact;
  firstNILpage, NILcount: Integer;
begin

  wasEmpty := pageCtrl.pageCount=0;
  i := chats.idxOf(otherHand);
  alreadyThere := i=pageIndex;
  result := i<0;
  if result then
    i := newIMchannel(otherHand);
  if wasEmpty then
    begin
      if i >= 0 then
        setTab(i);
      pageCtrlChange(self);
      if docking.Docked2chat then
        applyDocking;
    end
   else
    begin
      if not alreadyThere then
       begin
        if ForceActive then
         begin
           if i >= 0 then
             pageCtrl.activePageIndex := i
            else
             pagectrl.ActivePageIndex := chats.idxOf(otherHand);
           pageCtrlChange(self);
         end;
       end;
      if isAuto then
       begin // protection against bruteforce
         firstNILpage := -1;
         NILcount := 0;
         for k := 0 to chats.Count-1 do
          begin
            if chats.byIdx(k).chatType = CT_IM then
             begin
              cnt := chats.byIdx(k).who;
              if Assigned(cnt) and notInList.exists(cnt) then
               begin
                inc(NILcount);
                if firstNILpage < 0 then
                  firstNILpage := k;
               end;
             end;
          end;
         if (firstNILpage >= 0) and (NILcount > MaxNILpages) then
           closePageAt(firstNILpage);
       end;
    end;
  if ForceActive and not Visible then
    Visible := True;
end;

// openchat

function TchatFrm.isChatOpen(otherHand: TRnQcontact): Boolean;
begin
  result := chats.idxOf(otherHand) >= 0
end;

procedure TchatFrm.applyFormXY;
begin
  with chatfrmXY do
  if width > 0 then
   begin
    if maximized then
      begin
        SetBounds(left, top, width, height);
        windowState := wsMaximized;
      end
     else
      begin
       SetBounds(left, top, width, height);
       windowState := wsNormal
      end;
   end;
end; // applyFormXY

procedure TchatFrm.FormCreate(Sender: TObject);
begin
  chats := Tchats.create;
  plugBtns := TPlugButtons.Create;

  histPM := nil;
//  THistoryBox.initMenu(histPM, Self);

  InitMenuChats;
  createMenuAs(aSendMenu, sendMenuExt, self);
  createMenuAs(aCloseMenu, closeMenuExt, self);
 {$IFDEF USE_SECUREIM}
  if useSecureIM then
    createMenuAs(aEncryptMenu, EncryptMenuExt, self);
 {$ENDIF USE_SECUREIM}
  createMenuAs(aEncryptMenu2, EncryptMenuExt, self);

  createMenuAs(aFileSendMenu, FileSendMenu, self);

  sendBtn.DropdownMenu  := sendMenuExt;
  closeBtn.DropdownMenu := closeMenuExt;
 {$IFDEF USE_SMILE_MENU}
  smileMenuExt := TRnQPopupMenu.Create(self);
  smileMenuExt.OnPopup := smilesMenuPopup;
  smileMenuExt.OnClose := smilesMenuClose;
//  smilesBtn.PopupMenu := smileMenuExt;
 {$ENDIF USE_SMILE_MENU}
    SetSmilePopup(True);
//  favMenuExt := TPopupMenu.Create(self);
//  favMenuExt.OnPopup  := favMenuPopup;

  plugBtns.PluginsTB := NIL;
  plugBtns.btnCnt    := 0;
  hintwnd := nil;
  last_tabindex := -1;

  FAniTimer := TTimer.Create(nil);
  FAniTimer.Enabled := false;
  FAniTimer.Interval := 40;
  //timer.Enabled := UseAnime;
  FAniTimer.OnTimer := TickAniTimer;

//  DoubleBuffered := True;
  sbar.DoubleBuffered := StyleServices.Enabled;
  DragAcceptFiles(self.handle, True);
  applyFormXY;
  applyTaskButton(self);

  InitScale(Sender, getParentCurrentDPI);

  lastClickIdx := -1;
 {$IFDEF CHAT_SPELL_CHECK}
  TMemoEx.RefreshInputPrc := procedure
  begin
    if Assigned(chatFrm) then
      chatFrm.RefreshThisInput;
  end
 {$ENDIF CHAT_SPELL_CHECK}
end;

 {$IFDEF CHAT_SPELL_CHECK}
procedure TchatFrm.InitSpellCheck;
begin
  TMemoEx.DoInitSpellCheck;
end;

procedure TchatFrm.SpellCheck;
begin
  TMemoEx.DoSpellCheck;
end;

procedure TchatFrm.RefreshThisInput;
var
  ch: TchatInfo;
begin
  ch := thisChat;
  if Assigned(ch) and Assigned(ch.input) then
    ch.input.Refresh;
end;
 {$ENDIF CHAT_SPELL_CHECK}

procedure TchatFrm.setTab(idx: Integer);
var
  bool: Boolean;
begin
  if idx < 0 then
    Exit;

  if Assigned(pageCtrl.Onchanging) then
   begin
    bool := True;
    pageCtrl.OnChanging(self, bool);
    if bool = false then
      exit;
   end;

  with pageCtrl do
    if idx < pageCount then
      activePage := pages[idx]
     else
      msgDlg('Error: bad page', True, mtError);  // should never reach this
  if Assigned(pageCtrl.onChange) then
    pageCtrl.onChange(self);
end; // setTab

procedure TchatFrm.userChanged(c: TRnQContact);
var
  i: Integer;
  ch: TchatInfo;
begin
  if c = NIL then
    Exit;
  ch := thisChat;
  if (ch=NIL) then
    Exit;
  if c.isMyAcc then
   begin
    ch.repaint();
//  ch.repaintAndUpdateAutoscroll();
//  exit;
   end;
  i := chats.idxOf(c);
  if i < 0 then
    exit;
  setCaptionFor(c);
  redrawTab(c);
  updateContactStatus;
  if i = pageIndex then
    ch.repaint();
//  ch.repaintAndUpdateAutoscroll();
end; // userChanged

procedure TchatFrm.openOn(c: TRnQContact; focus: Boolean = True; pShow: Boolean = True);
var
  i: integer;
  wasEmpty: Boolean;
begin
  if c=NIL then
    exit;
  wasEmpty := pageCtrl.pageCount=0;
  i := chats.idxOf(c);
  if i < 0 then
    i := newIMchannel(c);
  if i >= 0 then
    setTab(i);
  pageCtrlChange(self);
  if wasEmpty then
   if docking.Docked2chat then
    applyDocking;
  if pShow then
    open(focus);
end; // openOn

{procedure TchatFrm.openOn(uid: TUID; focus: Boolean = True);
var
  i: Integer;
  cnt: Tcontact;
begin
  cnt := contactsDB.get(uid);
  if cnt=NIL then exit;
  i := chats.idxOf(cnt);
  if i < 0 then
    i:=newIMchannel(cnt);
  if i >= 0 then
   begin
    setTab(i);
    open(focus);
   end;
end; // openOn}

function TchatFrm.newIMchannel(c: TRnQContact): Integer;
var
  sheet: TtabSheet;
  chat: TchatInfo;
  pnl: Tpanel;
begin
 {$IFDEF CHAT_SCI} // Sciter
  if not THistoryBox.PreLoadTemplate then
    Exit(-1);
 {$ENDIF CHAT_SCI} // Sciter


 {$IFDEF SMILES_ANI_ENGINE}
//  rqSmiles.ClearAniParams;
  theme.ClearAniParams;
 {$ENDIF SMILES_ANI_ENGINE}
  chat := TchatInfo.create;
  chat.who := c;
  chat.chatType := CT_IM;
  chat.single := singleDefault;
  chat.who.typing.bIAmTyping := False;
//if not assigned(pTCE(c.data).history0) then
//  pTCE(c.data).history0:=Thistory.create;

  sheet := TtabSheet.Create(self);
  chats.Add(chat);
  sheet.PageControl := pageCtrl;
  result := sheet.pageIndex;
  setCaption(Result);
//  sheet.ControlStyle := sheet.ControlStyle + [csOpaque];
//setCaptionFor(c);
  sheet.DoubleBuffered := False;

//sheet.ShowHint := True;
//sheet.Hint := c.display;

  pnl := Tpanel.create(self);
  pnl.parent := sheet;
  pnl.align := alClient;
  pnl.BevelInner := bvNone;
  pnl.BevelOuter := bvNone;
  pnl.BorderStyle := bsSingle;
//  pnl.BorderStyle := bsNone;

  chat.historyBox := ThistoryBox.create(pnl, c);
  with chat.historyBox do
  begin
   color := theme.getColor(ClrHistBG, clWindow); // history.bgcolor;

   align := alClient;
   Realign;
   onDragOver := chatDragOver;
   onDragDrop := chatDragDrop;
   OnScroll := chat.updateAutoscroll;
{$IFDEF CHAT_CEF}
    OnPreKeyEvent := preKeyEvent;
    OnBeforeContextMenu := HistoryData.showHistMenu;
    OnBeforeBrowse := customBrowsing;
{$ELSE ~CHAT_CEF}
  {$IFDEF CHAT_SCI}
      OnShowMenu := HistoryData.showHistMenu;
//      InitSmiles;
  {$ELSE OLD VCL}
     onPainted := onHistoryRepaint;
  {$ENDIF}
{$ENDIF CHAT_CEF}
    InitAll;
  end;


 {$IFDEF SMILES_ANI_ENGINE}
//  rqSmiles.ClearAniParams;
  theme.ClearAniParams;
 {$ENDIF SMILES_ANI_ENGINE}
//pnl.insertControl(chat.historyBox);


 {$IFDEF FLASH_AVATARS}
 chat.avtPic.swf := NIL;
 {$ENDIF FLASH_AVATARS}
 chat.avtPic.PicAni := NIL;
 chat.avtPic.AvtPBox := NIL;
 chat.avtsplitr := NIL;

 if avatarShowInChat then
   begin
    chat.inputPnl := TPanel.create(self);
    chat.inputPnl.parent := sheet;
    chat.inputPnl.align := alBottom;
    chat.inputPnl.BorderWidth := 0;
//  chat.inputPnl.BorderStyle := bsNone;
    chat.inputPnl.BevelOuter := bvNone;
    chat.inputPnl.BevelKind := bkNone;
//  chat.inputPnl.BevelKind := bkNone;
///  chat.inputPnl.BevelWidth := 0;
    chat.inputPnl.ControlStyle := chat.inputPnl.ControlStyle + [csOpaque];
    chat.inputPnl.FullRepaint := False;
    chat.inputPnl.DoubleBuffered := True;

 {$IFDEF CHAT_SPELL_CHECK}
    chat.input := TMemoEx.create(chat.inputPnl);
 {$ELSE CHAT_SPELL_CHECK}
    chat.input := Tmemo.create(chat.inputPnl);
 {$ENDIF CHAT_SPELL_CHECK}
    chat.input.parent := chat.inputPnl;
    chat.input.align  := alClient;
{$IFNDEF CHAT_CEF}
    sheet.ControlStyle := sheet.ControlStyle + [csOpaque];
//    chat.inputPnl.ControlStyle := chat.inputPnl.ControlStyle + [csOpaque];
    sheet.DoubleBuffered := true;
{$ENDIF ~CHAT_CEF}
    if splitY > 0 then
      chat.inputPnl.height := splitY
     else
      chat.inputPnl.height := 50;
  //  chat.avtsplitr.cursor:=crVsplit;
  //  chat.avtsplitr.onMoved:=splitterMoved;
  //  chat.avtsplitr.OnCanResize:=splitterMoving;
   end
  else
   begin
    chat.inputPnl := NIL;
 {$IFDEF CHAT_SPELL_CHECK}
    chat.input := TMemoEx.create(sheet);
 {$ELSE CHAT_SPELL_CHECK}
    chat.input := Tmemo.create(sheet);
 {$ENDIF CHAT_SPELL_CHECK}
    chat.input.parent := sheet;
    chat.input.align := alBottom;
    if splitY > 0 then
      chat.input.height := splitY
     else
      chat.input.height := 50;
   end;

  chat.input.WordWrap := True;
   theme.ApplyFont('history.my', chat.input.Font);
  chat.input.ScrollBars := ssVertical;
  chat.input.onChange := inputChange;
  chat.input.OnContextPopup := inputPopup;
  chat.input.onKeyDown  := inputKeydown;
  chat.input.OnKeyUp    := inputKeyup;
  chat.input.onDragOver := chatDragOver;
  chat.input.onDragDrop := chatDragDrop;

  chat.input.WantTabs := True;
  chat.input.HideSelection := False;
  chat.input.DoubleBuffered := False;
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_COMPOSITED);

{  if theme.GetPicSize( PIC_CHAT_BG+'5').cx > 0 then
   begin
    if not Assigned(chat.input.Brush.Bitmap) then
      chat.input.Brush.Bitmap := TBitmap.Create;
//   chat.input.Brush.Handle := theme.GetBrush(PIC_CHAT_BG+'5')
    theme.GetPic(PIC_CHAT_BG+'5', chat.input.Brush.Bitmap, false);
   end
  else}
   chat.input.color := theme.getColor(ClrHistBG, clWindow);  // history.bgcolor;

  chat.splitter := Tsplitter.create(self);
  //chat.splitter.ResizeStyle := rsUpdate;
  chat.splitter.minsize := 1;
  chat.splitter.parent := sheet;
  chat.splitter.align := alBottom;
  chat.splitter.cursor := crVsplit;
  chat.splitter.onMoved := splitterMoved;
  chat.splitter.OnCanResize := splitterMoving;

  if usePlugPanel and (plugBtns.PluginsTB <> toolbar) then
  begin
    chat.btnPnl := TPanel.Create(self);
  //  chat.btnPnl.minsize:=1;
    chat.btnPnl.parent := pnl;
    chat.btnPnl.align  := alBottom;
    chat.btnPnl.Height := Max(24, MulDiv(24, GetParentCurrentDpi, cDefaultDPI));
    chat.btnPnl.BorderWidth := 0;
    chat.btnPnl.FullRepaint := False;
//  chat.inputPnl.BorderStyle := bsNone;
    chat.btnPnl.BevelOuter := bvLowered;
    chat.btnPnl.BevelKind := bkNone;
    if Assigned(chat.btnPnl) then
     if Assigned(plugBtns) then
      chat.btnPnl.Visible := plugBtns.btnCnt > 0
     else
      chat.btnPnl.Visible := false;
  //  chat.btnPnl.cursor:=crVsplit;
  end;

   {$IFDEF RNQ_AVATARS}
  updateAvatarFor(c);
   {$ENDIF RNQ_AVATARS}
{  chat.avtPic := TImage.create(self);
  chat.avtPic.parent := chat.inputPnl;
  chat.avtPic.align  := alRight;
  if Assigned(c.icon) then
   begin
    chat.avtPic.Width := c.icon.Width + 5;
    chat.avtPic.Picture.Assign(c.icon);
//    chat.avtPic.Picture.Bitmap.TransparentMode := tmAuto;
//    chat.avtPic.Picture.Bitmap.Transparent := True;
    chat.avtPic.Transparent := c.icon.Transparent;
   end
  else
    chat.avtPic.Width := 0;
}
  chat.historyBox.realign;
  resize;
//  savePages;
  saveListsDelayed := True;
 {$IFDEF SMILES_ANI_ENGINE}
//  rqSmiles.ClearAniParams;
  theme.ClearAniParams;
 {$ENDIF SMILES_ANI_ENGINE}
 {$IFNDEF CHAT_SCI}
  chat.historyBox.updateRSB(false);
 {$ENDIF ~CHAT_SCI}
end; // newIMchannel

procedure Tchatinfo.CheckTypingTime;
begin
 try
  if (chatType = CT_IM) and Assigned(who) then
   if (who.typing.bIamTyping) and ((now - who.typing.typingTime)*SecsPerDay > typingInterval) then
    who.Proto.InputChangedFor(who, false, True);
 except
 end;
end;


function TchatFrm.thisChat: TchatInfo;
begin
  if (chats.count = 0) or (not Assigned(pageCtrl.ActivePage)) then
    result := NIL
   else
    result := chats.byIdx(pageCtrl.ActivePage.pageIndex)
end;

function TchatFrm.thisContact: TRnQcontact;
var
  ch: TchatInfo;
begin
  ch := thisChat;
 if ch=NIL then
   result := NIL
  else
   if ch.chatType = CT_IM then
     thisContact := ch.who
    else
     result := NIL;
end; // thisContact


function TchatFrm.thisChatUID: TUID;
var
  cnt: TRnQContact;
begin
  cnt := thisContact;

  if (cnt <> NIL) then
    Result := cnt.UID2cmp
   else
    Result := '';
end;

procedure TchatFrm.sendBtnClick(Sender: TObject);
begin
  send
end;

function TchatFrm.pageIdxAt(x, y: Integer): Integer;
var
  R: Trect;
begin
  result := 0;
  while result < chats.count do
   begin
     SendMessage(pagectrl.Handle, TCM_GETITEMRECT, result, Longint(@R));
     if ptInRect(R, point(x,y)) then
       exit;
     inc(result);
   end;
  result := -1;
end; // pageIdxAt

procedure TchatFrm.pagectrl00MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  diff: TDateTime;
  i: integer;
  ev: Thevent;
  b: boolean;
begin
  case button of
   mbRight:
    begin
    i := pageIdxAt(x, y);
    if i < 0 then
      exit;
    if i <> pageIndex then
    	begin
      b := TRUE;
      pagectrlChanging(sender, b);
      if b then
      	begin
	      pagectrl.ActivePage := pagectrl.Pages[i];
	      pagectrlChange(sender);
        end;
      end;
    end;
   mbLeft:
    begin
     i := pageIdxAt(x, y);
     if i = lastClickIdx then
       diff := now-lastClick
      else
       diff := dblClickTime + 1;
     lastClick := now;
     lastClickIdx := i;
     if diff < dblClickTime then
      begin
      ev := eventQ.firstEventFor(thisContact);
      if ev<>NIL then
        begin
//          realizeEvents(ev.kind, ev.who);
//         eventQ.removeEvent(ev.kind, ev.who);
         eventQ.remove(ev);
         realizeEvent(ev);
            pagectrl.EndDrag(true);
        end
      else
        closeThisPage;
      end;
     pagectrl.BeginDrag(False);
    end;
   mbMiddle:
    begin
      i := pageIdxAt(x, y);
      if i < 0 then
        exit;
      if i = pageIndex then
        closeThisPage
      else
       try
        closePageAt(i);
       except
       end;
    end;
  end;
end; // pagectrl mousedown

procedure TchatFrm.closeThisPage;
Var
  ClosePgIdx: Integer;
begin
 if (pageCtrl.activePage = NIL) or (thisChat = NIL) then
   exit;
 ClosePgIdx := pageCtrl.activePage.TabIndex;
 pagectrl.SelectNextPage(True);
 closePageAt(ClosePgIdx);
end;

procedure TchatFrm.CLPanelDockDrop(Sender: TObject; Source: TDragDockObject; X, Y: Integer);
//var
// a: Integer;
begin
//  a := chatFrm.Width;
//  CLPanel.Align := alRight;
//  ChatPnl.Align := alClient;
//  Splitter1.Align := alRight;
  if Source.Control is TRnQmain then
   CLPanel.Width := max(MainFormWidth+2, 42);
  docking.Docked2chat := True;
  docking.active := False;
  mainfrmHandleUpdate;
//  chatFrm.Width := a + 202;
end;

procedure TchatFrm.CLPanelDockOver(Sender: TObject; Source: TDragDockObject; X, Y: Integer;
            State: TDragState; var Accept: Boolean);
begin
  Accept := Source.Control = MainDlg.RnQmain;
  MainFormWidth := MainDlg.RnQmain.Width;
end;

procedure TchatFrm.CLPanelUnDock(Sender: TObject; Client: TControl;
  NewTarget: TWinControl; var Allow: Boolean);
//var
// a : Integer;
begin
//{  a := CLPanel.Width;
 Allow := True;
 CLPanel.Width := 2;
 if pagectrl.PageCount > 0 then
  docking.Docked2chat := False;
// mainfrmHandleUpdate;
{  CLPanel.Align := alClient;
  ChatPnl.Align := alLeft;
  Splitter1.Align := alLeft;
  if Sender is TPanel then
   TPanel(Sender).Width := 1;
  MainDlg.RnQmain.Width := a + 2;}
end;

// closeThisPage

procedure TchatFrm.updateGraphics;
var
  ch: Tchatinfo;
  PPI: Integer;
begin
  ch := thisChat;
  if ch=NIL then
    exit;
  if ch.chatType = CT_PLUGING then
    Exit;
  PPI := GetParentCurrentDpi;
  theme.applyFont('history.my', ch.input.Font);
  smilesBtn.down := useSmiles;
  historyBtn.down := ch.historyBox.whole;
  singleBtn.down := ch.single;
  autoscrollBtn.down := ch.historyBox.autoScrollVal;
  //SimplMsgBtn.Down := ch.simpleMsg;
  updateContactStatus;
  ch.input.color := theme.getColor(ClrHistBG, clWindow);
  if Assigned(ch.btnPnl) then
   if Assigned(plugBtns) then
     ch.btnPnl.Visible := plugBtns.btnCnt > 0
    else
     ch.btnPnl.Visible := false;
  ch.historyBox.updateGraphics;
  ch.historyBox.color := ch.input.color;
  if chatFrm.visible and not IsIconic(chatFrm.handle) then
    ch.historyBox.repaint;
  panel.Realign;
  panel.repaint;

  InitScale(Self, PPI);
end; // updateGraphics

procedure TchatFrm.pagectrlChanging(Sender: TObject; var AllowChange: Boolean);
begin
  with thisChat do
   begin
    lastContact := who;
    if chatType = CT_PLUGING then
      plugins.castEv(PE_DESELECTTAB, id);
    if Assigned(who) then
      pTCE(who.data).keylay := GetKeyboardLayout(0)
   end;
end;

procedure TchatFrm.pagectrlChange(Sender: TObject);
var
  ch: TchatInfo;
  I: Integer;
begin
 {$IFDEF SMILES_ANI_ENGINE}
//  rqSmiles.ClearAniParams;
  theme.ClearAniParams;
 {$ENDIF SMILES_ANI_ENGINE}
  historyData.currentHB := NIl;
  ch := thisChat;
  if ch=NIL then
    exit;
  if ch.chatType = CT_IM then
    begin
     lastClick := 0;
     inputChange(self);    // update char counter
     historyData.currentHB := ch.historyBox;
     if autoSwitchKL
        and assigned(lastContact)
        and (lastContact<>ch.who)
        and (pTCE(ch.who.data).keylay<>0) then
       ActivateKeyboardLayout(pTCE(ch.who.data).keylay, 0);

     if chatFrm.visible and not IsIconic(chatFrm.handle) then
  {    if ch.historyBox.autoscroll then
        ch.historyBox.go2end
      else}
        ch.historyBox.repaint;

 {$IFDEF CHAT_SPELL_CHECK}
     if EnableSpellCheck then
      begin
        SetSpellText(ch.input.Text);
        SpellCheck;
      end;
 {$ENDIF CHAT_SPELL_CHECK}

     updateGraphics;
     SBSearch.Enabled := True;
     fp.Visible := findBtn.Down;
  //   SearchPnl.Visible := findBtn.Down;
     if usePlugPanel then
       begin
        if (plugBtns.PluginsTB <> toolbar) and Assigned(plugBtns.PluginsTB) then
         begin
          plugBtns.PluginsTB.Parent := ch.btnPnl;
          plugBtns.PluginsTB.Align := alClient;
          plugBtns.PluginsTB.Visible := True;
         end;
       end
      else
       for I := Low(plugBtns.btns) to High(plugBtns.btns) do
        if Assigned(plugBtns.btns[i]) then
         if not plugBtns.btns[i].Enabled then
          plugBtns.btns[i].Enabled := True;
     lastContact := NIL;
  //  if Assigned(ch.avtPic.PicAni) then
    if Assigned(ch.avtPic.PicAni) and (ch.avtPic.PicAni.Animated) then
      FAniTimer.Enabled := True
     else
      FAniTimer.Enabled := false;
    if isVisible and enabled and pagectrl.visible and pagectrl.enabled then
     ch.input.setFocus;

    BuzzBtn.Visible := ch.who.CanBuzz;
    BuzzBtn.Left := RnQFileBtn.Left + RnQFileBtn.Width;

   {$IF Defined(PROTOCOL_ICQ)or Defined(PROTOCOL_WIM)}
      stickersBtn.Visible := True;
   {$ELSE ~PROTOCOL_ICQ}
      stickersBtn.Visible := false;
   {$IFend PROTOCOL_ICQ}

  //    stickersBtn.Enabled := EnableStickers;
      stickersBtn.Enabled := MainPrefs.getPrefBoolDef('chat-images-enable-stickers', True);
    end
   else
    if (ch.chatType = CT_PLUGING) then
    begin
  //    ch.input.visible := false;
  //    ch.splitter.visible := false;
      if usePlugPanel then
       begin
        if plugBtns.PluginsTB <> toolbar then
        begin
          plugBtns.PluginsTB.Align := alNone;
          plugBtns.PluginsTB.Parent := self;
          plugBtns.PluginsTB.Visible := False;
        end;
       end
      else
       for I := Low(plugBtns.btns) to High(plugBtns.btns) do
        if Assigned(plugBtns.btns[i]) then
          plugBtns.btns[i].Enabled := False;
      SBSearch.Enabled := False;

  //    fp.Visible := false;
      plugins.castEv(PE_SELECTTAB, ch.id);
      BuzzBtn.Visible := False;
      stickersBtn.Enabled := False;
      stickersBtn.Visible := False;
    end;

  sendBtn.enabled := ch.chatType <> CT_PLUGING;
  historyBtn.enabled  := sendBtn.enabled;
  historyBtn.Visible  := sendBtn.enabled and (ch.chatType = CT_IM) and ch.historyBox.AllowShowAll;
  findBtn.enabled     := sendBtn.enabled;
  smilesBtn.enabled   := sendBtn.enabled;
  autoscrollBtn.enabled := sendBtn.enabled;
  infoBtn.enabled     := sendBtn.enabled;
  quoteBtn.enabled    := sendBtn.enabled;
  btnContacts.enabled := sendBtn.enabled;
  singleBtn.enabled   := sendBtn.enabled;
  RnQPicBtn.enabled   := sendBtn.enabled;
//SimplMsgBtn.Enabled := sendBtn.Enabled;
//panel.visible:=  ch.who.uin <> 5000;
end; // pageCtrlChange

procedure TchatFrm.inputKeydown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  x, y, i: integer;
  m: Tmemo;
  s: String;
  b: Boolean;
begin
if thisChat <> NIL then
begin
 m := thisChat.input;
 if shift = [ssCtrl] then
  case key of
    VK_BACK:
      begin
      x := m.caretpos.x;
      y := m.CaretPos.y;
      s := m.lines[y];
      if x=0 then
        if y=0 then
          exit
         else
          begin
            m.lines.Delete(y);
            dec(y);
            x:=length(m.lines[y]);
            m.lines[y]:=m.lines[y]+s;
          end
      else
        begin
        while (x>0) and ((x > Length(s)) or (s[x]=' ')) do
          dec(x);
        i:=x-1;
 {$IFDEF UNICODE}
        b :=  s[x].IsLetterOrDigit;
        while (i>0) and ((i > Length(s)) or ((b) = s[i].IsLetterOrDigit)) do
 {$ELSE nonUNICODE}
        b := s[x] in ALPHANUMERIC;
        while (i>0) and ((i > Length(s)) or ((b) = (s[i] in ALPHANUMERIC))) do
 {$ENDIF UNICODE}
          dec(i);
        delete(s, i+1, m.caretpos.x-i);
        m.lines[y] := s;
        x := i;
        end;
      m.caretpos := point(x,y);
      key := 0;
      end;
    end;
  end;
end;

procedure TchatFrm.inputKeyup(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  ch: TchatInfo;
begin
 {$IFDEF CHAT_SPELL_CHECK}
  if not EnableSpellCheck then
    Exit;
  ch := thisChat;
  if ch = nil then
    Exit;
  if SpellTextChanged(ch.input.Text) and not (Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_PRIOR, VK_NEXT, VK_ESCAPE, VK_SHIFT, VK_CONTROL]) then
  begin
    SetSpellText(ch.input.Text);
    SpellCheck;
  end;
 {$ENDIF CHAT_SPELL_CHECK}
end;

procedure TchatFrm.inputPopup(Sender: TObject;
  MousePos: TPoint; var Handled: Boolean);
begin
  enterCount := 0
end;

procedure TchatFrm.inputChange(Sender: TObject);
var
  ch: TchatInfo;
begin
  ch := thisChat;
  if ch <> NIL then
  with ch do
  begin
    if not Assigned(who) then
      Exit;
   // send typing notify
    sbar.panels[0].text := getTranslation('Chars:') + ' ' + intToStr(length(input.Text));
    quoteIdx := -1;
   { $IFDEF RNQ_FULL}
    who.Proto.InputChangedFor(who, length(input.Text) = 0);
   { $ENDIF}
  end;
end;

procedure TchatFrm.Close1Click(Sender: TObject);
begin
  closeThisPage
end;

procedure TchatFrm.Viewinfo1Click(Sender: TObject);
var
  cnt: TRnQContact;
begin
  cnt := thisContact;
  if Assigned(cnt) then
    cnt.ViewInfo;
end;

function TchatFrm.sawAllhere: Boolean;
const
//  clearEvents: array[0..4] of byte = (EK_msg, EK_url, EK_auth, EK_authDenied, EK_addedYou);
  clearEvents = [EK_msg, EK_url, EK_auth, EK_authDenied, EK_addedYou];
var
  c: TRnQcontact;
  ch: TchatInfo;
//  t: byte;
  k: Integer;
  ev0: Thevent;
  found: Boolean;
begin
  result := False;
  found := False;
  ch := thisChat;
  if ch=NIL then
    exit;
  if ch.chatType <> CT_IM then
    Exit;
  c := ch.who;
//  for t in clearEvents do
   begin
     k := -1;
     repeat
       k := eventQ.getNextEventFor(c, k);
//       if (ev0 = nil) then
//         Break;
//       if ev0.kind in clearEvents then
//       begin
//         if not chatFrm.moveToTimeOrEnd(c, ev0.when) then
//            chatFrm.addEvent(c, ev0.clone);
//       k := eventQ.find(t, c);
       if (k >= 0) and (k < eventQ.count) then
         begin
          ev0 := eventQ.items[k];
          if ev0.kind in clearEvents then
           begin
            found := True;
            eventQ.removeAt(k);
            if BE_history in behaviour[ev0.kind].trig then
              if not chatFrm.moveToTimeOrEnd(c, ev0.when, false) then
  //          if fo then
                chatFrm.addEvent(c, ev0.clone);
            try
          //    FreeAndNil(ev);
               ev0.free;
             except
            end;
           end
  //         eventQ.Remove(ev0);
          else
           inc(k);
         end
        else
         k := -1;
     until (k<0);
   end;
{
  if eventQ.removeEvent(EK_msg, c)
    or eventQ.removeEvent(EK_url, c)
    or eventQ.removeEvent(EK_auth, c)
    or eventQ.removeEvent(EK_authDenied, c)
    or eventQ.removeEvent(EK_addedYou, c) then}
   if found then
     begin
      result := TRUE;
      roasterLib.redraw(c);
      saveinboxDelayed := TRUE;
     end;

  TipRemove(c);
end; // sawAllHere



procedure TchatFrm.FormKeyPress(Sender: TObject; var Key: Char);
var
  s: String;
  i, l, k: integer;
  ch: TchatInfo;
begin
if key<>#13 then
  enterCount:=0
else
  begin
    ch := thischat;
  if ch <> NIL then
   if ch.chatType = CT_IM then
    if ActiveControl = w2sBox then
     begin
      SBSearchClick(NIL);
      exit;
     end
    else
     if (ActiveControl = ch.input)  then
      begin
       inc(enterCount);
       if (enterCount=sendOnEnter) then
        begin
         s := ch.input.text;
         l := 2*pred(enterCount);
         k := l;
//         i := 1 + ch.input.SelStart;
         i := ch.input.SelStart;
         while (l >0) and ((s[i] = #10)or(s[i]=#13)) do
          begin
           dec(i);
           dec(l);
          end;
         dec(k, l);
//         delete(s,1 + ch.input.SelStart-l, l);
         delete(s, 1+i, k);
         ch.input.text := s;
         key := #0;
         send;
  //      Exit;
        end;
      end;
  end;
case key of
  #27:begin close; key := #0; end;
  #127,   // ctrl+bs
  #10: key := #0;
//  else
//   Inherited;
  end;
end;

procedure TchatFrm.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  ch: TchatInfo;
  i: Integer;
  b: Boolean;
//  wm : TWMKey;
begin
  ch := thisChat;
//MainDlg.RnQmain.fin
//if ActiveControl then

  if ch = nil then
    Exit;
  if shift = [] then
  case key of
    VK_APPS:
      if Assigned(ch) and (ch.chatType = CT_IM) then
       begin
        clickedContact := ch.who;
        with ch.historyBox.ClientToScreen(ch.historyBox.margin.TopLeft) do
         MainDlg.RnQmain.contactMenu.popup(x, y);
       end;
    VK_BROWSER_BACK:
      begin
        pageCtrl.SelectNextPage(FALSE);
      end;
    VK_BROWSER_FORWARD:
      begin
        pageCtrl.SelectNextPage(True);
      end;
    end
else
if (shift = [ssAlt]) and (ch.chatType = CT_IM) then
  case key of
    VK_A:
      begin
        with autoscrollBtn do
          down := not down;
        autoscrollBtnClick(self);
      end;
    VK_P: prefBtnClick(self);
    VK_I: infoBtnClick(self);
    VK_Q: quote();
    VK_H:
      begin
      with historyBtn do
        down := not down;
      historyBtnClick(self);
      end;
    VK_M:
      begin
//       with smilesBtn do down:=not down;
//       smilesBtnClick(self);
        historyData.hAShowSmilesExecute(Self);
      end;
    VK_BACK: ch.input.Undo();
    VK_S: begin send; key := 0; end;
  end;
// else                    
if ( not useCtrlNumInstAlt and (shift = [ssAlt])) or
     ( useCtrlNumInstAlt and (shift = [ssCtrl])) then
    case key of
     byte('1')..byte('9'): begin
        i := key-byte('1');
        if chats.validIdx(i) then
        if pagectrl.ActivePageIndex <> i then
        begin
           b := True;
           pagectrlChanging(pagectrl, b);
           if b then
             pagectrl.ActivePageIndex := i;
           pageCtrlChange(pagectrl);
           key := 0;
           Shift := [];
           Exit;
        end;
      end;
    end;

if (shift = [ssAlt]) or (shift = [ssAlt,ssCtrl]) then
  case key of
    VK_LEFT:  pageCtrl.SelectNextPage(FALSE);
    VK_RIGHT: pageCtrl.SelectNextPage(TRUE);
    VK_UP,VK_DOWN,VK_PRIOR,VK_NEXT:
      if ch.chatType = CT_IM then
      case key of
        VK_UP:   ch.historyBox.histScrollEvent(-1);
        VK_DOWN: ch.historyBox.histScrollEvent(+1);
        VK_PRIOR:ch.historyBox.histScrollEvent(-5);
        VK_NEXT: ch.historyBox.histScrollEvent(+5);
        end;
    VK_HOME:
      if ch.chatType = CT_IM then
        ch.historyBox.move2start();
    VK_END:
      if ch.chatType = CT_IM then
      begin
//        ch.setAutoscroll(True);
          ch.historyBox.move2end(true);
      end;
    end
else
if shift = [ssCtrl] then
  case key of
    VK_PRIOR:
      if ch.chatType = CT_IM then
        ch.historyBox.histScrollEvent(-5);
    VK_NEXT:
      if ch.chatType = CT_IM then
        ch.historyBox.histScrollEvent(+5);
    VK_RETURN:
      if ch.chatType = CT_IM then
      if sendOnEnter = 1 then
        begin
         i := ch.input.SelStart;
         ch.input.Text := Copy(ch.input.Text, 1, i) + CRLF+
                    Copy(ch.input.Text, i+1, Length(ch.input.Text) - i);
         ch.input.SelStart := i+2;
         ch.input.Perform(EM_SCROLLCARET, 0, 0);
        end
       else send;
    VK_UP:
      if ch.chatType = CT_IM then
        ch.historyBox.histScrollLine(-1);
    VK_DOWN:
      if ch.chatType = CT_IM then
        ch.historyBox.histScrollLine(+1);
    VK_C:
      if ch.chatType = CT_IM then
        if ch.input.selLength=0 then
          begin
            ch.historyBox.copySel2Clpb;
          end;
    VK_F6: pageCtrl.SelectNextPage(TRUE);
    VK_F4, VK_W: try
            sawAllHere;
            closeThisPage;
            key := 0;
//            Shift := [];
            Exit;
          except
          end;
    VK_S:
      if ch.chatType = CT_IM then
   {$IFDEF USE_SMILE_MENU}
       if Assigned(smilesBtn.PopupMenu) then
         with smilesBtn.ClientOrigin do//ClientToScreen(smilesBtn.ClientOrigin) do
          smileMenuExt.Popup(x, y)
        else
   {$ENDIF USE_SMILE_MENU}
         ShowSmileMenu(MainPrefs, smilesBtn.ClientOrigin, Self, OnGetHNDL, self.OnSmileSelect);
    VK_A:
      if (ch.chatType = CT_IM) then
       begin
        if (ActiveControl= ch.input) then
          ch.input.SelectAll
         else
          historyData.hASelectAllExecute(self);
        Key := 0;
       end;
    VK_F:
      begin
           if not({(ActiveControl = MainDlg.RnQmain.roaster) or
                  (ActiveControl = MainDlg.RnQmain.FilterEdit))}
              childParent(getFocus, MainDlg.RnQmain.handle))  then
            begin
             findbtn.down := not findbtn.down;
             findBtnClick(self);
             Key := 0;
            end;
      end;
    end;
 if (shift<>[]) or (key <> 13) then
  enterCount := 0;
 if Assigned(ch) and (ch.chatType = CT_PLUGING) then
  begin
   SendMessage(ch.ID, WM_KEYDOWN, Key, 0);
{   wm.Msg := WM_KEYDOWN;
   wm.CharCode := Key;
   wm.KeyData KeyDataToShiftState
   TControl(ch.ID).WindowProc(
   Perform(WM_KEYDOWN, )}
  end;
  inherited;
end; // keydown

procedure TchatFrm.open(focus: Boolean = TRUE);
var
  bak: Thandle;
  ch: TchatInfo;
begin
  if chats.count = 0 then
    exit;
  if not visible then
    bak := getForegroundWindow
   else
    bak := 0;
  showForm(self);
  if (bak>0) and not focus then
    forceforegroundwindow(bak);
  SetWindowPos(Handle, HWND_TOP, 0,0,0,0, SWP_NOMOVE+SWP_NOSIZE); // bring it atop if it is not
  ch := thisChat;
  if focus then
    begin
      bringForeground := handle;
      if Assigned(ch) then
       if ch.chatType = CT_IM then
         ch.input.setFocus;
    end
   else
    if isVisible then
     if Assigned(ch) then
      if ch.chatType = CT_IM then
        ch.input.setFocus;
end; // open

function TchatFrm.isVisible:boolean;
begin
  result := getForegroundWindow=handle
end;

procedure TchatFrm.quote(qs: String = ''; MakeCarret: boolean = false);
var
  ch: TchatInfo;
  AddToInput: Boolean;
begin
  ch := thisChat;
  if ch = nil then
    exit;

  if Length(qs) > 0 then
    quoteCallback(qs, true, MakeCarret)
  else
  begin
    if ch.historyBox.history.count = 0 then // there's nothing to quote for sure
      Exit;

{$IFDEF CHAT_CEF}
    if quoting.quoteselected then
    begin
      ch.historyBox.copySel2Quote;
    end
    else
    begin
      // save original reply at the beginning of a quoting-cycle
      if ch.quoteIdx < 0 then
        ch.lastInputText := ch.input.text;
      quoteCallback(ch.historyBox.getQuoteByIdx(ch.quoteIdx), false, MakeCarret);
    end;

{$ELSE ~CHAT_CEF}

     begin
      AddToInput := True;
      if quoting.quoteselected then
        qs := trim(ch.historyBox.getSelText)
       else
        qs := '';
      if qs='' then
       begin
        AddToInput := False;
        // save original reply at the beginning of a quoting-cycle
        if ch.quoteIdx < 0 then
          ch.lastInputText := ch.input.text;

        qs := ch.historyBox.getQuoteByIdx(ch.quoteIdx);
       end;
      quoteCallback(qs, AddToInput, MakeCarret);
     end;
{$ENDIF CHAT_CEF}

  end;
end; // quote

procedure TchatFrm.quoteCallback(selected: String = ''; AddToInput: boolean = true; MakeCarret: boolean = false);
var
  i: Integer;
  oldPos: Tpoint;
  s, Result, leading: string;
//  sl, sn: TStringList;
  ch: TchatInfo;

  function addquote(const s: String): String;
  begin
   if (length(leading)>0) and (leading[1] = '>') then
     result := '>' + s
    else
     result := '> ' + s;
  end; // addquote
begin
  ch := thisChat;
  if ch = nil then
    exit;

  with ch do
  begin
   if Assigned(input) and (input.Visible) and input.Enabled then
    input.setFocus;

      if selected='' then
       begin
        AddToInput := False;
        // save original reply at the beginning of a quoting-cycle
        if quoteIdx < 0 then
          lastInputText := input.text;

        selected := historyBox.getQuoteByIdx(quoteIdx);
       end;

  result := '';
  while selected > '' do
   begin
    s := trimright(chop(#10,selected));
    if s='' then
      continue;
    leading := getLeadingInMsg(s);
    if MakeCarret then
      s := wraptext(s, 50);
    result := result + addquote(chop(CRLF, s)) + CRLF;
    while s > '' do
      result := result + addquote(chop(CRLF, s)) + CRLF;
   end;
  i := quoteIdx;
//  Delete(result, length(result)-1, 2);
  oldPos := input.CaretPos;
  if AddToInput then
    input.SelText := result
  else
   begin
    input.text := lastInputText;
    input.lines.add(result);
    if quoting.cursorBelow then
      input.selStart := length(input.text)
    else
      input.CaretPos := oldPos;
   end;
//  input.SelText := result;
  quoteIdx := i;
  end;
end; // quote

procedure TchatFrm.FormActivate(Sender: TObject);
var
  ch: TChatInfo;
begin
 {$IFDEF RNQ_FULL}
  ch := thisChat;
 if ch <> NIL then
   ch.repaint;
 {$ENDIF RNQ_FULL}
end;

procedure TchatFrm.InitScale(Sender: TObject; NewDPI: Integer);
var
  y: Integer;
  i, btnH: integer;
//  PPI: Integer;
  sz: TSize;
  gapY, gapX: Integer;
begin
  if NewDPI > cDefaultDPI then
    begin
      gapY := MulDiv(6, NewDPI, cDefaultDPI);
      gapX := MulDiv(8, NewDPI, cDefaultDPI);
      btnH := MulDiv(21, NewDPI, cDefaultDPI);
    end
   else
    begin
      gapY := 6;
      gapX := 8;
      btnH := 21;
    end
   ;

  //sbar.panels[0].Width:=80;
  with theme.getPicSize(RQteDefault, PIC_OUTBOX, 16, NewDPI) do
   begin
    sbar.panels[1].Width := cx + gapX;
    i := cy + gapY;
   end;
  with theme.getPicSize(RQteDefault, PIC_KEY, 16, NewDPI) do
   begin
    sbar.panels[3].Width := cx + gapX;
    i := max(i, cy + gapY);
   end;
  with theme.getPicSize(RQteDefault, PIC_CLI_QIP, 16, NewDPI) do
   begin
    sbar.panels[3].Width := sbar.panels[3].Width + cx + gapX div 2;
    i := max(i, cy + gapY);
   end;
  sbar.Height := boundInt(i, 22, 50);
  sbar.repaint;

  sz := theme.GetPicSize(RQteDefault, PIC_STATUS_ONLINE, 0, NewDPI);
  y := sz.cy;
  if y > 0 then
    pagectrl.tabHeight := y + gapY
   else
    pagectrl.tabHeight := 0;

  with theme.GetPicSize(RQteButton, PIC_STATUS_ONLINE, icon_size, NewDPI) do
  begin
    btnH := max(btnH, cy + gapY);
  end;
  with theme.GetPicSize(RQteButton, PIC_CLOSE, icon_size, NewDPI) do
  begin
    btnH := max(btnH, cy + gapY);
  end;
  toolbar.Height := btnH + gapY div 3;
  toolbar.ButtonHeight := btnH;
  panel.Height := btnH + gapY * 2;
  toolbar.Top := (panel.ClientHeight - toolbar.Height) div 2;
  SendBtn.Height := btnH;
  closeBtn.Height := btnH;
  SendBtn.Top := (panel.ClientHeight - SendBtn.Height) div 2;
  closeBtn.Top := (panel.ClientHeight - closeBtn.Height) div 2;

//  if usePlugPanel and (plugBtns.PluginsTB <> toolbar) then
//    chat.btnPnl.Height := Max(24, MulDiv(24, NewDPI, cDefaultDPI));

end;

procedure TchatFrm.FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
  NewDPI: Integer);
begin
  InitScale(Sender, NewDPI);
  setupChatButtons;
end;

procedure TchatFrm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  updatechatfrmXY;
  //if searchhistFrm <> nil then
  //  searchhistFrm.Close;
end; // form close

procedure TchatFrm.infoBtnClick(Sender: TObject);
var
  cnt: TRnQContact;
begin
  cnt := thisContact;
  if Assigned(cnt) then
    cnt.ViewInfo;
end;

procedure TchatFrm.updateContactStatus;
var
  cnt: TRnQContact;
  ch: TChatInfo;
begin
  ch := thisChat;
  cnt := thisContact;
  if (cnt=NIL) or (ch = NIL) then
   begin
    sendBtn.ImageName := Account.Accproto.status2imgName(byte(SC_UNK), FALSE);
    exit;
   end;
  sendBtn.ImageName := rosterImgNameFor(cnt);
  sendBtn.Invalidate;
  sbar.Invalidate;

 {$IF Defined(PROTOCOL_ICQ)or Defined(PROTOCOL_WIM)}
  if (ch.chatType = CT_IM) and not (cnt = nil) then
  begin
    BuzzBtn.Visible := cnt.CanBuzz;
    BuzzBtn.Left := RnQFileBtn.Left + RnQFileBtn.Width;
  end;

  {$IFDEF RNQ_AVATARS}
  {$IFDEF FLASH_AVATARS}
    if not cnt.icon.IsBmp then
     with ch.avtPic do
     if Assigned(swf) then
      // Статусы: stam, smile, laugh, mad, sad, cry, offline, busy, love
         case cnt.GetStatus of
           byte(SC_OCCUPIED)..byte(SC_AWAY): swf.TGotoLabel('face', 'busy');
           byte(SC_F4C)     :    swf.TGotoLabel('face', 'smile');
           byte(SC_OFFLINE) :    swf.TGotoLabel('face', 'offline');
           byte(SC_UNK)     :    swf.TGotoLabel('face', 'stam');
           byte(SC_Evil)    :    swf.TGotoLabel('face', 'mad');
           byte(SC_Depression) : swf.TGotoLabel('face', 'sad');
           //swf.TGotoFrame('face', 'stam');
           else
              swf.TGotoFrame('face', 0);
         end;
  {$ENDIF FLASH_AVATARS}
  {$ENDIF RNQ_AVATARS}
 {$IFend PROTOCOL_ICQ}
end; // updateSendBtn

procedure TchatFrm.closePageAt(idx: Integer);
var
  old: TTabSheet;
  oldCh: TchatInfo;
begin
  if (idx<0) or (idx >= pageCtrl.PageCount) then
    exit;
 {$IFDEF SMILES_ANI_ENGINE}
//  rqSmiles.ClearAniParams;
  theme.ClearAniParams;
 {$ENDIF SMILES_ANI_ENGINE}
  oldCh := chats.byIdx(idx);
//  with  do
   begin
    if plugBtns.PluginsTB.Parent = oldCh.btnPnl then
     begin
      plugBtns.PluginsTB.Parent := pagectrl;
     end;
    lastContact := oldCh.who;

    if oldCh.chatType = CT_PLUGING then
     begin
      plugins.castEv(PE_CLOSETAB, oldCh.id);
//    chatFrm.RemoveControl(TWinControl(id));
     end
    else
    if oldCh.chatType = CT_IM then
    begin
     // end typing
      oldCh.who.Proto.InputChangedFor(oldCh.who, True);
       historyData.currentHB := NIl;
      oldCh.historyBox.Visible := false;
//      oldCh.historyBox.newSession := 0;
      if oldCh.historyBox.history<>NIL then
       begin
        FreeAndNil(oldCh.historyBox.history);
       end;

    end;
    old := pageCtrl.Pages[idx];
//    with old do
      begin
{
        while controlCount > 0 do
//          FreeAndNil(controls[0]);
          controls[0].free;
}
      old.pageControl := NIL;
  //    free;
      end;
    chats.Delete(idx);
    oldCh.free;
//    chats.byIdx(idx).Free;
    old.free;
   end;
  if pageCtrl.pageCount = 0 then
    begin
     if docking.Docked2chat then
      begin
  //     docking.Dock2Chat := False;
       applyDocking(True);
      end;
     close
    end
   else
    begin
      pagectrl.repaint;
      if pageCtrl.activePage=NIL  then
        pageCtrl.SelectNextPage(true)
       else
        pageCtrlChange(self)
    end;
  if userTime > 0 then
//  savePages;
    saveListsDelayed := True;
end; // closePageAt

procedure TchatFrm.closeChatWith(c: TRnQContact);
begin
  closePageAt(chats.idxOf(c))
end;

procedure TchatFrm.FormShow(Sender: TObject);
var
//  i: integer;
  ch: TChatInfo;
begin
//  theme.getIco2(PIC_MSG, icon);
  theme.pic2ico(RQteFormIcon, PIC_MSG, icon);
//icon := getIco2('msg');
  applyFormXY;
  lastContact := NIL;
  updateContactStatus;
  ch := thisChat;
  if ch <> NIL then
    ch.repaint();
//  toolbar.buttonheight := panel.Height -18+5;
//  toolbar.buttonheight := 21;
  if plugBtns.PluginsTB <> toolbar then
   begin
     if Assigned(plugBtns.PluginsTB) then
      plugBtns.PluginsTB.buttonheight := max(21, MulDiv(21, GetParentCurrentDpi, cDefaultDPI));
   end;

//  i:=getWindowLong(pagectrl.handle, GWL_EXSTYLE);
//  setWindowLong(pagectrl.handle, GWL_EXSTYLE,  i and (not TCS_OWNERDRAWFIXED) );

//  i := GetClassLong(pagectrl.Handle, GCL_STYLE);
//  SetClassLong(pagectrl.Handle, GCL_STYLE, i and (not TCS_OWNERDRAWFIXED));
end;

procedure TchatFrm.findBtnClick(Sender: TObject);
var
  ch: TchatInfo;
begin
{  if not Assigned(searchHistFrm) then
   begin
     searchHistFrm := TsearchhistFrm.Create(Application);
     translateWindow(searchHistFrm);
   end;
  showForm(searchHistFrm)}
  w2sBox.Visible := findBtn.Down;
  directionGrp.Visible := findBtn.Down;
  directionGrp.ItemIndex := 0;
  caseChk.Visible := findBtn.Down;
  reChk.visible := findBtn.Down;
  SBSearch.Visible := findBtn.Down;
  ch := thisChat;
  if ch <> NIL then
    ch.historyBox.w2s := '';
  fp.Visible := findBtn.Down;
//  SearchPnl.Visible := findBtn.Down;
  if not (historyBtn.Down) and (findBtn.Down) then
     begin
       historyBtn.down := true;
       historyBtnClick(sender);
    end;
  if w2sBox.Visible then
    ActiveControl := w2sBox
   else
    if ch <> NIL then
     ActiveControl := ch.input;
end;

procedure TchatFrm.findBtnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
   showForm(WF_SEARCH);
end;

procedure TchatFrm.quoteBtnClick(Sender: TObject);
begin
  quote
end;

procedure TchatFrm.quoteBtnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
//   quote(clipboard.asText, false);
   quote(clipboard.asText, ssCtrl in Shift);
end;

procedure TchatFrm.smilesBtnClick(Sender: TObject);
//var
//  ch: Tchatinfo;
begin
//  ShowSmileMenu(TRnQSpeedButton(Sender).ClientToScreen(Point(
//      TRnQSpeedButton(Sender).Left, TRnQSpeedButton(Sender).Top)));
  ShowSmileMenu(MainPrefs, toolbar.ClientToScreen(Point(
      TRnQSpeedButton(Sender).Left, TRnQSpeedButton(Sender).Top)),
      Self, OnGetHNDL, OnSmileSelect);
  enterCount := 0;
{  useSmiles := smilesBtn.down;
  ch := thischat;
  if ch=NIL then exit;
  inc(ch.historyBox.history.Token);
  ch.repaint;
  if visible then
    ch.input.SetFocus;}
end;

procedure TchatFrm.smilesBtnMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if (Button<>mbRight) then
    exit;
  ShowSmileMenu(MainPrefs, TRnQSpeedButton(Sender).ClientToScreen(Point(x,y)), Self, OnGetHNDL, OnSmileSelect);
  enterCount := 0;
end;

procedure TchatFrm.closeAllPages(isAuto: Boolean = false);
begin
  if isAuto then
    PagesEnumStr := Pages2String
   else
    PagesEnumStr := '';
  pagectrl.hide;
  while pagectrl.PageCount > 1 do
   if pageIndex=0 then
     closePageAt(1)
    else
     closePageAt(0);
  closePageAt(0);
  pagectrl.show;
end;  // closeAllPages

procedure TchatFrm.autoscrollBtnClick(Sender: TObject);
var
  ch: Tchatinfo;
begin
  ch := thisChat;
  if ch=NIL then
    exit;
  ch.setAutoscroll(autoscrollBtn.down);
  ch.repaint();
  if visible then
    ch.input.SetFocus;
end;

procedure TchatFrm.redrawTab(c: TRnQcontact);
var
  i: Integer;
  R: Trect;
begin
 {$WARN UNSAFE_CODE OFF}
  i := chats.IdxOf(c);
  if (i < 0) or (i >= pagectrl.PageCount) then
    exit;
  SendMessage(pagectrl.Handle, TCM_GETITEMRECT, i, Longint(@R));
  R.right := R.left + 30;
  inc(r.Top, 1);
  dec(r.Bottom, 1);
  invalidateRect(pagectrl.handle, @R, TRUE);
 {$WARN UNSAFE_CODE ON}
end;

procedure TchatFrm.setCaptionFor(c: TRnQContact);
var
  i: Integer;
  w: Integer;
begin
  i := chats.idxOf(c);
  if (i >= 0) AND (i < pagectrl.PageCount) then
   begin
     w := max(pagectrl.Canvas.TextWidth('_'), 5);
     pageCtrl.pages[i].caption :=
     // additional spaces for icon
//    StringOfChar('_',2+theme.getPicSize(RQteDefault, status2imgName(byte(SC_ONLINE)), 16).cx div w);
//       StringOfChar('_',2+ statusDrawExt(0, 0, 0, byte(SC_ONLINE), False, 0, getParentCurrentDPI).cx div w)
    StringOfChar('_',2+theme.getPicSize(RQteDefault, PIC_STATUS_ONLINE, 16, getParentCurrentDPI).cx div w )
       +dupAmperstand(c.displayed);

 {$IFDEF RNQ_FULL}
 {$IFDEF CHECK_INVIS}
//  if c.invisibleState > 0 then
//  pageCtrl.pages[i].caption := pageCtrl.pages[i].caption +
//    StringOfChar('_',1+theme.getPicSize(status2imgName(SC_ONLINE, true), 5).cx div w);
 {$ENDIF}
//  if c.typing.bIsTyping then
//  pageCtrl.pages[i].caption := pageCtrl.pages[i].caption +
//    StringOfChar('_',1+theme.getPicSize(PIC_TYPING, 5).cx div w);
 {$ENDIF}
 end;
end; // setCaptionFor

procedure TchatFrm.setCaption(idx: Integer);
var
//  i: integer;
  c: TRnQcontact;
  R: Trect;
  w: Integer;
begin
//i := chats.idxOf(c);
  if not chats.validIdx(idx) then
    Exit;
  w := max(pagectrl.Canvas.TextWidth('_'), 5);
  if chats.byIdx(idx).chatType = CT_IM then
  begin
   c := chats.byIdx(idx).who;
   begin
    pageCtrl.pages[idx].caption :=
       // additional spaces for icon
//      StringOfChar('_',2+theme.getPicSize(RQteDefault, status2imgName(byte(SC_ONLINE)), 16).cx div w);
//      StringOfChar('_', 2 + statusDrawExt(0, 0, 0, byte(SC_ONLINE), False, 0, getParentCurrentDPI).cx div w)
      StringOfChar('_',2+theme.getPicSize(RQteDefault, PIC_STATUS_ONLINE, 16, getParentCurrentDPI).cx div w)
      +dupAmperstand(c.displayed);
   {$IFDEF RNQ_FULL}
   {$IFDEF CHECK_INVIS}
//    if c.invisibleState > 0 then
//    pageCtrl.pages[idx].caption := pageCtrl.pages[idx].caption +
//      StringOfChar('_',1+theme.getPicSize(status2imgName(SC_ONLINE, true), 5).cx div w);
   {$ENDIF}
//    if c.typing.bIsTyping then
//    pageCtrl.pages[idx].caption := pageCtrl.pages[idx].caption +
//      StringOfChar('_',1+theme.getPicSize(PIC_TYPING, 5).cx div w);
   {$ENDIF}
   end;
  end
  else
    begin
     pageCtrl.pages[idx].caption := chats.byIdx(idx).lastInputText +    // additional spaces for icon
       StringOfChar('_', 2 + theme.getPicSize(RQteDefault, 'plugintab' + IntToStrA(chats.byIdx(idx).ID), 16, getParentCurrentDPI).cx div w);
 {$WARN UNSAFE_CODE OFF}
     SendMessage(pagectrl.Handle, TCM_GETITEMRECT, idx, Longint(@R));
     //R.right := R.left+20;
     invalidateRect(pagectrl.handle, @R, TRUE);
 {$WARN UNSAFE_CODE ON}

    end;
end; // setCaption

procedure TchatFrm.singleBtnClick(Sender: TObject);
begin
  thisChat.single := singleBtn.down
end;

procedure TchatFrm.WndProc(var Message: TMessage);
var
//  ShiftState: TShiftState;
// ti: TTCItem;
  P: TPoint;
  tabindex: Integer;
  ch: TchatInfo;
begin
 case message.msg of
  WM_SYSCOMMAND:
    updatechatfrmXY;

  WM_mousewheel, WM_VSCROLL:
    begin
      ch := thisChat;
      if (Assigned(chats)) and (ch <> NIL) and (ch.chatType = CT_IM) then
     {$IFDEF CHAT_CEF} // Chromium
        SendMessage(ch.historyBox.Handle, message.msg, message.WParam, message.LParam);
     {$ELSE ~CHAT_CEF} // old
        if message.wparam shr 31 > 0 then
          ch.historyBox.histScrollEvent(+wheelVelocity)
         else
          ch.historyBox.histScrollEvent(-wheelVelocity);
     {$ENDIF ~CHAT_CEF}
    end;
{  WM_VSCROLL:
   if (Assigned(chats))and(thisChat <> NIL) and (thisChat.chatType = CT_IM) then
    if message.wparam shr 31 > 0 then
      thisChat.historyBox.histScrollEvent(+wheelVelocity)
    else
      thisChat.historyBox.histScrollEvent(-wheelVelocity);
}
//  WM_ENTERMENULOOP:
//    begin
//      thisChat.historyBox.histScrollEvent(+wheelVelocity)
//    end;
//  WM_EXITMENULOOP:
//    begin
//      clearMenu(smileMenuExt.Items);
//    end;
//   256:
//     begin
//     end;
  WM_KEYDOWN:
    begin
      ch := thisChat;
       if (ch <> nil) and (ch.chatType = CT_PLUGING) then
        begin
   {$WARN UNSAFE_CAST OFF}
         TControl(ch.ID).WindowProc(Message);
   {$WARN UNSAFE_CAST ON}
  //       Perform(WM_KEYDOWN, )
        end;
  {
      with TWMKey(Message) do
        begin
          ShiftState := KeyDataToShiftState(KeyData);
          if (ssCtrl in ShiftState) and (CharCode = VK_F4) then
            try
              sawAllHere;
              closeThisPage;
              Exit;
            except
            end;
        end;}
    end;
  WM_HELP:
    begin
      exit;
    end;
  {
    TCItem.iImage := GetImageIndex(I);
    if SendMessage(Handle, TCM_SETITEM, I,
      Longint(@TCItem)) = 0 then
      TabControlError(Format(sTabFailSet, [FTabs[I], I]));
  end;
  TabsChanged;
  
   }
   WM_TIMER:
 {$WARN UNSAFE_CAST OFF}
      if TWMTimer(Message).TimerID = HintTimer then
 {$WARN UNSAFE_CAST ON}
      begin
        // determine current mouse position to check if it left the window
        GetCursorPos(P);
        P := self.ScreenToClient(P);

        tabindex := pagectrl.IndexOfTabAt(p.X, p.Y);

        StopTimer(HintTimer);

        if not Assigned(hintwnd) or not hintwnd.Visible or (tabindex <> last_tabindex) then
          ShowTabHint(P.X, P.Y);
        last_tabindex := tabindex;
{        with FColumns do
        begin
          if not InHeader(P) or ((FDownIndex > NoColumn) and (FHoverIndex <> FDownIndex)) then
          begin
            Treeview.StopTimer(HeaderTimer);
            FHoverIndex := NoColumn;
            FClickIndex := NoColumn;
            FDownIndex := NoColumn;
            FCheckBoxHit := False;
            Result := True;
            Message.Result := 0;
            Invalidate(nil);
          end;
        end;}
      end;
  end;
  inherited;
end; // WMmouseWheel

procedure TchatFrm.btnContactsClick(Sender: TObject);
begin
  openSendContacts(thisContact)
end;

procedure TchatFrm.chatDragOver(Sender, Source: TObject; X, Y: Integer; State: TDragState; var Accept: Boolean);
begin
  accept := source=MainDlg.RnQmain.roster
end;

procedure TchatFrm.chatDragDrop(Sender, Source: TObject; X, Y: Integer);
var
  cl: TRnQCList;
begin
  if (clickedContact=NIL)or (thisContact = NIL) then
    exit;
  cl := TRnQCList.create;
  cl.add(clickedContact);
   Proto_Outbox_add(OE_contacts, thisContact, 0, cl);
  cl.free;
end;

procedure TchatFrm.updatechatfrmXY;
begin
  if not visible then
    exit;
  if windowState <> wsMaximized then
    begin
      chatfrmXY.top := top;
      chatfrmXY.left := left;
      chatfrmXY.height := height;
      chatfrmXY.width := width;
    end;
  if windowState <> wsMinimized then
    chatfrmXY.maximized := windowState=wsMaximized;
end; // updatechatfrmXY


procedure TchatFrm.historyAllShowChange(ch: TchatInfo; histBtnDown: Boolean);
begin
//  ch := thisChat;
  if ch=NIL then
    exit;

 {$IFDEF CHAT_CEF}
  with ch.historyBox do
  begin
    whole := histBtnDown;
    if whole then
      autoScroll := autoScrollVal
    else
      autoScroll := true;

    ReloadLast;

    autoScrollVal := autoScroll;
  end;
 {$ELSE ~CHAT_CEF}
  {$IFDEF CHAT_SCI}
    ;
  {$ELSE ~CHAT_SCI}
  ch.historyBox.setScrollPrefs(histBtnDown);
  {$ENDIF ~CHAT_SCI}
 {$ENDIF CHAT_CEF}

  if self.visible then
     if ch = thischat then
      try
        ch.input.SetFocus;
       except
      end;
end;

procedure TchatFrm.historyBtnClick(Sender: TObject);
var
//  olds, news: integer;
  ch: TchatInfo;
begin
  ch := thisChat;
  if ch=NIL then
    exit;
  historyAllShowChange(ch, historyBtn.down);
end;

procedure TchatFrm.ShowStickersExecute(Sender: TObject);
 {$IF Defined(PROTOCOL_ICQ)or Defined(PROTOCOL_WIM)}
var
  ch: TchatInfo;
 {$IFend PROTOCOL_ICQ}
begin
 {$IF Defined(PROTOCOL_ICQ)or Defined(PROTOCOL_WIM)}
  ch := thisChat;
  if ch = nil then
    exit;
  ShowStickersMenu(ch.who, Self, stickersBtn.ClientOrigin);
 {$IFend PROTOCOL_ICQ}
end;

procedure TchatFrm.sbarDblClick(Sender: TObject);
var
 ch: TchatInfo;
begin
  with sbar.ScreenToClient(mousePos) do
 case whatStatusPanel(sbar, x) of
  2: begin
       if Assigned(TranslitList) then
        if TranslitList.Count > 0 then
         begin
           ch := thisChat;
           if Assigned(ch) and (ch.chatType = CT_IM) and Assigned(ch.who) then
            begin
             ch.who.SendTransl := not ch.who.SendTransl;
             sbar.Invalidate;
            end;
         end;
     end;
 end;
end;

procedure TchatFrm.sbarDrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
var
  Details: TThemedElementDetails;
  ch: TchatInfo;
// s: String;
  Arect: TRect;
  agR, r2: TGPRect;
  PPI: Integer;
begin
//  statusbar.canvas.Brush.Color := clBtnFace
 StatusBar.Canvas.Font.Assign(Screen.MenuFont);
//  statusbar.canvas.FillRect(rect);
 Arect := rect;
 Arect.Top := 0;
// dec(Arect.Right);
// inc(Arect.Left);
 inc(Arect.Right);
 dec(Arect.Left);
 inc(Arect.Bottom);
 PPI := GetParentCurrentDpi;
 case panel.index of
  1, 2, 3:
      if StyleServices.Enabled then
      begin
//        Details := StyleServices.GetElementDetails(tsGripperPane);
//        Details := StyleServices.GetElementDetails(tsStatusDontCare);
//        Details := StyleServices.GetElementDetails(tsPane);
//        Details := StyleServices.GetElementDetails(tsPane);
        Details := StyleServices.GetElementDetails(tsStatusRoot);
//        StyleServices.DrawElement();
//        StyleServices.DrawElement(statusbar.canvas.Handle, Details, Rect, nil);
        StyleServices.DrawElement(statusbar.canvas.Handle, Details, Arect, nil);
//       StyleServices.DrawParentBackground(StatusBar.Handle, statusbar.canvas.Handle, @Details, false);
      end
      else
        statusbar.canvas.FillRect(rect);
 end;
 ch := thisChat;
 agR.X := Rect.Left;
 agR.Y := Rect.Top+1;
 agR.Width := Rect.Right - Rect.Left;
 agR.Height := Rect.Bottom - Rect.Top;
 case panel.index of
  1: begin
       if Account.outbox.stFor(thisContact) then
         theme.drawPic(statusbar.canvas.Handle, agR, PIC_OUTBOX, True, PPI)
        else
         theme.drawPic(statusbar.canvas.Handle, agR, PIC_OUTBOX_EMPTY, false, PPI)
       ;
     end;
  2: if Assigned(ch) then
     begin
//      s := 'TRLT';
      SetBkMode(StatusBar.Canvas.Handle, TRANSPARENT);
      if (ch.chatType = CT_IM) and Assigned(TranslitList) and (TranslitList.Count > 0) then
       begin
       if ch.who.SendTransl then //and Assigned(TranslitList) and (TranslitList.Count > 0) then
         begin
          statusbar.canvas.Font.Style :=  [fsBold];
//         statusbar.canvas.TextRect(Rect, Rect.Left , Rect.Top, 'TRLT')
//          statusbar.canvas.TextRect(Rect, Rect.Left + (36 - statusbar.canvas.TextWidth(s)) div 2 , Rect.Top+2, 'TRLT')
//         statusbar.canvas.TextRect(Rect, s)
         end
        else
         begin
           statusbar.canvas.Font.Color := clGrayText;
//           statusbar.canvas.Font.Color := clInactiveCaptionText;
//           statusbar.canvas.TextRect(Rect, Rect.Left , Rect.Top, 'TRLT');
//         statusbar.canvas.TextRect(Rect, Rect.Left + (36 - statusbar.canvas.TextWidth(s)) div 2 , Rect.Top+2, 'TRLT')
         end;
        DrawText(StatusBar.Canvas.Handle, 'TRLT', 4, ARect, DT_CENTER or DT_SINGLELINE or DT_VCENTER);
       end;
     end;
 {$IFDEF PROTOCOL_ICQ}
  3: if Assigned(ch) then
      if ch.chatType = CT_IM then
      if ch.who.ProtoID = ICQProtoID then
       if TICQSession(ch.who.Proto).UseCryptMsg and
          (( TICQContact(ch.who).crypt.supportCryptMsg
           or
            TICQSession(ch.who.Proto).useMsgType2for(TICQContact(ch.who))
           )
          or
          ( TICQContact(ch.who).crypt.SupportEcc
           and
            TICQSession(ch.who.Proto).UseEccCryptMsg)
          )
       then
         begin
          if TICQContact(ch.who).crypt.supportEcc then
            begin
               with theme.GetPicSize(RQteDefault, PIC_CLIENT_LOGO, 16, PPI) do
                begin
                  r2 := agR;
                  inc(R2.X, cx+2);
                  dec(R2.Width, cx+3);
                  agR.Width := cx+3;
                  theme.drawPic(statusbar.canvas.Handle, R2, PIC_KEY, True, PPI);
//                    dec(agR.Width, cx+2);
                end;
              theme.drawPic(statusbar.canvas.Handle, agR, PIC_CLIENT_LOGO, True, PPI)
            end
          else
          if TICQContact(ch.who).crypt.supportCryptMsg then
//           theme.drawPic(statusbar.canvas.Handle, rect.left,rect.top+1, PIC_KEY);
            theme.drawPic(statusbar.canvas.Handle, agR, PIC_KEY, True, PPI)
           else
            if CAPS_big_QIP_Secure in TICQContact(ch.who).capabilitiesBig then
             begin
              if TICQContact(ch.who).crypt.qippwd > 0 then
               with theme.GetPicSize(RQteDefault, PIC_CLI_QIP, 16, PPI) do
                begin
                  r2 := agR;
                  inc(R2.X, cx+2);
                  dec(R2.Width, cx+3);
                  agR.Width := cx+3;
                  theme.drawPic(statusbar.canvas.Handle, R2, PIC_KEY, True, PPI);
//                    dec(agR.Width, cx+2);
                end;
              theme.drawPic(statusbar.canvas.Handle, agR, PIC_CLI_QIP, True, PPI)
             end;

         end;
 {$ENDIF PROTOCOL_ICQ}
 {$IFDEF PROTOCOL_WIM}
  3: if Assigned(ch) then
      if ch.chatType = CT_IM then
      if ch.who.ProtoID = WIMProtoID then
       if TWIMSession(ch.who.Proto).UseCryptMsg and
          (( TWIMContact(ch.who).crypt.supportCryptMsg
           or
            TWIMSession(ch.who.Proto).useMsgType2for(TWIMContact(ch.who))
           )
          or
          ( TWIMContact(ch.who).crypt.SupportEcc
           and
            TWIMSession(ch.who.Proto).UseEccCryptMsg)
          )
       then
         begin
          if TWIMContact(ch.who).crypt.supportEcc then
            begin
               with theme.GetPicSize(RQteDefault, PIC_CLIENT_LOGO, 16, PPI) do
                begin
                  r2 := agR;
                  inc(R2.X, cx+2);
                  dec(R2.Width, cx+3);
                  agR.Width := cx+3;
                  theme.drawPic(statusbar.canvas.Handle, R2, PIC_KEY, True, PPI);
//                    dec(agR.Width, cx+2);
                end;
              theme.drawPic(statusbar.canvas.Handle, agR, PIC_CLIENT_LOGO, True, PPI)
            end
          else
          if TWIMContact(ch.who).crypt.supportCryptMsg then
//           theme.drawPic(statusbar.canvas.Handle, rect.left,rect.top+1, PIC_KEY);
            theme.drawPic(statusbar.canvas.Handle, agR, PIC_KEY, True, PPI)
           else
            if CAPS_big_QIP_Secure in TWIMContact(ch.who).capabilitiesBig then
             begin
              if TWIMContact(ch.who).crypt.qippwd > 0 then
               with theme.GetPicSize(RQteDefault, PIC_CLI_QIP, 16, PPI) do
                begin
                  r2 := agR;
                  inc(R2.X, cx+2);
                  dec(R2.Width, cx+3);
                  agR.Width := cx+3;
                  theme.drawPic(statusbar.canvas.Handle, R2, PIC_KEY, True, PPI);
//                    dec(agR.Width, cx+2);
                end;
              theme.drawPic(statusbar.canvas.Handle, agR, PIC_CLI_QIP, True, PPI)
             end;

         end;
 {$ENDIF PROTOCOL_WIM}
  4:
       DrawText(StatusBar.Canvas.Handle, StatusBar.SimpleText, 4, ARect, DT_CENTER or DT_SINGLELINE or DT_VCENTER);

 end;

end;

procedure TchatFrm.setStatusbar(s: String);
begin
  if isUploading then
    s := GetTranslation('Uploading file') + ': ' + IntToStr(Trunc(uploadedSize / uploadSize * 100)) + '%';
  with sbar.Panels do
    items[Count-1].text := s
end;

procedure TchatFrm.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  enterCount := 0;
end;

procedure TchatFrm.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
//var
//  tabindex: Integer;
begin
  hintMode := HM_comm;
{  tabindex := pagectrl.IndexOfTabAt(X, Y);
  if tabindex < 0 then
   begin
    FreeAndNil(hintwnd);
    hintTab := -1;
    exit;
   end;
}
end;

procedure TchatFrm.sbarMouseUp(Sender: TObject; Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
// var
// ch: TchatInfo;
begin
 case whatStatusPanel(sbar, x) of
  1: begin
       if not Assigned(outboxFrm) then
        begin
         outboxFrm := ToutboxFrm.Create(Application);
         translateWindow(outboxFrm);
        end;
       outboxFrm.open(thisContact)
     end;
{  2: begin
       if Assigned(TranslitList) then
        if TranslitList.Count > 0 then
         begin
           ch := thisChat;
           if Assigned(ch) and (ch.chatType = CT_IM) and Assigned(ch.who) then
            begin
             ch.who.SendTransl := not ch.who.SendTransl;
             sbar.Invalidate;
            end;
         end;
     end;
}
 { $IFDEF USE_SECUREIM}
   3: begin
//       if (Button = mbRight)and Assigned(EncryptMenuExt) then
       if Assigned(EncryptMenuExt) then
        with sbar.ClientToScreen(Point(x,y)) do
         EncryptMenuExt.Popup(x,y);
      end;
 { $ENDIF USE_SECUREIM}
 end;
end;

function TchatFrm.moveToTimeOrEnd(c: TRnQcontact; time: Tdatetime; NeedOpen: Boolean = True): Boolean;
var
  ch: TchatInfo;
  ev: Thevent;
  // i: Integer;
begin
  Result := False;
  ch := chats.byContact(c);
  if ch=NIL then
    exit;
  if ch.historyBox.history.Count = 0 then
//    result := True
   else
    begin

 {$IFDEF CHAT_SCI} // Sciter
    ev := ch.historyBox.history.getAt(ch.historyBox.history.count - 1);
    if (ev <> nil) then
      Result := CompareDateTime(ev.when, time) >= 0;

    if Result then
      ch.historyBox.move2end(true)
     else
      ch.historyBox.moveToTime(time);

 {$ELSE ~CHAT_SCI} // ~Sciter

      with ch.historyBox do
       begin
      // i := topVisible;
 {$IF Defined(CHAT_CEF) or Defined(CHAT_SCI)} // Chromium
        go2end;
 {$ELSE ~CHAT_CEF} // old
        go2end(True);
 {$ENDIF ~CHAT_CEF}
        ev := history.getAt(topVisible);
       end;
      if (ev=NIL) or (ev.when > time) then
        result := moveToTime(c, time, NeedOpen);
      if not Result then
        ev := ch.historyBox.history.getAt(ch.historyBox.history.Count-1);
      if (ev <> NIL) then
        result := ev.when >= time
 {$ENDIF CHAT_SCI}

    end;
end; // moveToTimeOrEnd

function TchatFrm.moveToTime(c: TRnQContact; time: Tdatetime; NeedOpen: Boolean = True): boolean;
var
  ch: TchatInfo;
begin
  result := False;
  ch := chats.byContact(c);
  if ch=NIL then
    exit;

  Result := ch.historyBox.moveToTime(time, NeedOpen);
  if ch = thisChat then
    historyBtn.down := ch.historyBox.whole;
end; // moveToTime

procedure TchatFrm.Sendwhenimvisibletohimher1Click(Sender: TObject);
begin
  send(IF_sendWhenImVisible)
end;

procedure TchatFrm.Sendmultiple1Click(Sender: TObject);
var
  wnd: TselectCntsFrm;
  msg: String;
  cnt: TRnQContact;
begin
//msg := grabThisText;
  msg := thisChat.input.text;
  if trim(msg) = '' then
  begin
    msgDlg('Can''t send an empty message', True, mtWarning);
    exit;
  end;
  cnt := thisContact;
 {$WARN UNSAFE_CODE OFF}
  wnd := TselectCntsFrm.doAll(MainDlg.RnQmain,
                              'Send multiple', 'Send message',
                              cnt.Proto,
                              cnt.Proto.readList(LT_ROSTER).clone.add(notinlist),
                              sendMessageAction,
                              [sco_multi, sco_groups, sco_predefined],
                              @wnd
                              );
 {$WARN UNSAFE_CODE ON}
  wnd.toggle(cnt);
//  theme.getIco2(PIC_MSG, wnd.icon);
  theme.pic2ico(RQteFormIcon, PIC_MSG, wnd.icon);
//wnd.extra := Tincapsulate.aString(msg);
  inputChange(self);
end;

procedure TchatFrm.sendMessageAction(sender: Tobject);
var
  wnd: TselectCntsFrm;
  cl: TRnQCList;
  msg: String;
  cnt: TRnQContact;
begin
  msg := grabThisText;
  wnd := (sender as Tcontrol).parent as TselectCntsFrm;
  //msg := (wnd.extra as Tincapsulate).str;
  cl := wnd.selectedList;
  wnd.extra.free;
  wnd.close;
  for cnt in cl do
    Proto_Outbox_add(OE_msg, cnt, IF_multiple, msg);
  cl.free;
end; // sendmessage action

procedure TchatFrm.emojiBtnClick(Sender: TObject);
var
  ch: TchatInfo;
begin
  ch := thisChat;
  if ch = nil then
    exit;
  ShowEmojiMenu(ch.who, Self, emojiBtn.ClientOrigin);
end;

procedure TchatFrm.Closeall1Click(Sender: TObject);
begin
  closeAllPages
end;

procedure TchatFrm.Closeallbutthisone1Click(Sender: TObject);
var
  i, sel: integer;
begin
  try
    pagectrl.hide;
    sel := pageIndex;
    for i := chats.count-1 downto 0 do
      if i<>sel then
        closePageAt(i);
   finally
    pagectrl.show;
  end;
end;

procedure TchatFrm.CloseallOFFLINEs1Click(Sender: TObject);
var
  i: Integer;
  c: TRnQcontact;
begin
  c := thisContact;
 try
  pagectrl.hide;
  for i := chats.count-1 downto 0 do
   if chats.byIdx(i).chatType = CT_IM then
    if chats.byIdx(i).who.isOffline then
      closePageAt(i);
 finally
  pagectrl.show;
  select(c);
 end;
end;

function TchatFrm.grabThisText: String;
begin
  result := thisChat.input.text;
  thisChat.input.text := '';
  // update char counter
  inputChange(self);
end; // grabThisText

procedure TchatFrm.send;
var
  s, s1: string;
  max: integer;
  flag: Integer;
  ch: TchatInfo;
begin
  enterCount := 0;
  flag := 0;
//  if SimplMsgBtn.Down then
//    flag := IF_Simple;
  ch := thisChat;
  if (ch = nil)or(ch.who = nil) then
    Exit;

  max := ch.who.Proto.maxCharsFor(ch.who);
  if length(ch.input.text) > max then
   if MessageDlg(getTranslation('Your message is too long. Max %d characters.\n\n                       Split the message?',[max]),
                mtInformation, [mbYes, mbNo], 0)=mrYes then
  begin
    s := grabThisText;
    repeat
      s1 := copy(s, 1, max-1);
      delete(s, 1, max-1);
      send(flag, s1);
    until length(s)<max;
    send(flag, s);
    exit;
  end else
else
  begin
    s := grabThisText;
    if trim(s)='' then
      begin
       if closeChatOnSend then
        close
      end
    else
      send(flag, s)
  end;
end; // send

procedure TchatFrm.send(flags_: Integer; msg: String = '');
begin
  if (thisChat=NIL) or not sendBtn.Enabled then
    exit;
  if msg='' then
    msg := grabThisText;
  if trim(msg) = '' then
    begin
      msgDlg('Can''t send an empty message', True, mtWarning);
      exit;
    end;
  sawAllhere;
  Proto_Outbox_add(OE_msg, thisChat.who, flags_, msg);
  thisChat.input.setFocus;
  if thisChat.single then
   begin
    if ClosePageOnSingle then
      closeThisPage
     else 
      close;
   end;
end; // send

procedure TchatFrm.select(c: TRnQcontact);
var
  i: integer;
begin
  if c=NIL then
   exit;
  i := chats.idxOf(c);
  if i >= 0 then
   setTab(i);
end; // select

procedure TchatFrm.flash;
var
	rec: FLASHWINFO;
begin
//if doFlashChat then
 begin
  rec.cbSize := sizeOf(rec);
  rec.hwnd := handle;
  rec.dwFlags := FLASHW_CAPTION OR FLASHW_TRAY OR FLASHW_TIMERNOFG;
  rec.dwTimeout := 0;
  rec.uCount := dword(-1);
  flashWindowEx(rec);
 end;
end; // flash

procedure TchatFrm.shake;
const
  MAXDELTA = 8;
  SHAKETIMES = 150;
var
  Task: ITask;
  oRect, wRect: TRect;
  wHandle: HWND;
begin
  wHandle := chatFrm.handle;
  GetWindowRect(wHandle, wRect);
  oRect := wRect;
  Randomize;

  Task := TTask.Create(procedure()
  var
    cnt: Integer;
  begin
    for cnt := 0 to SHAKETIMES do
    begin
      wRect := oRect;
      Types.OffsetRect(wRect, Round(Random(2 * MAXDELTA) - MAXDELTA), 0);
      MoveWindow(wHandle, wRect.Left, wRect.Top, wRect.Right - wRect.Left, wRect.Bottom - wRect.Top, True);
      Sleep(10);
    end;
    MoveWindow(wHandle, oRect.Left, oRect.Top, oRect.Right - oRect.Left, oRect.Bottom - oRect.Top, True);
  end, TThreadPool.Default);
  Task.Start;
end;

procedure TchatFrm.chatsendmenuopen1Click(Sender: TObject);
var
  i: Integer;
  s: String;
begin
  if (thisChat=NIL) or not sendBtn.Enabled then
    exit;
  s := grabThisText;
  if trim(s) = '' then
   begin
    msgDlg('Can''t send an empty message', True, mtWarning);
    exit;
   end;
  for i:=0 to chats.count-1 do
   if chats.byIdx(i).chatType = CT_IM then
     Proto_Outbox_add(OE_msg, chats.byIdx(i).who, IF_multiple, s);
  thisChat.input.setFocus;
end;

procedure TchatFrm.chatcloseignore1Click(Sender: TObject);
begin
  sawAllHere;
  addToIgnoreList(thisContact);
  if messageDlg(getTranslation('Do you want to remove %s from your contact list?', [thischat.who.displayed]), mtConfirmation, [mbYes,mbNo], 0) = mrYes then
    removeFromRoster(thisContact);
  closeThisPage;
end;

function TchatFrm.Pages2String: RawByteString;
var
//  cl: TRnQCList;
  i: integer;
begin
  if (userTime < 0) and (chats.count=0) then
    result := PagesEnumStr
   else
    begin
//      cl:=TRnQCList.create;
      Result := '';
      for i:=0 to chats.count-1 do
       if chats.byIdx(i).chatType = CT_IM then
        begin
//          cl.add(chats.byIdx(i).who);
           result:=result + StrToUTF8(chats.byIdx(i).who.UID) + CRLF;
        end;
//      result := cl.toString;
//      cl.free;
    end;
end;

procedure TchatFrm.InitPrefs(pp: TRnQPref);
begin
  pp.initPrefBool('use-smiles', True);
  pp.initPrefBool('chat-images-enable-stickers', True);
  pp.initPrefBool('chat-images-limit', True);
  pp.initPrefInt('chat-images-width-value', 300);
  pp.initPrefInt('chat-images-height-value', 300);
  pp.initPrefBool('hist-emoji-draw', True);
  pp.initPrefBool('auto-copy', True);
  pp.initPrefBool('auto-deselect', False);

end;

procedure TchatFrm.loadPages(proto: TRnQProtocol; const s: RawByteString);
var
  i: integer;
  s1: RawByteString;
  u: TUID;
  ofs: Integer;
  len: Integer;
begin
 ofs := 1;
// i := 1;
 len := Length(s);
 while ofs<Len do
  begin
    i := posEx(AnsiString(#10), s, ofs);
    if (i>1) and (s[i-1]=#13) then
      dec(i);
    if i=0 then
      i := Len+1;
    s1 := copy(s, ofs, i-ofs);
    try
      u := Raw2UID(s1);
      openOn(proto.getContact(u), True, False);
     except
//      result:=FALSE
    end;
    if s[i]=#13 then
      inc(i);
  //  system.delete(s,1,i);
    ofs := i+1;
  end;
//  cl.fromString(Account.AccProto, s, contactsDB);
  open(True);
end; // loadPages

procedure TchatFrm.loadPages(const cl: TRnQCList);
var
  cnt: TRnQContact;
begin
  for cnt in cl do
    openOn(cnt, True, False);
  open(True);
end;

procedure TchatFrm.closeBtnClick(Sender: TObject);
begin
  sawAllHere;
  closeThisPage
end;

procedure TchatFrm.prefBtnClick(Sender: TObject);
//var
//  i: Byte;
begin
  showForm(WF_PREF, 'Chat', vmShort);

{for i := 0 to length(prefPages)-1 do
 if prefPages[i].Cptn = 'Chat' then break;
prefFrm.SetViewMode(vmShort);
prefFrm.pagesBox.ItemIndex:=i;
prefFrm.pagesBoxClick(NIL); }
end;

procedure TchatFrm.prefBtnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
   showForm(WF_PREF, 'Plugins', vmShort);
end;

   {$IFDEF USE_SMILE_MENU}
procedure TchatFrm.smilesMenuPopup(Sender: TObject);
//var
// r: TRect;
begin
  if smile_theme_token <> theme.token then
   begin
    addSmilesToMenu(self, smileMenuExt.Items, addSmileAction);
    smile_theme_token := theme.token;
   end;
//  if GetWindowRect(smileMenuExt.WindowHandle, r) then
//   GPFillGradient(GetWindowDC(smileMenuExt.WindowHandle), r, theme.GetAColor('menu.fade1', clMenuBar),
//                  theme.GetAColor('menu.fade2', clMenu));
end;

procedure TchatFrm.smilesMenuClose(Sender: TObject);
begin
//  smileMenuExt.Items.Clear;
 theme.ClearAniMNUParams;
///...
end;
   {$ENDIF USE_SMILE_MENU}

procedure TchatFrm.addSmileAction(sender: Tobject);
begin
// thisChat.input.SelText := TRQmenuitem(sender).ImageName;
  thisChat.input.SelText := TRQmenuitem(sender).Caption;
end;

procedure TchatFrm.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  p: TPoint;
  ch: TchatInfo;
begin
 ch := thisChat;
 if Assigned(ch) then
 with ch do
 if chatType = CT_IM then
  begin
   p := input.ScreenToClient(MousePos);
 //  if Assigned(inputPnl) then
   if (p.X > 0) and (p.Y > 0) and
      (p.X < input.Width) and (p.Y < input.height)
      and (input.Lines.Count > 1)
    then
      Exit;
   if Assigned(CLPanel) and docking.Docked2chat then
    begin
     p := CLPanel.ScreenToClient(MousePos);
     if (p.X > 0) and (p.Y > 0) and
        (p.X < CLPanel.Width) and (p.Y < CLPanel.height)
  //      and (input.Lines.Count > 1)
      then
        Exit;
    end;

   if GetKeyState(VK_CONTROL) and $8000 > 0 then
     historyBox.histScrollLine(-wheelVelocity)
    else
     historyBox.histScrollEvent(-wheelVelocity);
   Handled := True;
  end;
end;

procedure TchatFrm.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
var
  p: TPoint;
  ch: TchatInfo;
begin
 ch := thisChat;
 if Assigned(ch) then
 with ch do
 if chatType = CT_IM then
  begin
   p := input.ScreenToClient(MousePos);
   if (p.X > 0) and (p.Y > 0) and
      (p.X < input.Width) and (p.Y < input.height)
      and (input.Lines.Count > 1)
    then Exit;
   if Assigned(CLPanel) and docking.Docked2chat then
    begin
     p := CLPanel.ScreenToClient(MousePos);
     if (p.X > 0) and (p.Y > 0) and
        (p.X < CLPanel.Width) and (p.Y < CLPanel.height)
  //      and (input.Lines.Count > 1)
      then
        Exit;
    end;
   if GetKeyState(VK_CONTROL) and $8000 > 0 then
     historyBox.histScrollLine(+wheelVelocity)
    else
     historyBox.histScrollEvent(+wheelVelocity);
   Handled := True;
  end;
end;

{$IFDEF CHAT_CEF}
procedure TchatFrm.preKeyEvent(Sender: TObject; const browser: ICefBrowser; const event: PCefKeyEvent;
                               osEvent: TCefEventHandle; out isKeyboardShortcut: Boolean; out Result: Boolean);
const
  CtrlA = 1966081;
  CtrlC = 3014657;
var
  ch: TchatInfo;
begin
{
  if (event.native_key_code = CtrlC) then
  begin
    ch := thisChat;
    if ch <> nil then
    begin
    end;
  end;
}
end;

procedure TchatFrm.showHistMenu(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
                                const params: ICefContextMenuParams; const model: ICefMenuModel);
var
  ch: TchatInfo;
begin
  model.Clear;

  ch := thisChat;
  if ch = nil then
     Exit;

  with ch.historyBox do
  if CM_TYPEFLAG_LINK in params.TypeFlags then
  begin
    rightClickedChatItem.kind := PK_LINK;
    rightClickedChatItem.stringData := params.LinkUrl;
  end;
{
  if CM_TYPEFLAG_PAGE in params.TypeFlags then
    OutputDebugString(PChar('Flag: CM_TYPEFLAG_PAGE'));
  if CM_TYPEFLAG_FRAME in params.TypeFlags then
    OutputDebugString(PChar('Flag: CM_TYPEFLAG_FRAME'));
  if CM_TYPEFLAG_LINK in params.TypeFlags then
    OutputDebugString(PChar('Flag: CM_TYPEFLAG_LINK'));
  if CM_TYPEFLAG_MEDIA in params.TypeFlags then
    OutputDebugString(PChar('Flag: CM_TYPEFLAG_MEDIA'));
  if CM_TYPEFLAG_SELECTION in params.TypeFlags then
    OutputDebugString(PChar('Flag: CM_TYPEFLAG_SELECTION'));
  if CM_TYPEFLAG_EDITABLE in params.TypeFlags then
    OutputDebugString(PChar('Flag: CM_TYPEFLAG_EDITABLE'));
}
  del1.enabled := ch.historyBox.wholeEventsAreSelected;
  saveas1.enabled := ch.historyBox.somethingIsSelected;
  copy2clpb.visible := ch.historyBox.somethingIsSelected;
  toantispam.visible := ch.historyBox.somethingIsSelected;
  N2.visible := ch.historyBox.somethingIsSelected;
  copylink2clpbd.visible := CM_TYPEFLAG_LINK in params.TypeFlags;
  addlink2fav.visible := CM_TYPEFLAG_LINK in params.TypeFlags;
  savePicMnu.visible := (CM_TYPEFLAG_MEDIA in params.TypeFlags) and (params.MediaType = CM_MEDIATYPE_IMAGE);
  ViewinfoM.visible := ch.historyBox.rightClickedChatItem.kind = PK_EVENT;
  viewmessageinwindow1.enabled := ch.historyBox.rightClickedChatItem.kind = PK_EVENT;
  selectall1.enabled := ch.historyBox.historyNowCount > 0;

  add2rstr.visible := (CM_TYPEFLAG_LINK in params.TypeFlags) and StartsText('uin:', params.LinkUrl);
  if add2rstr.visible then
  try
    selectedUIN := copy(params.LinkUrl, 5, length(params.LinkUrl));
    addGroupsToMenu(Self, add2rstr, addcontactAction, not ch.who.Proto.isOnline or
      ch.who.Proto.canAddCntOutOfGroup);
  except
    add2rstr.visible := false;
  end;

//  lastClickedItem := pointedItem;
  with thisCHat.historyBox.clientToScreen(Types.Point(params.XCoord, params.YCoord)) do
    histmenu.popup(X, Y);
end;

procedure TchatFrm.customBrowsing(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame;
                         const request: ICefRequest; isRedirect: Boolean; out Result: Boolean);
begin
  Result := true;
  if StartsText('uin:', request.Url) and not (thisChat = nil) then
  begin
    del1.enabled := False;
    saveas1.enabled := False;
    copy2clpb.visible := False;
    toantispam.visible := False;
    N2.visible := False;
    copylink2clpbd.visible := False;
    addlink2fav.visible := False;
    savePicMnu.visible := False;
    ViewinfoM.visible := False;
    viewmessageinwindow1.enabled := False;
    selectall1.enabled := False;

    add2rstr.visible := True;
    try
      selectedUIN := copy(request.Url, 5, length(request.Url));
      addGroupsToMenu(Self, add2rstr, addcontactAction, not thisChat.who.Proto.isOnline or
         thisChat.who.Proto.canAddCntOutOfGroup);
    except
      add2rstr.visible := false;
    end;

    histmenu.popup(mousePos.X, mousePos.Y);
  end
  else
    openURL(request.Url)
end;

{$ELSE ~CHAT_CEF}

{$IFNDEF CHAT_SCI}
procedure TchatFrm.onHistoryRepaint(sender: TObject);
var
  ch: TchatInfo;
begin
  if Sender is THistoryBox then
    begin
      autoscrollBtn.down := THistoryBox(Sender).autoScrollVal;
    end
   else
    begin
      ch := thischat;
      if Assigned(ch) then
      if ch.chatType = CT_IM then
      begin
        autoscrollBtn.down := ch.historyBox.autoScrollVal;
      end;
    end;
end; // onHistoryRepaint
{$ENDIF ~CHAT_SCI}

{$ENDIF CHAT_CEF}


procedure TchatFrm.OnSmileSelect(const S: string);
begin
  thisChat.input.SelText := s;
end;

function  TchatFrm.OnGetHNDL: HWND;
begin
  Result := Handle;
end;

procedure TchatFrm.onTimer;
begin
  historyData.onTimer(NIL);
end;


procedure TchatFrm.pagectrl00MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
if button = mbRight then
  begin
  clickedContact := thisContact;
  if clickedContact <> NIL then
    with mousepos do MainDlg.RnQmain.contactMenu.popup(x,y)
  end
end;


procedure TchatFrm.AvtsplitterMoving(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
begin
  Accept := NewSize > 0;
end;

procedure TchatFrm.AvtSplitterMoved(Sender: TObject);
//var
//  ch : TchatInfo;
begin
  with thisChat do
   if Assigned(avtPic.AvtPBox) then
    if avtsplitr.Left > avtPic.AvtPBox.Left then
     avtsplitr.Left := avtPic.AvtPBox.Left - 1;
end;

var
	// backup the values of autoscroll in the current chat
  bakAutoScroll: boolean;

procedure TchatFrm.splitterMoving(Sender: TObject; var NewSize: Integer; var Accept: Boolean);
begin
  bakAutoScroll := thisChat.historyBox.autoScrollVal
end;

procedure TchatFrm.stickersBtnClick(Sender: TObject);
var
  ch: TchatInfo;
begin
  {$IF Defined(PROTOCOL_ICQ)or Defined(PROTOCOL_WIM)}
  ch := thisChat;
  if ch = nil then
    exit;
  ShowStickersMenu(ch.who, Self, toolbar.ClientToScreen(Types.point(TRnQSpeedButton(Sender).Left, TRnQSpeedButton(Sender).Top)));
  enterCount := 0;
 {$IFend PROTOCOL_ICQ}
end;

procedure TchatFrm.SplitterMoved(Sender: TObject);
begin
 with thisChat do
 begin
//   historyBox.autoScrollVal :=bakAutoScroll;
   if Assigned(inputPnl) then
     splitY := inputPnl.height
   else
     splitY := input.height
 end;
 formresize(self);
end; // splitterMoved


procedure TchatFrm.pagectrlDragDrop(Sender, Source: TObject; X, Y: Integer);
const
  TCM_GETITEMRECT = $130A;
var
  i: Integer;
  oldTabindex, tabindex: integer;
//  r: TRect;
  p: TchatInfo;
begin
  if not (Sender is TPageControl) then
    Exit;
  	//получаем таб под курсором
  tabindex := pagectrl.IndexOfTabAt(X, Y);
  oldTabindex := pagectrl.ActivePageIndex;
  if tabindex = oldTabindex then
    Exit;
  if tabindex < oldTabindex then
    begin
     p := chats[oldTabindex];
     for I := oldTabindex-1 downto tabindex do
      begin
       chats[i+1] := chats[i];
       pagectrl.Pages[i+1].PageIndex := i;
      end;
     chats[Tabindex] := p;
    end
   else
    begin
     p := chats[oldTabindex];
     for I := oldTabindex to tabindex-1 do
      begin
       chats[i] := chats[i+1];
       pagectrl.Pages[i].PageIndex := i+1;
      end;
     chats[Tabindex] := p;
    end;
  //поменяем сведения о чате в активной закладке и в той, на которую навели мышь

  p := chats[tabindex];
	chats[tabindex] := chats[pagectrl.ActivePageIndex];
	chats[pagectrl.ActivePageIndex] := p;


  //устанавливаем таб под курсором в качестве активного
	pagectrl.Pages[pagectrl.ActivePageIndex].PageIndex := tabindex;
{
  with pagectrl do
  begin
    for i := 0 to PageCount - 1 do
    begin
      Perform(TCM_GETITEMRECT, i, lParam(@r));
      if PtInRect(r, Point(X, Y)) then
      begin
        if i <> ActivePage.PageIndex then
          ActivePage.PageIndex := i;
        Exit;
      end;
    end;
  end;
}
end;

procedure TchatFrm.pagectrlDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
var
  i: Integer;
begin
  Accept := False;
//  if (sender is TTabSheet)and (Source is TTabSheet) then
   begin
     i := pagectrl.IndexOfTabAt(X, Y);
//     i:=pageIdxAt(x,y);
//     if i <> TTabSheet(Source).TabIndex then
     if i <> pagectrl.ActivePageIndex then
       Accept := True;
   end
//  else
//    Accept := False;

//  if Sender is TPageControl then
//    Accept := True;

end;

procedure TchatFrm.pagectrlDrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  R: Trect;
  c: TRnQcontact;
  ev: Thevent;
  themePage: TThemedTab;
//  themePage: TThemedButton;
  Details: TThemedElementDetails;
//  oldMode: Integer;
  ci: TchatInfo;
  ss: String;
  p: TPicName;
//  fl: Cardinal;
  fl: TElementEdgeFlags;
  hnd: HDC;
//  ImElm: TRnQThemedElementDtls;
  Pic: TPicName;
  PPI: Integer;
//  i: Integer;
begin
// Exit;
  ci := chats.byIdx(tabindex);
  if ci = NIL then
    Exit;
  c := ci.who;
  R := rect;
//    control.Canvas.Brush.Color := clBlue;
//     control.Canvas.fillrect(r);
//  dec(r.Left, 2);
//  inc(r.Right, 1);
 hnd := control.Canvas.Handle;
 with control.Canvas do
  begin
  if StyleServices.Enabled then
    begin
//      fillrect(r);
//      if Parent.DoubleBuffered then
//        PerformEraseBackground(Control, control.Canvas.Handle)
//      else
//        StyleServices.DrawParentBackground(Control.Handle, control.Canvas.Handle, nil, False)
;
//      inc(r.Left, 2);
//      dec(r.Right, 2);
      inc(r.Top, 1);
//      dec(r.Top, 1);
      if not active then
        inc(r.Right, 1);

//      inc(r.Top, 1);
//      fl := BF_LEFT or BF_RIGHT or BF_TOP;
      fl := [efLeft, efTop, efRight];
      if Active then
        begin
          themePage := ttTopTabItemSelected; //ttTabItemSelected
        end
       else
        begin
          themePage := ttTopTabItemNormal; //ttTabItemNormal;
//          inc(fl, BF_BOTTOM);
          Include(fl, efBottom);
          dec(r.Left, 2);
          inc(r.Bottom, 3);
        end;
{      if active then
        themePage := ttTopTabItemBothEdgeSelected
       else
        themePage := ttTopTabItemBothEdgeNormal;

//      themePage := tpPageRoot;
      if active then
        themePage := ttTabItemLeftEdgeSelected //ttTabItemSelected
       else
        themePage := ttTabItemLeftEdgeNormal //ttTabItemNormal;}
;
      Details := StyleServices.GetElementDetails(themePage);
      StyleServices.DrawElement(hnd, Details, r);
//      StyleServices.DrawEdge(hnd, Details, r, 1, fl);//BF_RECT );
      StyleServices.DrawEdge(hnd, Details, r, [eeRaisedInner], fl);//BF_RECT );
{      rC.Left   := r.Right - 10;
      rC.Right  := rC.Left + 8;
      rC.Top    := r.Top + 2;
      rC.Bottom := rC.Top + 8;
      Details := StyleServices.GetElementDetails(twSmallCloseButtonNormal);
      StyleServices.DrawElement(Handle, Details, rC);
}
//      StyleServices.DrawEdge(Handle, Details, r, 1, BF_LEFT or BF_RIGHT or BF_TOP);

//      Details := StyleServices.GetElementDetails(themePage);
//      StyleServices.DrawElement(Handle, Details, r);
//      control.Canvas.MoveTo(r.Left, r.Top);
//      control.Canvas.LineTo(r.Right, r.Bottom);
//      r := StyleServices.ContentRect(Canvas.Handle, Details, r);
    end
   else
    begin
      fillrect(r);
    end;
  inc(r.left,4);
  inc(r.top, 4);
  dec(r.right); //dec(r.bottom);
  PPI := GetParentCurrentDpi;
//  oldMode:=
 SetBKMode(hnd, TRANSPARENT);
  if ci.chatType = CT_IM then
  begin
    ev := eventQ.firstEventFor(c);
    if (ev<>NIL) //then
//      begin
//      if
      and ((blinking or c.Proto.getStatusDisable.blinking) or not blinkWithStatus) then
       begin
        if (blinking or c.Proto.getStatusDisable.blinking) then
          inc(R.left, 1 + ev.Draw(hnd, R.left,R.top, PPI).cx)
        else
          inc(R.left, 1 + ev.PicSize(PPI).cx);
       end
    else
     begin
       {$IFDEF RNQ_FULL}
        if c.typing.bIsTyping then
//          inc(R.left, 1+theme.drawPic(hnd, R.left,R.top, PIC_TYPING).cx)
          pic := PIC_TYPING
        else
       {$ENDIF}
        if showStatusOnTabs then
         begin
          {$IFDEF RNQ_FULL}
           {$IFDEF CHECK_INVIS}
           if c.isInvisible and c.isOffline then
             pic := status2imgName(byte(SC_ONLINE), True)
  //         with theme.GetPicSize('')
//            inc(R.left, 1+ statusDrawExt(hnd, R.left,R.top, byte(SC_ONLINE), True).cx)
           else
  //           theme.drawPic(control.canvas, R.left,R.top, status2imgName(SC_ONLINE, True)).cx);
           {$ENDIF}
          {$ENDIF}
             pic := c.statusImg;
         end;
       inc(R.left, 1 + theme.drawPic(hnd, R.left,R.top, Pic, True, PPI).cx)
     end;
    if active then
      p := 'chat.tab.active'
     else
      p := 'chat.tab.inactive';
    theme.ApplyFont(p, control.Canvas.Font);

    if UseContactThemes and Assigned(ContactsTheme) then
     begin
      ContactsTheme.ApplyFont(TPicName('group.') + TPicName(AnsiLowerCase(c.getGroupName)) + '.'+p, control.Canvas.Font);
      ContactsTheme.ApplyFont(TPicName(c.UID2cmp) + '.'+p, control.Canvas.Font);
     end;
 hnd := control.Canvas.Handle;

  //  Font.Style := Font.Style + [fsStrikeOut];
//    inc(r.top, 2);
    dec(r.Right);

      if active then
       begin
//        inc(r.top, 2);
//        inc(R.left,2);
         dec(R.Bottom, 2);
       end
      else
       ;

//      oldMode:=
//      SetBKMode(control.Canvas.Handle, TRANSPARENT);
//    TextRect(r, r.Left, r.Top, c.displayed);
//      i := TextHeight(c.displayed);
//    TextRect(r, r.Left, r.Top, );
//    TextOut(r.Left, r.Top, c.displayed);
//    textoutExt
//      ss := c.displayed;
        ss := dupAmperstand(c.displayed);
//      Windows.ExtTextOut(control.Canvas.Handle, r.Left, r.Top, ETO_CLIPPED, @R, PChar(s), Length(s), nil);
      DrawText(hnd, PChar(ss), Length(ss), r,
              DT_LEFT or DT_SINGLELINE or DT_VCENTER);// or DT_ DT_END_ELLIPSIS);
//         textOut(handle, x,y, , j);
//         SetBKMode(Handle, oldMode);
  //  DrawText(Handle, PChar(dupAmperstand(c.displayed)), -1, R, DT_SINGLELINE or DT_WORD_ELLIPSIS{or DT_CENTER or DT_VCENTER});
  //  Font.Style := Font.Style - [fsStrikeOut];
  end
  else
    begin
      inc(R.left, 1+theme.drawPic(hnd, R.left,R.top, 'plugintab' + IntToStrA(chats.byIdx(tabindex).id), True, PPI).cx);
//      oldMode:= SetBKMode(Handle, TRANSPARENT);
      inc(r.top, 2);
      TextOut(r.Left, r.Top, ci.lastInputText);
//            textOut(handle, x,y, , j);
//      SetBKMode(Handle, oldMode);
    end;
 {
   procedure TCustomTabControl.UpdateTabSize;
  begin
    SendMessage(Handle, TCM_SETITEMSIZE, 0, Integer(FTabSize));
    TabsChanged;
  end;

  procedure TCustomTabControl.UpdateTabImages;
  var
    I: Integer;
    TCItem: TTCItem;
  begin
    TCItem.mask := TCIF_IMAGE;
    for I := 0 to FTabs.Count - 1 do
    begin
      TCItem.iImage := GetImageIndex(I);
      if SendMessage(Handle, TCM_SETITEM, I,
        Longint(@TCItem)) = 0 then
        TabControlError(Format(sTabFailSet, [FTabs[I], I]));
    end;
    TabsChanged;
  end;
 }
  end;
{
  if TabIndex < 9 then
   begin
//     s := intToStr(TabIndex);
//     Control.f
     i := control.Canvas.Font.Size;
     control.Canvas.Font.Height := 3;
     control.Canvas.Font.Size := 1;
     control.Canvas.TextOut(r.Right - 8, r.Top, intToStr(TabIndex));
     control.Canvas.Font.Size := i;
   end;
}
end;

procedure TchatFrm.StopTimer(ID: Integer);

begin
  if HandleAllocated then
    KillTimer(Handle, ID);
end;

procedure TchatFrm.ShowTabHint(X, Y: integer);
var
  bmp: Tbitmap;
  hr, r: TRect;
  hintdata: TVTHintData;
  tabindex: integer;
  ch: TchatInfo;
begin
  if not ShowHintsInChat then
    Exit;
  //на всякий случай, убедимся, что старое окно уничтожено
  FreeAndNil(hintwnd);

  //получим индекс закладки
  tabindex := pagectrl.IndexOfTabAt(X, Y);
  ch := NIL;
 {$WARN UNSAFE_CAST OFF}
  if chats.validIdx(tabindex) then
    ch := TchatInfo(chats[tabindex]);
 {$WARN UNSAFE_CAST ON}
  if not Assigned(ch) then
    Exit;
  if (tabindex < 0)or (ch.chatType = CT_PLUGING) then
		exit;

 {$WARN UNSAFE_CODE OFF}
 {$WARN UNSAFE_CAST OFF}
  if not (Assigned(ch.who.data) and Assigned(TCE(ch.who.data^).node)) then
    Exit;
 {$WARN UNSAFE_CODE ON}
 {$WARN UNSAFE_CAST ON}

  //сместим хинт чуть правее и ниже
  X := X + 10;
  Y := Y + 10;

  //вычислим размеры хинта - результат вернется в r
  bmp := createBitmap(1, 1, currentPPI);
  bmp.Canvas.Font := Screen.HintFont;
  drawHint(bmp.canvas, NODE_CONTACT, 0, ch.who, r, True, currentPPI);
  bmp.free;

	//подготовим данные для отрисовки хинта
  hintdata.HintRect := r;
	hintdata.Tree := MainDlg.RnQmain.roster;
  hr := pagectrl.TabRect(tabindex);
  hr.TopLeft :=  HintData.Tree.ScreenToClient(pagectrl.ClientToScreen(hr.TopLeft));
  hr.BottomRight := HintData.Tree.ScreenToClient(pagectrl.ClientToScreen(hr.BottomRight));
  hintdata.Tree.LastHintRect := hr;

 {$WARN UNSAFE_CODE OFF}
 {$WARN UNSAFE_CAST OFF}
  if Assigned(ch.who.data) and Assigned(TCE(ch.who.data^).node) then
    hintdata.Node := TCE(ch.who.data^).node.treenode
 {$WARN UNSAFE_CODE ON}
 {$WARN UNSAFE_CAST ON}
   else
    hintdata.Node := NIL;
  hintdata.HintText := '';
  hintdata.Column := -1;

  r.Left   := r.Left + X;
  r.Top    := r.Top + Y;
  r.Right  := r.Right + X;
  r.Bottom := r.Bottom + Y;
  //переводим прямоугольник хинта к координатам экрана
  //pagectrl.Pages[tabindex].ClientRect.Right
  r.TopLeft :=  pagectrl.ClientToScreen(r.TopLeft);
  r.BottomRight := pagectrl.ClientToScreen(r.BottomRight);

  //и создадим новое
  hintwnd := TVirtualTreeHintWindow.Create(chatFrm);
 {$WARN UNSAFE_CODE OFF}
 	hintwnd.CalcHintRect(10, '', @hintdata); //а эта функция нужна не для того,
 {$WARN UNSAFE_CODE ON}
  // чтобы рассчитать r, как можно было подумать, а лишь для того, чтобы
  //  передать окну @hintdata

	hintwnd.ActivateHint(r, '');
end;

procedure TchatFrm.pagectrlMouseLeave(Sender: TObject);
var
  hw: TVirtualTreeHintWindow;
begin
  StopTimer(HintTimer);
  hw := hintwnd;
  hintwnd := NIL;
  if hw <> nil then
    try
      hw.Free;
     except
    end
end;

procedure TchatFrm.pagectrlMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
//  bmp:Tbitmap;
//  r: TRect;
//  hintdata: TVTHintData;
  tabindex: integer;
  MousePos: TPoint;
  //окно хинта для отображения на закладках окна чата
begin
  if Assigned(pagectrl) then
    tabindex := pagectrl.IndexOfTabAt(X, Y)
   else
    tabindex := 0;
  if tabindex < 0 then
  	exit;
 // ShowTabHint(X, Y);
  if hintwnd <> nil then
   begin
    // если хинт существует, переместим его обновим для нового таба
    if (tabindex <> last_tabindex) then
     begin
 {$WARN UNSAFE_CAST OFF}
      if (TchatInfo(chats[tabindex]).chatType = CT_PLUGING) then
 {$WARN UNSAFE_CAST ON}
       FreeAndNil(hintwnd)
      else
       begin
//        last_tabindex := tabindex;
//        MousePos := pagectrl.ScreenToClient(Mouse.CursorPos);
//        ShowTabHint(X, Y)
//        hintTimer.X := X;
//        hintTimer.Y := Y;
//        hintTimer.Enabled := true;
         StopTimer(HintTimer);
         last_tabindex := -1;
         SetTimer(Handle, HintTimer, 100, nil);
       end;
     end;
    if Assigned(hintwnd) then
     begin
//       hintwnd.Left := Mouse.CursorPos.X + 10;
//       hintwnd.Top := Mouse.CursorPos.Y + 10;
     end;

    //поставим таймер на отключение хинта
    //SetTimer(Handle, HintTimer, 100, nil);
   end
  else
    begin
      //если хинт не существет, запустим таймер для его создания
//      SetTimer(Handle, HintTimer, 500, nil);
     MousePos := pagectrl.ScreenToClient(Mouse.CursorPos);

    //вычислим номер таба под курсором
    //tabindex := pagectrl.IndexOfTabAt(MousePos.X, MousePos.Y);

    //если мышь вышла за пределы контрола, удалим хинт
     if pagectrl.IndexOfTabAt(MousePos.X, MousePos.Y) < 0 then
       FreeAndNil(hintwnd)
      else
       begin
         //если хинта еще нет или поменялся таб, создадим новое окно хинта
         if (hintwnd = nil) {or (pagectrl.IndexOfTabAt(MousePos.X, MousePos.Y) <> last_tabindex)} then
          begin
          ShowTabHint(MousePos.X, MousePos.Y);
//            hintTimer.X := MousePos.X;
//            hintTimer.Y := MousePos.Y;
//            hintTimer.Enabled := true;
          end;

       end;
    end;

  //запомним координаты и номер таба
  LastMousePos.X := X;
  LastMousePos.Y := Y;
{

  tabindex := pagectrl.IndexOfTabAt(X, Y);
  if tabindex < 0 then
   begin
    FreeAndNil(hintwnd);
    hintTab := -1;
    exit;
   end;
  if (tabindex <> hintTab) then
   begin
    FreeAndNil(hintwnd);
    hintTab := -1;
//    exit;
   end;
  if (tabindex = hintTab) then
   Exit;

  hintTab := tabindex;
  r.Left := 0;
  r.Top := 0;
  r.Right := 0;
  r.Bottom := 0;

  bmp := createBitmap(1,1);
  bmp.Canvas.Font := Screen.HintFont;
  drawNodeHint(bmp.canvas, TCE(chats.byIdx(tabindex).who.data^).node.treenode, r);
  bmp.free;

  hintdata.HintRect := r;
	hintdata.Tree := MainDlg.RnQmain.roster;
  hintdata.Node := TCE(chats.byIdx(tabindex).who.data^).node.treenode;
  hintdata.HintText := '';
  hintdata.Column := -1;

  hintwnd := TVirtualTreeHintWindow.Create(chatFrm);
 	hintwnd.CalcHintRect(10, '', @hintdata);

  r.Left := r.Left + X + 20;
  r.Top := r.Top + Y + 20;
  r.Right := r.Right + X + 20;
  r.Bottom := r.Bottom + Y + 20;
  r.BottomRight := ClientToScreen(r.BottomRight);
  r.TopLeft := ClientToScreen(r.TopLeft);

	hintwnd.ActivateHintData(r, '', @hintdata);
// 	hintwnd.Free;
 }
end;

(*
procedure TchatFrm.pagectrlDrawTab(Control: TCustomTabControl;
  TabIndex: Integer; const Rect: TRect; Active: Boolean);
var
  R : Trect;
  c:Tcontact;
  ev:Thevent;
  themePage: TThemedTab;
//  themePage: TThemedButton;
  Details: TThemedElementDetails;
//  oldMode: Integer;
  ci : TchatInfo;
  dc  : HDC;
  ABitmap : HBITMAP;
  j : Integer;
//  fullR : TRect;
begin
  ci := chats.byIdx(tabindex);
  if ci = NIL then Exit;
  c := ci.who;
  R := rect;
  j := 0;
//with control.Canvas do
  try
    DC := CreateCompatibleDC(control.Canvas.Handle);
    with r do
    begin
      ABitmap := CreateCompatibleBitmap(control.Canvas.Handle, Right-Left, Bottom-Top);
      if (ABitmap = 0) and (Right-Left + Bottom-Top <> 0) then
        raise EOutOfResources.Create('Out of Resources');
      SelectObject(DC, ABitmap);
      SetWindowOrgEx(DC, Left, Top, Nil);
    end;
  finally

  end;

  begin
  if ThemeServices.ThemesEnabled then
    begin
      fillrect(DC, r, Control.Brush.Handle);
      inc(r.Left, 2);
//      dec(r.Right, 2);
//      inc(r.Top, 2);

      inc(r.Top, 1);
      if active then
        themePage := ttTopTabItemSelected //ttTabItemSelected
       else
        themePage := ttTopTabItemNormal //ttTabItemNormal;
;
      Details := ThemeServices.GetElementDetails(themePage);
      ThemeServices.DrawElement(DC, Details, r);
      ThemeServices.DrawEdge(DC, Details, r, 1, BF_LEFT or BF_RIGHT or BF_TOP);
    end
   else
    begin
      fillrect(DC, r, Control.Brush.Handle);
    end;
      inc(r.left,4); inc(r.top,4);
      dec(r.right); //dec(r.bottom);
      if active then
       begin
        inc(r.top, 2);
        inc(R.left,2);
       end;

//  oldMode:=
SetBKMode(Handle, TRANSPARENT);
  if ci.chatType = CT_ICQ then
  begin
    ev := eventQ.firstEventFor(c);
    if (ev<>NIL) //then
//      begin
//      if
      and (blinking or onStatusDisable[icq.myinfo.status].blinking) then
        inc(R.left, 1 + theme.drawPic(DC, R.left,R.top, ev.pic,
                ev.themeTkn, ev.picLoc, ev.picIdx).cx)
{       else
        inc(R.left, 1 + Theme.getPicSize(ev.pic,
                ev.themeTkn, ev.picLoc, ev.picIdx).cx);
      end}
    else
     {$IFDEF RNQ_FULL}
      if c.typing.bIsTyping then
        inc(R.left, 1+theme.drawPic(DC, R.left,R.top, PIC_TYPING).cx)
      else
     {$ENDIF}
      if showStatusOnTabs then
        inc(R.left, 1+statusDrawExt(DC, R.left,R.top, c.status, c.invisible, c.xStatus).cx);
    {$IFDEF RNQ_FULL}
     {$IFDEF CHECK_INVIS}
    if c.invisibleState > 0 then
     inc(R.left, 1+ statusDrawExt( DC, R.left,R.top, SC_ONLINE, True).cx);
//           theme.drawPic(control.canvas, R.left,R.top, status2imgName(SC_ONLINE, True)).cx);
     {$ENDIF}
    {$ENDIF}
  //  Font.Style := Font.Style + [fsStrikeOut];
//         TextOut(r.Left, r.Top, c.displayed);
         windows.TextOut(DC, r.Left, r.Top, PAnsiChar(c.displayed), j);
//         textOut(handle, x,y, , j);
//         SetBKMode(Handle, oldMode);
  //  DrawText(Handle, PChar(dupAmperstand(c.displayed)), -1, R, DT_SINGLELINE or DT_WORD_ELLIPSIS{or DT_CENTER or DT_VCENTER});
  //  Font.Style := Font.Style - [fsStrikeOut];
  end
  else
    begin
      inc(R.left, 1+theme.drawPic(control.canvas.Handle, R.left,R.top, 'plugintab' + IntToStr(chats.byIdx(tabindex).id)).cx);
//      oldMode:= SetBKMode(Handle, TRANSPARENT);
//      TextOut(r.Left, r.Top, ci.lastInputText);
           windows.TextOut(DC, r.Left, r.Top, PAnsiChar(ci.lastInputText), j);
//      SetBKMode(Handle, oldMode);
    end;
  end;
  BitBlt(Control.Canvas.Handle, rect.Left, rect.Top,
    rect.Right - rect.Left, rect.Bottom - rect.Top,
    dc, rect.Left, rect.Top, SrcCopy);

  DeleteObject(ABitmap);
  DeleteDC(DC);
end; *)

procedure TchatFrm.ANothingExecute(Sender: TObject);
begin
//
end;

procedure TchatFrm.CloseallandAddtoIgnorelist1Click(Sender: TObject);
var
  i: Integer;
begin
  if messageDlg(getTranslation('Move to ignorelist all "not in list"?'),
      mtConfirmation, [mbYes,mbNo], 0) <> mrYes then
    Exit;
  try
    pagectrl.hide;
    for i:=chats.count-1 downto 0 do
     if chats.byIdx(i).chatType = CT_IM then
      if notInList.exists(chats.byIdx(i).who) then
     begin
       addToIgnoreList(chats.byIdx(i).who);
       removeFromRoster(chats.byIdx(i).who);
       closePageAt(i);
     end;
  finally
    pagectrl.show;
  end;
end;

procedure TchatFrm.RnQPicBtnClick(Sender: TObject);
var
  fn: String;
  PicMaxSize: Integer;
//  s, s2: AnsiString;
  s, s2: RawByteString;
  sU: String;
  isRnQPic: Boolean;
//  bmp: TBitmap;
  fs: TFileStream;
begin
  if OpenSaveFileDialog(Application.Handle, '*',
     getSupPicExts //+ ';'#0 + 'R&Q Pics Files (wbmp)|*.wbmp'
     , '', 'Select R&Q Pic File', fn, True) then
//  if OpenPicDlg.Execute then
  begin
    if not FileExists(fn) then
     begin
      msgDlg('File doesn''t exist', true, mtError);
       exit;
     end;
    if not isSupportedPicFile(fn) then
     begin
       msgDlg('This picture format is not supported', True, mtError);
       exit;
     end;

    PicMaxSize := round(thisChat.who.Proto.maxCharsFor(thisChat.who, True) * 3 / 4 )- 100;

    fs := TFileStream.Create(fn, fmOpenRead or fmShareDenyNone);
    sU := SysUtils.ExtractFileExt(fn);
    isRnQPic := (sU = '.wbmp')or(sU = '.wbm');

    if (not isRnQPic and (fs.Size > PicMaxSize)) or (fs.Size < 4) then
     begin
       msgDlg('Max ' + IntToStr(PicMaxSize) + ' bytes', true, mtError);
       msgDlg('This file is too big', True, mtError);
       fs.Free;
       exit;
     end;
    if (isRnQPic and (fs.Size > 0)) or (fs.Size < 4) then
     begin
       // Unsupported for now!
//       msgDlg('Max ' + IntToStr(0) + ' bytes', true, mtError);
       msgDlg('This image format is unsupported for now', True, mtError);
       fs.Free;
       exit;
     end;
    setLength(s, fs.Size);
    if fs.Size > 1 then
 {$WARN UNSAFE_CODE OFF}
      fs.Read(s[1], length(s))
 {$WARN UNSAFE_CODE ON}
     else
      s := '';
    fs.Free;
    s2 := Base64EncodeString(s);
    s := '';
    sU := String( RnQImageExTag + s2 + RnQImageExUnTag );
    Proto_Outbox_add(OE_msg, thisChat.who, IF_Bin, sU);
    s2 := '';

  end;
end;

procedure TchatFrm.RnQSpeedButton1Click(Sender: TObject);
begin
  if Assigned(histPM) then
    histPM.popup(mousePos.X, mousePos.Y);
//  ThistoryBox.popupmenu;
end;

{procedure TchatFrm.process_tZers(ASender: TObject; percentDone: Integer);
begin
  if percentDone = 100 then
   ASender.Free;
end;

procedure TchatFrm.state_tZers(ASender: TObject; newState: Integer);
begin
// if newState = 4 then
//   ASender.Free;
end;

procedure TchatFrm.RnQSpeedButton1Click(Sender: TObject);
begin
  tZers := TShockwaveFlash.Create(self);
//  tZers.Left := 0;
//  tZers.Top  := 0;
//  tZers.Width := ClientWidth;
//  tZers.Height := ClientHeight;
         tZers.parent := pagectrl;
         tZers.align  := alClient;
  tZers.OnProgress := process_tZers;
  tZers.OnReadyStateChange := state_tZers;
  tZers.BackgroundColor := -1;
  tZers.WMode := 'Transparent';
//  tZers.TSetPropertyNum('/', 6, 1);
  tZers.Movie := myPath + 'boo.swf';
  tZers.Repaint;
  tZers.Play;
end;}

procedure TchatFrm.BuzzBtnClick(Sender: TObject);
var
  ch: TchatInfo;
  ev: THevent;
begin
  ch := thisChat;

  if not OnlFeature(ch.who.Proto) then
    Exit;

  if (ch = nil) or (ch.who = nil) then
    exit;

  if ch.who.sendBuzz then
    begin
      ev := THevent.new(EK_buzz, ch.who.Proto.getMyInfo, Now, '', '', 0);
      ev.fIsMyEvent := True;
      if logpref.writehistory and (BE_save in behaviour[ev.kind].trig) then
        writeHistorySafely(ev);
      chatFrm.addEvent(ch.who, ev);
    end
   else
    msgDlg('Wait at least 15 seconds before buzzing again', True, mtInformation)
end;

procedure TchatFrm.SBSearchClick(Sender: TObject);
var
  dir: THistSearchDirection;
  found: Boolean;
begin
  if w2sBox.text = '' then
    begin
      sbar.simpletext := getTranslation('Type what you want to search...!');
      if w2sBox.Enabled and w2sBox.Visible then
        w2sBox.setFocus;
      exit;
    end;

  case directionGrp.itemIndex of
    0: dir := hsdFromBegin;
    1: dir := hsdFromEnd;
    2: dir := hsdBack;
    3: dir := hsdAhead;
   else
    dir := hsdFromBegin;
  end;
  found := false;

 if (thisChat<>NIL)and(thisChat.chatType = CT_IM) then
   found := thisChat.historyBox.search(w2sBox.text, dir, caseChk.checked, reChk.checked);

  if found then
    begin
      sbar.simpletext := getTranslation('Found!');
      case directionGrp.itemIndex of
        0: directionGrp.itemIndex := 3;
        1: directionGrp.itemIndex := 2;
       end;
      exit;
    end;
  sbar.simpletext := getTranslation('Nothing found, sorry');
  w2sBox.setFocus;
end;

procedure TchatFrm.w2sBoxKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if key=VK_RETURN then
    SBSearchClick(Sender);
end;

procedure TchatFrm.RnQFileBtnClick(Sender: TObject);
 {$IFDEF usesDC}
var
  fn: String;
 {$ENDIF usesDC}
begin
 {$IFDEF usesDC}
  fn := openSaveDlg(self, 'Select file to transfer', True);
  if fn > '' then
//  if OpenSaveFileDialog(Application.Handle, '*',
//     'Any file|*.*', '', 'Select file to transfer', fn, True) then
//  if OpenPicDlg.Execute then
  begin
    if not FileExists(fn) then
     begin
       msgDlg('File doesn''t exist', true, mtError);
       exit;
     end;
    if Assigned(thisChat.who) then
      thisChat.who.SendFilesTo(fn);
  end;
 {$ENDIF usesDC}

 {$IFDEF SEND_FILE}
  SendFAM(thisChat.who.uin);
 {$ENDIF}
end;

procedure TchatFrm.RnQFileUploadClick(Sender: TObject);
var
  fn, url: String;
  ch: TChatInfo;
//  ServerToUpload: Integer;
begin
  fn := openSaveDlg(self, 'Select file to transfer', true);
  if fn > '' then
  // if OpenSaveFileDialog(Application.Handle, '*',
  // 'Any file|*.*', '', 'Select file to transfer', fn, True) then
  // if OpenPicDlg.Execute then
  begin
    if not FileExists(fn) then
    begin
      msgDlg('File doesn''t exist', true, mtError);
      Exit;
    end;
    ch := thisChat;
    if Assigned(ch.who) then
    begin
      RnQFileBtn.Enabled := False;
      try
//        ServerToUpload := MainPrefs.getPrefIntDef('file-transfer-upload-server', 0);
//        if ServerToUpload = 0 then
          url := UploadFileRGhost(NIL, fn, OnUploadSendData)
//        else
//          url := UploadFileRnQ(fn, OnUploadSendData);
      finally
        RnQFileBtn.Enabled := True;
      end;

      if not (trim(url) = '') and not (ch = nil) and Assigned(ch.input) then
        ch.input.SelText := trim(url);
    end;
  end;
end;

procedure TchatFrm.RnQFileUploadRClick(Sender: TObject);
var
  fn, url: String;
  ch: TChatInfo;
//  ServerToUpload: Integer;
begin
  fn := openSaveDlg(self, 'Select file to transfer', true);
  if fn > '' then
  // if OpenSaveFileDialog(Application.Handle, '*',
  // 'Any file|*.*', '', 'Select file to transfer', fn, True) then
  // if OpenPicDlg.Execute then
  begin
    if not FileExists(fn) then
    begin
      msgDlg('File doesn''t exist', true, mtError);
      Exit;
    end;
    ch := thisChat;
    if Assigned(ch.who) then
    begin
      RnQFileBtn.Enabled := False;
      try
        url := UploadFileRnQ(NIL, fn, OnUploadSendData);
      finally
        RnQFileBtn.Enabled := True;
      end;

      if not (trim(url) = '') and not (ch = nil) and Assigned(ch.input) then
        ch.input.SelText := trim(url);
    end;
  end;
end;

procedure TchatFrm.RnQFileUploadMClick(Sender: TObject);
// MultiFile upload
var
  fn, url: String;
  ch: TChatInfo;
begin
  fn := openSaveDlg(self, 'Select several files to transfer', true, '', '', '', True);
  if fn > '' then
  begin
//    if not FileExists(fn) then
//    begin
//      msgDlg('File doesn''t exist', true, mtError);
//      Exit;
//    end;
    ch := thisChat;
    if Assigned(ch.who) then
    begin
      RnQFileBtn.Enabled := False;
      try
        url := UploadTarFileRnQ(fn, OnUploadSendData);
      finally
        RnQFileBtn.Enabled := True;
      end;

      if not (trim(url) = '') and not (ch = nil) and Assigned(ch.input) then
        ch.input.SelText := trim(url);
    end;
  end;
end;

procedure TchatFrm.OnUploadSendData(Sender: TObject; Buffer: Pointer; Len: Integer);
begin
  inc(uploadedSize, len);
  if Assigned(chatFrm) and chatFrm.Visible then
    chatFrm.setStatusbar('');
end;

procedure TchatFrm.RnQFileBtnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if Button = mbRight then
//    showForm(WF_PREF, 'Other', vmShort);
    if Assigned(FileSendMenu) then
      with RnQFileBtn.ClientToScreen(Point(x,y)) do
        FileSendMenu.Popup(x,y);
end;

procedure TchatFrm.FormDeactivate(Sender: TObject);
begin
 {$IFDEF RNQ_FULL}
//  theme.ClearAniParams;
 {$ENDIF RNQ_FULL}
end;

procedure TchatFrm.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FAniTimer);
  FreeAndNil(plugBtns);
  FreeAndNil(chats);
end;

procedure TchatFrm.FormHide(Sender: TObject);
begin
 {$IFDEF SMILES_ANI_ENGINE}
//  rqSmiles.ClearAniParams;
  theme.ClearAniParams;
 {$ENDIF SMILES_ANI_ENGINE}
 {$IFDEF RNQ_FULL}
//  if Assigned(FSmiles) then
//    FSmiles.Hide;
 {$IF Defined(PROTOCOL_ICQ)or Defined(PROTOCOL_WIM)}
  if Assigned(FStickers) then
    FStickers.Hide;
 {$IFend PROTOCOL_ICQ}
 {$ENDIF RNQ_FULL}
end;

{$IFDEF CHAT_SCI}
procedure TchatFrm.UpdateChatSettings;
var
  i: Integer;
begin
  for i := 0 to chats.count - 1 do
    if Assigned(chats.byIdx(i)) and (chats.byIdx(i).chatType = CT_IM) then
      chats.byIdx(i).historyBox.InitSettings;
end;

procedure TchatFrm.UpdateChatSmiles;
var
  i: Integer;
begin
  for i := 0 to chats.count - 1 do
    if Assigned(chats.byIdx(i)) and (chats.byIdx(i).chatType = CT_IM) then
      chats.byIdx(i).historyBox.UpdateSmiles;
end;
{$ENDIF CHAT_SCI}

procedure TchatFrm.UpdatePluginPanel;
begin
  if not Assigned(plugBtns.PluginsTB) then
   begin
//  usePlugPanel := True;
    if not usePlugPanel then
     plugBtns.PluginsTB := toolbar
    else
     begin
      plugBtns.PluginsTB := TToolBar.Create(pagectrl);
      plugBtns.PluginsTB.Parent := panel;
      plugBtns.PluginsTB.AutoSize := True;
      plugBtns.PluginsTB.Transparent := False;
      plugBtns.PluginsTB.Wrapable := False;
//      plugBtns.PluginsTB.
     end
   end
  else
    if (not usePlugPanel) then
      begin
       if(plugBtns.PluginsTB <> toolbar) then
        begin
          plugBtns.PluginsTB.Free;
          plugBtns.PluginsTB := toolbar;
        end
      end
    else
     begin
      plugBtns.PluginsTB := TToolBar.Create(pagectrl);
      plugBtns.PluginsTB.Parent := panel;
      plugBtns.PluginsTB.AutoSize := True;
      plugBtns.PluginsTB.Transparent := False;
      plugBtns.PluginsTB.Wrapable := False;
//      plugBtns.PluginsTB.
     end
end;


//----------------------------------------------------------------------------------------------------------------------
procedure TchatInfo.updateAutoscroll(Sender: TObject);
begin
  if Assigned(historyBox) then
  begin
    if Assigned(chatFrm)and Assigned(chatFrm.autoscrollBtn) then
      chatFrm.autoscrollBtn.down := historyBox.autoScrollVal;
//    historyBox.autoscroll := historyBox.autoscroll;
  end;
end;

function CHAT_TAB_ADD(Control: Integer; iIcon: HIcon; const TabCaption: string): Integer;
var
  sheet: TtabSheet;
  chat: TchatInfo;
//  pnl,
  pnl2: TPanel;
  c: TRnQContact;
  i: Integer;
begin

 {$IFDEF SMILES_ANI_ENGINE}
//  rqSmiles.ClearAniParams;
  theme.ClearAniParams;
 {$ENDIF SMILES_ANI_ENGINE}

  for i:=0 to chatFrm.chats.count-1 do
  begin
    if chatFrm.chats.byIdx(i).ID = Control then
    begin
      chatFrm.setTab(i);
      result := -1;
      Exit;
    end;
  end;

  with chatFrm do
  begin
//    c := MainProto.getContactClass.create('PLUGIN');
//    c.nick:= TabCaption;
//    c.status:= SC_OFFLINE;
    c := NIL;
    chat := TchatInfo.create;
//    chat.who := c;
    chat.who := NIL;
    chat.chatType := CT_PLUGING;
    chat.single := singleDefault;
//    if not assigned(pTCE(c.data).history) then
//      pTCE(c.data).history:=Thistory.create;

    sheet := TtabSheet.create(chatFrm);
    chatFrm.chats.Add(chat);
    sheet.PageControl := pageCtrl;
    setCaptionFor(c);
    pnl2 := TPanel.create(sheet);
    pnl2.parent := sheet;
    pnl2.align := alClient;
    pnl2.BevelInner  := bvNone;
    pnl2.BevelOuter  := bvNone;
    pnl2.BorderStyle := bsNone;
    pnl2.BringToFront;
    //pnl2.caption := TabCaption;
    pnl2.Tag := 5000;

//    chat.input.visible := false;
//    chat.splitter.visible := false;
    chat.id := Control;
//    chatFrm.InsertControl(TWinControl(Control));
    if iIcon <> 0 then
    begin
//      theme.addprop('plugintab' + intToStr(chat.id), iIcon, True);
      theme.addHIco('plugintab' + intToStrA(chat.id), iIcon, True);
    end;
    chat.lastInputText := TabCaption;
    resize;
//    savePages;
    saveListsDelayed := True;
    pageCtrl.ActivePageIndex := sheet.pageIndex;

    chatFrm.setCaption(sheet.pageIndex);

    pagectrlChange(pageCtrl);

 {$WARN UNSAFE_CAST OFF}
    result := Integer(pnl2);
 {$WARN UNSAFE_CAST ON}
  end;
end;

procedure CHAT_TAB_MODIFY(Control: Integer; iIcon: HIcon; const TabCaption: string);
var
//  sheet: TtabSheet;
  chat: TchatInfo;
//  pnl,
//  pnl2: Tpanel;
//  c: Tcontact;
  i, curIdx: Integer;
begin
  chat := NIL;
  curIdx := -1;
  for i:=0 to chatFrm.chats.count-1 do
  begin
    if chatFrm.chats.byIdx(i).ID = Control then
    begin
      chat := chatFrm.chats.byIdx(i);
      curIdx := i;
//      chat.lastInputText := TabCaption;
      Break;
    end;
  end;
  if chat = NIL then
   Exit;
  if iIcon <> 0 then
  begin
//    theme.addprop('plugintab' + intToStr(chat.id), iIcon, True);
    theme.addHIco('plugintab' + intToStrA(chat.id), iIcon, True);
  end;
    chat.lastInputText := TabCaption;
//    pageCtrl.ActivePageIndex := sheet.pageIndex;
   chatFrm.setCaption(curIdx);
//  chatFrm.pagectrl.Pages[i].
//  chatFrm.pagectrlChange(NIL);

//    result := Integer(pnl2);
end;

procedure CHAT_TAB_DELETE(Control: Integer);
var
//  chat:TchatInfo;
//  c: Tcontact;
  //curIdx,
  i : Integer;
begin
//  chat := NIL;
//  curIdx := -1;
  for i:=0 to chatFrm.chats.count-1 do
  begin
    if chatFrm.chats.byIdx(i).ID = Control then
    begin
//      chat := chatFrm.chats.byIdx(i);
//      curIdx := i;
      chatFrm.closePageAt(i);
//      chat.lastInputText := TabCaption;
      Break;
    end;
  end;
end;

procedure TchatFrm.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
{  with Params do
  begin
//    Style := Style and (not WS_CAPTION);
//    Style := Style and not WS_OVERLAPPEDWINDOW or WS_BORDER and (not WS_CAPTION);
//    Style := (Style or WS_POPUP) and (not WS_DLGFRAME);
    Style := Style or WS_SYSMENU;
    ExStyle := ExStyle or WS_EX_APPWINDOW or WS_EX_NOPARENTNOTIFY;
  end;}
end;

procedure TchatFrm.WMEXITSIZEMOVE(var Message: TMessage);
var
  ch: TchatInfo;
begin
  inherited;
  ch := thisChat;
  if ch = NIL then
    exit;
  if ch.chatType = CT_PLUGING then
    plugins.castEv(PE_SELECTTAB, ch.id);
end;

procedure TchatFrm.closemenuPopup(Sender: TObject);
var
  ch: TchatInfo;
begin
  ch := thisChat;
  if ch = NIL then
    exit;
//  chatcloseignore1.visible:= ch.chatType <> CT_PLUGING;
//  CloseallandAddtoIgnorelist1.visible:= ch.chatType <> CT_PLUGING;
end;

procedure TchatFrm.AvtPBoxPaint(Sender: TObject);
var
//  gr: TGPGraphics;
//  ia: TGPImageAttributes;
  cnt: TRnQContact;
  ch: TchatInfo;
  sz: TSize;
begin
  {$IFDEF RNQ_AVATARS}
  ch  := thisChat;
  cnt := thisContact;
  if Assigned(cnt) then
  if sender is TPaintBox then
   if Assigned(cnt.icon.Bmp) and not Assigned(ch.avtPic.PicAni) then
   begin
//          TPaintBox(sender).Canvas.Brush.Color := paramSmile.color;
    TPaintBox(sender).Canvas.FillRect(TPaintBox(sender).Canvas.ClipRect);
//    SetStretchBltMode(TPaintBox(sender).Canvas.Handle, HALFTONE);
    sz := cnt.icon.Bmp.GetSize(currentPPI);

    DrawRbmp(TPaintBox(sender).Canvas.Handle, cnt.icon.Bmp,
             DestRect(sz.cx, sz.cy,
                      TPaintBox(sender).ClientWidth, TPaintBox(sender).ClientHeight), false);
{    gr := TGPGraphics.Create(TPaintBox(sender).Canvas.Handle);
//    ia.SetWrapMode(w)
    with DestRect(cnt.icon.Bmp.GetWidth, cnt.icon.Bmp.GetHeight,
                  TPaintBox(sender).ClientWidth, TPaintBox(sender).ClientHeight) do
     gr.DrawImage(cnt.icon.Bmp, Left, Top, Right-Left, Bottom - Top);
    gr.Free;}
   end
   else
    if Assigned(ch.avtPic.PicAni) then
//     TickAniTimer(Sender);
      DrawAniAvatar(ch.avtPic.AvtPBox, ch.avtPic.PicAni, True);
  {$ENDIF RNQ_AVATARS}
end;
{
procedure TchatFrm.AvtPBoxPaint(Sender: TObject);
var
  gr : TGPGraphics;
//  ia : TGPImageAttributes;
  dc  : HDC;
  ABitmap : HBITMAP;
  fullR : TRect;
  cnt : Tcontact;
begin
  cnt := thisContact;
  if Assigned(cnt) and Assigned(cnt.icon.Bmp) then
   begin
    fullR := TPaintBox(sender).Canvas.ClipRect;
    try
      DC := CreateCompatibleDC(TPaintBox(sender).Canvas.Handle);
      with fullR do
      begin
        ABitmap := CreateCompatibleBitmap(TPaintBox(sender).Canvas.Handle, Right-Left, Bottom-Top);
        if (ABitmap = 0) and (Right-Left + Bottom-Top <> 0) then
          raise EOutOfResources.Create('Out of Resources');
        HOldBmp := SelectObject(DC, ABitmap);
        SetWindowOrgEx(DC, Left, Top, Nil);
      end;
    finally

    end;

    gr :=TGPGraphics.Create(DC);
    gr.Clear(gpColorFromAlphaColor($FF, Self.Brush.Color));
//    gr := TGPGraphics.Create(TPaintBox(sender).Canvas.Handle);
//    ia.SetWrapMode(w)
    with DestRect(cnt.icon.Bmp.GetWidth, cnt.icon.Bmp.GetHeight,
                  TPaintBox(sender).ClientWidth, TPaintBox(sender).ClientHeight) do
     gr.DrawImage(cnt.icon.Bmp, Left, Top, Right-Left, Bottom - Top);
    gr.Free;
    BitBlt(TPaintBox(sender).Canvas.Handle, fullR.Left, fullR.Top,
      fullR.Right - fullR.Left, fullR.Bottom - fullR.Top,
      dc, fullR.Left, fullR.Top, SrcCopy);

    DeleteObject(ABitmap);
    DeleteDC(DC);
   end;
end;}
{
procedure TchatFrm.WMEraseBkgnd(var Msg: TWmEraseBkgnd);
var
 cnv : TCanvas;
begin
  cnv := TCanvas.Create;
  cnv.Handle := msg.DC;
  wallpaperize(cnv);
  cnv.Free;
end;
}

procedure TchatFrm.TickAniTimer(Sender: TObject);
var
  ch: TchatInfo;
begin
//  if not UseAnime then Exit;
//  checkGifTime;
  ch := thisChat;
//  if (ch = NIL)or (ch.chatType <> CT_ICQ)or not (Assigned(ch.avtPic.Pic))  then
  if (ch = NIL)or (ch.chatType <> CT_IM)or not (Assigned(ch.avtPic.PicAni))  then
    Exit;
  if not Assigned(ch.avtPic.AvtPBox) then
    Exit;
  if not ch.avtPic.PicAni.RnQCheckTime then
    Exit;
  DrawAniAvatar(ch.avtPic.AvtPBox, ch.avtPic.PicAni, True);
end;

procedure TchatFrm.WMWINDOWPOSCHANGING(var Msg: TWMWINDOWPOSCHANGING);
const
  chkLeft  = True;
  chkRight = True;
  chkTop   = True;
  chkBottom = True;
var
//  rWorkArea: TRect;
  rMainRect: TRect;
  StickAt: Word;
//  Docked: Boolean;
begin
//  Docked := FALSE;
  if Assigned(MainDlg.RnQmain) then
  if MainDlg.RnQmain.Visible then
 begin
  StickAt := 15;//StrToInt(edStickAt.Text);
  rMainRect := MainDlg.RnQmain.BoundsRect;
//  SystemParametersInfo
//     (SPI_GETWORKAREA, 0, @rWorkArea, 0);

 {$WARN UNSAFE_CODE OFF}
  with Msg.WindowPos^ do begin
 {$WARN UNSAFE_CODE ON}
    if chkLeft then
//     if ABS(x - rWorkArea.Left) <=  StickAt then begin
//      x := rWorkArea.Left;
     if (ABS(x - rMainRect.Right) <=  StickAt)
       and (y < rMainRect.Bottom)and(y+cy > rMainRect.Top) then
     begin
      x := rMainRect.Right;
//      Docked := TRUE;
     end;

    if chkRight then
//     if abs(x + cx - rWorkArea.Right) <=  StickAt then begin
//      x := rWorkArea.Right - cx;
     if (abs(x + cx - rMainRect.Left) <=  StickAt)
       and (y < rMainRect.Bottom)and(y+cy > rMainRect.Top) then
      begin
       x := rMainRect.Left - cx;
//       Docked := TRUE;
      end;

    if chkTop then
     if (abs(y - rMainRect.Bottom)<=  StickAt)
      and (x < rMainRect.Right)and (x + cx > rMainRect.Left) then
     begin
      y := rMainRect.Bottom;
//      Docked := TRUE;
     end;

    if chkBottom then
     if (abs(y + cy - rMainRect.Top)<= StickAt)
      and (x < rMainRect.Right)and (x + cx > rMainRect.Left) then
     begin
      y := rMainRect.Top - cy;
//      Docked := TRUE;
     end;
(*
    if Docked then begin
      with rWorkArea do begin
      // не должна вылезать за пределы экрана
      if x < Left then x := Left;
      if x + cx > Right then x := Right - cx;
      if y < Top then y := Top;
      if y + cy > Bottom then y := Bottom - cy;
      end; {ширина rWorkArea}
    end; {}
*)
  end; {с Msg.WindowPos^}
 end;
 inherited;
end;

procedure TchatFrm.WMAppCommand(var msg: TMessage);
begin
  case GET_APPCOMMAND_LPARAM(msg.LParam) of
    APPCOMMAND_BROWSER_BACKWARD:
      begin
        pagectrl.SelectNextPage(false);
        msg.Result := 1;
      end;

    APPCOMMAND_BROWSER_FORWARD:
      begin
        pagectrl.SelectNextPage(true);
        msg.Result := 1;
      end;

    APPCOMMAND_FIND, APPCOMMAND_BROWSER_SEARCH:
      begin
        showForm(WF_SEARCH);
        msg.Result := 1;
      end;
  end;
end;

 {$IFDEF USE_SECUREIM}
procedure TchatFrm.EncryptSendInit(Sender: TObject);
begin
// activeICQ.sendSNAC()
//  cpp.
end;
 {$ENDIF USE_SECUREIM}

procedure TchatFrm.EncryptSetPWD(Sender: TObject);
 {$IFDEF PROTOCOL_ICQ}
var
  ch: TchatInfo;
  s: String;
  sA: AnsiString;
 {$ENDIF PROTOCOL_ICQ}
begin
 {$IFDEF PROTOCOL_ICQ}
  ch := thisChat;
//  if (ch = NIL)or (ch.chatType <> CT_ICQ) or not (Assigned(ch.avtPic.Pic))  then
  if (ch = NIL)or (ch.chatType <> CT_IM) then
    Exit;
  if not (ch.who is TICQcontact) then
    Exit;

  if enterPwdDlg(s, getTranslation('Enter password for %s', [ch.who.displayed]), 255, True) then
    begin
      sA := AnsiString(s);
      TICQcontact(ch.who).crypt.qippwd := qip_str2pass(sA);
    end;

  updateContactStatus;
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TchatFrm.EncryptClearPWD(Sender: TObject);
 {$IFDEF PROTOCOL_ICQ}
var
  ch: TchatInfo;
 {$ENDIF PROTOCOL_ICQ}
begin
 {$IFDEF PROTOCOL_ICQ}
  ch := thisChat;
//  if (ch = NIL)or (ch.chatType <> CT_ICQ)or not (Assigned(ch.avtPic.Pic))  then
  if (ch = NIL)or (ch.chatType <> CT_IM) then
    Exit;
  if not (ch.who is TICQcontact) then
    Exit;
  TICQcontact(ch.who).crypt.qippwd := 0;
  updateContactStatus;
 {$ENDIF PROTOCOL_ICQ}
end;

procedure TchatFrm.SetSmilePopup(pIsMenu: Boolean);
begin
   {$IFDEF USE_SMILE_MENU}
  if pIsMenu then
    begin
      smilesBtn.PopupMenu := smileMenuExt;
      smilesBtn.OnMouseUp := NIL;
    end
   else
   {$ENDIF USE_SMILE_MENU}
    begin
      smilesBtn.PopupMenu := NIL;
      smilesBtn.OnMouseUp := smilesBtnMouseUp;
    end
end;

 {$IFDEF usesDC}
procedure TchatFrm.WMDROPFILES(var Message: TWMDROPFILES);
var
  ch: TchatInfo;
  cnt: TRnQContact;
  i, n: integer;
  ss: string;
  buffer: array[0..2000] of char;
begin
  ch := thisChat;
  if (ch = NIL) then
    exit;
  if ch.chatType = CT_IM then
   begin
    cnt := ch.who;
    if cnt = NIL then
      Exit;
    if cnt is TICQContact then
     begin
      ss := '';
      n := DragQueryFile(Message.Drop, Cardinal(-1), NIL, 0);
      for i:=0 to n-1 do
        begin
 {$WARN UNSAFE_CODE OFF}
        DragQueryFile(Message.Drop, i, @buffer, sizeOf(buffer));
 {$WARN UNSAFE_CODE ON}
        ss := ss + buffer + CRLF;
        end;
      DragFinish(message.Drop);
      cnt.SendFilesTo(ss);
      ss := '';
     end; 
   end;
end; // WMDROPFILES
 {$ENDIF usesDC}

end.

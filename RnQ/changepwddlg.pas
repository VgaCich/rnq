{
This file is part of R&Q.
Under same license
}
unit changepwddlg;

{$I Compilers.inc}
{$I RnQConfig.inc}
{$I NoRTTI.inc}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  StdCtrls, ExtCtrls, RnQButtons, RnQDialogs,
  RnQProtocol;

type
  TchangePwdFrm = class(TForm)
    Label2: TLabel;
    Label3: TLabel;
    newpwd1Box: TEdit;
    newpwd2Box: TEdit;
    Label1: TLabel;
    oldpwdBox: TEdit;
    saveBtn: TRnQButton;
    procedure FormShow(Sender: TObject);
    procedure saveBtnClick(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    constructor Create(const proto : TRnQProtocol; isAccPass : Boolean);
  private
    { Private declarations }
    curProto : TRnQProtocol;
    isProtoPwd : Boolean;
  public
    { Public declarations }
//  public procedure DestroyHandle; OverRide;
  end;

var
  changePwdFrm: TchangePwdFrm;
  changeAccPwdFrm: TchangePwdFrm;


implementation

{$R *.DFM}

uses
  utilLib, globalLib,
  RnQSysUtils, RnQPics,
  RnQLangs, mainDlg, RQUtil, RDGlobal, RQThemes, themesLib;

constructor TchangePwdFrm.Create(const proto : TRnQProtocol; isAccPass : Boolean);
begin
  inherited create(Application);
  if not isAccPass then
    begin
      curProto := proto;
      isProtoPwd := True;
    end
   else
    begin
      curProto := NIL;
      isProtoPwd := False;
    end
     ;
  theme.pic2ico(RQteFormIcon, PIC_KEY, icon);
  oldpwdbox.text:='';
  newpwd1box.text:='';
  newpwd2box.text:='';
  oldpwdbox.onKeyDown  := RnQmain.pwdBoxKeyDown;
  newpwd1box.onKeyDown := RnQmain.pwdBoxKeyDown;
  newpwd2box.onKeyDown := RnQmain.pwdBoxKeyDown;
end;


procedure TchangePwdFrm.FormShow(Sender: TObject);
begin
  oldpwdbox.setfocus;
  applyTaskButton(self);
end;

procedure TchangePwdFrm.saveBtnClick(Sender: TObject);
const
  ErrIncr = 'The password you entered is incorrect';
  ErrMist = 'You mistyped the new password. Re-type it, please.';
begin
  if (newpwd1box.text <> newpwd2box.text) then
   begin
     msgDlg(ErrMist, True, mtWarning);
     newpwd1box.text:='';
     newpwd2box.text:='';
     newpwd1box.setFocus;
     exit;
   end;
  if isProtoPwd then
    begin
     if not curProto.isOnline then
      begin
       msgDlg('You are offline\nYou have to be online to change password', True, mtError);
       exit;
      end;
     if not curProto.pwdEqual(oldPwdBox.text) then
       begin
        msgDlg(ErrIncr, True, mtError);
        oldpwdbox.text:='';
        oldpwdbox.setFocus;
        exit;
       end;
     if (trim(newpwd1box.text)='') then
     begin
      msgDlg(ErrMist, True, mtWarning);
      newpwd1box.text:='';
      newpwd2box.text:='';
      newpwd1box.setFocus;
      exit;
     end;
     curProto.pwd:=newpwd1box.text;
    end
   else
    begin
     if oldPwdBox.text <> AccPass then
       begin
        msgDlg(ErrIncr, True, mtError);
        oldpwdbox.text:='';
        oldpwdbox.setFocus;
        exit;
       end;
      AccPass := newpwd1box.text;
      saveCfgDelayed := True;
    end;
 close;
end;

procedure TchangePwdFrm.FormPaint(Sender: TObject);
begin wallpaperize(canvas) end;

procedure TchangePwdFrm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
//  destroyHandle;
  Action := caFree;
  if isProtoPwd then
    changePwdFrm := NIL
   else
    changeAccPwdFrm := NIL;
end;

//procedure TchangePwdFrm.destroyHandle; begin inherited end;

end.

//---------------------------------------------------------------------------

// This software is Copyright (c) 2021 Embarcadero Technologies, Inc.
// You may only use this software if you are an authorized licensee
// of an Embarcadero developer tools product.
// This software is considered a Redistributable as defined under
// the software license agreement that comes with the Embarcadero Products
// and is subject to that software license agreement.

//---------------------------------------------------------------------------

unit View.NewForm;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  View.Main, FMX.Effects, FMX.Layouts, FMX.Ani, FMX.Objects,
  FMX.Controls.Presentation, REST.Types, REST.Client, Data.Bind.Components,
  Data.Bind.ObjectScope, System.Generics.Collections, System.JSON, FMX.Edit,
  System.Threading;

type
  TNewFormFrame = class(TMainFrame)
    VertScrollBox1: TVertScrollBox;
    BtnSendRequest: TButton;
    Rectangle1: TRectangle;
    RESTClient1: TRESTClient;
    RESTRequest1: TRESTRequest;
    RESTResponse1: TRESTResponse;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Edit1: TEdit;
    procedure BtnSendRequestClick(Sender: TObject);
  private
    // runtime component for news card
    RctResultsCard: TRectangle;
    LblTitle: TLabel;
    LblURL  : TLabel;
    LblDomain: TLabel;
    LblDisplayedURL: TLabel;

    // save runtime components in the list to clear them while closing
    RctList: TList<TRectangle>;
    LblTitleList: TList<TLabel>;
    LblURLList: TList<TLabel>;
    LblDomainList : TList<TLabel>;
    LblDisplayedURLList: TList<TLabel>;
  public
    { Public declarations }
  end;

const AccKey = 'd41fb824d005de9f7dca1d6a3eb43732';

implementation

{$R *.fmx}

procedure TNewFormFrame.BtnSendRequestClick(Sender: TObject);
begin
  inherited;
  var aTask: ITask;

  RESTClient1.ResetToDefaults;
  RESTClient1.Accept := 'application/json';
  RESTClient1.AcceptCharset := 'UTF-8, *;q=0.8';
  RESTClient1.BaseURL := 'http://api.serpstack.com/search';

  // pass given parameters for the URL
  RESTRequest1.Resource := Format('?access_key=%s&query=%s&num=5',
    [AccKey, Edit1.text]);

  RESTResponse1.ContentType := 'application/json';

  aTask := TTask.Create(
    procedure
    begin
      Sleep(3000);
      TThread.Synchronize(TThread.Current,
        procedure
        begin
          RESTRequest1.Execute;

          var JSONValue: TJSONValue;
          var JSONArray: TJSONArray;
          var ArrayElement: TJSONValue;

          // after using object we just free them within the list
          RctList := TList<TRectangle>.Create;
          LblTitleList := TList<TLabel>.Create;
          LblURLList := TList<TLabel>.Create;
          LblDomainList := TList<TLabel>.Create;
          LblDisplayedURLList := TList<TLabel>.Create;

          try
            JSONValue := TJSONObject.ParseJSONValue(RESTResponse1.Content);
            JSONArray := JSONValue.GetValue<TJSONArray>('organic_results');

            for ArrayElement in JSONArray do
            begin
                {$region 'Create news card' }
                RctResultsCard := TRectangle.Create(VertScrollBox1);
                RctResultsCard.Parent := VertScrollBox1;
                RctResultsCard.HitTest := False;
                RctResultsCard.Fill.Color := TAlphaColorRec.Azure;
                RctResultsCard.Fill.Kind  := TBrushKind.Solid;
                RctResultsCard.Stroke.Thickness := 0;
                RctResultsCard.Align := TAlignLayout.Top;
                RctResultsCard.Height := 220;
                RctResultsCard.Width  := 314;
                RctResultsCard.XRadius := 15;
                RctResultsCard.YRadius := 15;
                RctResultsCard.Margins.Top := 5;
                RctResultsCard.Margins.Bottom := 5;
                RctResultsCard.Margins.Left := 7;
                RctResultsCard.Margins.Right := 7;
                RctList.Add(RctResultsCard);  // add to the TList instance
                {$endregion}

                {$region 'create title url ... labels in the search result card' }
                LblDisplayedURL := TLabel.Create(RctResultsCard);
                LblDisplayedURL.Parent := RctResultsCard;
                LblDisplayedURL.Align := TAlignLayout.Top;
                LblDisplayedURL.AutoSize := True;
                LblDisplayedURL.Height := 33;
                LblDisplayedURL.Width  := 308;
                LblDisplayedURL.HitTest := False;
                LblDisplayedURL.AutoSize := True;
                LblDisplayedURL.Font.Size := 14;
                LblDisplayedURL.Margins.Left := 3;
                LblDisplayedURL.Margins.Right := 3;
                LblDisplayedURL.Margins.Top := 3;
                LblDisplayedURL.Margins.Bottom := 3;
                LblDisplayedURL.Text := 'Displayed URL: ' + ArrayElement.GetValue<String>('displayed_url');
                LblDisplayedURL.StyledSettings := LblDisplayedURL.StyledSettings - [TStyledSetting.FontColor, TStyledSetting.Size];
                LblDisplayedURLList.Add(LblDisplayedURL);

                LblDomain := TLabel.Create(RctResultsCard);
                LblDomain.Parent := RctResultsCard;
                LblDomain.Align := TAlignLayout.Top;
                LblDomain.Height := 33;
                LblDomain.Width  := 308;
                LblDomain.HitTest := False;
                LblDomain.AutoSize := True;
                LblDomain.Font.Size := 14;
                LblDomain.Margins.Left := 3;
                LblDomain.Margins.Right := 3;
                LblDomain.Margins.Top := 3;
                LblDomain.Margins.Bottom := 3;
                LblDomain.Text := 'Domain: ' + ArrayElement.GetValue<String>('domain');
                LblDomain.StyledSettings := LblDomain.StyledSettings - [TStyledSetting.FontColor, TStyledSetting.Size];
                LblDomainList.Add(LblDomain);

                LblURL := TLabel.Create(RctResultsCard);
                LblURL.Parent := RctResultsCard;
                LblURL.Align := TAlignLayout.Top;
                LblURL.Height := 33;
                LblURL.Width  := 308;
                LblURL.HitTest := False;
                LblURL.AutoSize := True;
                LblURL.Font.Size := 14;
                LblURL.Margins.Left := 3;
                LblURL.Margins.Right := 3;
                LblURL.Margins.Top := 3;
                LblURL.Margins.Bottom := 3;
                LblURL.Text := 'URL: ' + ArrayElement.GetValue<String>('url');
                LblURL.StyledSettings := LblURL.StyledSettings - [TStyledSetting.FontColor, TStyledSetting.Size];
                LblURLList.Add(LblURL);

                LblTitle := TLabel.Create(RctResultsCard);
                LblTitle.Parent := RctResultsCard;
                LblTitle.Align := TAlignLayout.Top;
                LblTitle.Height := 33;
                LblTitle.Width  := 308;
                LblTitle.HitTest := False;
                LblTitle.AutoSize := True;
                LblTitle.Font.Size := 16;
                LblTitle.Margins.Left := 3;
                LblTitle.Margins.Right := 3;
                LblTitle.Margins.Top := 3;
                LblTitle.Margins.Bottom := 3;
                LblTitle.Text := 'Title: ' + ArrayElement.GetValue<String>('title');
                LblTitle.StyledSettings := LblTitle.StyledSettings - [TStyledSetting.FontColor, TStyledSetting.Size];
                LblTitleList.Add(LblTitle);
                {$endregion}
              end;
            finally
              FreeAndNil(RctList);
              FreeAndNil(LblURLList);
              FreeAndNil(LblDomainList);
              FreeAndNil(LblDisplayedURLList);
            end;
        end);
    end);
  aTask.Start;
end;

initialization
  // Register frame
  RegisterClass(TNewFormFrame);
finalization
  // Unregister frame
  UnRegisterClass(TNewFormFrame);

end.

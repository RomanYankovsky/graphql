{******************************************************************************}
{                                                                              }
{  Delphi GraphQL                                                              }
{  Copyright (c) 2022 Luca Minuti                                              }
{  https://github.com/lminuti/graphql                                          }
{                                                                              }
{******************************************************************************}
{                                                                              }
{  Licensed under the Apache License, Version 2.0 (the "License");             }
{  you may not use this file except in compliance with the License.            }
{  You may obtain a copy of the License at                                     }
{                                                                              }
{      http://www.apache.org/licenses/LICENSE-2.0                              }
{                                                                              }
{  Unless required by applicable law or agreed to in writing, software         }
{  distributed under the License is distributed on an "AS IS" BASIS,           }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.    }
{  See the License for the specific language governing permissions and         }
{  limitations under the License.                                              }
{                                                                              }
{******************************************************************************}
unit Demo.Form.RttiQuery;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.Rtti, System.Types, System.IOUtils, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, GraphQL.Query.Rtti;

type
  TRttiQueryForm = class(TForm)
    SourceMemo: TMemo;
    RunQueryButton: TButton;
    ResultMemo: TMemo;
    Label1: TLabel;
    FilesComboBox: TComboBox;
    procedure FilesComboBoxChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure RunQueryButtonClick(Sender: TObject);
  private
    FSampleDir: string;
    FRttiQuery: TGraphQLRttiQuery;
    procedure ReadFiles;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  RttiQueryForm: TRttiQueryForm;

implementation

{$R *.dfm}

uses
  System.JSON, REST.Json,
  Demo.API.Test, GraphQL.Utils.JSON;

{ TRttiQueryForm }

constructor TRttiQueryForm.Create(AOwner: TComponent);
begin
  inherited;
  FRttiQuery := TGraphQLRttiQuery.Create;

  FRttiQuery.RegisterFunction('rollDice',
    function (AParams: TGraphQLParams) :TValue
    begin
      Result := RollDice(AParams.Get('numDice').AsInteger, AParams.Get('numSides').AsInteger);
    end
  );

  FRttiQuery.RegisterFunction('reverseString',
    function (AParams: TGraphQLParams) :TValue
    begin
      Result := ReverseString(AParams.Get('value').AsString);
    end
  );

  FRttiQuery.RegisterFunction('hero',
    function (AParams: TGraphQLParams) :TValue
    begin
      if AParams.Exists('id') then
        Result := StarWarsHero(AParams.Get('id').AsString)
      else
        Result := StarWarsHero('1000');
    end
  );

end;

procedure TRttiQueryForm.FormCreate(Sender: TObject);
begin
  ReadFiles;
end;

destructor TRttiQueryForm.Destroy;
begin
  FRttiQuery.Free;
  inherited;
end;

procedure TRttiQueryForm.FilesComboBoxChange(Sender: TObject);
var
  LFileName: string;
begin
  if FilesComboBox.Text <> '' then
  begin
    LFileName := FSampleDir + PathDelim + FilesComboBox.Text;
    if FileExists(LFileName) then
      SourceMemo.Lines.LoadFromFile(LFileName);
  end;
end;

procedure TRttiQueryForm.FormKeyUp(Sender: TObject; var Key: Word; Shift:
    TShiftState);
begin
  if Key = VK_F5 then
    RunQueryButton.Click;
end;

procedure TRttiQueryForm.ReadFiles;
var
  LFiles: TStringDynArray;
  LFileName: string;
begin
  FSampleDir := ExtractFileDir( ParamStr(0)) + PathDelim + '..' + PathDelim + '..' + PathDelim + '..' + PathDelim + 'Files';

  FilesComboBox.Items.Clear;
  LFiles := TDirectory.GetFiles(FSampleDir);
  for LFileName in LFiles do
    FilesComboBox.Items.Add(ExtractFileName(LFileName));
end;

procedure TRttiQueryForm.RunQueryButtonClick(Sender: TObject);
begin
  ResultMemo.Text := TJSONHelper.PrettyPrint(FRttiQuery.Run(SourceMemo.Text));
end;

end.
unit Orion.Manager.Client;

interface

uses
  System.JSON, System.Generics.Collections;

type
  TOrionManager = class
  private
    FJSONArray : TJSONArray;
  public
    constructor Create;
    destructor Destroy; override;

    function AddJSONArray(aValue : TJSONArray) : TOrionManager;
    function Receive<T:class, constructor>(var aValue : T; aJsonNode : string) : TOrionManager; overload;
    function Receive<T:class, constructor>(var aValue : TObjectList<T>; aJsonNode : string) : TOrionManager; overload;
  end;
implementation

{ TOrionManager }

uses Orion.Rtti;

function TOrionManager.AddJSONArray(aValue: TJSONArray): TOrionManager;
begin
  Result := Self;

  if Assigned(FJSONArray) then
    FJSONArray.DisposeOf;

  FJSONArray := aValue;
end;

constructor TOrionManager.Create;
begin
  FJSONArray := TJSONArray.Create;
end;

destructor TOrionManager.Destroy;
begin
  if Assigned(FJSONArray) then
    FJSONArray.Free;
  inherited;
end;

function TOrionManager.Receive<T>(var aValue: T; aJsonNode: string): TOrionManager;
var
  lJson : TJSONValue;
begin
  lJson := nil;
  if aJsonNode <> '' then
  begin
    lJson := FJSONArray.FindValue(aJsonNode);
    if Assigned(lJson) then
      TOrionRtti<T>.New(nil).JSONToObject(lJSON, aValue);
  end;
end;

function TOrionManager.Receive<T>(var aValue: TObjectList<T>; aJsonNode: string): TOrionManager;
var
  lJsonArray : TJSONArray;
  I: Integer;
  lObj : T;
begin
  lJsonArray := nil;
  try
    if aJsonNode <> '' then
    begin
      lJsonArray := TJSONArray(FJSONArray.FindValue(aJsonNode));
      if Assigned(lJsonArray) then
      begin
        for I := 0 to Pred(lJsonArray.Count) do
        begin
          lObj := T.Create;
          TOrionRtti<T>.New(nil).JSONToObject(lJsonArray.Items[i], lObj);
          aValue.Add(lObj);
        end;
      end;
    end;
  finally
    if Assigned(lJsonArray) then
      lJsonArray.DisposeOf;
  end;
end;

end.

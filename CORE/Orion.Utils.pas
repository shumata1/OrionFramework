unit Orion.Utils;

interface

uses
  System.JSON,
  Rest.JSON,
  System.Generics.Collections;

type
  TOrionUtils = class
  private
    FStatusCode : TJSONArray;
    procedure TryDisposeOf(aValue : TObject);
  public
    constructor Create;
    destructor Destroy; override;

    function ObjectToJSON<T :class>(aObject : T) : TJSONObject;
    function ObjectListToJSON<T:class>(aObjectList : TObjectList<T>) : TJSONArray;
    function JSONToObject<T :class, constructor>(aJSONObject : TJSONObject) : T; overload;
    function JSONToObject<T :class, constructor>(aJson :string) : T; overload;
    function JSONArrayToObjectList<T : class, constructor>(aJSONArray : TJSONArray) : TObjectList<T>;
    function JSONStringToJSONValue(aValue: string): TJSONValue;
    function ResultCode201 : TJSONArray;
    function ResultCode401 : TJSONArray;
  end;
implementation

uses
  System.TypInfo, System.SysUtils;

{ TOrionUtils }

constructor TOrionUtils.Create;
begin

end;

destructor TOrionUtils.Destroy;
begin

  inherited;
end;

procedure TOrionUtils.TryDisposeOf(aValue: TObject);
begin
  if Assigned(aValue) then
    aValue.DisposeOf;
end;

function TOrionUtils.JSONToObject<T>(aJson: string): T;
begin
  Result := TJson.JsonToObject<T>(aJSON);
end;

function TOrionUtils.JSONToObject<T>(aJSONObject: TJSONObject): T;
begin
  Result := TJson.JsonToObject<T>(aJSONObject);
end;

function TOrionUtils.ObjectListToJSON<T>(
  aObjectList: TObjectList<T>): TJSONArray;
var
  I: Integer;
begin
  Result := TJSONArray.Create;
  for I := 0 to Pred(aObjectList.Count) do
    Result.AddElement(ObjectToJSON(aObjectList[i]));
end;

function TOrionUtils.ObjectToJSON<T>(aObject : T) : TJSONObject;
begin
  if aObject <> nil then
    Result := TJson.ObjectToJsonObject(aObject);
end;

function TOrionUtils.ResultCode201: TJSONArray;
var
  LObjResult : TJSONObject;
begin
  TryDisposeOf(FStatusCode);
  FStatusCode := TJSONArray.Create;
  LObjResult := TJSONObject.Create;
  LObjResult.AddPair('Message', 'Inserção realizada com sucesso!');
  LObjResult.AddPair('StatusCode', '201');
  FStatusCode.Add(LObjResult);
  Result := FStatusCode;
end;

function TOrionUtils.ResultCode401: TJSONArray;
var
  LObjResult : TJSONObject;
begin
  TryDisposeOf(FStatusCode);
  FStatusCode := TJSONArray.Create;
  LObjResult := TJSONObject.Create;
  LObjResult.AddPair('Message', 'Usuário não autenticado.');
  LObjResult.AddPair('StatusCode', '401');
  FStatusCode.Add(LObjResult);
  Result := FStatusCode;
end;

function TOrionUtils.JSONArrayToObjectList<T>(
  aJSONArray: TJSONArray): TObjectList<T>;
var
  I: Integer;
  lObjJson : TJSONObject;
begin
  Result := TObjectList<T>.Create;
  for I := 0 to Pred(aJSONArray.Count) do
  begin
    lObjJson := TJSONObject(aJSONArray.Items[i]);
    Result.Add(JSONToObject<T>(lObjJson));
  end;
end;

function TOrionUtils.JSONStringToJSONValue(aValue: string): TJSONValue;
begin
  Result := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(aValue), 0);
end;

end.

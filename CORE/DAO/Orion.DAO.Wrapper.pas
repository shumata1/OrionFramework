unit Orion.DAO.Wrapper;

interface

uses
  Orion.Interfaces,
  System.JSON,
  System.Generics.Collections;
type
  TOrionDAOWrapper = class(TInterfacedObject, iOrionDAOWrapper)
  private
    [Weak]
    FObjectList : TObjectList<TObject>;
    FOwnsObjectList : Boolean;

    FJSONList : TObjectDictionary<string, TJSONArray>;
    FCLassType : TClass;
    FNodeName :string;
    FKeyFieldNames :array of string;
    FJSONObject :TJSONObject;
  public
    constructor Create(aOwnsObjects :boolean = True);
    destructor Destroy; override;
    class function New(aOwnsObjects :boolean = True) :iOrionDAOWrapper;

    function SetObjectList(aValue :TObjectList<TObject>; aOwnsObjects :Boolean = true): iOrionDAOWrapper;
    function SetNodeName(aValue :string) : iOrionDAOWrapper;
    function SetKeyFieldNames(aValue : array of string) : iOrionDAOWrapper;
    function Execute : iOrionDAOWrapper;
    function Result : TDictionary<string, TJSONArray>;
  end;
implementation

uses
  Orion.NormalRtti,
  Orion.Rtti,
  System.Variants,
  Rest.JSON;

{ TOrionDAOWrapper }

constructor TOrionDAOWrapper.Create(aOwnsObjects :boolean = True);
begin
  FJSONObject := TJSONObject.Create;
  if aOwnsObjects then
    FJSONList :=  TObjectDictionary<string, TJSONArray>.Create([doOwnsValues])
  else
    FJSONList :=  TObjectDictionary<string, TJSONArray>.Create;
end;

destructor TOrionDAOWrapper.Destroy;
begin
  if Assigned(FJSONObject) then
    FJSONObject.Free;

//  if Assigned(FJSONList) then
//    FJSONList.Free;

  if FOwnsObjectList then
    FObjectList.Free;
  inherited;
end;

function TOrionDAOWrapper.Execute: iOrionDAOWrapper;
var
  I: Integer;
  LFieldValues : TDictionary<string, Variant>;
  Key :string;
  Value: Variant;
  LJsonArray :TJSONArray;
  LJSonObj : TJSONObject;
begin
  for I := 0 to Pred(FObjectList.Count) do
  begin
    if Assigned(FObjectList[i]) then
    begin
      LFieldValues := TOrionNormalRtti.New.GetFieldValue(FKeyFieldNames, FObjectList[i]);
      Key          := '';
      for Value in LFieldValues.Values do
        Key := Key + VarToStr(Value);

      if FJSONList.ContainsKey(Key) then
        FJSONList.TryGetValue(Key, LJsonArray)
      else
        LJsonArray := TJSONArray.Create;

      LJSonObj := TJson.ObjectToJsonObject(FObjectList[i]);

      LJsonArray.AddElement(LJsonObj);

      FJSONList.AddOrSetValue(Key, LJsonArray);

      if Assigned(LFieldValues) then
        LFieldValues.Free;

    end;
  end;
end;

class function TOrionDAOWrapper.New(aOwnsObjects :boolean = True) : iOrionDAOWrapper;
begin
  Result := Self.Create(aOwnsObjects);
end;

function TOrionDAOWrapper.Result: TDictionary<string, TJSONArray>;
begin
  Result := FJSONList;
end;

function TOrionDAOWrapper.SetKeyFieldNames(aValue: array of string): iOrionDAOWrapper;
var
  I: Integer;
begin
  Result := Self;
  for I := 0 to Pred(Length(aValue)) do
  begin
    SetLength(FKeyFieldNames, 1);
    FKeyFieldNames[i] := aValue[i];
  end;
end;

function TOrionDAOWrapper.SetNodeName(aValue: string): iOrionDAOWrapper;
begin
  Result := Self;
  FNodeName := aValue;
end;

function TOrionDAOWrapper.SetObjectList(aValue :TObjectList<TObject>; aOwnsObjects :Boolean = true): iOrionDAOWrapper;
begin
  Result      := Self;
  FObjectList := aValue;
  FOwnsObjectList := aOwnsObjects;
end;

end.

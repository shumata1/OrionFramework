unit Orion.Wrapper.JSON;

interface

uses
  System.Generics.Collections,
  System.JSON, Orion.Utils, Orion.Rtti;

type
  TOrionWrapperJSON = class
  private
    FOwnResult : Boolean;
    FJSONResult : TJSONArray;
    FOwnerList : TDictionary<TClass, TClass>;
    FObjectsList : TDictionary<TClass, TObjectList<TObject>>;
    FOrionUtils : TOrionUtils;
    FJSONList : TObjectDictionary<string, TJSONArray>;
    FKeyName : string;
    FObjJSON : TJSONObject;
    FObjArray : TJSONArray;
    procedure BuildJSON(aKey :integer; aObjectList : TDictionary<TClass, TObjectList<TObject>>);
  public
    constructor Create(aOwnResult : Boolean = True);
    destructor Destroy; override;

    procedure AddObjectList<Owner : class>(AObjectList : TObjectList<Owner>); overload;
    procedure AddObjectList<Owner, ChildClass :class>(AObjectList : TObjectList<ChildClass>); overload;
    procedure SetPrimaryKey(const aKeyName : string);
    procedure Execute;
    function Result : TJSONArray;
  end;
implementation

{ TOrionWrapperJSON }

uses
  Orion.NormalRtti,
  Variants;

procedure TOrionWrapperJSON.AddObjectList<Owner, ChildClass>(
  AObjectList: TObjectList<ChildClass>);
begin
  if FOwnerList.ContainsValue(Owner) then
    Exit;

  FOwnerList.Add(Owner, ChildClass);
  FObjectsList.Add(ChildClass, TObjectList<TObject>(AObjectList));
end;

procedure TOrionWrapperJSON.AddObjectList<Owner>(
  AObjectList: TObjectList<Owner>);
begin
  if FOwnerList.ContainsValue(Owner) then
    Exit;

  FOwnerList.Add(nil, Owner);
  FObjectsList.Add(Owner, TObjectList<TObject>(AObjectList));
end;

procedure TOrionWrapperJSON.BuildJSON(aKey :integer; aObjectList : TDictionary<TClass, TObjectList<TObject>>);
var
  LObjList: TObjectList<TObject>;
  LPrimaryJeys : TDictionary<string, Variant>;
  I: Integer;
  Value: Variant;
  LObjJSON : TJSONObject;
begin
  for LObjList in aObjectList.Values do
  begin
    for I := aKey to Pred(LObjList.Count) do
    begin
      LPrimaryJeys := TOrionNormalRtti.New.GetFieldValue([FKeyName], LObjList[i]);
      for Value in LPrimaryJeys.Values do
      begin
        if Value = aKey then
          LObjJSON := FOrionUtils.ObjectToJSON(LObjList[i]);
      end;
    end;
  end;
end;

constructor TOrionWrapperJSON.Create(aOwnResult : Boolean = True);
begin
  FOwnResult   := aOwnResult;
  FJSONResult  := TJSONArray.Create;
  FOrionUtils  := TOrionUtils.Create;
  FObjectsList := TDictionary<TClass, TObjectList<TObject>>.Create;
  FOwnerList   := TDictionary<TClass, TClass>.Create;
  FJSONList    := TObjectDictionary<string, TJSONArray>.Create([doOwnsValues]);
end;

destructor TOrionWrapperJSON.Destroy;
begin
  if Assigned(FJSONResult) then
    FJSONResult.DisposeOf;

  FObjectsList.DisposeOf;
  FOwnerList.DisposeOf;
  FOrionUtils.DisposeOf;
  inherited;
end;

procedure TOrionWrapperJSON.Execute;
var
  Value: TObjectList<TObject>;
  Obj : TObject;
  IDValue : Variant;
  I :integer;
  LObjArray : TJSONArray;
begin
  for Value in FObjectsList.Values do
  begin
    for I := 0 to Pred(Value.Count) do
    begin
      if Assigned(FObjJSON) then
        FObjJSON.Free;

      if Assigned(FObjArray) then
        FObjArray.Free;

      Obj := Value[i];
      IDValue := TOrionNormalRtti.New.GetIDValue(Obj);

      if not FJSONList.ContainsKey(VarToStr(IDValue)) then
      begin
        FJSONList.Add(IDValue, TJSONArray(FOrionUtils.ObjectToJSON(Obj)));
        Continue;
      end;

      FJSONList.TryGetValue(IDValue, FObjArray);
      FObjJSON := FOrionUtils.ObjectToJSON(Obj);
      FObjArray.AddElement(FObjJSON);
      FJSONList.AddOrSetValue(IDValue, FObjArray);
    end;
  end;

  for LObjArray in FJSONList.Values do
  begin
    FJSONResult.AddElement(LObjArray);
  end;

end;

function TOrionWrapperJSON.Result: TJSONArray;
begin
  Result := FJSONResult;
end;

procedure TOrionWrapperJSON.SetPrimaryKey(const aKeyName : string);
begin
  FKeyName := aKeyName;
end;

end.

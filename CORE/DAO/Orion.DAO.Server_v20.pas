unit Orion.DAO.Server_v20;

interface

uses
  Orion.Interfaces,
  Orion.Data.Interfaces,
  System.JSON,
  System.Generics.Collections,
  Data.DB;
type
  TOrionDAOServer<T:class, constructor> = class(TInterfacedObject, iOrionDAOServer<T>, iOrionDAOServerSearch<T>, iOrionDAOEntity<T>, iOrionDAOServerResultSet<T>)
  private
    FDataSet : iDataSet;
    FEntity : T;
    FEntityList : TObjectList<T>;

    FJSON :TJSONArray;
    FParamsList :TDictionary<string, variant>;
    FListaParametros :TDictionary<string, Variant>;
    FListaRecNoDataSet :TDictionary<integer, Boolean>;

    FOrderBy :string;
    FWhere :string;

    procedure BuildDataSetSQL(aWhere :string = '');
    procedure BuildDataSetSQLForUpdate(aWhere: string = '');
    procedure EmptyParams;
    procedure LoadParams;

    procedure PrepareListOfPossibleExclusions;
    procedure ChecarExclusoes;

    procedure InternalInsert(aValue :T);
    procedure InternalUpdate(aValue :T);
    procedure InternalDelete(aValue : T);
    procedure InternalApplyUpdates;
    procedure InternalRefreshObject(aValue : T);

    procedure IgnoreJoinFieldsToUpdate;
  public
    constructor Create(aDataSet :iDataSet);
    destructor Destroy; override;
    class function New(aDataSet :iDataSet) :iOrionDAOServer<T>;

    function Search :iOrionDAOServerSearch<T>;
    function Entity :iOrionDAOEntity<T>;
    function ResultSet : iOrionDAOServerResultSet<T>;

    function Insert(aValue :T) : iOrionDAOServer<T>; overload;
    function Insert(aValue :TObjectList<T>) : iOrionDAOServer<T>; overload;
    function Update(aValue :T) : iOrionDAOServer<T>; overload;
    function Update(aValue :TObjectList<T>) : iOrionDAOServer<T>; overload;
    function Delete : iOrionDAOServer<T>;
    function ApplyUpdates  : iOrionDAOServer<T>;
    function ToJSON(aValue :TJSONValue) : iOrionDAOServer<T>;

    {iOrionDAOServerSearch}
    function SetParam(aName :string; aValue :Variant) :iOrionDAOServerSearch<T>;
    function Go : iOrionDAOServer<T>;

    {iOrionDAOServerResultSet}
    function AsObjectList : TObjectList<T>;
    function AsObject : T;
    function AsJSON :TJSONValue;

    {iOrionDAOEntity}
    function Current :T;
    function NewInstance :T;
  end;
implementation

uses
  Orion.Data.Rtti,
  System.SysUtils, System.Variants;
{ TOrionDAOServer<T> }

function TOrionDAOServer<T>.ApplyUpdates: iOrionDAOServer<T>;
begin

end;

function TOrionDAOServer<T>.AsJSON: TJSONValue;
begin
//  if Assigned(FJSON) then
//    FJSON.Free;
//
//  FJSON := TConverter.New.DataSet(FDataSet.DataSet).AsJSONArray;
//  Result := FJSON;
end;

function TOrionDAOServer<T>.AsObject: T;
begin
  Result := T.Create;
  TOrionDataRtti<T>.New(nil).DataSetSelectedRecordToObject(FDataset, Result);
end;

function TOrionDAOServer<T>.AsObjectList: TObjectList<T>;
var
  LObject : T;
begin
  Result := TObjectList<T>.Create;
  FDataSet.First;
  while not FDataSet.EOF do
  begin
    LObject := T.Create;
    TOrionDataRtti<T>.New(nil).DataSetSelectedRecordToObject(FDataset, LObject);
    Result.Add(LObject);
    FDataSet.Next;
  end;
end;

procedure TOrionDAOServer<T>.BuildDataSetSQL(aWhere: string);
var
  LSQL, LJoins: string;
begin
  LSQL :=        ' select ' + TOrionDataRtti<T>.New(nil).GetFieldsNames(T);
  LSQL := LSQL + ' from '   + TOrionDataRtti<T>.New(nil).GetTableName(T);

  LJoins := TOrionDataRtti<T>.New(nil).GetJoins(T);
  LSQL := LSQL + ' ' + LJoins;

  LSQL := LSQL + ' ' + aWhere;

  if FOrderBy <> '' then
    LSQL := LSQL + ' Order by ' + FOrderBy;

  FDataSet.Close;
  FDataSet.SQL(LSQL);
end;

procedure TOrionDAOServer<T>.BuildDataSetSQLForUpdate(aWhere: string = '');
var
  LSQL, LJoins: string;
begin
  LSQL :=        ' select ' + TOrionDataRtti<T>.New(nil).GetTableFieldsNames(T);
  LSQL := LSQL + ' from '   + TOrionDataRtti<T>.New(nil).GetTableName(T);

  LJoins := TOrionDataRtti<T>.New(nil).GetJoins(T);
  LSQL := LSQL + ' ' + LJoins;

  LSQL := LSQL + ' ' + aWhere;

  if FOrderBy <> '' then
    LSQL := LSQL + ' Order by ' + FOrderBy;

  FDataSet.Close;
  FDataSet.SQL(LSQL);
end;

procedure TOrionDAOServer<T>.ChecarExclusoes;
var
  Key :integer;
begin
  for Key in FListaRecNoDataSet.Keys do
  begin
    if FListaRecNoDataSet[Key] = False then
    begin
      FDataSet.First;
      while not FDataSet.Eof do
      begin
        if Key = FDataSet.RecNo then
          FDataSet.Delete;

        FDataSet.Next;
      end;
    end;
  end;
end;

constructor TOrionDAOServer<T>.Create(aDataSet :iDataSet);
begin
  FDataSet := aDataSet;
  FEntity := T.Create;
  FEntityList := TObjectList<T>.Create;
  TOrionDataRtti<T>.New(nil).CriarCamposDataSet(FDataSet);

  FParamsList := TDictionary<string, variant>.Create;

  FListaParametros   := TDictionary<string, Variant>.Create;
  FListaRecNoDataSet := TDictionary<integer, Boolean>.Create;
end;

function TOrionDAOServer<T>.Current: T;
begin
  TOrionDataRtti<T>.New(nil).DataSetSelectedRecordToClass(FDataset, FEntity);
  Result := FEntity;
end;

function TOrionDAOServer<T>.Delete: iOrionDAOServer<T>;
begin
  LoadParams;
  FDataSet.Open;
  FDataSet.First;
  while not FDataSet.Eof do
    FDataSet.Delete;

  FDataSet.ApplyUpdates(0);
end;

destructor TOrionDAOServer<T>.Destroy;
begin
  FEntity.DisposeOf;
  FEntityList.DisposeOf;
  FListaParametros.DisposeOf;
  FListaRecNoDataSet.DisposeOf;
  FParamsList.DisposeOf;

  if Assigned(FJSON) then
    FJSON.Free;
  inherited;
end;

procedure TOrionDAOServer<T>.EmptyParams;
begin
  FParamsList.Clear;
end;

function TOrionDAOServer<T>.Entity :iOrionDAOEntity<T>;
begin
  Result := Self;
end;

function TOrionDAOServer<T>.Go: iOrionDAOServer<T>;
begin
  Result := Self;
  FDataSet.Close;
  LoadParams;
  BuildDataSetSQL(FWhere);
  FDataSet.Open;
  IgnoreJoinFieldsToUpdate;
end;

function TOrionDAOServer<T>.Insert(aValue: T): iOrionDAOServer<T>;
begin
  Result := Self;
  try
    if Assigned(FEntity) then
      FEntity.DisposeOf;

    FEntity := aValue;
    BuildDataSetSQLForUpdate;
    FDataSet.EmptyOpen;
    IgnoreJoinFieldsToUpdate;
    InternalInsert(FEntity);
    InternalApplyUpdates;
    InternalRefreshObject(FEntity);
  except on E: Exception do

  end;

end;

procedure TOrionDAOServer<T>.IgnoreJoinFieldsToUpdate;
begin
  var LListaFieldJoins := TOrionDataRtti<T>.New(nil).GetFieldsOnJoins;
  if LListaFieldJoins.Count > 0 then
  begin
    for var FieldName in LListaFieldJoins do
      FDataSet.Fields.FieldByName(FieldName).ProviderFlags := [];
  end;
  FreeAndNil(LListaFieldJoins);
end;

function TOrionDAOServer<T>.Insert(aValue: TObjectList<T>): iOrionDAOServer<T>;
begin
  BuildDataSetSQLForUpdate;
  FDataSet.EmptyOpen;
  IgnoreJoinFieldsToUpdate;
  for var I := 0 to Pred(aValue.Count) do
  begin
    InternalInsert(aValue[i]);
    InternalRefreshObject(aValue[i]);
  end;

  InternalApplyUpdates;
end;

procedure TOrionDAOServer<T>.InternalApplyUpdates;
begin
  if not FDataSet.ApplyUpdates(0) = 0 then
    raise Exception.Create('Problema na gravação dos dados. A operação não poderá ser concluída. Classe : ' + T.ClassName);
end;

procedure TOrionDAOServer<T>.InternalDelete(aValue: T);
var
  lPrimaryKeys : TDictionary<string,Variant>;
begin
  lPrimaryKeys := TOrionDataRtti<T>.New(nil).GetPrimaryKeys(aValue);

end;

procedure TOrionDAOServer<T>.InternalInsert(aValue: T);
begin
  FDataSet.Append;
  TOrionDataRtti<T>.New(nil).ObjectToDataSet(aValue, FDataSet);
  FDataSet.Post;
end;

procedure TOrionDAOServer<T>.InternalRefreshObject(aValue : T);
//var
//  FieldValues : TDictionary<string,Variant>;
//  lValue : Variant;
//  Key :string;
begin
//  FieldValues := TOrionDataRtti<T>.New(nil).GetPrimaryKeys(aValue);
//
//  for Key in FieldValues.Keys do
//  begin
//    lValue := Null;
//    lValue := FDataSet.Fields.FieldByName(Key).AsVariant;
//    FieldValues.AddOrSetValue();
//  end;
  TOrionDataRtti<T>.New(nil).DataSetSelectedRecordToObject(FDataSet, aValue);
end;

procedure TOrionDAOServer<T>.InternalUpdate(aValue: T);
var
  CamposPK :string;
  ValoresPK :array of Variant;
  Key: string;
  LListaCamposPK :TDictionary<string, Variant>;
begin
  CamposPK := '';
  LListaCamposPK := TOrionDataRtti<T>.New(nil).GetPrimaryKeys(aValue);
  try
    for Key in LListaCamposPK.Keys do
    begin
      if CamposPK = '' then
        CamposPK := Key
      else
        CamposPK := CamposPK + ';' + Key;

      SetLength(ValoresPK, (Length(ValoresPK)+1));
      ValoresPK[Pred(Length(ValoresPK))] := LListaCamposPK[Key];
    end;

    if CamposPK = '' then
      raise  Exception.Create('Nenhuma Chave Primária foi definida na classe ' + aValue.ClassName);

    if FDataSet.Locate(CamposPK, ValoresPK, []) then
    begin
      FDataSet.Edit;
      FListaRecNoDataSet.AddOrSetValue(FDataSet.RecNo, True);
    end
    else
      FDataSet.Append;

    TOrionDataRtti<T>.New(nil).ObjectToDataSet(aValue, FDataSet);

    FDataSet.Post;
  finally
    if Assigned(LListaCamposPK) then
      FreeAndNil(LListaCamposPK);
  end;
end;

procedure TOrionDAOServer<T>.LoadParams;
var
  LName: string;
begin
  FWhere := '';
  for LName in FParamsList.Keys do
  begin
    if VarIsNull(FParamsList[LName]) then
      Continue;

    if Trim(FParamsList[LName]) = '' then
      Continue;

    if FWhere = '' then
      FWhere := 'where ' + LName + ' = ' + VarToStr(FParamsList[LName]).QuotedString
    else
      FWhere := FWhere + ' and ' + LName + ' = ' + VarToStr(FParamsList[LName]).QuotedString;;

  end;
end;

class function TOrionDAOServer<T>.New(aDataSet :iDataSet): iOrionDAOServer<T>;
begin
  Result := Self.Create(aDataSet);
end;

function TOrionDAOServer<T>.NewInstance: T;
begin
  if Assigned(FEntity) then
    FEntity.Free;

  FEntity := T.Create;
  Result := FEntity;
end;

procedure TOrionDAOServer<T>.PrepareListOfPossibleExclusions;
begin
  FDataSet.First;
  while not FDataSet.EOF do
  begin
    FListaRecNoDataSet.Add(FDataSet.RecNo, False);
    FDataSet.Next;
  end;
  FDataSet.First;
end;

function TOrionDAOServer<T>.ResultSet: iOrionDAOServerResultSet<T>;
begin
  Result := Self;
end;

function TOrionDAOServer<T>.Search: iOrionDAOServerSearch<T>;
begin
  Result := Self;
end;

function TOrionDAOServer<T>.SetParam(aName: string; aValue: Variant): iOrionDAOServerSearch<T>;
begin
  Result := Self;
  FParamsList.AddOrSetValue(aName, aValue);
end;

function TOrionDAOServer<T>.ToJSON(aValue: TJSONValue): iOrionDAOServer<T>;
begin

end;

function TOrionDAOServer<T>.Update(aValue: TObjectList<T>): iOrionDAOServer<T>;
var
  I, Key: Integer;
begin
//  EmptyParams;
//  FParamsList := TOrionDataRtti<T>.New(nil).GetPrimaryKeys(aValue[0]);
//  LoadParams;
//  BuildDataSetSQLForUpdate(FWhere);
//  FDataSet.Open;
//  IgnoreJoinFieldsToUpdate;
  PrepareListOfPossibleExclusions;
  if aValue.Count > 0 then
  begin
    for I := 0 to Pred(aValue.Count) do
      InternalUpdate(aValue[i]);

    ChecarExclusoes;
    InternalApplyUpdates;
  end;
end;

function TOrionDAOServer<T>.Update(aValue: T): iOrionDAOServer<T>;
begin
//  EmptyParams;
//  FParamsList := TOrionDataRtti<T>.New(nil).GetPrimaryKeys(aValue);
//  LoadParams;
//  BuildDataSetSQLForUpdate(FWhere);
//  FDataSet.Open;
//  IgnoreJoinFieldsToUpdate;
  InternalUpdate(aValue);
  InternalApplyUpdates;
end;

end.

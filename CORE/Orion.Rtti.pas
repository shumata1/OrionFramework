unit Orion.Rtti;

interface

uses
  Orion.Interfaces,
  System.JSON,
  System.Generics.Collections,
  Orion.Data.Interfaces;
type
  TOrionRtti<T:class, constructor> = class(TInterfacedObject, iOrionRtti<T>)
  private
    FInstance :T;
  public
    constructor Create(aInstance :T);
    destructor Destroy; override;
    class function New(aInstance :T) :iOrionRtti<T>;

    function GetResource(out aResource :string)                     : iOrionRtti<T>;
    function GetTableName                                           : string;
    function GetFieldsNames                                         : string;
    function ObjJSONToClass(aObj :TJSONValue; var aLista: TList<T>) : iOrionRtti<T>;
    function JSONToObject(aJSON :TJSONValue; aObject : T)           : iOrionRtti<T>;
    function JSONArrayToObjectList(aJSON :TJSONArray; var aList :TObjectList<T>) : iOrionRtti<T>;
    function CriarCamposDataSet(var aDataSet :iDataSet)             : iOrionRtti<T>;
    function SetarConfiguracoesCampos(var aDataSet :iDataSet)       : iOrionRtti<T>;
    function ClassToDataSet(aClass :T; aDataSet :iDataSet)          : iOrionRtti<T>;
    function ClassToDataSetEquals(aClass :T; aDataSet :iDataSet)    : iOrionRtti<T>;
    function ClassListToDataSet(aList :TObjectList<T>; aDataSet :iDataSet) : iOrionRtti<T>;
    function DataSetSelectedRecordToClass(aDataSet :iDataSet; aClass :T)          : iOrionRtti<T>;
    function GetPrimaryKeys(aClass :T)                              : TDictionary<string, Variant>;
    function ObjectToObject(aSource, aTarget :T) : iOrionRtti<T>;
  end;
implementation

uses
  System.Rtti,
  Orion.Attributes,
  System.TypInfo,
  Data.DB,
  System.SysUtils,
  System.Variants;

{ TOrionORMRtti }

function TOrionRtti<T>.ClassListToDataSet(aList: TObjectList<T>; aDataSet: iDataSet): iOrionRtti<T>;
var
  LObject :T;
begin
  if Assigned(aList) then
  begin
    for LObject in aList.List do
    begin
      aDataSet.Append;
      ClassToDataSet(LObject, aDataSet);
      aDataSet.Post;
    end;
  end;
end;

function TOrionRtti<T>.ClassToDataSet(aClass: T; aDataSet: iDataSet): iOrionRtti<T>;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
  LNomeCampo :string;
  LInfo :pTypeInfo;
begin
  LCtxRtti := TRttiContext.Create;
  try
    LInfo    := System.TypeInfo(T);
    LTypRtti := LCtxRtti.GetType(LInfo);

    for LpropRtti in LTypRtti.GetProperties do
    begin
      for LAttribRtti in LpropRtti.GetAttributes do
      begin
        if (LAttribRtti is Campo) then
        begin
          LNomeCampo := Campo(LAttribRtti).Nome;
          Break;
        end;
      end;

      if LNomeCampo <> '' then
      begin
        case LpropRtti.PropertyType.TypeKind of
          tkUnknown: aDataSet.Fields.FieldByName(LNomeCampo).AsVariant  := LpropRtti.GetValue(LInfo).AsVariant;
          tkString:  aDataSet.Fields.FieldByName(LNomeCampo).AsString   := LpropRtti.GetValue(LInfo).AsString;
          tkChar:    aDataSet.Fields.FieldByName(LNomeCampo).AsString   := LpropRtti.GetValue(LInfo).AsString;
          tkWChar:   aDataSet.Fields.FieldByName(LNomeCampo).AsString   := LpropRtti.GetValue(LInfo).AsString;
          tkLString: aDataSet.Fields.FieldByName(LNomeCampo).AsString   := LpropRtti.GetValue(LInfo).AsString;
          tkWString: aDataSet.Fields.FieldByName(LNomeCampo).AsString   := LpropRtti.GetValue(LInfo).AsString;
          tkUString: aDataSet.Fields.FieldByName(LNomeCampo).AsString   := LpropRtti.GetValue(LInfo).AsString;
          tkVariant: aDataSet.Fields.FieldByName(LNomeCampo).AsVariant  := LpropRtti.GetValue(LInfo).AsVariant;
          tkFloat:   aDataSet.Fields.FieldByName(LNomeCampo).AsExtended := LpropRtti.GetValue(LInfo).AsExtended;
          tkInteger: aDataSet.Fields.FieldByName(LNomeCampo).AsInteger  := LpropRtti.GetValue(LInfo).AsInteger;
        end;
        LNomeCampo := '';
      end;
    end;
  finally
    LCtxRtti.Free;
  end;
end;

function TOrionRtti<T>.ClassToDataSetEquals(aClass: T; aDataSet: iDataSet): iOrionRtti<T>;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LInfo :pTypeInfo;
begin
  LCtxRtti := TRttiContext.Create;
  try
    LInfo    := System.TypeInfo(T);
    LTypRtti := LCtxRtti.GetType(LInfo);

    for LpropRtti in LTypRtti.GetProperties do
    begin
      if aDataSet.Fields.FindField(LpropRtti.Name) <> nil then
      begin
        case LpropRtti.PropertyType.TypeKind of
          tkUnknown: aDataSet.Fields.FieldByName(LpropRtti.Name).AsVariant  := LpropRtti.GetValue(Pointer(FInstance)).AsVariant;
          tkString:  aDataSet.Fields.FieldByName(LpropRtti.Name).AsString   := LpropRtti.GetValue(Pointer(FInstance)).AsString;
          tkChar:    aDataSet.Fields.FieldByName(LpropRtti.Name).AsString   := LpropRtti.GetValue(Pointer(FInstance)).AsString;
          tkWChar:   aDataSet.Fields.FieldByName(LpropRtti.Name).AsString   := LpropRtti.GetValue(Pointer(FInstance)).AsString;
          tkLString: aDataSet.Fields.FieldByName(LpropRtti.Name).AsString   := LpropRtti.GetValue(Pointer(FInstance)).AsString;
          tkWString: aDataSet.Fields.FieldByName(LpropRtti.Name).AsString   := LpropRtti.GetValue(Pointer(FInstance)).AsString;
          tkUString: aDataSet.Fields.FieldByName(LpropRtti.Name).AsString   := LpropRtti.GetValue(Pointer(FInstance)).AsString;
          tkVariant: aDataSet.Fields.FieldByName(LpropRtti.Name).AsVariant  := LpropRtti.GetValue(Pointer(FInstance)).AsVariant;
          tkFloat:   aDataSet.Fields.FieldByName(LpropRtti.Name).AsExtended := LpropRtti.GetValue(Pointer(FInstance)).AsExtended;
          tkInteger: aDataSet.Fields.FieldByName(LpropRtti.Name).AsInteger  := LpropRtti.GetValue(Pointer(FInstance)).AsInteger;
        end;
      end;
    end;
  finally
    LCtxRtti.Free;
  end;
end;

constructor TOrionRtti<T>.Create(aInstance :T);
begin
  FInstance := aInstance;
end;

function TOrionRtti<T>.CriarCamposDataSet(var aDataSet :iDataSet): iOrionRtti<T>;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
  LNomeCampo :string;
  LDisplayLabel :string;
  LTipoCampo :TTipoCampo;
  LTamanhoCampo :integer;
  LDisplayWidth :integer;
begin
  LCtxRtti := TRttiContext.Create;
  try
    LTypRtti := LCtxRtti.GetType(T);
    aDataSet.FieldDefs.Clear;
    for LpropRtti in LTypRtti.GetProperties do
    begin
      for LAttribRtti in LpropRtti.GetAttributes do
      begin
        if LAttribRtti is Campo then
        begin
          LNomeCampo    := LpropRtti.Name;
          LTipoCampo    := Campo(LAttribRtti).TipoCampo;
          LTamanhoCampo := Campo(LAttribRtti).Tamanho;
          LDisplayWidth := Campo(LAttribRtti).DisplayWidth;
          Break;
        end;
      end;
      case LTipoCampo of
        tcString:   aDataSet.FieldDefs.Add( LNomeCampo, ftString,   LTamanhoCampo );
        tcInteger:  aDataSet.FieldDefs.Add( LNomeCampo, ftInteger,  LTamanhoCampo );
        tcFloat:    aDataSet.FieldDefs.Add( LNomeCampo, ftFloat,    LTamanhoCampo );
        tcDateTime: aDataSet.FieldDefs.Add( LNomeCampo, ftDateTime, LTamanhoCampo );
        tcBoolean:  aDataSet.FieldDefs.Add( LNomeCampo, ftBoolean,  LTamanhoCampo );
      end;
    end;

    aDataSet.Close;
    aDataSet.CreateDataSet;
    for LpropRtti in LTypRtti.GetProperties do
    begin

      for LAttribRtti in LpropRtti.GetAttributes do
      begin
        if LAttribRtti is Campo then
        begin
          LNomeCampo    := LpropRtti.Name;
          LDisplayWidth := Campo(LAttribRtti).DisplayWidth;
          LDisplayLabel := Campo(LAttribRtti).DisplayLabel;
          Break;
        end;
      end;
      aDataSet.Fields.FieldByName(LNomeCampo).DisplayWidth := LDisplayWidth;
      aDataSet.Fields.FieldByName(LNomeCampo).DisplayLabel := LDisplayLabel;
    end;

    aDataSet.Close;
    aDataSet.CreateDataSet;
  finally
    LCtxRtti.Free;
  end;
end;

function TOrionRtti<T>.DataSetSelectedRecordToClass(aDataSet: iDataSet; aClass: T): iOrionRtti<T>;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
  LNomeCampo :string;
  LInfo :pTypeInfo;
begin

end;

destructor TOrionRtti<T>.Destroy;
begin

  inherited;
end;

class function TOrionRtti<T>.New(aInstance :T): iOrionRtti<T>;
begin
  Result := Self.Create(aInstance);
end;

function TOrionRtti<T>.ObjectToObject(aSource, aTarget: T): iOrionRtti<T>;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRttiSource :TRttiProperty;
  LpropRttiTarget :TRttiProperty;
begin
  try
    LTypRtti := LCtxRtti.GetType(T);
    for LPropRttiSource in LTypRtti.GetProperties do
    begin
      for LPropRttiTarget in LTypRtti.GetProperties do
      begin
        if LpropRttiTarget.Name = LpropRttiSource.Name then
        begin
          LpropRttiSource.SetValue(Pointer(aTarget), LPropRttiSource.GetValue(Pointer(aSource)));
          Break;
        end;
      end;
    end;
  finally
    LTypRtti.Free;
  end;
end;

function TOrionRtti<T>.ObjJSONToClass(aObj: TJSONValue; var aLista: TList<T>): iOrionRtti<T>;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
  LValue :TValue;
  LNomeCampo :string;
  LTipoCampo :TTipoCampo;
  LInfo :PTypeInfo;
begin
  LCtxRtti := TRttiContext.Create;
  try
    LTypRtti := LCtxRtti.GetType(T);
    LInfo := System.TypeInfo(T);
    for LpropRtti in LTypRtti.GetProperties do
    begin
      for LAttribRtti in LpropRtti.GetAttributes do
      begin
        if LAttribRtti is Campo then
        begin
          LNomeCampo := Campo(LAttribRtti).Nome;
          LTipoCampo := Campo(LAttribRtti).TipoCampo;
        end;
      end;

      if LNomeCampo <> '' then
      begin
        case LTipoCampo of
          tcString:   LValue := aObj.GetValue<string>(LpropRtti.Name);
          tcInteger:  LValue := aObj.GetValue<integer>(LpropRtti.Name);
          tcFloat:    LValue := aObj.GetValue<Double>(LpropRtti.Name);
          tcDateTime: LValue := aObj.GetValue<TDateTime>(LpropRtti.Name);
        end;
      end;

      LpropRtti.SetValue(Pointer(aLista.Last), LValue);
      LNomeCampo := '';
    end;
  finally
    LCtxRtti.Free;
  end;
end;


function TOrionRtti<T>.SetarConfiguracoesCampos(var aDataSet: iDataSet): iOrionRtti<T>;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
  LDisplayWidth :integer;
  LDisplayLabel :string;
begin
  LCtxRtti := TRttiContext.Create;
  try
    LTypRtti := LCtxRtti.GetType(T);
    for LpropRtti in LTypRtti.GetProperties do
    begin
      for LAttribRtti in LpropRtti.GetAttributes do
      begin
        if LAttribRtti is Campo then
        begin
          LDisplayWidth := Campo(LAttribRtti).DisplayWidth;
          LDisplayLabel := Campo(LAttribRtti).DisplayLabel;
          Break;
        end;

      end;
      aDataSet.Fields.FieldByName(LpropRtti.Name).DisplayWidth := LDisplayWidth;
      aDataSet.Fields.FieldByName(LpropRtti.Name).DisplayLabel := LDisplayLabel;
    end;
  finally
    LCtxRtti.Free;
  end;
end;

function TOrionRtti<T>.GetTableName: string;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
begin
  LCtxRtti := TRttiContext.Create;
  try
    LTypRtti := LCtxRtti.GetType(T);
    for LAttribRtti in LTypRtti.GetAttributes do
    begin
      if LAttribRtti is Tabela then
      begin
        Result := Tabela(LAttribRtti).Nome;
        Break
      end;
    end;
  finally
    LCtxRtti.Free;
  end;
end;

function TOrionRtti<T>.JSONArrayToObjectList(aJSON: TJSONArray; var aList: TObjectList<T>): iOrionRtti<T>;
var
  I: Integer;
begin
  if not Assigned(aJSON) then
    raise Exception.Create('TOrionRtti.JSONArrayToObjectList: JSON não atribuído');

  if not Assigned(aList) then
    raise Exception.Create('TOrionRtti.JSONArrayToObjectList: Lista de Objetos não atribuído');

  for I := 0 to Pred(aJSON.Count) do
  begin
    aList.Add(T.Create);
    TOrionRtti<T>.New(nil).JSONToObject(aJSON.Items[i], aList.Last);
  end;
end;

function TOrionRtti<T>.JSONToObject(aJSON: TJSONValue; aObject: T): iOrionRtti<T>;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
  LValue :TValue;
  LNomeCampo :string;
  LTipoCampo :TTipoCampo;
begin
  LCtxRtti := TRttiContext.Create;
  try
    LTypRtti := LCtxRtti.GetType(T);
    for LpropRtti in LTypRtti.GetProperties do
    begin
      for LAttribRtti in LpropRtti.GetAttributes do
      begin
        if LAttribRtti is Campo then
        begin
          LNomeCampo := Campo(LAttribRtti).Nome;
          LTipoCampo := Campo(LAttribRtti).TipoCampo;
          Break;
        end;
      end;

      LValue.FromVariant(Null);
      LNomeCampo := UpperCase(LpropRtti.Name);
      if LNomeCampo <> '' then
      begin
        case LTipoCampo of
          tcString:   LValue := aJSON.GetValue<string>(LNomeCampo);
          tcInteger:  LValue := aJSON.GetValue<integer>(LNomeCampo);
          tcFloat:    LValue := aJSON.GetValue<Double>(LNomeCampo);
          tcDateTime:
          begin
            if Trim(aJSON.GetValue<string>(LNomeCampo)) <> '' then
              LValue := aJSON.GetValue<TDateTime>(LNomeCampo)
            else
              LValue := TDateTime(0);
          end;
        end;
      end;
      if LValue.DataSize > 0 then
        LpropRtti.SetValue(Pointer(aObject), LValue);
      LNomeCampo := '';
    end;
  finally
    LCtxRtti.Free;
  end;
end;

function TOrionRtti<T>.GetFieldsNames: string;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
  LNomeCampo :string;
begin
  Result := '';

  LCtxRtti := TRttiContext.Create;
  try
    LTypRtti := LCtxRtti.GetType(T);
    for LPropRtti in LTypRtti.GetProperties do
    begin
      for LAttribRtti in LPropRtti.GetAttributes do
      begin
        if LAttribRtti is Campo then
        begin
          LNomeCampo := Campo(LAttribRtti).Nome;
          Break
        end;
      end;
      Result := Result + LNomeCampo + ' as ' + LpropRtti.Name+', ';
    end;
    Result := Copy(Result, 0, Length(Result) - 2) + ' ';
  finally
    LCtxRtti.Free;
  end;
end;

function TOrionRtti<T>.GetPrimaryKeys(aClass: T): TDictionary<string, Variant>;
var
  LCtx :TRttiContext;
  LType :TRttiType;
  LProp :TRttiProperty;
  LAttrib :TCustomAttribute;
  LNomeCampo :string;
  Passou :Boolean;
begin
  LCtx := TRttiContext.Create;
  Result := TDictionary<string, Variant>.Create;
  try
    LType := LCtx.GetType(AClass.ClassInfo);
    for LProp in LType.GetProperties do
    begin
      LNomeCampo := '';
      Passou     := False;
      for LAttrib in LProp.GetAttributes do
      begin
        if (LAttrib is Campo) then
          LNomeCampo := Campo(LAttrib).Nome;

        if (LAttrib is PK) then
          Passou := True;
      end;
      if Passou then
        Result.Add(LNomeCampo, LProp.GetValue(Pointer(aClass)).AsVariant);
    end;
  finally
    LCtx.Free;
  end;
end;

function TOrionRtti<T>.GetResource(out aResource :string): iOrionRtti<T>;
var
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LpropRtti :TRttiProperty;
  LAttribRtti :TCustomAttribute;
begin
  LCtxRtti := TRttiContext.Create;
  try
    LTypRtti := LCtxRtti.GetType(T);
    for LAttribRtti in LTypRtti.GetAttributes do
    begin
      if LAttribRtti is RestResource then
      begin
        aResource := RestResource(LAttribRtti).Resource;
        Break;
      end;
    end;
  finally
    LCtxRtti.Free;
  end;
end;
end.

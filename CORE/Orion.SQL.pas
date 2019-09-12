unit Orion.SQL;

interface

uses
  Orion.Interfaces;

type
  TOrionORMSQL<T> = class(TInterfacedObject, iOrionSQL<T>)
  private
    function NomeTabela :string;
  public
    constructor Create;
    destructor Destroy; override;
    class function New :iOrionSQL<T>;

    function MontarBuscar(out aSQL :string) :iOrionSQL<T>;
    function MontarBuscarPorID(out aSQL :string; aID :string) :iOrionSQL<T>;
    function MontarInserir(out aSQL :string) :iOrionSQL<T>;
    function MontarAlterar(out aSQL :string) :iOrionSQL<T>;
    function MontarDeletar(out aSQL :string) :iOrionSQL<T>;
  end;
implementation

uses
  System.JSON, System.Rtti, System.TypInfo, Orion.Attributes;

{ TOrionORMSQL<T> }

constructor TOrionORMSQL<T>.Create;
begin

end;

destructor TOrionORMSQL<T>.Destroy;
begin

  inherited;
end;

function TOrionORMSQL<T>.MontarAlterar(out aSQL: string): iOrionSQL<T>;
begin

end;

function TOrionORMSQL<T>.MontarBuscar(out aSQL: string): iOrionSQL<T>;
var
  LctxRtti :TRttiContext;
  LtypRtti :TRttiType;
  LprpRtti :TRttiProperty;
  LInfo : PTypeInfo;
  LAttRtti: TCustomAttribute;
  LIgnorar :Boolean;
  LCampo, LID :string;
begin
  if aSQL = '' then
    aSQL := 'select ';

  LIgnorar := False;
  LInfo := System.TypeInfo(T);
  LctxRtti := TRttiContext.Create;
  try
    LtypRtti := LctxRtti.GetType(LInfo);
    for LprpRtti in LtypRtti.GetProperties do
    begin
      for LAttRtti in LprpRtti.GetAttributes do
      begin
        if LAttRtti is Ignorar then
          LIgnorar := true;

        if LAttRtti is Campo then
          LCampo := Campo(LAttRtti).Nome;

        if LAttRtti is ID then
          LID := LCampo;
      end;
      if LIgnorar = False then
        aSQL := aSQL + LCampo+', ';



    end;

    {Retirar a última vírgula}
    aSQL := Copy(aSQL, 0, Length(aSQL) - 2) + ' ';

    aSQL := aSQL + ' from ' + NomeTabela;
    aSQL := aSQL + ' order by ' + LID;
  finally
    LctxRtti.Free;
  end;
end;

function TOrionORMSQL<T>.MontarBuscarPorID(out aSQL: string; aID :string): iOrionSQL<T>;
var
  LctxRtti :TRttiContext;
  LtypRtti :TRttiType;
  LprpRtti :TRttiProperty;
  LInfo : PTypeInfo;
  LAttRtti: TCustomAttribute;
  LIgnorar :Boolean;
  LCampo :string;
  LCampoID :string;
begin
  if aSQL = '' then
    aSQL := 'select ';

  LIgnorar := False;
  LInfo := System.TypeInfo(T);
  LctxRtti := TRttiContext.Create;
  try
    LtypRtti := LctxRtti.GetType(LInfo);
    for LprpRtti in LtypRtti.GetProperties do
    begin
      for LAttRtti in LprpRtti.GetAttributes do
      begin
        if LAttRtti is Campo then
          LCampo := Campo(LAttRtti).Nome;

        if LAttRtti is ID then
          LCampoID := LCampo;
      end;

      aSQL := aSQL + LCampo+', ';
    end;

    {Retirar a última vírgula}
    aSQL := Copy(aSQL, 0, Length(aSQL) - 2) + ' ';

    aSQL := aSQL + ' from ' + NomeTabela;
    aSQL := aSQL + ' where ' +LCampoID +' = ' + aID;
  finally
    LctxRtti.Free;
  end;

end;

function TOrionORMSQL<T>.MontarDeletar(out aSQL: string): iOrionSQL<T>;
begin

end;

function TOrionORMSQL<T>.MontarInserir(out aSQL: string): iOrionSQL<T>;
var
  LFieldList :string;
  LFieldValueList : string;
  LCtxRtti :TRttiContext;
  LTypRtti :TRttiType;
  LPropRtti :TRttiProperty;
  LAttRtti :TCustomAttribute;
  LInfo :PTypeInfo;
  LID, LIDValue :string;
  LIgnorar :Boolean;
  LCampo :string;
begin
  LCtxRtti := TRttiContext.Create;
  try
    LInfo := System.TypeInfo(T);
    LTypRtti := LCtxRtti.GetType(LInfo);
    for LPropRtti in LTypRtti.GetProperties do
    begin
      LIgnorar := False;
      for LAttRtti in LPropRtti.GetAttributes do
      begin
        if LAttRtti is Ignorar then
          LIgnorar := True;

        if LAttRtti is Campo then
          LCampo := Campo(LAttRtti).Nome;

        if LAttRtti is ID then
          LID := LCampo;
      end;

      LFieldList := LFieldList + LCampo + ', ';
      LFieldValueList := LFieldValueList + LPropRtti.GetValue(LInfo).AsString + ', ';
    end;
  finally
    LCtxRtti.Free;
  end;

  LFieldList      := Copy(LFieldList, 0, Length(LFieldList) - 2) + ' ';
  LFieldValueList := Copy(LFieldValueList, 0, Length(LFieldValueList) - 2) + ' ';

  aSQL            := ' insert into ' + NomeTabela + '(' + LFieldList;
  aSQL            := aSQL +') values (' + LFieldValueList + ')';
  aSQL            := aSQL +' where ' + LID + ' = ' + LIDValue;
end;

class function TOrionORMSQL<T>.New: iOrionSQL<T>;
begin
  Result := Self.Create;
end;

function TOrionORMSQL<T>.NomeTabela: string;
var
  LctxRtti :TRttiContext;
  LtypRtti :TRttiType;
  LprpRtti :TRttiProperty;
  LInfo : PTypeInfo;
  LAttRtti: TCustomAttribute;
begin
  LInfo := System.TypeInfo(T);
  LctxRtti := TRttiContext.Create;
  try
    LtypRtti := LctxRtti.GetType(LInfo);
    for LAttRtti in LtypRtti.GetAttributes do
    begin
      if LAttRtti is Tabela then
      begin
        Result := Tabela(LAttRtti).Nome;
        Break;
      end;
    end;
  finally
    LctxRtti.Free;
  end;
end;

end.

unit Orion.NormalRtti;

interface

uses
  Orion.Interfaces, System.Generics.Collections;

type
  TOrionNormalRtti = class(TInterfacedObject, iOrionNormalRtti)
  private

  public
    constructor Create;
    destructor Destroy; override;
    class function New :iOrionNormalRtti;

    function GetFieldValue(aFieldNames: array of string; aClass :TObject): TDictionary<string, Variant>;
    function GetIDValue (aObject : TObject): Variant;
  end;
implementation

uses
  System.Rtti,
  Orion.Attributes,
  System.SysUtils,
  System.Variants;

{ TOrionNormalRtti }

constructor TOrionNormalRtti.Create;
begin

end;

destructor TOrionNormalRtti.Destroy;
begin

  inherited;
end;

function TOrionNormalRtti.GetFieldValue(aFieldNames: array of string; aClass :TObject): TDictionary<string, Variant>;
var
  LCtx :TRttiContext;
  LType :TRttiType;
  LProp :TRttiProperty;
  LAttrib :TCustomAttribute;
  LNomeCampo :string;
  Passou :Boolean;
  I: Integer;
begin
  Result := TDictionary<string, Variant>.Create;
  try
    LType := LCtx.GetType(AClass.ClassInfo);
    for LProp in LType.GetProperties do
    begin
      for I := 0 to Pred(Length(aFieldNames)) do
      begin
        if UpperCase(LProp.Name) = aFieldNames[i] then
          Result.Add(LProp.Name, LProp.GetValue(aClass).AsVariant);

        if LProp.Name = aFieldNames[i] then
          Result.Add(LProp.Name, LProp.GetValue(aClass).AsVariant);
      end;
    end;
  finally
    LCtx.Free;
  end;
end;

function TOrionNormalRtti.GetIDValue(aObject : TObject): Variant;
var
  LCtx :TRttiContext;
  LType :TRttiType;
  LProp :TRttiProperty;
  LAttrib :TCustomAttribute;
  LNomeCampo :string;
  Passou :Boolean;
  I: Integer;
begin
  Result := Null;
  try
    LType := LCtx.GetType(aObject.ClassInfo);
    for LProp in LType.GetProperties do
    begin
      for LAttrib in LProp.GetAttributes do
      begin
        if LAttrib is ID then
        begin
          Result := LProp.GetValue(aObject).AsVariant;
          Passou := True;
          Break;
        end;
      end;
      if Passou then
        Break;
    end;
  finally
    LCtx.Free;
  end;

end;

class function TOrionNormalRtti.New: iOrionNormalRtti;
begin
  Result := Self.Create;
end;

end.

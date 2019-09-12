unit Orion.RestHttpClient;

interface

uses
  Orion.Interfaces,
  System.JSON,
  IdHTTP,
  System.Generics.Collections;
type
  TOrionRestHttpClient = class(TInterfacedObject, iOrionRestUri, iOrionRestUriParam)
  private
    FIdHttp :TIdHTTP;
    FBaseUrl :string;
    FResource :string;
    FResourseMethod :TResourceMethod;
    FResult :string;
    FListaParametros : TDictionary<string, string>;

    function RetornaUriGet :string;
    function RetornaUriPost :string;
  public
    constructor Create;
    destructor Destroy; override;
    class function New :iOrionRestUri;

    {iOrionRestUri}
    function AddBaseURL(aValue :string) :iOrionRestUri;
    function Resource(aValue :string) :iOrionRestUri;
    function ResourceMethod(aValue :TResourceMethod) : iOrionRestUri;
    function Params : iOrionRestUriParam;
    function Execute : iOrionRestUri;
    function JSON :TJSONValue;
    function Result :string;

    {iOrionRestUriParam}
    function CreateParam(aName :string) : iOrionRestUriParam;
    function AddParamsList(aLista :TList<string>) : iOrionRestUriParam;
    function SetParamValue(aParamName, aValue :string) : iOrionRestUriParam;
    function Clear : iOrionRestUriParam;
    function EndParam : iOrionRestUri;
  end;

implementation

uses
  System.SysUtils;

{ TOrionRestHttpClient }

function TOrionRestHttpClient.AddBaseURL(aValue: string): iOrionRestUri;
begin
  Result := Self;
  FBaseUrl := aValue;
end;

function TOrionRestHttpClient.AddParamsList(aLista: TList<string>): iOrionRestUriParam;
var
  I: Integer;
begin
  Result := Self;
  for I := 0 to Pred(aLista.Count) do
    FListaParametros.AddOrSetValue(aLista[i], '');
end;

function TOrionRestHttpClient.Clear: iOrionRestUriParam;
begin
  Result := Self;
  FListaParametros.Clear;
end;

constructor TOrionRestHttpClient.Create;
begin
  FIdHttp          := TIdHTTP.Create(nil);
  FListaParametros := TDictionary<string,string>.Create;
end;

function TOrionRestHttpClient.CreateParam(aName: string): iOrionRestUriParam;
begin
  Result := Self;
  FListaParametros.Add(aName, '');
end;

destructor TOrionRestHttpClient.Destroy;
begin
  FreeAndNIl(FIdHttp);
  FreeAndNil(FListaParametros);
  inherited;
end;

function TOrionRestHttpClient.EndParam: iOrionRestUri;
begin

end;

function TOrionRestHttpClient.Execute: iOrionRestUri;
begin
  case FResourseMethod of
    rsmGet:    FResult := FIdHttp.Get(RetornaUriGet);
    rsmPost:   ;
    rsmPut:    ;
    rsmDelete: ;
  end;
end;

function TOrionRestHttpClient.JSON: TJSONValue;
begin
  Result := TJSONObject.ParseJSONValue(TEncoding.ASCII.GetBytes(FResult), 0);
end;

class function TOrionRestHttpClient.New: iOrionRestUri;
begin
  Result := Self.Create;
end;

function TOrionRestHttpClient.Params: iOrionRestUriParam;
begin
  Result := Self;
end;

function TOrionRestHttpClient.Resource(aValue: string): iOrionRestUri;
begin
  Result := Self;
  FResource := aValue;
end;

function TOrionRestHttpClient.ResourceMethod(aValue: TResourceMethod): iOrionRestUri;
begin
  Result := Self;
  FResourseMethod := aValue;
end;

function TOrionRestHttpClient.Result: string;
begin
  Result := FResult;
end;

function TOrionRestHttpClient.RetornaUriGet: string;
var
  LUri: TStringBuilder;
  Key: string;
begin
  LUri := TStringBuilder.Create;
  try
    LUri.Append(FBaseUrl+FResource);
    if FListaParametros.Count > 0 then
    begin

      for Key in FListaParametros.Keys do
      begin
        if Trim(FListaParametros[Key]) <> '' then
        begin
          LUri.Append('?');
          LUri.Append(Key+'=' + FListaParametros[Key]);
          if (FListaParametros.Count > 1) then
            LUri.Append('?');
        end;
      end;
    end;
    Result := LUri.ToString;
  finally
    LUri.Free;
  end;
end;

function TOrionRestHttpClient.RetornaUriPost: string;
begin

end;

function TOrionRestHttpClient.SetParamValue(aParamName, aValue: string): iOrionRestUriParam;
begin
  Result := Self;
  FListaParametros.AddOrSetValue(aParamName, aValue);
end;

end.

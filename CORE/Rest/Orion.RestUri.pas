unit Orion.RestUri;

interface

uses
  REST.Client,
  REST.Response.Adapter,
  System.JSON,
  Orion.Interfaces,
  System.Generics.Collections;
type
  TOrionORMRestUriNativeDelphi = class(TInterfacedObject, iOrionRestUri, iOrionRestUriParam)
  private
    FRestClient :TRESTClient;
    FRestRequest :TRESTRequest;
    FRestResponse :TRESTResponse;
    FResponseAdapter :TRESTResponseDataSetAdapter;

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
  REST.Types, System.SysUtils, System.Classes;

{ TOrionORMRestUriNativeDelphi }

function TOrionORMRestUriNativeDelphi.AddBaseURL(aValue: string): iOrionRestUri;
begin
  Result := Self;
  FRestClient.BaseURL := aValue;
end;

function TOrionORMRestUriNativeDelphi.AddParamsList(aLista: TList<string>): iOrionRestUriParam;
var
  I: Integer;
begin
  for I := 0 to Pred(aLista.Count) do
  begin
    FRestRequest.Params.Add;
    FRestRequest.Params[Pred(FRestRequest.Params.Count)].Name        := aLista[i];
    FRestRequest.Params[Pred(FRestRequest.Params.Count)].ContentType := ctAPPLICATION_JSON;
  end;
end;

function TOrionORMRestUriNativeDelphi.Clear: iOrionRestUriParam;
begin
  Result := Self;
  FRestRequest.Params.Clear;
end;

constructor TOrionORMRestUriNativeDelphi.Create;
begin
  FRestClient         := TRESTClient.Create(nil);
  FRestRequest        := TRESTRequest.Create(nil);
  FRestResponse       := TRESTResponse.Create(nil);
  FResponseAdapter    := TRESTResponseDataSetAdapter.Create(nil);

  FRestClient.Accept         := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
  FRestClient.AcceptCharset  := 'utf-8, *;q=0.8';
  FRestRequest.Accept        := 'application/json, text/plain; q=0.9, text/html;q=0.8,';
  FRestRequest.AcceptCharset := 'utf-8, *;q=0.8';

  FRestRequest.Client       := FRestClient;
  FRestRequest.Response     := FRestResponse;

  FRestResponse.ContentType     := 'application/json';
  FRestResponse.ContentEncoding := 'utf-8';
  FResponseAdapter.Response := FRestResponse;
end;

function TOrionORMRestUriNativeDelphi.CreateParam(aName :string) : iOrionRestUriParam;
begin
  Result := Self;
  FRestRequest.Params.Add;
  FRestRequest.Params[Pred(FRestRequest.Params.Count)].Name        := aName;
  FRestRequest.Params[Pred(FRestRequest.Params.Count)].ContentType := ctAPPLICATION_JSON;
end;

destructor TOrionORMRestUriNativeDelphi.Destroy;
begin
  FreeAndNil(FRestClient);
  FreeAndNil(FRestRequest);
  FreeAndNil(FRestResponse);
  FreeAndNil(FResponseAdapter);

  inherited;
end;

function TOrionORMRestUriNativeDelphi.EndParam: iOrionRestUri;
begin
  Result := Self;
end;

function TOrionORMRestUriNativeDelphi.Execute: iOrionRestUri;
begin
  Result := Self;
  FRestRequest.Execute;
end;

class function TOrionORMRestUriNativeDelphi.New: iOrionRestUri;
begin
  Result := Self.Create;
end;

function TOrionORMRestUriNativeDelphi.Params: iOrionRestUriParam;
begin
  Result := Self as iOrionRestUriParam;
end;

function TOrionORMRestUriNativeDelphi.Resource(aValue: string): iOrionRestUri;
begin
  Result := Self;
  FRestRequest.Resource := aValue;
end;

function TOrionORMRestUriNativeDelphi.ResourceMethod(aValue: TResourceMethod): iOrionRestUri;
begin
  Result := Self;
  case aValue of
    rsmGet    : FRestRequest.Method := rmGET;
    rsmPost   : FRestRequest.Method := rmPOST;
    rsmPut    : FRestRequest.Method := rmPUT;
    rsmDelete : FRestRequest.Method := rmDELETE;
  end;
end;

function TOrionORMRestUriNativeDelphi.Result: string;
begin
  FRestResponse.JSONText;
end;

function TOrionORMRestUriNativeDelphi.JSON: TJSONValue;
begin
  Result := FRestResponse.JSONValue;
end;

function TOrionORMRestUriNativeDelphi.SetParamValue(aParamName, aValue :string) : iOrionRestUriParam;
begin
  Result := Self;
  FRestRequest.Params.ParameterByName(aParamName).Value := aValue;
end;

end.

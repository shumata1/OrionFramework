unit Orion.Data.Conexoes.DBX;

interface

uses
  Orion.Data.Interfaces,
  System.Classes,
  Data.SqlExpr,
  Data.DB,
  DBXMSSQL;

type
  TOrionDataConexoesDBX = class(TInterfacedObject, iConexao, iConexaoParametros)
  private
     FConexao : TSQLConnection;
     FCaminhoBanco : string;
     FUserName : string;
     FSenha : string;
     FPorta : integer;
     FServer : string;
     FTipoBanco :TTipoBanco;
     FDriverName : string;
     FFileName : string;
  public
    constructor Create;
    destructor Destroy; override;
    class function New :iConexao;

    function Parametros :iConexaoParametros;
    function Conexao :iConexao;
    function Conectar :iConexao;
    function GetConnection :TComponent;

    function CarregarArquivo(aFileName : string) : iConexaoParametros;
    function CaminhoBanco(aValue :string) :iConexaoParametros;
    function UserName(aValue :string) :iConexaoParametros;
    function Senha(aValue :string) :iConexaoParametros;
    function Porta(aValue :integer) :iConexaoParametros;
    function Server(aValue :string) :iConexaoParametros;
    function TipoBanco(aValue :TTipoBanco) :iConexaoParametros;
    function &EndParametros:iConexao;
  end;
implementation

uses
  System.SysUtils;

{ TOrionDataConexoesDBX }

function TOrionDataConexoesDBX.CaminhoBanco(aValue: string): iConexaoParametros;
begin
  Result := Self;
  FCaminhoBanco := aValue;
end;

function TOrionDataConexoesDBX.CarregarArquivo(
  aFileName: string): iConexaoParametros;
begin
  Result := Self;
  FFileName := aFileName;
  FConexao.Params.Clear;
  FConexao.Params.LoadFromFile(FFileName);
end;

function TOrionDataConexoesDBX.Conectar: iConexao;
begin
  Result := Self;
  FConexao.DriverName := 'MSSQL';

//  FConexao.Params.Clear;
//  FConexao.LoginPrompt := False;
//  FConexao.DriverName := 'MSSQL';
//
//  FConexao.Params.AddPair('DriverName', 'MSSQL');
//  FConexao.Params.AddPair('DataBase', FCaminhoBanco);
//  FConexao.Params.AddPair('HostName', FServer);
//  FConexao.Params.AddPair('UserName', FUserName);
//  FConexao.Params.AddPair('Password', FSenha);

  FConexao.Connected := True;
end;

function TOrionDataConexoesDBX.Conexao: iConexao;
begin
  Result := Self;
end;

constructor TOrionDataConexoesDBX.Create;
begin
  FConexao := TSQLConnection.Create(nil);
  FConexao.LoginPrompt := False;
end;

destructor TOrionDataConexoesDBX.Destroy;
begin
  FConexao.Free;
  inherited;
end;

function TOrionDataConexoesDBX.EndParametros: iConexao;
begin
  Result := Self;
end;

function TOrionDataConexoesDBX.GetConnection: TComponent;
begin
  Result := FConexao;
end;

class function TOrionDataConexoesDBX.New: iConexao;
begin
  Result := Self.Create;
end;

function TOrionDataConexoesDBX.Parametros: iConexaoParametros;
begin
  Result := Self;
end;

function TOrionDataConexoesDBX.Porta(aValue: integer): iConexaoParametros;
begin
  Result := Self;
  FPorta := aValue;
end;

function TOrionDataConexoesDBX.Senha(aValue: string): iConexaoParametros;
begin
  Result := Self;
  FSenha := aValue;
end;

function TOrionDataConexoesDBX.Server(aValue: string): iConexaoParametros;
begin
  Result := Self;
  FServer := aValue;
end;

function TOrionDataConexoesDBX.TipoBanco(
  aValue: TTipoBanco): iConexaoParametros;
begin
  Result := Self;
  FTipoBanco := aValue;
end;

function TOrionDataConexoesDBX.UserName(aValue: string): iConexaoParametros;
begin
  Result := Self;
  FUserName := aValue;
end;

end.

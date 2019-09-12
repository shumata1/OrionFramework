unit Orion.Data.Factory.FireDAC;

interface

uses
  Orion.Data.Interfaces;
type
  TOrionDataFactoryFireDAC = class(TInterfacedObject, iFactoryFireDAC)
  private

  public
    constructor Create;
    destructor Destroy; override;
    class function New :iFactoryFireDAC;

    function Conexao :iConexao;
    function Query(aConexao :iConexao) :iDataSet;
    function MemTable :iDataSet;
  end;
implementation

uses
  Orion.Data.Conexoes.FireDAC,
  Orion.Data.DataSets.FireDAC.MemTable,
  Orion.Data.DataSets.FireDAC.Query;

{ TOrionDataFactoryFireDAC }

function TOrionDataFactoryFireDAC.Conexao: iConexao;
begin
  Result := TOrionConexaoFireDAC.New;
end;

constructor TOrionDataFactoryFireDAC.Create;
begin

end;

destructor TOrionDataFactoryFireDAC.Destroy;
begin

  inherited;
end;

function TOrionDataFactoryFireDAC.MemTable: iDataSet;
begin
  Result := TOrionDataSetFireDACMemTable.New;
end;

class function TOrionDataFactoryFireDAC.New: iFactoryFireDAC;
begin
  Result := Self.Create;
end;

function TOrionDataFactoryFireDAC.Query(aConexao: iConexao): iDataSet;
begin
  Result := TOrionDataSetFireDACQuery.New(aConexao);
end;

end.

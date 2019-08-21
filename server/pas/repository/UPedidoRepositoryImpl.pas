unit UPedidoRepositoryImpl;

interface

uses
  UPedidoRepositoryIntf, UPizzaTamanhoEnum, UPizzaSaborEnum, UDBConnectionIntf, FireDAC.Comp.Client,
  UPedidoRetornoDTOImpl;

type
  TPedidoRepository = class(TInterfacedObject, IPedidoRepository)
  private
    FDBConnection: IDBConnection;
    FFDQuery: TFDQuery;
  public
    procedure efetuarPedido(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum; const AValorPedido: Currency;
      const ATempoPreparo: Integer; const ACodigoCliente: Integer);
    function consultarPedido(const ADocumentoCliente: String): TPedidoRetornoDTO;
    constructor Create; reintroduce;
    destructor Destroy; override;
  end;

implementation

uses
  UDBConnectionImpl, System.SysUtils, Data.DB, FireDAC.Stan.Param;

const
  CMD_INSERT_PEDIDO
    : String =
    'INSERT INTO tb_pedido (cd_cliente, dt_pedido, dt_entrega, vl_pedido, nr_tempopedido, sabor, tamanho) VALUES (:pCodigoCliente, :pDataPedido, :pDataEntrega, :pValorPedido, :pTempoPedido, :pSabor, :pTamanho)';

  { TPedidoRepository }

function TPedidoRepository.consultarPedido(
  const ADocumentoCliente: String): TPedidoRetornoDTO;
begin
  FFDQuery.Close;
  FFDQuery.SQL.Clear;
  FFDQuery.SQL.Add('select nr_tempopedido, vl_pedido, tamanho, sabor from tb_pedido INNER JOIN tb_cliente  ON tb_cliente.id = tb_pedido.cd_cliente where tb_cliente.nr_documento = :pCodigoCliente ORDER BY tb_pedido.id desc limit 1' );
  FFDQuery.ParamByName('pCodigoCliente').AsString := ADocumentoCliente;
  FFDQuery.Open;
  if FFDQuery.IsEmpty then
     result := TPedidoRetornoDTO.Create(TPizzaTamanhoEnum(0), TPizzaSaborEnum(0), 0, -1)
  else
      Result := TPedidoRetornoDTO.Create(TPizzaTamanhoEnum(FFDQuery.FieldByName('tamanho').AsInteger), TPizzaSaborEnum(FFDQuery.FieldByName('sabor').AsInteger), FFDQuery.FieldByName('vl_pedido').AsFloat, FFDQuery.FieldByName('nr_tempopedido').AsInteger);
end;

constructor TPedidoRepository.Create;
begin
  inherited;

  FDBConnection := TDBConnection.Create;
  FFDQuery := TFDQuery.Create(nil);
  FFDQuery.Connection := FDBConnection.getDefaultConnection;
end;

destructor TPedidoRepository.Destroy;
begin
  FFDQuery.Free;
  inherited;
end;

procedure TPedidoRepository.efetuarPedido(const APizzaTamanho: TPizzaTamanhoEnum; const APizzaSabor: TPizzaSaborEnum; const AValorPedido: Currency;
  const ATempoPreparo: Integer; const ACodigoCliente: Integer);
begin
  FFDQuery.SQL.Text := CMD_INSERT_PEDIDO;

  FFDQuery.ParamByName('pCodigoCliente').AsInteger := ACodigoCliente;
  FFDQuery.ParamByName('pDataPedido').AsDateTime := now();
  FFDQuery.ParamByName('pDataEntrega').AsDateTime := now();
  FFDQuery.ParamByName('pValorPedido').AsCurrency := AValorPedido;
  FFDQuery.ParamByName('pTempoPedido').AsInteger := ATempoPreparo;

  FFDQuery.ParamByName('pSabor').AsInteger   := Ord(APizzaSabor);
  FFDQuery.ParamByName('pTamanho').AsInteger := Ord(APizzaTamanho);


  FFDQuery.Prepare;
  FFDQuery.ExecSQL(True);
end;

end.

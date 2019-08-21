unit UPizzariaControllerImpl;

interface

{$I dmvcframework.inc}

uses MVCFramework,
  MVCFramework.Logger,
  MVCFramework.Commons,
  Web.HTTPApp, UPizzaTamanhoEnum, UPizzaSaborEnum, UEfetuarPedidoDTOImpl;

type

  [MVCDoc('Pizzaria backend')]
  [MVCPath('/')]
  TPizzariaBackendController = class(TMVCController)
  public

    [MVCDoc('Criar novo pedido "201: Created"')]
    [MVCPath('/efetuarPedido')]
    [MVCHTTPMethod([httpPOST])]
    procedure efetuarPedido(const AContext: TWebContext);

    [MVCDoc('Consultar pedido "200: OK"')]
    [MVCPath('/consultarPedido/($ADocumentoCliente)')]
    [MVCHTTPMethod([httpGET])]
    procedure consultarPedido(const ADocumentoCliente: String);
  end;

implementation

uses
  System.SysUtils,
  Rest.json,
  MVCFramework.SystemJSONUtils,
  UPedidoServiceIntf,
  UPedidoServiceImpl, UPedidoRetornoDTOImpl;

{ TApp1MainController }

procedure TPizzariaBackendController.efetuarPedido(const AContext: TWebContext);
var
  oEfetuarPedidoDTO: TEfetuarPedidoDTO;
  oPedidoRetornoDTO: TPedidoRetornoDTO;
begin
  oEfetuarPedidoDTO := AContext.Request.BodyAs<TEfetuarPedidoDTO>;
  try
    with TPedidoService.Create do
      try
        oPedidoRetornoDTO := efetuarPedido(oEfetuarPedidoDTO.PizzaTamanho,
          oEfetuarPedidoDTO.PizzaSabor, oEfetuarPedidoDTO.DocumentoCliente);
        Render(TJson.ObjectToJsonString(oPedidoRetornoDTO));
      finally
        oPedidoRetornoDTO.Free
      end;
  finally
    oEfetuarPedidoDTO.Free;
  end;
  Log.Info('==>Executou o método ', 'efetuarPedido');
end;

procedure TPizzariaBackendController.consultarPedido
  (Const ADocumentoCliente: string);
var
  oPedidoRetornoDTO: TPedidoRetornoDTO;
  oPedidoService: TPedidoService;
begin
  oPedidoService := TPedidoService.Create;
  oPedidoRetornoDTO := oPedidoService.consultarPedido(ADocumentoCliente);
  try
    Render(TJson.ObjectToJsonString(oPedidoRetornoDTO));
  finally
    oPedidoRetornoDTO.Free
  end;
  Log.Info('==>Executou o método ', 'consultarPedido');
end;

end.

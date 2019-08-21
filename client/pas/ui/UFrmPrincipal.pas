unit UFrmPrincipal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    edtDocumentoCliente: TLabeledEdit;
    cmbTamanhoPizza: TComboBox;
    cmbSaborPizza: TComboBox;
    Button1: TButton;
    mmRetornoWebService: TMemo;
    edtEnderecoBackend: TLabeledEdit;
    edtPortaBackend: TLabeledEdit;
    Panel1: TPanel;
    edtDocumento: TLabeledEdit;
    Button2: TButton;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    edtTamanho: TEdit;
    edtSabor: TEdit;
    edtTotal: TEdit;
    edtTempo: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    procedure LimparCampos;
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

var
  Form1: TForm1;

implementation

uses
  Rest.JSON, MVCFramework.RESTClient, UEfetuarPedidoDTOImpl, System.Rtti,
  UPizzaSaborEnum, UPizzaTamanhoEnum, UPedidoRetornoDTOImpl;

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Clt: TRestClient;
  oEfetuarPedido: TEfetuarPedidoDTO;
begin
  Clt := MVCFramework.RESTClient.TRestClient.Create(edtEnderecoBackend.Text,
    StrToIntDef(edtPortaBackend.Text, 80), nil);
  try
    oEfetuarPedido := TEfetuarPedidoDTO.Create;
    try
      oEfetuarPedido.PizzaTamanho :=
        TRttiEnumerationType.GetValue<TPizzaTamanhoEnum>(cmbTamanhoPizza.Text);
      oEfetuarPedido.PizzaSabor :=
        TRttiEnumerationType.GetValue<TPizzaSaborEnum>(cmbSaborPizza.Text);
      oEfetuarPedido.DocumentoCliente := edtDocumentoCliente.Text;
      mmRetornoWebService.Text := Clt.doPOST('/efetuarPedido', [],
        TJson.ObjecttoJsonString(oEfetuarPedido)).BodyAsString;
    finally
      oEfetuarPedido.Free;
    end;
  finally
    Clt.Free;
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  Clt: TRestClient;
  Response: IRESTResponse;
  oPedidoRetornoDTO: TPedidoRetornoDTO;
begin
 Clt := MVCFramework.RESTClient.TRestClient.Create(edtEnderecoBackend.Text,
    StrToIntDef(edtPortaBackend.Text, 80), nil);
    Clt.ReadTimeOut(60000);
    LimparCampos;
  try
    Response := Clt.doGET('/consultarPedido', [edtDocumento.Text]);
    if Response.HasError then
      begin
      Showmessage(Response.BodyAsString());
      Exit;
    end;

    oPedidoRetornoDTO := TJson.JsonToObject<TPedidoRetornoDTO>(Response.BodyAsString());
    if oPedidoRetornoDTO.TempoPreparo < 0 then
      Raise Exception.Create
        ('Não existem pedidos para este número de documento!')
    else
    begin
      edtTamanho.Text := Copy((TRttiEnumerationType.GetName<TPizzaTamanhoEnum>(oPedidoRetornoDTO.PizzaTamanho)),3);
      edtSabor.Text   := Copy((TRttiEnumerationType.GetName<TPizzaSaborEnum>(oPedidoRetornoDTO.PizzaSabor)),3);
      edtTotal.Text   := FormatFloat('#,##0.00', oPedidoRetornoDTO.ValorTotalPedido);
      edtTempo.Text   := IntToStr(oPedidoRetornoDTO.TempoPreparo) + ' minutos';
    end;
  finally
    Clt.Free;
  end;
end;

procedure TForm1.LimparCampos;
begin
  edtTamanho.Clear;
  edtSabor.Clear;
  edtTotal.Clear;
  edtTempo.Clear;
end;

end.

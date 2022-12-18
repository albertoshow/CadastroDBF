unit untPrincipal;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, dbf, DB, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, ExtDlgs, StdCtrls, MaskEdit, DBCtrls, DBExtCtrls, DBGrids;

type

  { TfrmPrincipal }

  TfrmPrincipal = class(TForm)
    btnLocalizar: TButton;
    btnLimpar: TButton;
    btnInserir: TButton;
    btnCompactar: TButton;
    btnReconstruir: TButton;
    cbEstado: TDBComboBox;
    DBNavigator: TDBNavigator;
    gridDados: TDBGrid;
    edtCodigo: TDBEdit;
    edtCelular: TDBEdit;
    edtCredito: TDBEdit;
    edtEndereco: TDBEdit;
    edtDataCad: TDBEdit;
    edtNome: TDBEdit;
    edtBairro: TDBEdit;
    edtCidade: TDBEdit;
    edtCpf: TDBEdit;
    edtRg: TDBEdit;
    edtFone: TDBEdit;
    DBGroupBox1: TDBGroupBox;
    imgFoto: TDBImage;
    dsClientes: TDataSource;
    edtFiltrar: TEdit;
    Label1: TLabel;
    edtLocalizar: TMaskEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    OpFoto: TOpenPictureDialog;
    pnlFoto: TPanel;
    RbCpf: TRadioButton;
    RbRG: TRadioButton;
    TbClientes: TDbf;
    PageControl1: TPageControl;
    Panel1: TPanel;
    Panel2: TPanel;
    pnlBackground: TPanel;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TbClientesBAIRRO: TStringField;
    TbClientesCELULAR: TStringField;
    TbClientesCIDADE: TStringField;
    TbClientesCPF: TStringField;
    TbClientesCREDITO: TFloatField;
    TbClientesDATACAD: TDateTimeField;
    TbClientesENDERECO: TStringField;
    TbClientesESTADO: TStringField;
    TbClientesFONE: TStringField;
    TbClientesFOTO: TBlobField;
    TbClientesID: TAutoIncField;
    TbClientesNOME: TStringField;
    TbClientesRG: TStringField;
    procedure btnCompactarClick(Sender: TObject);
    procedure btnInserirClick(Sender: TObject);
    procedure btnLimparClick(Sender: TObject);
    procedure btnLocalizarClick(Sender: TObject);
    procedure btnReconstruirClick(Sender: TObject);
    procedure dsClientesStateChange(Sender: TObject);
    procedure edtFiltrarChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: char);
    procedure FormShow(Sender: TObject);
    procedure RbCpfClick(Sender: TObject);
    procedure RbRGClick(Sender: TObject);
    procedure TbClientesBeforePost(DataSet: TDataSet);
    procedure TbClientesNewRecord(DataSet: TDataSet);
  private

  public

  end;

var
  frmPrincipal: TfrmPrincipal;

implementation

{$R *.lfm}

{ TfrmPrincipal }

procedure TfrmPrincipal.FormCreate(Sender: TObject);
begin
  // Configurando date e número no linux.
  {$IFDEF LINUX}
  CurrencyString    := 'R$';
  CurrencyFormat    := 2;
  DecimalSeparator  := ',';
  ThousandSeparator := '.';
  DateSeparator     := '/';
  ShortDateFormat   := 'dd/mm/yyyy';
  {$ENDIF}

  //Criando Arquivo DBF
  //Criando o banco e os campos
  if not(FileExists(ExtractFilePath(Application.Name) + 'clientes.dbf')) then
  begin
    TbClientes.FilePathFull := ExtractFilePath(Application.ExeName);
    tbClientes.TableLevel := 7;
    TbClientes.TableName := 'clientes.dbf';
    TbClientes.FieldDefs.Add('Id', ftAutoInc, 0, True);
    TbClientes.FieldDefs.add('Datacad', ftDateTime, 10, True);
    TbClientes.FieldDefs.Add('Nome', ftString, 100, True);
    TbClientes.FieldDefs.Add('Endereco', ftString, 150, False);
    TbClientes.FieldDefs.Add('Bairro', ftString, 80, False);
    TbClientes.FieldDefs.Add('Cidade', ftString, 150, False);
    TbClientes.FieldDefs.Add('Estado', ftString, 2, False);
    TbClientes.FieldDefs.Add('CPF', ftString, 14, False);
    TbClientes.FieldDefs.Add('RG', ftString, 13, False);
    TbClientes.FieldDefs.Add('Fone', ftString, 10, False);
    TbClientes.FieldDefs.Add('Celular', ftString, 13, False);
    TbClientes.FieldDefs.Add('Foto', ftBlob, 0, False);
    TbClientes.FieldDefs.Add('Credito', ftFloat, 16, False);
    TbClientes.FieldDefs.Items[12].Size := 14;
    TbClientes.FieldDefs.Items[12].Precision := 2;
    TbClientes.CreateTable;
  end;
  //Criando os Indices
  if not(FileExists(ExtractFilePath(Application.ExeName) + 'clientes.mdx')) then
  begin
    tbClientes.Exclusive := True;
    TbClientes.Open;
    TbClientes.AddIndex('indx_id','Id', [ixPrimary, ixUnique]);
    TbClientes.AddIndex('indx_nome','Nome', [ixCaseInsensitive]);
    TbClientes.AddIndex('indx_CPF','CPF',[ixUnique]);
    TbClientes.AddIndex('indx_RG', 'RG', [ixCaseInsensitive]);
    TbClientes.Close;
    TbClientes.Exclusive := False;
  end;
  tbClientes.Open;
end;

procedure TfrmPrincipal.FormKeyPress(Sender: TObject; var Key: char);
begin
  if Key = #13 then
  begin
    SelectNext(ActiveControl, true, true);
    Key := #0;
  end;
end;

procedure TfrmPrincipal.FormClose(Sender: TObject; var CloseAction: TCloseAction
  );
begin
  tbClientes.Close;
end;

procedure TfrmPrincipal.dsClientesStateChange(Sender: TObject);
begin
  if tbClientes.State in [dsEdit, dsInsert] then
  begin
    btnInserir.Enabled := True;
    btnLimpar.Enabled  := True;
  end
  else
  begin
    btnInserir.Enabled := False;
    btnLimpar.Enabled  := False;
  end;
end;

procedure TfrmPrincipal.edtFiltrarChange(Sender: TObject);
begin
  if trim(edtFiltrar.text) <> '' then
    TbClientes.Filter := 'Nome = ' + QuotedStr(edtFiltrar.text + '*')
  else
    TbClientes.Filter := '';
end;

procedure TfrmPrincipal.btnInserirClick(Sender: TObject);
begin
  if opFoto.Execute then
  begin
    try
      imgFoto.Picture.LoadFromFile(opFoto.FileName);
    except
      ShowMessage('Arquivo de imagem inválido');
    end;
  end;
end;

procedure TfrmPrincipal.btnCompactarClick(Sender: TObject);
begin
  tbclientes.Close;
  tbclientes.Exclusive := True;
  tbclientes.Open;
  tbclientes.PackTable;
  tbclientes.Close;
  tbclientes.Exclusive := False;
  tbclientes.Open;
end;

procedure TfrmPrincipal.btnLimparClick(Sender: TObject);
begin
  if application.messagebox('Deseja mesmo ' + 'excluir a foto do cliente.','Confirmação',6) <> 6 then
    exit;
  imgFoto.Picture.Clear;
end;

procedure TfrmPrincipal.btnLocalizarClick(Sender: TObject);
begin
  TbClientes.Locate('CPF', edtLocalizar.Text, []);
  TbClientes.Locate('RG', edtLocalizar.Text, []);
end;

procedure TfrmPrincipal.btnReconstruirClick(Sender: TObject);
begin
  tbclientes.Close;
  tbclientes.Exclusive := True;
  tbclientes.Open;
  tbclientes.RegenerateIndexes;
  tbclientes.Close;
  tbclientes.Exclusive := False;
  tbclientes.Open;
end;

procedure TfrmPrincipal.FormShow(Sender: TObject);
begin
  edtFiltrar.SetFocus;
  PageControl1.ActivePage := TabSheet1;
end;

procedure TfrmPrincipal.RbCpfClick(Sender: TObject);
begin
  edtLocalizar.EditMask := '999.999.999-99;1;_';
end;

procedure TfrmPrincipal.RbRGClick(Sender: TObject);
begin
  edtLocalizar.EditMask := '';
  edtLocalizar.MaxLength := 10;
end;

procedure TfrmPrincipal.TbClientesBeforePost(DataSet: TDataSet);
begin
  if Trim(edtNome.Text) = '' then
  begin
    ShowMessage('Informe no nome do cliente');
    Abort;
  end;
end;

procedure TfrmPrincipal.TbClientesNewRecord(DataSet: TDataSet);
begin
  tbClientes.FieldByName('Datacad').Value := date;
  if PageControl1.PageIndex <> 0 then
    PageControl1.PageIndex := 0;
  edtNome.SetFocus;
end;

end.


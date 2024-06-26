unit DataModule.Produto;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef, FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat, FireDAC.FMXUI.Wait, FireDAC.Stan.Param,
  FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB, FireDAC.Comp.DataSet,
  FireDAC.Comp.Client, FMX.Graphics, System.IOUtils;

type
  TDmProduto = class(TDataModule)
    Conn: TFDConnection;
    qryProduto: TFDQuery;
    qryCadProduto: TFDQuery;
    procedure ConnBeforeConnect(Sender: TObject);
    procedure DataModuleCreate(Sender: TObject);
    procedure ConnAfterConnect(Sender: TObject);
  private
  public
    procedure ListarProdutos(pagina: integer; busca: string);
    procedure CadastrarProduto(descricao: string; valor: double; foto: TBitmap);
    procedure EditarProduto(cod_produto: integer; descricao: string; valor: double; foto: TBitmap);
    procedure ExcluirProduto(cod_produto: integer);
  end;

var
  DmProduto: TDmProduto;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

{$R *.dfm}

// Executado antes da conexão com o banco de dados
procedure TDmProduto.ConnBeforeConnect(Sender: TObject);
begin
    Conn.DriverName := 'SQLite';

    {$IFDEF MSWINDOWS}
    Conn.Params.Values['Database'] := System.SysUtils.GetCurrentDir + '\produtos.db';
    {$ELSE}
    Conn.Params.Values['Database'] := TPath.Combine(TPath.GetDocumentsPath, 'produtos.db');
    {$ENDIF}
end;

// Executado ao criar o módulo de dados
procedure TDmProduto.DataModuleCreate(Sender: TObject);
begin
    Conn.Connected := true;
end;

// Executado após conectar ao banco de dados
procedure TDmProduto.ConnAfterConnect(Sender: TObject);
begin
    Conn.ExecSQL('CREATE TABLE IF NOT EXISTS TAB_PRODUTO ( ' +
                            'COD_PRODUTO   INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, ' +
                            'DESCRICAO           VARCHAR (200), ' +
                            'VALOR               DECIMAL (12, 2), ' +
                            'FOTO                BLOB);'
                );
   {
    for x := 51 to 3000 do
        Conn.ExecSQL('INSERT INTO TAB_PRODUTO (DESCRICAO, VALOR, FOTO) VALUES(''Produto de Teste ' +
                    FormatFloat('00', x) + ''', ' + (100 + x).ToString + ', null)');
     }
                
end;

// Lista os produtos de acordo com a página e a busca especificada
procedure TDmProduto.ListarProdutos(pagina: integer; busca: string);
begin
    qryProduto.Active := false;
    qryProduto.SQL.Clear;
    qryProduto.SQL.Add('SELECT P.* ');
    qryProduto.SQL.Add('FROM TAB_PRODUTO P');

    // Filtro por busca
    if busca <> '' then
    begin
        qryProduto.SQL.Add('WHERE P.DESCRICAO LIKE :BUSCA ');
        qryProduto.ParamByName('BUSCA').Value := '%' + busca + '%';
    end;

    qryProduto.SQL.Add('ORDER BY DESCRICAO');
    qryProduto.SQL.Add('LIMIT :PAGINA, :QTD_REG');
    qryProduto.ParamByName('PAGINA').Value := (pagina - 1) * 15;
    qryProduto.ParamByName('QTD_REG').Value := 15;
    qryProduto.Active := true;
end;

// Cadastra um novo produto
procedure TDmProduto.CadastrarProduto(descricao: string; valor: double; foto: TBitmap);
begin
    with qryCadProduto do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('insert into tab_produto(descricao, valor, foto) ');
        SQL.Add('values(:descricao, :valor, :foto)');
        ParamByName('descricao').Value := descricao;
        ParamByName('valor').Value := valor;
        ParamByName('foto').Assign(foto);
        ExecSQL;
    end;
end;

// Edita um produto existente
procedure TDmProduto.EditarProduto(cod_produto: integer; descricao: string; valor: double; foto: TBitmap);
begin
    with qryCadProduto do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('update tab_produto set descricao=:descricao, valor=:valor, ');
        SQL.Add('foto=:foto where cod_produto=:cod_produto');
        ParamByName('descricao').Value := descricao;
        ParamByName('valor').Value := valor;
        ParamByName('foto').Assign(foto);
        ParamByName('cod_produto').Value := cod_produto;
        ExecSQL;
    end;
end;

// Exclui um produto existente
procedure TDmProduto.ExcluirProduto(cod_produto: integer);
begin
    with qryCadProduto do
    begin
        Active := false;
        SQL.Clear;
        SQL.Add('delete from tab_produto where cod_produto=:cod_produto');
        ParamByName('cod_produto').Value := cod_produto;
        ExecSQL;
    end;
end;

end.

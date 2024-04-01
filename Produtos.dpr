program Produtos;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitProduto in 'UnitProduto.pas' {FrmProduto},
  UnitProdutoCad in 'UnitProdutoCad.pas' {FrmProdutoCad},
  DataModule.Produto in 'DataModules\DataModule.Produto.pas' {DmProduto: TDataModule},
  u99Permissions in 'Units\u99Permissions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmProduto, FrmProduto);
  Application.CreateForm(TDmProduto, DmProduto);
  Application.Run;
end.

unit Controller.Cliente;

interface

uses
  Horse, System.JSON, System.SysUtils, Model.Cliente,
  FireDAC.Comp.Client, Data.DB, DataSet.Serialize;

procedure Registry;

implementation

procedure ListarClientes(Req: THorseRequest; Res: THorseResponse);
var
  cli: TCliente;
  qry: TFDQuery;
  erro: string;
  arrayClientes: TJSONArray;
begin
  //Res.Send('Listar clientes novo...');
  try
    cli := TCliente.Create;
  except
    Res.Send('Erro ao conectar com o banco').Status(500);
    Exit;
  end;

  qry := cli.ListarCliente('', erro);
  try
    arrayClientes := qry.ToJSONArray();
    Res.Send<TJSONArray>(arrayClientes);
  finally
    qry.Free;
    cli.Free;
  end;
end;

procedure ListarClienteID(Req: THorseRequest; Res: THorseResponse);
var
  cli: TCliente;
  objCliente: TJSONObject;
  qry: TFDQuery;
  erro: string;
begin
  //Res.Send('Listar clientes novo...');
  try
    cli := TCliente.Create;
    cli.ID_CLIENTE := Req.Params['id'].ToInteger;
  except
    Res.Send('Erro ao conectar com o banco').Status(500);
    Exit;
  end;

  qry := cli.ListarCliente('', erro);
  try
    if qry.RecordCount > 0 then
    begin
      objCliente := qry.ToJSONObject;
      res.Send<TJSONObject>(objCliente);
    end
    else
      res.Send('Cliente não encontrado').Status(404);
  finally
    qry.Free;
    cli.Free;
  end;
end;

procedure AddCliente(Req: THorseRequest; Res: THorseResponse);
var
  cli: TCliente;
  objCliente: TJSONObject;
  erro: string;
  body: TJsonValue;
begin
  //Res.Send('Cadastrar um clientes...');
  try
    cli := TCliente.Create;
  except
    Res.Send('Erro ao conectar com o banco').Status(500);
    Exit;
  end;

  try
    try
      body := TJsonObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body), 0) as TJsonValue;

      cli.NOME := body.GetValue<string>('nome', '');
      cli.EMAIL := body.GetValue<string>('email', '');
      cli.FONE := body.GetValue<string>('fone', '');
      cli.Inserir(erro);

      body.Free;

      if not erro.IsEmpty then
        raise Exception.Create(erro);
    except
      on e: Exception do
      begin
        res.Send(e.Message).Status(400);
        Exit;
      end;
    end;

    objCliente := TJSONObject.Create;
    objCliente.AddPair('id_cliente', cli.ID_CLIENTE.ToString);

    Res.Send<TJSONObject>(objCliente).Status(201);
  finally
    cli.Free;
  end;
end;

procedure DeleteCliente(Req: THorseRequest; Res: THorseResponse);
var
  cli: TCliente;
  objCliente: TJSONObject;
  erro: string;
begin
  //Res.Send('Excluir um clientes...');
  try
    cli := TCliente.Create;
  except
    Res.Send('Erro ao conectar com o banco').Status(500);
    Exit;
  end;

  try
    try
      cli.ID_CLIENTE := Req.Params['id'].ToInteger;

      if not cli.Excluir(erro) then
        raise Exception.Create(erro);
    except
      on e: Exception do
      begin
        res.Send(e.Message).Status(400);
        Exit;
      end;
    end;

    objCliente := TJSONObject.Create;
    objCliente.AddPair('id_cliente', cli.ID_CLIENTE.ToString);

    Res.Send<TJSONObject>(objCliente).Status(201);
  finally
    cli.Free;
  end;
end;

procedure EditarCliente(Req: THorseRequest; Res: THorseResponse);
var
  cli: TCliente;
  objCliente: TJSONObject;
  erro: string;
  body: TJsonValue;
begin
  //Res.Send('Excluir um clientes...');
  try
    cli := TCliente.Create;
  except
    Res.Send('Erro ao conectar com o banco').Status(500);
    Exit;
  end;

    try
    try
      body := TJsonObject.ParseJSONValue(TEncoding.UTF8.GetBytes(req.Body), 0) as TJsonValue;

      cli.ID_CLIENTE := body.GetValue<Integer>('id_cliente', 0);
      cli.NOME := body.GetValue<string>('nome', '');
      cli.EMAIL := body.GetValue<string>('email', '');
      cli.FONE := body.GetValue<string>('fone', '');
      cli.Editar(erro);

      body.Free;

      if not erro.IsEmpty then
        raise Exception.Create(erro);
    except
      on e: Exception do
      begin
        res.Send(e.Message).Status(400);
        Exit;
      end;
    end;

    objCliente := TJSONObject.Create;
    objCliente.AddPair('id_cliente', cli.ID_CLIENTE.ToString);

    Res.Send<TJSONObject>(objCliente).Status(200);
  finally
    cli.Free;
  end;
end;

procedure Registry;
begin
  THorse.Get('/cliente', ListarClientes);
  THorse.Get('/cliente/:id', ListarClienteID);
  THorse.Post('/cliente', AddCliente);
  THorse.Put('/cliente', EditarCliente);
  THorse.Delete('/cliente/:id', DeleteCliente);
end;

end.

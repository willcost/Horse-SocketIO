unit Horse.SocketIO;

interface

uses
  Horse, Horse.SocketIO.ServerSocket, Web.HTTPApp, System.SysUtils, System.JSON;

procedure StartSocket(PORT : Integer);
procedure SocketIO(Req: THorseRequest; Res: THorseResponse; Next: TProc);

implementation

uses Horse.SocketIO.Functions, Horse.Commons;

procedure SocketIO(Req: THorseRequest; Res: THorseResponse; Next: TProc);
var
  LWebRequest: TWebRequest;
  PreparedBody : String;
begin
  if (Req.Headers['socket_client'] <> '') then
    begin
      LWebRequest := THorseHackRequest(Req).GetWebRequest;

      PreparedBody := Req.Body;

      if not (Req.Headers['content-type'] = 'application/json') then
        PreparedBody := '"'+ PreparedBody + '"';

      Res.Send<TJSONValue>(
        TJSONObject.ParseJSONValue(
          _ServerSocket.Send(Req.Headers['socket_client'], LWebRequest.PathInfo, PreparedBody)
        )
      )
      .Status(THTTPStatus.OK);
    end
  else
    Next();
end;

procedure StartSocket(PORT : Integer);
begin
  _ServerSocket.Connect(PORT);

  Registry;
end;

end.

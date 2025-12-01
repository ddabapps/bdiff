//!  BSD 3-clause license: see LICENSE.md

///  <summary>Code to assist in working with stdin, stdout and stderr.</summary>
///  <remarks>Code common to both BDiff and BPatch.</remarks>

unit Common.IO;


interface


type

  ///  <summary>Static class that provides common IO functions required by both
  ///  BDiff and BPatch to read/write from/to Windows handles.</summary>
  TCommonIO = class(TObject)
  strict private
    ///  <summary>Checks if the given standard windows handle is valid.
    ///  </summary>
    ///  <exception>An exception is raised if the handle is invalid.</exception>
    class procedure CheckStdHandle(Handle: THandle);
  public
    ///  <summary>Returns Windows standard input handle.</summary>
    ///  <exception>Raises exception if the handle is not valid.</exception>
    class function StdIn: THandle;
    ///  <summary>Returns Windows standard output handle.</summary>
    ///  <exception>Raises exception if the handle is not valid.</exception>
    class function StdOut: THandle;
    ///  <summary>Returns Windows standard error handle.</summary>
    ///  <exception>Raises exception if the handle is not valid.</exception>
    class function StdErr: THandle;
    ///  <summary>Writes binary data from a buffer pointed to by <c>BufPtr</c>
    ///  with length <c>Size</c> bytes. The data is written to the output
    ///  identified by <c>Handle</c>.</summary>
    ///  <exception>Raises exception if write fails.</exception>
    class procedure WriteRaw(Handle: THandle; BufPtr: Pointer; Size: Int32);
    ///  <summary>Writes a Unicode string <c>S</c> to the output identified by
    ///  <c>Handle</c>.</summary>
    ///  <exception>Raises exception if write fails.</exception>
    class procedure WriteStr(Handle: THandle; const S: UnicodeString); overload;
    ///  <summary>Writes ANSI string <c>S</c> to the output identified by
    ///  <c>Handle</c>.</summary>
    ///  <exception>Raises exception if write fails.</exception>
    class procedure WriteStr(Handle: THandle; const S: AnsiString); overload;
    ///  <summary>Writes a string built from format string <c>Fmt</c> and
    ///  arguments <c>Args</c> to the output identified by <c>Handle</c>.
    ///  </summary>
    ///  <exception>Raises exception if write fails.</exception>
    class procedure WriteStrFmt(Handle: THandle; const Fmt: string;
      Args: array of const);
    ///  <summary>Gets the size of a file identified by <c>Handle</c>.</summary>
    ///  <returns><c>Int64</c>. File size or -1 on error.</returns>
    ///  <remarks>File must have been opened for reading.</remarks>
    class function FileSize(Handle: THandle): Int64;
  end;


implementation


uses
  // Delphi
  System.SysUtils,
  Winapi.Windows,
  // Project
  Common.Errors;


{ TCommonIO }

class procedure TCommonIO.CheckStdHandle(Handle: THandle);
begin
  if Handle = WinApi.Windows.INVALID_HANDLE_VALUE then
    OSError;
end;

class function TCommonIO.FileSize(Handle: THandle): Int64;
begin
  if not GetFileSizeEx(Handle, Result) then
    Result := -1;
end;

class function TCommonIO.StdErr: THandle;
begin
  Result := Winapi.Windows.GetStdHandle(Winapi.Windows.STD_ERROR_HANDLE);
  CheckStdHandle(Result);
end;

class function TCommonIO.StdIn: THandle;
begin
  Result := Winapi.Windows.GetStdHandle(Winapi.Windows.STD_INPUT_HANDLE);
  CheckStdHandle(Result);
end;

class function TCommonIO.StdOut: THandle;
begin
  Result := Winapi.Windows.GetStdHandle(Winapi.Windows.STD_OUTPUT_HANDLE);
  CheckStdHandle(Result);
end;

class procedure TCommonIO.WriteRaw(Handle: THandle; BufPtr: Pointer;
  Size: Int32);
begin
  if Size <= 0 then
    Exit;
  var Dummy: DWORD;
  if not Winapi.Windows.WriteFile(Handle, BufPtr^, DWORD(Size), Dummy, nil) then
    OSError;
end;

class procedure TCommonIO.WriteStr(Handle: THandle; const S: UnicodeString);
begin
  var Bytes := TEncoding.Default.GetBytes(S);
  WriteRaw(Handle, Bytes, Length(S));
end;

class procedure TCommonIO.WriteStr(Handle: THandle; const S: AnsiString);
begin
  WriteRaw(Handle, PAnsiChar(S), Length(S));
end;

class procedure TCommonIO.WriteStrFmt(Handle: THandle; const Fmt: string;
  Args: array of const);
begin
  WriteStr(Handle, Format(Fmt, Args));
end;

end.


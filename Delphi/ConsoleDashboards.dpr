program ConsoleDashboards;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils, System.Classes,
  dxBackend, dxBackend.ConnectionString.SQL, dxDashboard;

var
  ACountryName: string;

procedure ExportDashboardToPdf(const ACountryName: string);
var
  AConnection: TdxBackendDatabaseSQLConnection;
  ADashboard: TdxDashboard;
  AStream: TMemoryStream;
  AOutputFileName: string;
begin
  // Step 1: Create and set up the database connection
  AConnection := TdxBackendDatabaseSQLConnection.Create(nil);
  try
    // Assign a database name matching the name specified in the dashboard layout
    AConnection.DisplayName := 'NWindConnectionString';
    // Assign a connection string required to use the local SQLite database
    AConnection.ConnectionString := 'XpoProvider=SQLite; Data Source=nwind.db; Mode=ReadOnly';

    // Step 2: Create a dashboard instance and load the dashboard layout
    ADashboard := TdxDashboard.Create(nil);
    try
      ADashboard.Name := 'Country Sales';
      ADashboard.Layout.LoadFromFile('CountrySalesDashboard.xml');


      // Step 3: Define Dashboard Parameter Values
      // Set the "CountryDashboardParameter" value in the dashboard layout
      ADashboard.Parameters['CountryDashboardParameter'].Value := ACountryName;

      // Step 4: Export the dashboard to PDF
      AStream := TMemoryStream.Create;
      try
        // Export the dashboard to a memory stream in the PDF format
        ADashboard.ExportTo(TdxDashboardExportFormat.PDF, AStream);
        // Save memory stream content to a file
        AOutputFileName := 'Sales_' + ACountryName + '.pdf';
        AStream.SaveToFile(AOutputFileName);
        Writeln('Dashboard saved to: ', AOutputFileName);
      finally
        AStream.Free;
      end;
    finally
      ADashboard.Free;
    end;
  finally
    AConnection.Free;
  end;
end;

begin
  if ParamCount < 1 then
  begin
    Writeln('Error: CountryName parameter is required. For example: ConsoleDashboards.exe USA');
    Halt(1); // Exit with error code 1
  end;

  ACountryName := ParamStr(1); // Read the first parameter as CountryName
  try
    ExportDashboardToPdf(ACountryName);
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

unit Orion.Interfaces;

interface

uses
  System.Generics.Collections, System.JSON, Data.DB;

type
  TResourceMethod = (rsmGet, rsmPost, rsmPut, rsmDelete);
  iOrionDAOServer<T:class> = interface;

  iOrionDAO<T:class> = interface
    ['{BDC529E4-D2CA-4160-A4AE-9132BDA9BEAF}']

    function Buscar : TObjectList<T>; overload;
    function Buscar(aID :string) : T; overload;
    function Filtrar(aID :string) :TJSONValue;
    function Instancia :T;
    function Inserir(aValue :T) : iOrionDAO<T>;
    function Alterar(aValue :T) : iOrionDAO<T>;
    function Deletar(aID :string) : iOrionDAO<T>;
    function JSON :TJSONValue;
  end;

  iOrionDAOServerSearch<T:class> = interface
    ['{0480E6A2-A7D5-4AF5-BA89-71F85E040F88}']
    function SetParam(aName :string; aValue :Variant) :iOrionDAOServerSearch<T>;
    function Go : iOrionDAOServer<T>;
  end;

  iOrionDAOServerResultSet<T:class> = interface
    ['{C67E711E-0C15-45AB-AEBA-7BFF6CFE3067}']
    function AsObject : T;
    function AsObjectList : TObjectList<T>;
    function AsJSON : TJSONValue;
  end;

  iOrionDAOEntity<T:Class> = interface
    ['{E3137F79-D85E-47A3-A628-9326F84567E4}']
    function Current :T;
    function NewInstance :T;
  end;

  iOrionDAOServer<T:class> = interface
    ['{B2372D2B-67AE-4DA8-9B76-2A1A3817B3CD}']
    function Search :iOrionDAOServerSearch<T>;
    function Entity :iOrionDAOEntity<T>;
    function ResultSet : iOrionDAOServerResultSet<T>;

    function Insert(aValue :T) : iOrionDAOServer<T>; overload;
    function Insert(aValue :TObjectList<T>) : iOrionDAOServer<T>; overload;

    function Update(aValue :T) : iOrionDAOServer<T>; overload;
    function Update(aValue :TObjectList<T>) : iOrionDAOServer<T>; overload;

    function Delete : iOrionDAOServer<T>;

    function ApplyUpdates  : iOrionDAOServer<T>;
    function ToJSON(aValue :TJSONValue) : iOrionDAOServer<T>;
  end;

  iOrionRestUri = interface;
  iOrionRestUriParam = interface;
//  iOrionORMDAORESTClientParams<T> = interface;

  iOrionDAOClientSearchResult<T:class> = interface
    ['{F04CC130-0B3B-4E63-A6B3-B2B66C57A46C}']
    function AsObjectList : TObjectList<T>;
  end;
  iOrionDAOClient<T:class> = interface
    ['{2C30A921-51E2-4A81-85EC-F775B5DE22C3}']
    function DataSource(aValue :TDataSource) : iOrionDAOClient<T>;
    function Entity :T;
    function Insert(aValue :T) : iOrionDAOClient<T>;
    function Update(aValue :T) : iOrionDAOClient<T>;
    function Delete(aValue :T) : iOrionDAOClient<T>;
    function Communication : iOrionRestUri;
    function Search : iOrionDAOClient<T>;
    function Result : iOrionDAOClientSearchResult<T>;
    function AsJSONArray :TJSONArray;
    function ToJSON(aValue : TJSONValue) : iOrionDAOClient<T>;
  end;

  iOrionSQL<T> = interface
    ['{C1767DA5-6449-4A6A-BF6C-FAA2DC6F0108}']
    function MontarBuscar(out aSQL :string)                   : iOrionSQL<T>;
    function MontarBuscarPorID(out aSQL :string; aID :string) : iOrionSQL<T>;
    function MontarInserir(out aSQL :string)                  : iOrionSQL<T>;
    function MontarAlterar(out aSQL :string)                  : iOrionSQL<T>;
    function MontarDeletar(out aSQL :string)                  : iOrionSQL<T>;
  end;

  iOrionRtti<T:class> = interface
    ['{FA075AD4-8157-47E4-9121-9AAB40842386}']
    function GetResource(out aResource :string) : iOrionRtti<T>;
    function GetTableName                                           : string;
    function GetFieldsNames                                         : string;
    function JSONToObject(aJSON :TJSONValue; aObject : T)           : iOrionRtti<T>;
    function JSONArrayToObjectList(aJSON :TJSONArray; var aList :TObjectList<T>) : iOrionRtti<T>;
    function ObjJSONToClass(aObj :TJSONValue; var aLista: TList<T>) : iOrionRtti<T>;
    function GetPrimaryKeys(aClass :T) : TDictionary<string, Variant>;
    function ObjectToObject(aSource, aTarget :T) : iOrionRtti<T>;
  end;

  iOrionNormalRtti = interface
    ['{BABB4754-4567-4402-BC50-F6D786447CD7}']
    function GetFieldValue(aFieldNames :array of string; aClass :TObject) : TDictionary<string, Variant>;
    function GetIDValue (aObject : TObject): Variant;
  end;
{$REGION 'REST URI'}


  iOrionRestUri = interface
    ['{4A131B2A-AFBC-4121-900C-5530ED220F90}']
    function AddBaseURL(aValue :string) :iOrionRestUri;
    function Resource(aValue :string) :iOrionRestUri;
    function ResourceMethod(aValue :TResourceMethod) : iOrionRestUri;
    function Params : iOrionRestUriParam;
    function Execute : iOrionRestUri;
    function JSON :TJSONValue;
    function Result :string;
  end;

  iOrionRestUriParam = interface
    ['{6FEC07EC-8169-4F6F-8E91-88D453163255}']
    function CreateParam(aName :string) : iOrionRestUriParam;
    function AddParamsList(aLista :TList<string>) : iOrionRestUriParam;
    function SetParamValue(aParamName, aValue :string) : iOrionRestUriParam;
    function Clear : iOrionRestUriParam;
    function EndParam : iOrionRestUri;
  end;
{$ENDREGION}

  iOrionDAOWrapper = interface
    ['{7E1A63FE-0EC9-4C99-A26D-420D1095D010}']
    function SetObjectList(aValue :TObjectList<TObject>; aOwnsObjects :boolean = true) : iOrionDAOWrapper;
    function SetNodeName(aValue :string) : iOrionDAOWrapper;
    function SetKeyFieldNames(aValue : array of string) : iOrionDAOWrapper;
    function Execute : iOrionDAOWrapper;
    function Result : TDictionary<string, TJSONArray>;
  end;

  iOrionDAORollBack<T : class> = interface
    ['{EC875F88-43EB-44B0-9FEF-03904E949CE9}']
    function BeforeState(aValue : T) : iOrionDAORollBack<T>; overload;
    function BeforeState(aValue : TObjectList<T>) : iOrionDAORollBack<T>; overload;
    function ActualState(aValue : T) : iOrionDAORollBack<T>; overload;
    function ActualState(aValue : TObjectList<T>) : iOrionDAORollBack<T>; overload;
    function RollBack : iOrionDAORollBack<T>;
  end;
implementation

end.

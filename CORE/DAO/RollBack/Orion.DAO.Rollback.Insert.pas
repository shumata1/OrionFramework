unit Orion.DAO.Rollback.Insert;

interface

uses
  Orion.Interfaces,
  System.Generics.Collections;
type
  TOrionDAORollbackInsert<T : class, constructor> = class(TInterfacedObject, iOrionDAORollBack<T>)
  private
    [weak]
    FParent : iOrionDAOServer<T>;

    FOldStateEntity : T;
    FOldStateEntityList : TObjectList<T>;

    FActualStateEntity : T;
    FActualStateEntityList : TObjectList<T>;
  public
    constructor Create(aParent : iOrionDAOServer<T>);
    destructor Destroy; override;
    class function New(aParent : iOrionDAOServer<T>) :iOrionDAORollBack<T>;

    function BeforeState(aValue : T) : iOrionDAORollBack<T>; overload;
    function BeforeState(aValue : TObjectList<T>) : iOrionDAORollBack<T>; overload;
    function ActualState(aValue : T) : iOrionDAORollBack<T>; overload;
    function ActualState(aValue : TObjectList<T>) : iOrionDAORollBack<T>; overload;
    function RollBack : iOrionDAORollBack<T>;
  end;
implementation

{ TOrionDAORollbackInsert<T> }

function TOrionDAORollbackInsert<T>.ActualState(aValue: T): iOrionDAORollBack<T>;
begin
  Result := Self;
  FActualStateEntity := aValue;
end;

function TOrionDAORollbackInsert<T>.ActualState(aValue: TObjectList<T>): iOrionDAORollBack<T>;
begin
  Result := Self;
  FActualStateEntityList := aValue;
end;

function TOrionDAORollbackInsert<T>.BeforeState(aValue: T): iOrionDAORollBack<T>;
begin
  Result := Self;
  FOldStateEntity := aValue;
end;

function TOrionDAORollbackInsert<T>.BeforeState(aValue: TObjectList<T>): iOrionDAORollBack<T>;
begin
  Result := Self;
  FOldStateEntityList := aValue;
end;

constructor TOrionDAORollbackInsert<T>.Create(aParent : iOrionDAOServer<T>);
begin
  FParent := aParent;
end;

destructor TOrionDAORollbackInsert<T>.Destroy;
begin
  inherited;
end;

class function TOrionDAORollbackInsert<T>.New(aParent : iOrionDAOServer<T>): iOrionDAORollBack<T>;
begin
  Result := Self.Create(aParent);
end;

function TOrionDAORollbackInsert<T>.RollBack: iOrionDAORollBack<T>;
begin
  if Assigned(FActualStateEntity) then
    FParent.Delete;
end;

end.

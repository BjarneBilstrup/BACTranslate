table 78609 "BAC Translation Blob"
{
  DataClassification = ToBeClassified;
  Caption = 'Translation Blob';

  fields
  {
    field(1;"Primary Key";Integer)
    {
      DataClassification = ToBeClassified;
      Caption = 'Primary Key';
    }
    field(2;Blob;Blob)
    {
      DataClassification = ToBeClassified;
      Caption = 'Blob Field';
    }
  }
  keys
  {
    key(PK;"Primary Key")
    {
      Clustered = true;
    }
  }
}

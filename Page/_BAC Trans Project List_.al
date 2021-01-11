page 78600 "BAC Trans Project List"
{
  Caption = 'Translation Projects';
  PageType = List;
  ApplicationArea = All;
  UsageCategory = Lists;
  SourceTable = "BAC Translation Project Name";
  SourceTableView = sorting("Project Code")order(descending);

  layout
  {
    area(Content)
    {
      repeater(GroupName)
      {
        field("Project Code";rec."Project Code")
        {
          ApplicationArea = All;
          AssistEdit = true;

          trigger OnAssistEdit();
          begin
            if rec.AssistEdit then CurrPage.Update;
          end;
        }
        field("Project Name";rec."Project Name")
        {
          ApplicationArea = All;
        }
        field("NAV Version";rec."NAV Version")
        {
          ApplicationArea = All;
        }
        field("Source Language";rec."Source Language")
        {
          ApplicationArea = All;
        }
        field("Source Language ISO code";rec."Source Language ISO code")
        {
          ApplicationArea = All;
        }
        field("Created By";rec."Created By")
        {
          ApplicationArea = All;
        }
        field("Creation Date";rec."Creation Date")
        {
          ApplicationArea = All;
        }
      }
    }
    area(Factboxes)
    {
    }
  }
  actions
  {
    area(Processing)
    {
      action("Import Source")
      {
        ApplicationArea = All;
        Caption = 'Import Source';
        Image = ImportCodes;
        Promoted = true;
        PromotedOnly = true;
        PromotedCategory = Process;

        trigger OnAction()var ImportSourceXML: XmlPort "BAC Import Translation Source";
        ImportSource2018XML: XmlPort "BAC Import Trans. Source 2018";
        TransSource: Record "BAC Translation Source";
        TransNotes: Record "BAC Translation Notes";
        DeleteWarningTxt: Label 'This will overwrite the Translation source for %1';
        TransProject: Record "BAC Translation Project Name";
        ImportedTxt: Label 'The file %1 has been imported into project %2';
        begin
          TransSource.SetRange("Project Code", rec."Project Code");
          if not TransSource.IsEmpty then if Confirm(DeleteWarningTxt, false, rec."Project Code")then begin
              TransSource.DeleteAll();
              TransNotes.DeleteAll();
            end
            else
              exit;
          case rec."NAV Version" of rec."NAV Version"::"Dynamics 365 Business Central": begin
            ImportSourceXML.SetProjectCode(Rec."Project Code");
            ImportSourceXML.Run();
          end;
          rec."NAV Version"::"Dynamics NAV 2018": begin
            ImportSource2018XML.SetProjectCode(Rec."Project Code");
            ImportSource2018XML.Run();
          end;
          end;
          TransProject.Get(rec."Project Code");
          message(ImportedTxt, TransProject."File Name", rec."Project Code");
        end;
      }
    }
    area(Navigation)
    {
      action("Translation Source")
      {
        ApplicationArea = All;
        Caption = 'Translation Source';
        Image = SourceDocLine;
        Promoted = true;
        PromotedOnly = true;
        PromotedCategory = Process;
        RunObject = page "BAC Translation Source List";
        RunPageLink = "Project Code"=field("Project Code");
      }
      action("Target Languages")
      {
        ApplicationArea = All;
        Caption = 'Target Languages';
        Image = Language;
        Promoted = true;
        PromotedOnly = true;
        PromotedCategory = Process;
        RunObject = page "BAC Target Language List";
        RunPageLink = "Project Code"=field("Project Code"), "Source Language"=field("Source Language"), "Source Language ISO code"=field("Source Language ISO code");
      }
    }
  }
}

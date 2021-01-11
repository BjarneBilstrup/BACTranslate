page 78603 "BAC Translation Target List"
{
    Caption = 'Translation Target List';
    PageType = List;
    SourceTable = "BAC Translation Target";
    PopulateAllFields = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Trans-Unit Id"; rec."Trans-Unit Id")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Source; rec.Source)
                {
                    ApplicationArea = All;
                }
                field(Translate2; rec.Translate)
                {
                    ApplicationArea = All;
                    ToolTip = 'Set the Translate field to no if you don''t want it to be translated';
                }
                field(Target; rec.Target)
                {
                    ApplicationArea = All;
                    ToolTip = 'Enter the translated text';
                }
                field(Occurrencies; rec.Occurrencies)
                {
                    Visible = false;
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {
            part(TransNotes; "BAC Translation Notes")
            {
                SubPageLink = "Project Code" = field("Project Code"), "Trans-Unit Id" = field("Trans-Unit Id");
                Editable = false;
            }
            part(TargetFactbox; "BAC Trans Target Factbox")
            {
                SubPageLink = "Project Code" = field("Project Code"), "Trans-Unit Id" = field("Trans-Unit Id");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("Translate")
            {
                ApplicationArea = All;
                Caption = 'Translate';
                Image = Translation;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Enabled = ShowTranslate;

                trigger OnAction();
                var
                    GoogleTranslate: Codeunit "BAC Google Translate Rest";
                    Project: Record "BAC Translation Project Name";
                    OptionField: Boolean;
                begin
                    Optionfield := FieldType(rec.Source);
                    Project.get(rec."Project Code");
                    rec.Target := GoogleTranslate.Translate(Project."Source Language ISO code", rec."Target Language ISO code", rec.Source);
                    rec.Target := ReplaceTermInTranslation(rec.Target, OptionField);
                    rec.Validate(Target);
                end;
            }
            action("Translate All")
            {
                ApplicationArea = All;
                Caption = 'Translate All';
                Image = Translations;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                Enabled = ShowTranslate;

                trigger OnAction();
                var
                    MenuSelectionTxt: Label 'Convert all,Convert only missing';
                begin
                    case StrMenu(MenuSelectionTxt, 1) of
                        1:
                            TranslateAll(false);
                        2:
                            TranslateAll(true);
                    end;
                end;
            }
            action("Select All")
            {
                ApplicationArea = All;
                Caption = 'Select All';
                Image = Approve;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    WarningTxt: Label 'Mark all untranslated lines to be translated?';
                    TransTarget: Record "BAC Translation Target";
                begin
                    CurrPage.SetSelectionFilter(TransTarget);
                    if TransTarget.Count = 1 then TransTarget.Reset();
                    TransTarget.SetRange(Target, '');
                    if Confirm(WarningTxt) then TransTarget.ModifyAll(Translate, true);
                    CurrPage.Update(false);
                end;
            }
            action("Deselect All")
            {
                ApplicationArea = All;
                Caption = 'Deselect All';
                Image = Cancel;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    WarningTxt: Label 'Remove mark from all lines and disable translation?';
                    TransTarget: Record "BAC Translation Target";
                begin
                    CurrPage.SetSelectionFilter(TransTarget);
                    if TransTarget.Count = 1 then TransTarget.Reset();
                    if Confirm(WarningTxt) then TransTarget.ModifyAll(Translate, false);
                    CurrPage.Update(false);
                end;
            }
            action("Clear All translations")
            {
                ApplicationArea = All;
                Caption = 'Clear All translations within filter';
                Image = RemoveLine;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    WarningTxt: Label 'Remove all translations?';
                    TransTarget: Record "BAC Translation Target";
                begin
                    CurrPage.SetSelectionFilter(TransTarget);
                    if TransTarget.Count = 1 then TransTarget.Reset();
                    if Confirm(WarningTxt) then TransTarget.ModifyAll(Target, '');
                end;
            }
            action("Translation Terms")
            {
                Caption = 'Translation Terms';
                ApplicationArea = All;
                Image = BeginningText;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                RunObject = page "BAC Translation terms";
                RunPageLink = "Project Code" = field("Project Code"), "Target Language" = field("Target Language");
            }
            action("Export Translation File")
            {
                ApplicationArea = All;
                Caption = 'Export Translation File';
                Image = ExportFile;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    WarningTxt: Label 'Export the Translation file?';
                    ExportTranslation: XmlPort "BAC Export Translation Target";
                    ExportTranslation2018: XmlPort "BAC Export Trans Target 2018";
                    TransProject: Record "BAC Translation Project Name";
                begin
                    if Confirm(WarningTxt) then begin
                        TransProject.get(rec."Project Code");
                        case TransProject."NAV Version" of
                            TransProject."NAV Version"::"Dynamics 365 Business Central":
                                begin
                                    ExportTranslation.SetProjectCode(rec."Project Code", TransProject."Source Language ISO code", rec."Target Language ISO code");
                                    ExportTranslation.Run();
                                end;
                            TransProject."NAV Version"::"Dynamics NAV 2018":
                                begin
                                    ExportTranslation2018.SetProjectCode(rec."Project Code", TransProject."Source Language ISO code", rec."Target Language ISO code");
                                    ExportTranslation2018.Run();
                                end;
                        end;
                    end;
                end;
            }
        }
    }
    var
        [InDataSet]
        ShowTranslate: Boolean;

    trigger OnOpenPage()
    var
        TransSource: Record "BAC Translation Source";
        TransTarget: Record "BAC Translation Target";
        TransSetup: Record "BAC Translation Setup";
    begin
        TransSetup.get();
        //ShowTranslate := TransSetup."Use Free Google Translate";
        ShowTranslate := True;
        TransSource.SetFilter("Project Code", rec.GetFilter("Project Code"));
        if TransSource.FindSet() then
            repeat
                TransTarget.TransferFields(TransSource);
                TransTarget."Target Language" := rec.GetFilter("Target Language");
                TransTarget."Target Language ISO code" := rec.GetFilter("Target Language ISO code");
                if TransTarget.Insert() then;
            until TransSource.Next() = 0;
    end;

    local procedure TranslateAll(inOnlyEmpty: Boolean)
    var
        GoogleTranslate: Codeunit "BAC Google Translate Rest";
        TransTarget: Record "BAC Translation Target";
        TransTarget2: Record "BAC Translation Target";
        Project: Record "BAC Translation Project Name";
        Window: Dialog;
        DialogTxt: Label 'Converting #1###### of #2######';
        Counter: Integer;
        TotalCount: Integer;
        TransferFilter: Text;
        OptionField: Boolean;
    begin
        TransTarget.SetCurrentKey("Project Code", Source);
        if inOnlyEmpty then TransTarget.SetRange(Target, '');
        TransTarget.SetRange(Translate, true);
        TransTarget.SetRange("Project Code", rec."Project Code");
        Project.get(rec."Project Code");
        TotalCount := TransTarget.Count;
        Window.Open(DialogTxt);
        TransTarget.SetRange(Occurrencies, 1);
        if TransTarget.FindSet() then begin
            repeat
                Counter += 1;
                Window.Update(1, Counter);
                Window.Update(2, TotalCount);
                Optionfield := FieldType(TransTarget.Source);
                TransTarget.Target := GoogleTranslate.Translate(Project."Source Language ISO code", rec."Target Language ISO code", TransTarget.Source);
                TransTarget.Target := ReplaceTermInTranslation(TransTarget.Target, OptionField);
                TransTarget.Translate := false;
                TransTarget.Modify();
                commit();
            until TransTarget.Next() = 0;
        end;
        // To avoid the Sorry message (Another user has change the record)
        TransTarget.Reset();
        if inOnlyEmpty then TransTarget.SetRange(Target, '');
        TransTarget.SetRange(Translate, true);
        TransTarget.SetRange("Project Code", rec."Project Code");
        TransTarget.SetCurrentKey(Source);
        TransTarget.SetFilter(Occurrencies, '>1');
        if TransTarget.FindSet() then begin
            repeat
                Counter += 1;
                Window.Update(1, Counter);
                Window.Update(2, TotalCount);
                Optionfield := FieldType(TransTarget.Source);
                TransTarget.Target := GoogleTranslate.Translate(Project."Source Language ISO code", rec."Target Language ISO code", TransTarget.Source);
                TransTarget.Target := ReplaceTermInTranslation(TransTarget.Target, OptionField);
                TransferFilter := '''' + TransTarget.Source + '''';
                TransTarget2.SetFilter(Source, TransferFilter);
                TransTarget2.ModifyAll(Target, TransTarget.Target);
                commit();
                SelectLatestVersion();
                TransTarget.SetFilter(Source, '<>%1', TransferFilter);
            until TransTarget.Next() = 0;
        end;
        TransTarget.ModifyAll(Translate, false);
    end;

    local procedure ReplaceTermInTranslation(inTarget: Text[2048];
    OptionField: Boolean) outTarget: Text[2048]
    var
        TransTerm: Record "BAC Translation Term";
        StartPos: Integer;
        StartLetterIsUppercase: Boolean;
        Found: Boolean;
    begin
        if TransTerm.FindSet() then
            repeat
                StartPos := strpos(LowerCase(inTarget), LowerCase(TransTerm.Term));
                if StartPos > 0 then begin
                    StartLetterIsUppercase := copystr(inTarget, StartPos, 1) = uppercase(copystr(inTarget, StartPos, 1));
                    if StartLetterIsUppercase then
                        TransTerm.Translation := UpperCase(TransTerm.Translation[1]) + CopyStr(TransTerm.Translation, 2)
                    else
                        TransTerm.Translation := LowerCase(TransTerm.Translation[1]) + CopyStr(TransTerm.Translation, 2);
                    if (StartPos > 1) then begin
                        outTarget := CopyStr(inTarget, 1, StartPos - 1) + TransTerm.Translation + CopyStr(inTarget, StartPos + strlen(TransTerm.Term));
                        Found := true;
                    end
                    else begin
                        outTarget := TransTerm.Translation + CopyStr(inTarget, strlen(TransTerm.Term) + 1);
                        Found := true;
                    end;
                end;
                if Found then inTarget := outTarget;
            until TransTerm.Next() = 0;
        if not Found then outTarget := inTarget;
        if (strpos(OutTarget, ' ') = 1) and (strpos(OutTarget, '%') = 2) then outtarget := copystr(outTarget, 2);
        if OptionField then begin
            if strpos(outTarget, ',') = 1 then outTarget := ' ' + uppercase(copystr(outTarget, 1, 1)) + CopyStr(outTarget, 2);
            if strpos(outTarget, ', ') > 0 then
                repeat
                    outTarget := copystr(outTarget, 1, strpos(outTarget, ', ')) + uppercase(copystr(outTarget, strpos(outTarget, ', ') + 2, 1)) + copystr(outTarget, strpos(outTarget, ', ') + 3);
                until strpos(outtarget, ', ') = 0;
        end;
    end;

    local procedure FieldType(var inText: Text[2048]) OptionField: Boolean
    begin
        if strpos(inText, ',') > 0 then OptionField := true;
        if strpos(intext, ', ') > 0 then OptionField := false;
        exit(OptionField);
    end;
}

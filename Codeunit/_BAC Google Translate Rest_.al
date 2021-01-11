codeunit 78600 "BAC Google Translate Rest"
{
  procedure Translate(inSourceLang: Text[10];
  inTargetLang: Text[10];
  inText: Text[2048])outTransText: text[2048]var EndPoint: Text;
  TokenName: Text[50];
  Headers: HttpHeaders;
  Setup: Record "BAC Translation Setup";
  SpecChar: Boolean;
  begin
    Setup.get;
    if strpos(inText, '&') > 0 then begin
      inText:=ConvertStr(InText, '&', '¤');
      SpecChar:=true;
    end;
    if setup."Use Free Google Translate" then begin
      HttpClient.DefaultRequestHeaders.Add('User-Agent', 'Dynamics 365');
      setup.TestField("Google Translate Endpoint Free");
      //EndPoint := 'https://translate.googleapis.com/translate_a/single?client=gtx&sl=%1&tl=%2&dt=t&q=%3';
      EndPoint:=Setup."Google Translate Endpoint Free";
      EndPoint:=StrSubstNo(EndPoint, inSourceLang, inTargetLang, inText);
    end
    else
    begin
      HttpClient.DefaultRequestHeaders.Add('User-Agent', 'WebService');
      setup.TestField("Google Translate Key");
      setup.TestField("Google Translate Endpoint");
      // EndPoint := https://www.googleapis.com/language/translate/v2?key=%1&q=%2&source=%3&target=%4
      EndPoint:=Setup."Google Translate Endpoint";
      EndPoint:=StrSubstNo(EndPoint, setup."Google Translate Key", inText, copystr(inSourceLang, 1, 2), copystr(inTargetLang, 1, 2));
    end;
    if not HttpClient.Get(EndPoint, ResponseMessage)then Error('The call to the web service failed.');
    if not ResponseMessage.IsSuccessStatusCode then error('The web service returned an error message:\\' + 'Status code: %1\' + 'Description: %2', ResponseMessage.HttpStatusCode, ResponseMessage.ReasonPhrase);
    ResponseMessage.Content.ReadAs(TransText);
    if setup."Use Free Google Translate" then outTransText:=GetLines(TransText, SpecChar)
    else
      outTransText:=GetLinesAPI(TransText, SpecChar);
  end;
  local procedure GetLines(inTxt: Text;
  SpecChar: Boolean)outTxt: Text;
  begin
    if copystr(inTxt, 1, 1) <> '[' then exit;
    while copystr(inTxt, 1, 1) = '[' do inTxt:=DelChr(inTxt, '<', '[');
    inTxt:=DelChr(inTxt, '<', '"');
    outTxt:=CopyStr(inTxt, 1, strpos(inTxt, '"') - 1);
    if StrPos(inTxt, '],[') > 0 then begin
      inTxt:=CopyStr(inTxt, StrPos(inTxt, '],[') + 3);
      inTxt:=DelChr(inTxt, '<', '"');
      outTxt+=CopyStr(inTxt, 1, strpos(inTxt, '"') - 1);
    end;
    if SpecChar then OutTxt:=ConvertStr(OutTxt, '¤', '&');
  end;
  local procedure GetLinesAPI(inTxt: Text;
  Specchar: Boolean)outTxt: Text;
  begin
    if copystr(inTxt, 1, 1) <> '{' then exit;
    IF STRPOS(inTxt, '"translatedText": "') > 0 THEN BEGIN
      inTxt:=COPYSTR(inTxt, STRPOS(inTxt, '"translatedText": "') + 18);
      inTxt:=DELCHR(inTxt, '<', '"');
      outTxt+=COPYSTR(inTxt, 1, STRPOS(inTxt, '"') - 1);
    END;
    if SpecChar then OutTxt:=ConvertStr(OutTxt, '¤', '&');
  end;
  var HttpClient: HttpClient;
  ResponseMessage: HttpResponseMessage;
  TransText: text;
  CurrencyRate: Record "Currency Exchange Rate" temporary;
  Currency: Record Currency;
  InvExchRate: Decimal;
}

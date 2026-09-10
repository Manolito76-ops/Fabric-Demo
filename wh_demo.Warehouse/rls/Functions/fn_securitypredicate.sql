-- 3. Funktion & Policy mit den neuen Datentypen wieder anlegen
CREATE FUNCTION rls.fn_securitypredicate(@SalesRep AS VARCHAR(256)) 
    RETURNS TABLE  
WITH SCHEMABINDING  
AS  
    RETURN SELECT 1 AS fn_securitypredicate_result   
WHERE @SalesRep = USER_NAME();
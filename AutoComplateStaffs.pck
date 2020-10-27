create or replace package gp54_admin.AutoComplateStaffs is

  -- Author  : PANCHUKDA
  -- Created : 01.09.2020 9:48:40
  -- Purpose : 
  
  -- Public type declarations
  --type <TypeName> is <Datatype>;
         
  -- Public constant declarations
  --<ConstantName> constant <Datatype> := <Value>;
                   p_attrID NUMBER := '6856576';
  -- Public variable declarations
  --<VariableName> <Datatype>;

  -- Public function and procedure declarations
  
  /*
            Добавление услуг по специальности врача
  */
  procedure AddServicesStaff(p_DocId in NUMBER);
  
  
  /*
           Проверка на соответствие всех услуг у доктора
  */
  function CheckFullServicesStaff(p_DocId in NUMBER) return boolean;
  
  
  /*
           Добавление привязки врача к врачу ОМС
  */
  function AddLinkStaffOMS(p_DocId in NUMBER) return boolean;
  
  /*
           Проверка на наличие привязки
  */
  function CheckLinkStaffOMS(p_DocId in NUMBER) return number;
  
  /*
           Проверка заполнености всех данных
  */
  function CheckFullDataStaff(p_DocId in NUMBER) return number;
  /*
           private (я так и не нашел как разграничивать доступ)
  */
  function GetSpecIdStaff(p_DocId in NUMBER) return number;  
  

end AutoComplateStaffs;
/
create or replace package body gp54_admin.AutoComplateStaffs is

  -- Private type declarations
  --type <TypeName> is <Datatype>;
  
  -- Private constant declarations
  --<ConstantName> constant <Datatype> := <Value>;

  -- Private variable declarations
  --<VariableName> <Datatype>;

  -- Function and procedure implementations
  procedure AddServicesStaff(p_DocId in number) is
    var                    number;
    p_SpecIdinDocId        number;
    rc1                    solution_med.pkg_global.ref_cursor_type;
  begin
    p_SpecIdinDocId := GetSpecIdStaff(p_DocId => p_DocId);
    
    FOR serid in (
                           SELECT attr.linkid
                           FROM solution_med.attr
                           WHERE attr.rootid IN (SELECT a.keyid
                                             FROM SOLUTION_MED.ATTR A
                                             WHERE A.rootid = '6856576'
                                             AND A.Linkid = p_SpecIdinDocId))
                                             
    LOOP
      
      solution_med.p_content.insert_docserv(
      p_DocId
      , serid.linkid
      , '1'
      , '0'
      , ''
      , NULL
      , NULL
      , rc1);
      
    END LOOP;                                         
        
    
  end;
  function CheckFullServicesStaff(p_DocId in number) return boolean is
    var                    boolean;
  begin
    var:= False;    
    return var;
  end;
  function AddLinkStaffOMS(p_DocId in number) return boolean is
    var                    boolean;
  begin
    var:= False;    
    return var;
  end;
  
  function CheckLinkStaffOMS(p_DocId in number) return number is
    var                    number;
    p_code                 varchar2(40);
  begin
        SELECT dd.code
          into p_code
          FROM solution_med.docdep dd
         WHERE dd.keyid = p_DocId;  
          
          SELECT count(*)
            into var
            FROM solution_med.attr
           WHERE attr.rootid in (select a.keyid
                                   from solution_med.attr a
                                  WHERE a.rootid = 1124446
                                    AND a.Scode = p_code);
    return var;
  end;
  
  function CheckFullDataStaff(p_DocId in number) return number is
    var                    number:=0;
  begin
    FOR doctor IN (SELECT dd.specid, dd.code FROM solution_med.docdep dd WHERE dd.keyid = p_DocId)
      LOOP
        if doctor.specid is NULL  OR doctor.specid = 0 THEN         
          return 1;
        END IF;
        if doctor.code is NULL OR doctor.code = 0 THEN   
          return 1;
        END IF;        
    END LOOP;    
    return 0;
  end;
  
  function GetSpecIdStaff(p_DocId in number) return number is
    n                       NUMBER:=0;
    
  BEGIN
    
    SELECT dd.specid INTO n   
    from solution_med.docdep dd
    WHERE dd.keyid = p_DocId
    AND ROWNUM = 1;
    return n;
    
  EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
  end;


end AutoComplateStaffs;
/

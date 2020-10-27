create or replace function gp54_admin.check_number_attr(rnumbid IN number)
  return varchar2 IS
  FunctionResult varchar2(200);
  r_rnumb        solution_med.rnumb%rowtype;
  tmp_doctor     number;
  tmp_spec       number;
  tmp_otd        number;
  tmp_checksum   number;
begin
  select r.*
    INTO r_rnumb
    FROM solution_med.rnumb r
   WHERE r.keyid = rnumbid;

  SELECT count(*)
    INTO tmp_doctor
    FROM solution_med.attr,
         (SELECT dd.keyid AS link_id,
                 dd.code AS docdepcode,
                 dd.text,
                 d.text AS dep,
                 l.text AS spec,
                 (SELECT text
                    FROM solution_med.dep
                   WHERE sortcode = substr(d.sortcode, 1, 3)) AS structure,
                 (SELECT keyid
                    FROM solution_med.dep
                   WHERE sortcode = substr(d.sortcode, 1, 3)) AS structureid /*! для фильтра по структурам */,
                 dd.status,
                 solution_med.fn_get_lu_name(doc.staffid) AS doctype
            FROM solution_med.docdep dd,
                 solution_med.doctor doc,
                 solution_med.lu     l,
                 solution_med.dep    d
           WHERE d.keyid = dd.depid
             AND l.keyid(+) = dd.specid
             AND doc.keyid = dd.docid) t
   WHERE attr.rootid IN (SELECT a.keyid
                           FROM SOLUTION_MED.ATTR A
                          WHERE A.rootid = '6349864'
                            AND A.Linkid = r_rnumb.stacid)
     AND t.link_id = attr.linkid
     AND t.link_id = (select dd.keyid 
                     from solution_med.docdep dd 
                     WHERE dd.docid = (select dd.keyid 
                                       from solution_med.doctor dd 
                                       WHERE dd.man_id = solution_med.fn_get_user_id()));

  SELECT count(*)
    INTO tmp_spec
    FROM solution_med.attr,
         (SELECT t.keyid AS link_id, t.*
            FROM solution_med.lu t
           WHERE t.tag = 9
             AND status = 1) t
   WHERE attr.rootid IN (SELECT a.keyid
                           FROM SOLUTION_MED.ATTR A
                          WHERE A.rootid = '6349862'
                            AND A.Linkid = r_rnumb.stacid)
     AND t.link_id = attr.linkid
     AND t.link_id =
         (select dd.specid 
              from solution_med.docdep dd 
              WHERE dd.docid = (select dd.keyid 
                                       from solution_med.doctor dd 
                                       WHERE dd.man_id = solution_med.fn_get_user_id()));
              
  SELECT count(*)
  INTO tmp_otd
  FROM solution_med.attr
      ,(SELECT d.keyid AS link_id
      ,d.status
      ,d.code
      ,d.text
      ,d.sortcode
      ,(SELECT text
          FROM solution_med.dep s
         WHERE s.sortcode = substr(d.sortcode, 1, 3)) AS struct
  FROM solution_med.dep d) t
 WHERE attr.rootid IN (SELECT a.keyid
                           FROM SOLUTION_MED.ATTR A
                          WHERE A.rootid = '6349883'
                            AND A.Linkid = r_rnumb.stacid) 
   AND t.link_id = attr.linkid
   AND t.link_id =
         (select dd.depid
              from solution_med.docdep dd 
              WHERE dd.docid = (select dd.keyid 
                                       from solution_med.doctor dd 
                                       WHERE dd.man_id = solution_med.fn_get_user_id()));

  tmp_checksum := tmp_spec + tmp_doctor + tmp_otd;  
    if solution_med.fn_get_user_id() in(400)
    then
      return('OK');
  end if;          
  IF tmp_checksum > 0 THEN
    return 'OK';
  else
    if (TRUNC(r_rnumb.dat) - trunc(sysdate)) = 0 and r_rnumb.stacid not in(87088) THEN
      return 'OK';
    else
      return 'Данные номерки предназначены только для Вас(Attr)' || solution_med.fn_get_user_id() ;
    end if;
  end if;

end;

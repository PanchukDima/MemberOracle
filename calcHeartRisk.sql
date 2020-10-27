CREATE OR REPLACE Function GP54_ADMIN.calc_risk(in_sex in number
                                    ,in_smoke in number
                                    ,in_age in number
                                    ,in_ad in number
                                    ,in_chol in number
                                    ,in_other_p in number)
RETURN NUMBER IS
         ball number;

BEGIN
    SELECT
     CASE
       WHEN (in_chol <= 4) THEN r.L1
       WHEN (in_chol >= 4 AND in_chol <= 5) THEN r.L2
       WHEN (in_chol >= 5 AND in_chol <=6) THEN r.l3
       WHEN (in_chol >= 6 AND in_chol <=7) THEN r.L4
       WHEN (in_chol >= 7)  THEN r.L5
         END CASE INTO ball
     from risk r
     WHERE r.sex = 1-in_sex
     AND r.smoke = in_smoke
     AND r.age = 
     CASE
       WHEN (in_age <= 49) THEN 0
       WHEN (in_age >= 50 AND in_age <= 54) THEN 1
       WHEN (in_age >= 55 AND in_age <= 59) THEN 2
       WHEN (in_age >= 60 AND in_age <= 64) THEN 3
       WHEN (in_age >= 65) THEN 4 
     END
     
     AND r.ad = in_ad; 
     

  IF in_other_p = 1 THEN 
    ball := ball*2;
      END IF;
RETURN ball;
END;

/* Formatted on 2007/05/28 12:29 (Formatter Plus v4.8.8) */
CREATE OR REPLACE PROCEDURE test_emplu (
   counter          IN   INTEGER,
   employee_id_in   IN   employees.employee_id%TYPE := 137
)
/*

Compare performance of repeated querying of data to
caching in the PGA (packaged collection) and the
new Oracle 11g Result Cache.

Author: Steven Feuerstein

*/
IS
   emprec   employees%ROWTYPE;

   PROCEDURE setup
   IS
   BEGIN
      DBMS_SESSION.free_unused_user_memory ();
      PLVtmr.set_factor (counter);
      PLVtmr.capture;
   END;
BEGIN
   setup ();
   DBMS_OUTPUT.put_line ('PGA before tests are run:');
   my_session.MEMORY (TRUE, FALSE);

   FOR i IN 1 .. counter
   LOOP
      emprec := emplu1.onerow (employee_id_in);
   END LOOP;

   PLVtmr.show_elapsed ('Execute query each time');
   my_session.MEMORY (TRUE, FALSE);
   --
   setup ();

   FOR i IN 1 .. counter
   LOOP
      emprec := emplu2.onerow (employee_id_in);
   END LOOP;

   PLVtmr.show_elapsed ('Cache table in PGA memory');
   my_session.MEMORY (TRUE, FALSE);
   --
   setup ();

   FOR i IN 1 .. counter
   LOOP
      emprec := emplu11g.onerow (employee_id_in);
   END LOOP;

   PLVtmr.show_elapsed ('Oracle 11g result cache');
   my_session.MEMORY (TRUE, FALSE);
END;
/
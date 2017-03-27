/*

Compare performance of repeated querying of data to
caching in the PGA (packaged collection) and the
new Oracle 11g Result Cache.

To compile and run this test script, you will first need to
run the following script.

Note that to compile the my_session package and display PGA
usage statistics, you will need SELECT authority on:

sys.v_$session
sys.v_$sesstat
sys.v_$statname

Author: Steven Feuerstein

*/

@@plvtmr.pkg
@@mysess.pkg
@@11g_emplu.pkg
@@11g_emplu_compare.sp

SET SERVEROUTPUT ON

BEGIN
   test_emplu (100000);
/*

With 100000 iterations:

PGA before tests are run:
session PGA:  910860

Execute query each time Elapsed: 4.5 seconds. Factored: .00005 seconds.
session PGA:  910860

Cache table in PGA memory Elapsed: .11 seconds. Factored: 0 seconds.
session PGA: 1041932

Oracle 11g result cache Elapsed: .27 seconds. Factored: 0 seconds.
session PGA: 1041932

*/   
END;
/

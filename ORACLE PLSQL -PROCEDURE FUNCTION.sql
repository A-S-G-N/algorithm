-- UTUBE[최용진] 오라클 기초 강좌 19 - PROCEDURE, FUNCTION, PACKAGE - PL/SQL

SELECT * FROM EMP;

SELECT ROUND(123.456)
    , ROUND(123.456,1)
    FROM DUAL;

SELECT MONTHS_BETWEEN(SYSDATE, TO_DATE ('2019/12/15'))
FROM DUAL;

--PL/SQL 블록단위의 실행을 제공한다. 마지막 라인에 /를 입력하면 해당 블록이 실행

CREATE OR REPLACE PROCEDURE scott.adjust_sal
    (v_flag VARCHAR2, v_empno NUMBER, v_pct NUMBER) AS 
BEGIN 
    IF v_flag = 'INCREASE' THEN
        UPDATE emp SET sal = sal + (sal * (v_pct / 100))
        WHERE empno = v_empno;
    ELSE
        UPDATE emp SET sal = sal - (sal * (v_pct / 100))
        WHERE empno = v_empno;
    END IF;
END;
/

CREATE OR REPLACE FUNCTION scott.get_annual_sal (v_empno NUMBER)
    RETURN NUMBER IS v_sal NUMBER;
BEGIN
    SELECT(sal + NVL(comm, 0)) * 12 INTO v_sal
    FROM emp WHERE empno = v_empno;
    RETURN v_sal;
END;
/
CREATE OR REPLACE FUNCTION scott.get_retire_money (v_empno NUMBER)
    RETURN NUMBER IS v_sal NUMBER;
BEGIN
    SELECT ROUND((sal + NVL(comm, 0))
          * ROUND(MONTHS_BETWEEN(sysdate, hiredate), 0) / 12, 0)
    INTO v_sal FROM emp WHERE empno = v_empno;
    RETURN v_sal;
END;
/
CREATE OR REPLACE FUNCTION scott.get_retire_money (v_empno NUMBER)
    RETURN NUMBER IS v_sal NUMBER;
BEGIN
    SELECT ROUND((sal + NVL(comm, 0))
          * ROUND(MONTHS_BETWEEN(sysdate, hiredate), 0) / 12, 0)
    INTO v_sal FROM emp WHERE empno = v_empno;
    RETURN v_sal;
END;

CREATE OR REPLACE PROCEDURE scott.remove_emp 
(v_empno NUMBER) AS
BEGIN
    DELETE FROM EMP WHERE EMPNO = v_empno;
END;
/

CREATE OR REPLACE FUNCTION scott.get_hiredate (v_empno NUMBER, v_fmt VARCHAR2)
    RETURN VARCHAR2 IS v_hiredate VARCHAR(20);
BEGIN
    SELECT TO_CHAR(hiredate, v_fmt) INTO v_hiredate
    FROM emp WHERE empno = v_empno;
    RETURN v_hiredate;
END;
/

-- SMITH 사원의 월급 10% 인상
EXEC ADJUST_SAL('INCREASE', 7369, 10);

SELECT * FROM EMP 
WHERE EMPNO = 7369;

-- 연봉 퇴직금 FUNCTION 사용
SELECT empno "사번", ename "성명",
    get_annual_sal(empno) "연봉", get_retire_money(empno) "퇴직금"
FROM emp
WHERE DEPTNO = 30;

-- 개발자를 위한 HELP FUNCTION
CREATE OR REPLACE FUNCTION scott.help(v_module VARCHAR2)
    RETURN VARCHAR2 IS v_usage VARCHAR2(100);
BEGIN
    v_usage :=  v_module || '는(은) 등록되지 않은 모듈 입니다.';
    IF UPPER(v_module) = 'ADJUST_SAL' THEN
        v_usage := '종류 : PROC, 사용법 : ADJUST_SAL(INCREASE|DECREASE, 사번, 증감률)';
    ELSIF UPPER(v_module) = 'GET_ANNUAL_SAL' THEN
        v_usage := '종류 : FUNC, 사용법 : GET_ANNUAL_SAL(사번)';
    END IF;
    RETURN v_usage;
END;
/
 
SELECT HELP('GET_ANNUAL_SAL') FROM DUAL;    

-- CREATE PACKAGE
CREATE OR REPLACE PACKAGE emp_mgmt AS
    PROCEDURE adjust_sal(v_flag VARCHAR2, v_empno NUMBER, v_pct NUMBER);
    FUNCTION get_annual_sal(v_empno NUMBER) RETURN NUMBER;
END emp_mgmt;

-- CREATE PACKAGE BODY
CREATE OR REPLACE PACKAGE BODY emp_mgmt AS 
    PROCEDURE adjust_sal(v_flag VARCHAR2, v_empno NUMBER, v_pct NUMBER) IS 
    BEGIN 
        IF v_flag = 'INCREASE' THEN
            UPDATE emp SET sal = sal + (sal * (v_pct / 100))
            WHERE empno = v_empno;
        ELSE
            UPDATE emp SET sal = sal - (sal * (v_pct / 100))
            WHERE empno = v_empno;
        END IF;
    END;
    
    FUNCTION get_annual_sal (v_empno NUMBER)
    RETURN NUMBER IS v_sal NUMBER;
    BEGIN
        SELECT(sal + NVL(comm, 0)) * 12 INTO v_sal
        FROM emp WHERE empno = v_empno;
        RETURN v_sal;
    END;
END emp_mgmt;

EXEC emp_mgmt.adjust_sal('INCREASE', 7369, 10);

SELECT * FROM EMP WHERE EMPNO = 7369;

-- 관련 DICTIONARY
SELECT * FROM USER_SOURCE
WHERE NAME = 'ADJUST_SAL'
ORDER BY LINE;

SELECT * FROM USER_OBJECTS 
ORDER BY TIMESTAMP DESC;
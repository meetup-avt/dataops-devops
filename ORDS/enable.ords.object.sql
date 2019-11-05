

CREATE TABLE ORDERS_ML (
"ORDER_ID" NUMBER(12,0) CONSTRAINT "ORDERS_ML_ID_NN" NOT NULL ENABLE,
"SCORE" NUMBER(2,0)
)


CREATE VIEW ORDERS_ML_V as
select O.ORDER_ID, O.ORDER_MODE, O.ORDER_STATUS, 
       O.ORDER_TOTAL, O.PROMOTION_ID, O.WAREHOUSE_ID, O.DELIVERY_TYPE, O.COST_OF_DELIVERY, O.CUSTOMER_CLASS, M.SCORE 
from  ORDERS O, ORDERS_ML M 
where O.ORDER_ID = M.ORDER_ID;


CREATE OR REPLACE TRIGGER score_orders_after_insert
AFTER INSERT
   ON ORDERS
   FOR EACH ROW

DECLARE
   v_score number;

BEGIN

   -- calcular el score usando el modelo
   SELECT
   PREDICTION(ORDERS_DT_MODEL USING 
   :new.ORDER_MODE as ORDER_MODE,
   :new.ORDER_STATUS as ORDER_STATUS,
   :new.ORDER_TOTAL as ORDER_TOTAL,
   :new.PROMOTION_ID as PROMOTION_ID,
   :new.DELIVERY_TYPE as DELIVERY_TYPE,
   :new.COST_OF_DELIVERY as COST_OF_DELIVERY,
   :new.WAREHOUSE_ID as WAREHOUSE_ID)
   INTO v_score from dual;

   -- guardar el score calculado
   INSERT INTO ORDERS_ML
   ( order_id,
     score )
   VALUES
   ( :new.order_id,
     v_score );

EXCEPTION
   when others then raise;
   
END;
/


DECLARE
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN

    ORDS.ENABLE_OBJECT(p_enabled => TRUE,
                       p_schema => 'SOE',
                       p_object => 'ORDERS_ML_V',
                       p_object_type => 'VIEW',
                       p_object_alias => 'orders_ml_v',
                       p_auto_rest_auth => FALSE);

    commit;

END;
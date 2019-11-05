
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
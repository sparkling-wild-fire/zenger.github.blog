# Oceandb

1. 删除所有的表：
```sql
SELECT CONCAT('DROP TABLE IF EXISTS ', table_name, ';') FROM information_schema.tables WHERE table_schema = 'zengzg';
```
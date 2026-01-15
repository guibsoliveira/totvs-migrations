{
  "PostgreSQL Select with Limit": {
    "prefix": "sel",
    "body": [
      "SELECT ",
      "    ${1:*}",
      "FROM ${2:gennera_stg}.${3:table_name}",
      "WHERE ${4:condition}",
      "LIMIT ${5:100};"
    ],
    "description": "Select básico com limite"
  },
  
  "Create or Replace View": {
    "prefix": "view",
    "body": [
      "DROP VIEW IF EXISTS ${1:schema}.${2:view_name};",
      "CREATE OR REPLACE VIEW ${1:schema}.${2:view_name} AS",
      "SELECT ",
      "    ${3:columns}",
      "FROM ${4:table_name}",
      "WHERE ${5:condition};",
      "",
      "-- Testar view",
      "SELECT * FROM ${1:schema}.${2:view_name} LIMIT 10;"
    ],
    "description": "Criar view completa"
  },
  
  "Left Join": {
    "prefix": "lj",
    "body": [
      "LEFT JOIN ${1:table} ${2:alias} ON ${2:alias}.${3:id} = ${4:main}.${5:id}"
    ],
    "description": "Left Join rápido"
  },
  
  "Distinct On": {
    "prefix": "diston",
    "body": [
      "SELECT DISTINCT ON (${1:column})",
      "    ${2:columns}",
      "FROM ${3:table}",
      "ORDER BY ${1:column}, ${4:order_column};"
    ],
    "description": "Select Distinct On"
  }
}
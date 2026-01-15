#!/usr/bin/env python3
import psycopg2
import csv
from datetime import datetime
import os

# ============================================================================
# 🔥 EDITE APENAS AQUI - ADICIONE/REMOVA/MODIFIQUE SUAS QUERIES
# ============================================================================

QUERIES = {
    'Disciplinas NOT futuro do record': """
        SELECT DISTINCT subject_name
FROM gennera_stg.enrollment_record
WHERE institution_name NOT IN (
  'Escola do Futuro',
  'Escola do Futuro - Unidade 1',
  'Escola do Futuro - Unidade 2'
)
ORDER BY subject_name ASC;
"""
}

# ============================================================================
# ⚠️ NÃO MEXA DAQUI PRA BAIXO (a menos que saiba o que está fazendo)
# ============================================================================

DB_CONFIG = {
    'host': '192.168.0.75',
    'port': 5433,
    'database': 'Edf_bd_legado',
    'user': 'postgres',
    'password': 'tisuporte123'
}

OUTPUT_DIR = 'exports/csv'

def export_query_to_csv(query_name, sql_query):
    """Exporta uma query SQL para CSV"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cursor = conn.cursor()
        
        print(f"📊 Executando query: {query_name}...")
        cursor.execute(sql_query)
        
        columns = [desc[0] for desc in cursor.description]
        rows = cursor.fetchall()
        
        os.makedirs(OUTPUT_DIR, exist_ok=True)
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        output_file = f"{OUTPUT_DIR}/{query_name}_{timestamp}.csv"
        
        with open(output_file, 'w', newline='', encoding='ansi') as f:
            writer = csv.writer(f, delimiter=';')
            writer.writerow(columns)
            writer.writerows(rows)
        
        print(f"✅ CSV exportado: {output_file}")
        print(f"📊 Total de registros: {len(rows)}")
        print(f"📋 Colunas: {', '.join(columns)}\n")
        
        cursor.close()
        conn.close()
        
        return True
        
    except Exception as e:
        print(f"❌ Erro ao exportar {query_name}: {e}\n")
        return False

def main():
    """Executa todas as queries e exporta para CSV"""
    print("="*70)
    print("🚀 INICIANDO EXPORTAÇÃO DE CSVs")
    print("="*70 + "\n")
    
    total_queries = len(QUERIES)
    success_count = 0
    
    for idx, (query_name, sql_query) in enumerate(QUERIES.items(), 1):
        print(f"[{idx}/{total_queries}] Processando: {query_name}")
        if export_query_to_csv(query_name, sql_query):
            success_count += 1
    
    print("="*70)
    print(f"✅ CONCLUÍDO: {success_count}/{total_queries} queries exportadas com sucesso")
    print("="*70)

if __name__ == "__main__":
    main()
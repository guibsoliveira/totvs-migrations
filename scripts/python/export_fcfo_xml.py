#!/usr/bin/env python3
"""
Exporta a view export.fcfo para XML no formato TOTVS
"""

import psycopg2
from lxml import etree
from datetime import datetime
import os

# Configurações
DB_CONFIG = {
    'host': '192.168.0.75',
    'port': 5433,
    'database': 'Edf_bd_legado',
    'user': 'postgres',
    'password': 'tisuporte123'
}

OUTPUT_DIR = 'exports/xml'

def connect_db():
    """Conecta ao PostgreSQL"""
    try:
        conn = psycopg2.connect(**DB_CONFIG)
        print("✅ Conectado ao banco de dados")
        return conn
    except Exception as e:
        print(f"❌ Erro ao conectar: {e}")
        exit(1)

def export_fcfo_to_xml():
    """Exporta FCFO para XML"""
    conn = connect_db()
    cursor = conn.cursor()
    
    print("📊 Buscando dados da view export.fcfo...")
    cursor.execute("SELECT * FROM export.fcfo2;")
    
    columns = [desc[0].upper() for desc in cursor.description]
    rows = cursor.fetchall()
    
    print(f"📦 {len(rows)} registros encontrados")
    
    # Criar XML raiz
    root = etree.Element(
        "FinCFOImportacao",
        nsmap={None: "http://tempuri.org/FinCFOImportacao.xsd"}
    )
    
    # Processar cada registro
    for idx, row in enumerate(rows, 1):
        data = dict(zip(columns, row))
        
        # Elemento FCFO
        fcfo_elem = etree.SubElement(root, "FCFO")
        
        # Adicionar campos não nulos
        for col, val in data.items():
            if val is not None and str(val).strip() != '':
                elem = etree.SubElement(fcfo_elem, col)
                elem.text = str(val).strip()
        
        # Elemento FCFOCOMPL
        fcfocompl = etree.SubElement(root, "FCFOCOMPL")
        codcoligada_elem = etree.SubElement(fcfocompl, "CODCOLIGADA")
        codcoligada_elem.text = data.get('CODCOLIGADA', '00001')
        codcfo_elem = etree.SubElement(fcfocompl, "CODCFO")
        codcfo_elem.text = str(data.get('CODCFO', ''))
        
        if idx % 100 == 0:
            print(f"  Processando... {idx}/{len(rows)}")
    
    # Salvar arquivo
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    filename = f"{OUTPUT_DIR}/FCFO_{timestamp}.xml"
    
    tree = etree.ElementTree(root)
    tree.write(
        filename,
        pretty_print=True,
        xml_declaration=True,
        encoding='UTF-8'
    )
    
    print(f"✅ XML exportado: {filename}")
    print(f"📊 Total de registros: {len(rows)}")
    
    cursor.close()
    conn.close()

if __name__ == "__main__":
    export_fcfo_to_xml()
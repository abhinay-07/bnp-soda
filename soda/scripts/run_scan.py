#!/usr/bin/env python3
"""
KYC Data Quality Platform - Soda Core Scan Executor
Runs Soda scans and ingests results into PostgreSQL
"""

import os
import sys
import json
import logging
from datetime import datetime
from pathlib import Path
import psycopg2
from psycopg2.extras import Json, execute_values
import subprocess
import uuid

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/app/logs/scan_execution.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

class SodaScanExecutor:
    """Executes Soda scans and persists results to PostgreSQL"""
    
    def __init__(self):
        self.db_config = {
            'host': os.getenv('POSTGRES_HOST', 'postgres'),
            'port': int(os.getenv('POSTGRES_PORT', 5432)),
            'database': os.getenv('POSTGRES_DB', 'kyc_platform'),
            'user': os.getenv('POSTGRES_USER', 'kyc_admin'),
            'password': os.getenv('POSTGRES_PASSWORD', 'kyc_secure_pass_2024')
        }
        self.config_dir = os.getenv('SODA_CONFIG_DIR', '/app/config')
        self.checks_dir = os.getenv('SODA_CHECKS_DIR', '/app/checks')
        self.results_dir = '/app/results'
        self.scan_id = str(uuid.uuid4())
        
        # Ensure results directory exists
        Path(self.results_dir).mkdir(parents=True, exist_ok=True)
    
    def get_db_connection(self):
        """Create PostgreSQL database connection"""
        try:
            conn = psycopg2.connect(**self.db_config)
            logger.info("Successfully connected to PostgreSQL")
            return conn
        except Exception as e:
            logger.error(f"Failed to connect to PostgreSQL: {e}")
            raise
    
    def execute_soda_scan(self):
        """Execute Soda Core scan and generate JSON results"""
        logger.info(f"Starting Soda scan with ID: {self.scan_id}")
        
        # Prepare output file
        output_file = f"{self.results_dir}/scan_{self.scan_id}.json"
        
        # Build Soda scan command
        cmd = [
            'soda', 'scan',
            '-d', 'kyc_postgres',
            '-c', f"{self.config_dir}/data_source.yml",
            f"{self.checks_dir}/checks.yml"
        ]
        
        logger.info(f"Executing command: {' '.join(cmd)}")
        
        try:
            # Execute scan
            start_time = datetime.now()
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=300  # 5 minute timeout
            )
            end_time = datetime.now()
            duration = (end_time - start_time).total_seconds()
            
            logger.info(f"Scan completed in {duration:.2f} seconds")
            logger.info(f"Return code: {result.returncode}")
            
            # Log output
            if result.stdout:
                logger.info(f"STDOUT:\n{result.stdout}")
                
                # Save output to file
                with open(output_file, 'w') as f:
                    f.write(result.stdout)
            
            if result.stderr:
                logger.warning(f"STDERR:\n{result.stderr}")
            
            return {
                'scan_id': self.scan_id,
                'return_code': result.returncode,
                'duration': duration,
                'output_file': output_file,
                'stdout': result.stdout,
                'stderr': result.stderr,
                'start_time': start_time,
                'end_time': end_time
            }
            
        except subprocess.TimeoutExpired:
            logger.error("Scan execution timed out")
            raise
        except Exception as e:
            logger.error(f"Scan execution failed: {e}")
            raise
    
    def parse_soda_output(self, scan_output):
        """Parse Soda scan output and extract structured results"""
        logger.info("Parsing Soda scan output...")
        
        try:
            # Soda outputs results in the console
            # We need to parse the text output
            stdout = scan_output['stdout']
            
            # Initialize results structure
            results = {
                'scan_id': self.scan_id,
                'scan_timestamp': scan_output['start_time'],
                'scan_duration_seconds': scan_output['duration'],
                'checks': [],
                'summary': {
                    'total': 0,
                    'passed': 0,
                    'failed': 0,
                    'warned': 0,
                    'not_evaluated': 0
                }
            }
            
            # Parse Soda output for summary statistics
            # Soda format includes lines like: "46/53 checks PASSED:"
            lines = stdout.split('\n')
            for i, line in enumerate(lines):
                line_stripped = line.strip()
                
                # Look for summary lines like "46/53 checks PASSED:"
                if 'checks PASSED' in line_stripped and '/' in line_stripped:
                    # Extract passed count: "46/53 checks PASSED:"
                    parts = line_stripped.split('/')
                    if len(parts) >= 2:
                        passed = int(parts[0].split()[-1])
                        total = int(parts[1].split()[0])
                        results['summary']['passed'] = passed
                        results['summary']['total'] = total
                        
                elif 'checks FAILED' in line_stripped and '/' in line_stripped:
                    parts = line_stripped.split('/')
                    if len(parts) >= 2:
                        failed = int(parts[0].split()[-1])
                        results['summary']['failed'] = failed
                        
                elif 'checks WARNED' in line_stripped and '/' in line_stripped:
                    parts = line_stripped.split('/')
                    if len(parts) >= 2:
                        warned = int(parts[0].split()[-1])
                        results['summary']['warned'] = warned
                        
                elif 'checks NOT EVALUATED' in line_stripped:
                    parts = line_stripped.split('/')
                    if len(parts) >= 2:
                        not_eval = int(parts[0].split()[-1])
                        results['summary']['not_evaluated'] = not_eval
                        
                # Parse individual check results (marked with [PASSED], [FAILED], [WARNED], [NOT_EVALUATED])
                if '[PASSED]' in line_stripped:
                    check_name = line_stripped.replace('[PASSED]', '').strip()
                    results['checks'].append({
                        'outcome': 'PASS',
                        'check_name': check_name
                    })
                    
                elif '[FAILED]' in line_stripped:
                    check_name = line_stripped.replace('[FAILED]', '').strip()
                    results['checks'].append({
                        'outcome': 'FAIL',
                        'check_name': check_name
                    })
                    
                elif '[WARNED]' in line_stripped:
                    check_name = line_stripped.replace('[WARNED]', '').strip()
                    results['checks'].append({
                        'outcome': 'WARN',
                        'check_name': check_name
                    })
                    
                elif '[NOT_EVALUATED]' in line_stripped:
                    check_name = line_stripped.replace('[NOT_EVALUATED]', '').strip()
                    results['checks'].append({
                        'outcome': 'NOT_EVALUATED',
                        'check_name': check_name
                    })
            
            logger.info(f"Parsed checks: {len(results['checks'])}")
            logger.info(f"Summary: {results['summary']}")
            
            return results
            
        except Exception as e:
            logger.error(f"Failed to parse Soda output: {e}")
            raise
    
    def ingest_scan_results(self, results):
        """Ingest scan results into PostgreSQL"""
        logger.info("Ingesting scan results into PostgreSQL...")
        
        conn = None
        try:
            conn = self.get_db_connection()
            cursor = conn.cursor()
            
            # Insert scan metadata
            scan_insert_sql = """
                INSERT INTO soda_scan_results (
                    scan_id, scan_timestamp, scan_type, data_source,
                    total_checks, checks_passed, checks_failed, checks_warned, 
                    checks_not_evaluated, scan_duration_seconds, scan_status,
                    soda_version
                ) VALUES (
                    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                )
            """
            
            cursor.execute(scan_insert_sql, (
                results['scan_id'],
                results['scan_timestamp'],
                'SCHEDULED',
                'kyc_postgres',
                results['summary']['total'],
                results['summary']['passed'],
                results['summary']['failed'],
                results['summary']['warned'],
                results['summary']['not_evaluated'],
                results['scan_duration_seconds'],
                'COMPLETED',
                '3.3.2'
            ))
            
            logger.info(f"Inserted scan metadata for scan_id: {results['scan_id']}")
            
            # Insert individual check results
            if results['checks']:
                check_insert_sql = """
                    INSERT INTO soda_check_results (
                        scan_id, check_name, check_type, check_outcome,
                        table_name, check_definition
                    ) VALUES %s
                """
                
                check_values = []
                for check in results['checks']:
                    check_values.append((
                        results['scan_id'],
                        check['check_name'],
                        'DATA_QUALITY',  # Default type
                        check['outcome'],
                        self._extract_table_name(check['check_name']),
                        check['check_name']
                    ))
                
                execute_values(cursor, check_insert_sql, check_values)
                logger.info(f"Inserted {len(check_values)} check results")
            
            # Commit transaction
            conn.commit()
            logger.info("Successfully ingested scan results")
            
            # Generate summary report
            self._print_summary_report(results)
            
            return True
            
        except Exception as e:
            if conn:
                conn.rollback()
            logger.error(f"Failed to ingest scan results: {e}")
            raise
        finally:
            if conn:
                cursor.close()
                conn.close()
    
    def _extract_table_name(self, check_name):
        """Extract table name from check name"""
        # Simple extraction - look for common table names
        tables = ['users', 'kyc_docs', 'soda_scan_results']
        for table in tables:
            if table in check_name.lower():
                return table
        return 'unknown'
    
    def _print_summary_report(self, results):
        """Print formatted summary report"""
        summary = results['summary']
        
        print("\n" + "="*60)
        print("SODA DATA QUALITY SCAN SUMMARY")
        print("="*60)
        print(f"Scan ID: {results['scan_id']}")
        print(f"Timestamp: {results['scan_timestamp']}")
        print(f"Duration: {results['scan_duration_seconds']:.2f} seconds")
        print("-"*60)
        print(f"Total Checks: {summary['total']}")
        print(f"✓ Passed: {summary['passed']} ({self._percentage(summary['passed'], summary['total'])}%)")
        print(f"✗ Failed: {summary['failed']} ({self._percentage(summary['failed'], summary['total'])}%)")
        print(f"⚠ Warned: {summary['warned']} ({self._percentage(summary['warned'], summary['total'])}%)")
        print(f"? Not Evaluated: {summary['not_evaluated']}")
        print("-"*60)
        
        if summary['failed'] > 0:
            print("\n⚠️  DATA QUALITY ISSUES DETECTED!")
            print("Failed checks:")
            for check in results['checks']:
                if check['outcome'] == 'FAIL':
                    print(f"  ✗ {check['check_name']}")
        else:
            print("\n✓ ALL DATA QUALITY CHECKS PASSED!")
        
        print("="*60 + "\n")
    
    def _percentage(self, value, total):
        """Calculate percentage"""
        return round((value / total * 100), 2) if total > 0 else 0
    
    def run(self):
        """Main execution method"""
        try:
            logger.info("="*60)
            logger.info("STARTING KYC DATA QUALITY SCAN")
            logger.info("="*60)
            
            # Execute scan
            scan_output = self.execute_soda_scan()
            
            # Parse results
            results = self.parse_soda_output(scan_output)
            
            # Ingest into database
            self.ingest_scan_results(results)
            
            # Determine exit code
            if results['summary']['failed'] > 0:
                logger.warning(f"Scan completed with {results['summary']['failed']} failed checks")
                return 1  # Non-zero exit code for CI/CD
            else:
                logger.info("Scan completed successfully with no failures")
                return 0
            
        except Exception as e:
            logger.error(f"Scan execution failed: {e}", exc_info=True)
            return 2

def main():
    """Entry point"""
    executor = SodaScanExecutor()
    exit_code = executor.run()
    sys.exit(exit_code)

if __name__ == '__main__':
    main()

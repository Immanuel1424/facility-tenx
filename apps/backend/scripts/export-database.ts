/**
 * PostgreSQL Database Export Script (TypeScript)
 * 
 * This script exports the database using pg_dump via shell command execution.
 * For better performance and more options, use export-database.sh directly.
 * 
 * USAGE:
 *   npm run export:db
 *   npm run export:db -- --format custom --compress
 *   npm run export:db -- --schema-only
 */

import { execSync } from 'child_process';
import * as fs from 'fs';
import * as path from 'path';

interface ExportOptions {
  format?: 'plain' | 'custom' | 'directory' | 'tar';
  schemaOnly?: boolean;
  dataOnly?: boolean;
  compress?: boolean;
  withOwner?: boolean;
  withPrivileges?: boolean;
  outputDir?: string;
  host?: string;
  port?: string;
  user?: string;
  database?: string;
}

// Default values
const defaults = {
  format: 'plain' as const,
  schemaOnly: false,
  dataOnly: false,
  compress: false,
  withOwner: false, // Default: exclude for portability
  withPrivileges: false, // Default: exclude for portability
  outputDir: './exports',
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || '5432',
  user: process.env.DB_USER || 'postgres',
  database: process.env.DB_NAME || 'facility_erp',
};

function parseArgs(): ExportOptions {
  const args = process.argv.slice(2);
  const options: ExportOptions = {};

  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    switch (arg) {
      case '--format':
        if (args[i + 1]) {
          options.format = args[i + 1] as any;
          i++;
        }
        break;
      case '--schema-only':
        options.schemaOnly = true;
        break;
      case '--data-only':
        options.dataOnly = true;
        break;
      case '--compress':
        options.compress = true;
        break;
      case '--with-owner':
        options.withOwner = true;
        break;
      case '--with-privileges':
        options.withPrivileges = true;
        break;
      case '--output-dir':
        if (args[i + 1]) {
          options.outputDir = args[i + 1];
          i++;
        }
        break;
      case '--host':
        if (args[i + 1]) {
          options.host = args[i + 1];
          i++;
        }
        break;
      case '--port':
        if (args[i + 1]) {
          options.port = args[i + 1];
          i++;
        }
        break;
      case '--user':
        if (args[i + 1]) {
          options.user = args[i + 1];
          i++;
        }
        break;
      case '--database':
        if (args[i + 1]) {
          options.database = args[i + 1];
          i++;
        }
        break;
      case '--help':
        printHelp();
        process.exit(0);
        break;
      default:
        if (arg.startsWith('--')) {
          console.warn(`⚠️  Unknown option: ${arg}`);
        }
        break;
    }
  }

  return options;
}

function printHelp() {
  console.log(`
Usage: npm run export:db [OPTIONS]

Options:
  --format FORMAT       Export format: plain, custom, directory, tar (default: plain)
  --schema-only         Export schema only (no data)
  --data-only           Export data only (no schema)
  --compress            Compress the output (gzip for plain format)
  --output-dir DIR      Output directory (default: ./exports)
  --host HOST           Database host (default: localhost)
  --port PORT           Database port (default: 5432)
  --user USER           Database user (default: postgres)
  --database DB         Database name (default: facility_erp)
  --help                Show this help message

Environment Variables:
  DB_HOST, DB_PORT, DB_USER, DB_NAME, DB_PASSWORD

Examples:
  npm run export:db
  npm run export:db -- --format custom --compress
  npm run export:db -- --schema-only --output-dir ./backups
  npm run export:db -- --data-only --format plain

Note: This script uses export-database.sh internally.
For direct shell script usage, run: ./scripts/export-database.sh
`);
}

function validateOptions(options: ExportOptions) {
  const merged = { ...defaults, ...options };

  if (!['plain', 'custom', 'directory', 'tar'].includes(merged.format)) {
    throw new Error(
      `Invalid format: ${merged.format}. Must be: plain, custom, directory, or tar`,
    );
  }

  if (merged.schemaOnly && merged.dataOnly) {
    throw new Error('Cannot use both --schema-only and --data-only');
  }

  return merged;
}

function checkPgDump(): void {
  try {
    execSync('which pg_dump', { stdio: 'ignore' });
  } catch {
    throw new Error(
      'pg_dump is not installed or not in PATH. Install PostgreSQL client tools.',
    );
  }
}

function testConnection(options: Required<ExportOptions>): void {
  const password = process.env.DB_PASSWORD || 'postgres';
  try {
    execSync(
      `PGPASSWORD=${password} psql -h ${options.host} -p ${options.port} -U ${options.user} -d ${options.database} -c "SELECT 1;"`,
      { stdio: 'ignore' },
    );
  } catch {
    throw new Error(
      `Cannot connect to database ${options.database} on ${options.host}:${options.port}`,
    );
  }
}

async function exportDatabase() {
  try {
    const options = validateOptions(parseArgs());

    console.log('\n📦 PostgreSQL Database Export\n');
    console.log('Configuration:');
    console.log(`  Host:     ${options.host}`);
    console.log(`  Port:     ${options.port}`);
    console.log(`  User:     ${options.user}`);
    console.log(`  Database: ${options.database}`);
    console.log(`  Format:   ${options.format}`);
    console.log(`  Output:   ${options.outputDir}\n`);

    // Check prerequisites
    console.log('Checking prerequisites...');
    checkPgDump();
    console.log('✅ pg_dump is available');

    // Test connection
    console.log('Testing database connection...');
    testConnection(options);
    console.log('✅ Database connection successful\n');

    // Create output directory
    if (!fs.existsSync(options.outputDir)) {
      fs.mkdirSync(options.outputDir, { recursive: true });
      console.log(`✅ Created output directory: ${options.outputDir}\n`);
    }

    // Build shell script command
    const scriptPath = path.join(__dirname, 'export-database.sh');
    if (!fs.existsSync(scriptPath)) {
      throw new Error(`Shell script not found: ${scriptPath}`);
    }

    // Build command arguments
    const args: string[] = [];
    if (options.format) args.push('--format', options.format);
    if (options.schemaOnly) args.push('--schema-only');
    if (options.dataOnly) args.push('--data-only');
    if (options.compress) args.push('--compress');
    if (options.withOwner) args.push('--with-owner');
    if (options.withPrivileges) args.push('--with-privileges');
    if (options.outputDir) args.push('--output-dir', options.outputDir);
    if (options.host) args.push('--host', options.host);
    if (options.port) args.push('--port', options.port);
    if (options.user) args.push('--user', options.user);
    if (options.database) args.push('--database', options.database);

    // Execute shell script
    console.log('Starting database export...\n');
    const command = `bash "${scriptPath}" ${args.join(' ')}`;
    execSync(command, { stdio: 'inherit', env: process.env });

    console.log('\n✅ Export completed successfully!\n');
  } catch (error: any) {
    console.error('\n❌ Export failed:', error.message);
    process.exit(1);
  }
}

// Run if executed directly
if (require.main === module) {
  exportDatabase();
}

export { exportDatabase, type ExportOptions };


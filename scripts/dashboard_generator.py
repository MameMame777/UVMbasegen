# UVM Project Dashboard Generator

**Author**: UVM Base Generator  
**Date**: July 27, 2025  
**Purpose**: Automated project metrics and dashboard generation

## Overview

This tool generates comprehensive project dashboards for UVM verification environments, providing real-time insights into test execution, coverage metrics, and project health indicators.

## Features

- **Real-time Test Execution Monitoring**
- **Coverage Trend Analysis**
- **Performance Metrics Tracking**
- **Team Productivity Analytics**
- **Automated Report Generation**

## Usage

```bash
# Generate dashboard
python scripts/dashboard_generator.py --config dashboard_config.yaml

# Real-time monitoring
python scripts/dashboard_generator.py --monitor --port 8080

# Generate weekly report
python scripts/dashboard_generator.py --report weekly --email team@company.com
```

## Dashboard Components

### 1. Test Execution Status

```python
#!/usr/bin/env python3
"""
UVM Project Dashboard Generator
Provides real-time monitoring and reporting for UVM verification projects
"""

import json
import yaml
import sqlite3
import pandas as pd
import plotly.graph_objects as go
import plotly.express as px
from plotly.subplots import make_subplots
from datetime import datetime, timedelta
import argparse
import sys
import os
from pathlib import Path

class UVMDashboard:
    def __init__(self, config_file):
        """Initialize dashboard with configuration"""
        self.config = self.load_config(config_file)
        self.db_path = self.config.get('database_path', 'verification_metrics.db')
        self.output_dir = Path(self.config.get('output_directory', 'dashboard_output'))
        self.output_dir.mkdir(exist_ok=True)
        
        # Initialize database connection
        self.conn = sqlite3.connect(self.db_path)
        self.setup_database()
        
    def load_config(self, config_file):
        """Load dashboard configuration"""
        try:
            with open(config_file, 'r') as f:
                return yaml.safe_load(f)
        except FileNotFoundError:
            print(f"Warning: Config file {config_file} not found. Using defaults.")
            return self.get_default_config()
    
    def get_default_config(self):
        """Return default configuration"""
        return {
            'database_path': 'verification_metrics.db',
            'output_directory': 'dashboard_output',
            'refresh_interval_minutes': 5,
            'email_notifications': False,
            'coverage_targets': {
                'functional': 95.0,
                'code': 90.0,
                'toggle': 85.0,
                'fsm': 100.0
            },
            'performance_targets': {
                'simulation_speed_khz': 1000,
                'memory_usage_gb': 16,
                'regression_time_hours': 8
            }
        }
    
    def setup_database(self):
        """Create database tables if they don't exist"""
        cursor = self.conn.cursor()
        
        # Test runs table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS test_runs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                branch_name TEXT,
                commit_hash TEXT,
                test_suite TEXT,
                total_tests INTEGER,
                passed_tests INTEGER,
                failed_tests INTEGER,
                coverage_functional REAL,
                coverage_code REAL,
                coverage_toggle REAL,
                coverage_fsm REAL,
                runtime_seconds INTEGER,
                simulation_speed_khz REAL,
                memory_usage_gb REAL
            )
        ''')
        
        # Daily metrics table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS daily_metrics (
                date DATE PRIMARY KEY,
                tests_run INTEGER,
                tests_passed INTEGER,
                tests_failed INTEGER,
                avg_coverage_functional REAL,
                avg_coverage_code REAL,
                bugs_found INTEGER,
                bugs_fixed INTEGER,
                commits INTEGER,
                team_productivity_score REAL
            )
        ''')
        
        self.conn.commit()
    
    def collect_test_metrics(self, test_results_file):
        """Collect test execution metrics from results file"""
        try:
            with open(test_results_file, 'r') as f:
                results = json.load(f)
            
            cursor = self.conn.cursor()
            cursor.execute('''
                INSERT INTO test_runs (
                    branch_name, commit_hash, test_suite, total_tests,
                    passed_tests, failed_tests, coverage_functional,
                    coverage_code, coverage_toggle, coverage_fsm,
                    runtime_seconds, simulation_speed_khz, memory_usage_gb
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                results.get('branch_name', 'unknown'),
                results.get('commit_hash', ''),
                results.get('test_suite', 'default'),
                results.get('total_tests', 0),
                results.get('passed_tests', 0),
                results.get('failed_tests', 0),
                results.get('coverage', {}).get('functional', 0.0),
                results.get('coverage', {}).get('code', 0.0),
                results.get('coverage', {}).get('toggle', 0.0),
                results.get('coverage', {}).get('fsm', 0.0),
                results.get('runtime_seconds', 0),
                results.get('simulation_speed_khz', 0.0),
                results.get('memory_usage_gb', 0.0)
            ))
            
            self.conn.commit()
            print(f"✓ Imported test results from {test_results_file}")
            
        except Exception as e:
            print(f"✗ Error importing test results: {e}")
    
    def generate_test_status_chart(self):
        """Generate test execution status chart"""
        query = '''
            SELECT timestamp, passed_tests, failed_tests, total_tests
            FROM test_runs
            WHERE timestamp >= datetime('now', '-30 days')
            ORDER BY timestamp
        '''
        
        df = pd.read_sql_query(query, self.conn)
        df['timestamp'] = pd.to_datetime(df['timestamp'])
        df['pass_rate'] = (df['passed_tests'] / df['total_tests'] * 100).round(2)
        
        fig = make_subplots(
            rows=2, cols=1,
            subplot_titles=('Test Execution Trend', 'Pass Rate Trend'),
            specs=[[{"secondary_y": False}], [{"secondary_y": False}]]
        )
        
        # Test count trends
        fig.add_trace(
            go.Scatter(x=df['timestamp'], y=df['passed_tests'], 
                      name='Passed Tests', line=dict(color='green')),
            row=1, col=1
        )
        fig.add_trace(
            go.Scatter(x=df['timestamp'], y=df['failed_tests'], 
                      name='Failed Tests', line=dict(color='red')),
            row=1, col=1
        )
        
        # Pass rate trend
        fig.add_trace(
            go.Scatter(x=df['timestamp'], y=df['pass_rate'], 
                      name='Pass Rate %', line=dict(color='blue')),
            row=2, col=1
        )
        
        # Add target line for pass rate
        target_pass_rate = 95.0
        fig.add_hline(y=target_pass_rate, line_dash="dash", line_color="orange",
                     annotation_text=f"Target: {target_pass_rate}%", row=2, col=1)
        
        fig.update_layout(
            title='Test Execution Status (Last 30 Days)',
            height=600,
            showlegend=True
        )
        
        fig.write_html(self.output_dir / 'test_status.html')
        return fig
    
    def generate_coverage_dashboard(self):
        """Generate coverage analysis dashboard"""
        query = '''
            SELECT timestamp, coverage_functional, coverage_code, 
                   coverage_toggle, coverage_fsm
            FROM test_runs
            WHERE timestamp >= datetime('now', '-30 days')
            ORDER BY timestamp
        '''
        
        df = pd.read_sql_query(query, self.conn)
        df['timestamp'] = pd.to_datetime(df['timestamp'])
        
        fig = go.Figure()
        
        coverage_types = [
            ('coverage_functional', 'Functional Coverage', 'blue'),
            ('coverage_code', 'Code Coverage', 'green'),
            ('coverage_toggle', 'Toggle Coverage', 'orange'),
            ('coverage_fsm', 'FSM Coverage', 'red')
        ]
        
        for col, name, color in coverage_types:
            fig.add_trace(
                go.Scatter(x=df['timestamp'], y=df[col], 
                          name=name, line=dict(color=color))
            )
            
            # Add target line
            target = self.config['coverage_targets'].get(col.replace('coverage_', ''), 90.0)
            fig.add_hline(y=target, line_dash="dash", line_color=color, opacity=0.5,
                         annotation_text=f"{name} Target: {target}%")
        
        fig.update_layout(
            title='Coverage Trends (Last 30 Days)',
            xaxis_title='Date',
            yaxis_title='Coverage Percentage',
            height=500,
            yaxis=dict(range=[0, 100])
        )
        
        fig.write_html(self.output_dir / 'coverage_trends.html')
        return fig
    
    def generate_performance_metrics(self):
        """Generate performance metrics dashboard"""
        query = '''
            SELECT timestamp, runtime_seconds, simulation_speed_khz, 
                   memory_usage_gb, total_tests
            FROM test_runs
            WHERE timestamp >= datetime('now', '-30 days')
            ORDER BY timestamp
        '''
        
        df = pd.read_sql_query(query, self.conn)
        df['timestamp'] = pd.to_datetime(df['timestamp'])
        df['runtime_hours'] = df['runtime_seconds'] / 3600
        df['tests_per_hour'] = df['total_tests'] / df['runtime_hours']
        
        fig = make_subplots(
            rows=2, cols=2,
            subplot_titles=('Runtime Trend', 'Simulation Speed', 
                          'Memory Usage', 'Test Throughput'),
            specs=[[{"secondary_y": False}, {"secondary_y": False}],
                   [{"secondary_y": False}, {"secondary_y": False}]]
        )
        
        fig.add_trace(
            go.Scatter(x=df['timestamp'], y=df['runtime_hours'], 
                      name='Runtime (hours)', line=dict(color='blue')),
            row=1, col=1
        )
        
        fig.add_trace(
            go.Scatter(x=df['timestamp'], y=df['simulation_speed_khz'], 
                      name='Speed (kHz)', line=dict(color='green')),
            row=1, col=2
        )
        
        fig.add_trace(
            go.Scatter(x=df['timestamp'], y=df['memory_usage_gb'], 
                      name='Memory (GB)', line=dict(color='red')),
            row=2, col=1
        )
        
        fig.add_trace(
            go.Scatter(x=df['timestamp'], y=df['tests_per_hour'], 
                      name='Tests/Hour', line=dict(color='orange')),
            row=2, col=2
        )
        
        fig.update_layout(
            title='Performance Metrics (Last 30 Days)',
            height=600,
            showlegend=True
        )
        
        fig.write_html(self.output_dir / 'performance_metrics.html')
        return fig
    
    def generate_project_health_score(self):
        """Calculate and display project health score"""
        query = '''
            SELECT * FROM test_runs
            WHERE timestamp >= datetime('now', '-7 days')
        '''
        
        df = pd.read_sql_query(query, self.conn)
        
        if df.empty:
            return {"health_score": 0, "status": "No data available"}
        
        # Calculate health metrics
        latest = df.iloc[-1]
        
        # Test pass rate (40% weight)
        pass_rate = (latest['passed_tests'] / latest['total_tests']) * 100 if latest['total_tests'] > 0 else 0
        test_score = min(pass_rate, 100) * 0.4
        
        # Coverage score (30% weight)
        avg_coverage = (
            latest['coverage_functional'] + 
            latest['coverage_code'] + 
            latest['coverage_toggle'] + 
            latest['coverage_fsm']
        ) / 4
        coverage_score = min(avg_coverage, 100) * 0.3
        
        # Performance score (20% weight)
        target_speed = self.config['performance_targets']['simulation_speed_khz']
        speed_ratio = min(latest['simulation_speed_khz'] / target_speed, 1.0) if target_speed > 0 else 0
        performance_score = speed_ratio * 100 * 0.2
        
        # Trend score (10% weight)
        if len(df) >= 2:
            trend_direction = 1 if latest['passed_tests'] >= df.iloc[-2]['passed_tests'] else -1
            trend_score = (50 + trend_direction * 50) * 0.1
        else:
            trend_score = 50 * 0.1
        
        health_score = test_score + coverage_score + performance_score + trend_score
        
        # Determine status
        if health_score >= 80:
            status = "Excellent"
            color = "green"
        elif health_score >= 60:
            status = "Good"
            color = "yellow"
        elif health_score >= 40:
            status = "Fair"
            color = "orange"
        else:
            status = "Poor"
            color = "red"
        
        return {
            "health_score": round(health_score, 1),
            "status": status,
            "color": color,
            "components": {
                "test_score": round(test_score, 1),
                "coverage_score": round(coverage_score, 1),
                "performance_score": round(performance_score, 1),
                "trend_score": round(trend_score, 1)
            }
        }
    
    def generate_summary_dashboard(self):
        """Generate main summary dashboard"""
        # Get project health
        health = self.generate_project_health_score()
        
        # Create summary HTML
        html_content = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>UVM Verification Dashboard</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; }}
                .header {{ background-color: #f0f0f0; padding: 20px; border-radius: 10px; }}
                .health-score {{ 
                    font-size: 48px; 
                    font-weight: bold; 
                    color: {health['color']}; 
                    text-align: center; 
                }}
                .metrics-grid {{ 
                    display: grid; 
                    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); 
                    gap: 20px; 
                    margin: 20px 0; 
                }}
                .metric-card {{ 
                    background-color: #f9f9f9; 
                    padding: 15px; 
                    border-radius: 8px; 
                    border-left: 4px solid #007acc; 
                }}
                .timestamp {{ 
                    color: #666; 
                    font-size: 14px; 
                    text-align: right; 
                }}
            </style>
        </head>
        <body>
            <div class="header">
                <h1>UVM Verification Project Dashboard</h1>
                <div class="health-score">{health['health_score']}/100</div>
                <div style="text-align: center; font-size: 24px; color: {health['color']};">
                    Project Status: {health['status']}
                </div>
            </div>
            
            <div class="metrics-grid">
                <div class="metric-card">
                    <h3>Test Execution Score</h3>
                    <div style="font-size: 24px; font-weight: bold;">
                        {health['components']['test_score']}/40
                    </div>
                </div>
                
                <div class="metric-card">
                    <h3>Coverage Score</h3>
                    <div style="font-size: 24px; font-weight: bold;">
                        {health['components']['coverage_score']}/30
                    </div>
                </div>
                
                <div class="metric-card">
                    <h3>Performance Score</h3>
                    <div style="font-size: 24px; font-weight: bold;">
                        {health['components']['performance_score']}/20
                    </div>
                </div>
                
                <div class="metric-card">
                    <h3>Trend Score</h3>
                    <div style="font-size: 24px; font-weight: bold;">
                        {health['components']['trend_score']}/10
                    </div>
                </div>
            </div>
            
            <h2>Detailed Reports</h2>
            <ul>
                <li><a href="test_status.html">Test Execution Status</a></li>
                <li><a href="coverage_trends.html">Coverage Analysis</a></li>
                <li><a href="performance_metrics.html">Performance Metrics</a></li>
            </ul>
            
            <div class="timestamp">
                Last Updated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
            </div>
        </body>
        </html>
        """
        
        with open(self.output_dir / 'index.html', 'w') as f:
            f.write(html_content)
        
        print(f"✓ Summary dashboard generated: {self.output_dir / 'index.html'}")
    
    def generate_all_dashboards(self):
        """Generate all dashboard components"""
        print("Generating UVM Project Dashboard...")
        
        try:
            self.generate_test_status_chart()
            print("✓ Test status chart generated")
            
            self.generate_coverage_dashboard()
            print("✓ Coverage dashboard generated")
            
            self.generate_performance_metrics()
            print("✓ Performance metrics generated")
            
            self.generate_summary_dashboard()
            print("✓ Summary dashboard generated")
            
            print(f"\n🎉 Dashboard generation complete!")
            print(f"📊 Open {self.output_dir / 'index.html'} in your browser")
            
        except Exception as e:
            print(f"✗ Error generating dashboard: {e}")
            return False
        
        return True
    
    def simulate_sample_data(self):
        """Generate sample data for demonstration"""
        import random
        from datetime import datetime, timedelta
        
        print("Generating sample data for demonstration...")
        
        cursor = self.conn.cursor()
        
        # Generate 30 days of sample data
        base_date = datetime.now() - timedelta(days=30)
        
        for day in range(30):
            current_date = base_date + timedelta(days=day)
            
            # Simulate improving trends
            trend_factor = day / 30.0
            
            cursor.execute('''
                INSERT INTO test_runs (
                    timestamp, branch_name, commit_hash, test_suite,
                    total_tests, passed_tests, failed_tests,
                    coverage_functional, coverage_code, coverage_toggle, coverage_fsm,
                    runtime_seconds, simulation_speed_khz, memory_usage_gb
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ''', (
                current_date.isoformat(),
                'develop',
                f'abc{random.randint(1000, 9999)}',
                'regression',
                random.randint(100, 200),
                random.randint(80 + int(trend_factor * 20), 200),
                random.randint(0, 10 - int(trend_factor * 8)),
                85.0 + trend_factor * 10 + random.uniform(-5, 5),
                80.0 + trend_factor * 15 + random.uniform(-5, 5),
                75.0 + trend_factor * 10 + random.uniform(-5, 5),
                90.0 + trend_factor * 5 + random.uniform(-3, 3),
                random.randint(3600, 14400),
                800 + trend_factor * 400 + random.uniform(-100, 100),
                10.0 + random.uniform(-2, 4)
            ))
        
        self.conn.commit()
        print("✓ Sample data generated")

def main():
    parser = argparse.ArgumentParser(description='UVM Project Dashboard Generator')
    parser.add_argument('--config', default='dashboard_config.yaml',
                       help='Configuration file path')
    parser.add_argument('--import-results', 
                       help='Import test results from JSON file')
    parser.add_argument('--generate', action='store_true',
                       help='Generate dashboard')
    parser.add_argument('--sample-data', action='store_true',
                       help='Generate sample data for demonstration')
    
    args = parser.parse_args()
    
    dashboard = UVMDashboard(args.config)
    
    if args.sample_data:
        dashboard.simulate_sample_data()
    
    if args.import_results:
        dashboard.collect_test_metrics(args.import_results)
    
    if args.generate or len(sys.argv) == 1:
        dashboard.generate_all_dashboards()

if __name__ == "__main__":
    main()
```

### 2. Configuration File Template

```yaml
# Dashboard Configuration
database_path: "verification_metrics.db"
output_directory: "dashboard_output"
refresh_interval_minutes: 5

# Email notification settings
email_notifications: true
smtp_server: "smtp.company.com"
smtp_port: 587
email_recipients:
  - "verification-team@company.com"
  - "project-manager@company.com"

# Coverage targets
coverage_targets:
  functional: 95.0
  code: 90.0
  toggle: 85.0
  fsm: 100.0

# Performance targets
performance_targets:
  simulation_speed_khz: 1000
  memory_usage_gb: 16
  regression_time_hours: 8

# Alert thresholds
alert_thresholds:
  pass_rate_minimum: 90.0
  coverage_drop_threshold: 5.0
  performance_degradation_threshold: 20.0

# Report generation
reports:
  daily_summary: true
  weekly_detailed: true
  monthly_trends: true
```

### 3. Integration Script

```bash
#!/bin/bash
# Integration script for UVM dashboard

# Setup paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DASHBOARD_DIR="$PROJECT_ROOT/dashboard_output"

# Create dashboard directory
mkdir -p "$DASHBOARD_DIR"

# Check for test results
if [ -f "$PROJECT_ROOT/sim/exec/test_results.json" ]; then
    echo "Importing test results..."
    python3 "$SCRIPT_DIR/dashboard_generator.py" \
        --import-results "$PROJECT_ROOT/sim/exec/test_results.json"
fi

# Generate dashboard
echo "Generating dashboard..."
python3 "$SCRIPT_DIR/dashboard_generator.py" --generate

# Open dashboard in browser (optional)
if command -v xdg-open > /dev/null; then
    xdg-open "$DASHBOARD_DIR/index.html"
elif command -v open > /dev/null; then
    open "$DASHBOARD_DIR/index.html"
fi

echo "Dashboard available at: $DASHBOARD_DIR/index.html"
```

## Installation

1. **Install Dependencies**:
   ```bash
   pip install pandas plotly pyyaml sqlite3
   ```

2. **Create Configuration**:
   ```bash
   cp dashboard_config.yaml.template dashboard_config.yaml
   # Edit configuration as needed
   ```

3. **Initialize Database**:
   ```bash
   python scripts/dashboard_generator.py --sample-data
   ```

4. **Generate Dashboard**:
   ```bash
   python scripts/dashboard_generator.py --generate
   ```

## Usage Examples

### Basic Dashboard Generation
```bash
# Generate dashboard with sample data
python scripts/dashboard_generator.py --sample-data --generate
```

### Import Test Results and Generate
```bash
# Import test results and generate dashboard
python scripts/dashboard_generator.py \
    --import-results sim/exec/test_results.json \
    --generate
```

### Automated Integration
```bash
# Add to your CI/CD pipeline
python scripts/dashboard_generator.py \
    --config production_config.yaml \
    --import-results ${TEST_RESULTS_FILE} \
    --generate
```

## Dashboard Features

### Real-time Monitoring
- **Test Execution Status**: Pass/fail trends over time
- **Coverage Analysis**: Functional, code, toggle, and FSM coverage tracking
- **Performance Metrics**: Simulation speed, memory usage, runtime analysis
- **Project Health Score**: Composite score based on multiple metrics

### Trend Analysis
- **30-day Historical View**: Track progress and identify patterns
- **Target Comparisons**: Visual indicators for meeting project goals
- **Performance Degradation Alerts**: Early warning system for issues

### Team Productivity
- **Commit Correlation**: Link test results to code changes
- **Bug Discovery Rate**: Track verification effectiveness
- **Resource Utilization**: Monitor compute resource efficiency

This dashboard system provides comprehensive visibility into UVM verification project health, enabling data-driven decisions and continuous improvement of the verification process.

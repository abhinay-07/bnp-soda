"""
KYC Data Quality Monitoring Platform
Enterprise-Grade Streamlit Dashboard
"""

import streamlit as st
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from plotly.subplots import make_subplots
import psycopg2
from psycopg2.extras import RealDictCursor
from sqlalchemy import create_engine
import os
from datetime import datetime, timedelta
import sys

# Page configuration
st.set_page_config(
    page_title="KYC Data Quality Monitor",
    page_icon="🔍",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom CSS for enterprise look
st.markdown("""
<style>
    /* Main theme colors */
    :root {
        --primary-color: #FF4B4B;
        --secondary-color: #0E1117;
        --success-color: #00CC96;
        --warning-color: #FFA500;
        --danger-color: #FF4B4B;
    }
    
    /* Hide Streamlit branding */
    #MainMenu {visibility: hidden;}
    footer {visibility: hidden;}
    
    /* Metric cards styling */
    [data-testid="stMetricValue"] {
        font-size: 32px;
        font-weight: 700;
    }
    
    [data-testid="stMetricLabel"] {
        font-size: 14px;
        font-weight: 500;
        text-transform: uppercase;
        letter-spacing: 1px;
    }
    
    /* Custom card styling */
    .metric-card {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        padding: 20px;
        border-radius: 10px;
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        color: white;
        margin: 10px 0;
    }
    
    .metric-card h3 {
        margin: 0;
        font-size: 36px;
        font-weight: 700;
    }
    
    .metric-card p {
        margin: 5px 0 0 0;
        font-size: 14px;
        opacity: 0.9;
    }
    
    /* Alert boxes */
    .alert-danger {
        padding: 15px;
        background-color: #ff4b4b22;
        border-left: 4px solid #ff4b4b;
        border-radius: 4px;
        margin: 10px 0;
    }
    
    .alert-warning {
        padding: 15px;
        background-color: #ffa50022;
        border-left: 4px solid #ffa500;
        border-radius: 4px;
        margin: 10px 0;
    }
    
    .alert-success {
        padding: 15px;
        background-color: #00cc9622;
        border-left: 4px solid: #00cc96;
        border-radius: 4px;
        margin: 10px 0;
    }
    
    /* Table styling */
    .dataframe {
        font-size: 12px;
    }
    
    /* Sidebar styling */
    .css-1d391kg {
        padding-top: 1rem;
    }
    
    /* Title styling */
    h1 {
        font-weight: 700;
        font-size: 42px;
        margin-bottom: 10px;
    }
    
    h2 {
        font-weight: 600;
        font-size: 28px;
        margin-top: 20px;
    }
    
    h3 {
        font-weight: 600;
        font-size: 20px;
    }
</style>
""", unsafe_allow_html=True)

# Database connection class
class DatabaseConnection:
    """Handles PostgreSQL database connections"""
    
    def __init__(self):
        self.config = {
            'host': os.getenv('POSTGRES_HOST', 'postgres'),
            'port': int(os.getenv('POSTGRES_PORT', 5432)),
            'database': os.getenv('POSTGRES_DB', 'kyc_platform'),
            'user': os.getenv('POSTGRES_USER', 'kyc_admin'),
            'password': os.getenv('POSTGRES_PASSWORD', 'kyc_secure_pass_2024')
        }
    
    @st.cache_resource
    def get_engine(_self):
        """Create cached SQLAlchemy engine"""
        try:
            connection_string = f"postgresql://{_self.config['user']}:{_self.config['password']}@{_self.config['host']}:{_self.config['port']}/{_self.config['database']}"
            engine = create_engine(connection_string)
            return engine
        except Exception as e:
            st.error(f"❌ Database connection failed: {e}")
            return None
    
    def query(self, sql, params=None):
        """Execute query and return DataFrame"""
        engine = self.get_engine()
        if engine is None:
            return pd.DataFrame()
        
        try:
            df = pd.read_sql_query(sql, engine, params=params)
            return df
        except Exception as e:
            st.error(f"❌ Query failed: {e}")
            return pd.DataFrame()

# Initialize database connection
db = DatabaseConnection()

# Sidebar navigation
st.sidebar.title("🔍 KYC Data Quality")
st.sidebar.markdown("---")

page = st.sidebar.radio(
    "Navigation",
    ["📊 Overview", "🚨 Failed Checks", "📈 Scan History", "🔎 Fraud Detection", "⚙️ System Info"],
    label_visibility="collapsed"
)

st.sidebar.markdown("---")

# Sidebar filters (applies to all pages)
st.sidebar.subheader("📅 Filters")

# Date range filter
date_range = st.sidebar.selectbox(
    "Time Period",
    ["Last 24 Hours", "Last 7 Days", "Last 30 Days", "All Time"],
    index=1
)

# Calculate date filter
date_filters = {
    "Last 24 Hours": datetime.now() - timedelta(days=1),
    "Last 7 Days": datetime.now() - timedelta(days=7),
    "Last 30 Days": datetime.now() - timedelta(days=30),
    "All Time": datetime.min
}
date_filter = date_filters[date_range]

# Auto-refresh
auto_refresh = st.sidebar.checkbox("Auto-refresh (30s)", value=False)
if auto_refresh:
    st.experimental_rerun()

# Sidebar stats
st.sidebar.markdown("---")
st.sidebar.subheader("📊 Quick Stats")

# Get quick stats
latest_scan = db.query("""
    SELECT 
        scan_timestamp,
        total_checks,
        checks_passed,
        checks_failed
    FROM soda_scan_results
    ORDER BY scan_timestamp DESC
    LIMIT 1
""")

if not latest_scan.empty:
    scan_time = latest_scan['scan_timestamp'].iloc[0]
    st.sidebar.metric("Last Scan", scan_time.strftime("%Y-%m-%d %H:%M") if pd.notna(scan_time) else "N/A")
    
    total_checks_val = latest_scan['total_checks'].iloc[0]
    st.sidebar.metric("Total Checks", int(total_checks_val) if pd.notna(total_checks_val) else 0)
    
    passed = latest_scan['checks_passed'].iloc[0]
    total = latest_scan['total_checks'].iloc[0]
    if pd.notna(passed) and pd.notna(total) and total > 0:
        success_rate = (passed / total * 100)
        st.sidebar.metric("Success Rate", f"{success_rate:.1f}%")
    else:
        st.sidebar.metric("Success Rate", "N/A")

# =====================================================
# PAGE 1: OVERVIEW DASHBOARD
# =====================================================
if page == "📊 Overview":
    st.title("📊 Data Quality Overview")
    st.markdown("Real-time monitoring of KYC data quality metrics")
    
    # Get latest scan summary
    latest_scan_query = """
        SELECT * FROM v_latest_scan_summary
    """
    latest_scan = db.query(latest_scan_query)
    
    if latest_scan.empty:
        st.warning("⚠️ No scan results available. Please run a scan first.")
    else:
        scan_data = latest_scan.iloc[0]
        
        # Safe value extraction with defaults
        total_checks = int(scan_data['total_checks']) if pd.notna(scan_data['total_checks']) else 0
        checks_passed = int(scan_data['checks_passed']) if pd.notna(scan_data['checks_passed']) else 0
        checks_failed = int(scan_data['checks_failed']) if pd.notna(scan_data['checks_failed']) else 0
        checks_warned = int(scan_data['checks_warned']) if pd.notna(scan_data['checks_warned']) else 0
        success_rate = scan_data['success_rate']
        rate_display = f"{float(success_rate):.1f}%" if pd.notna(success_rate) else "N/A"
        
        # Top metrics row
        col1, col2, col3, col4, col5 = st.columns(5)
        
        with col1:
            st.metric(
                "Total Checks",
                total_checks,
                delta=None
            )
        
        with col2:
            st.metric(
                "✅ Passed",
                checks_passed,
                delta=None,
                delta_color="normal"
            )
        
        with col3:
            st.metric(
                "❌ Failed",
                checks_failed,
                delta=None,
                delta_color="inverse"
            )
        
        with col4:
            st.metric(
                "⚠️ Warned",
                checks_warned,
                delta=None,
                delta_color="off"
            )
        
        with col5:
            st.metric(
                "Success Rate",
                rate_display,
                delta=None
            )
        
        st.markdown("---")
        
        # Second row: Charts
        col1, col2 = st.columns(2)
        
        with col1:
            st.subheader("Check Distribution")
            
            # Get safe values for not_evaluated
            checks_not_eval = int(scan_data['checks_not_evaluated']) if pd.notna(scan_data['checks_not_evaluated']) else 0
            
            # Pie chart of check results
            fig_pie = go.Figure(data=[go.Pie(
                labels=['Passed', 'Failed', 'Warned', 'Not Evaluated'],
                values=[
                    checks_passed,
                    checks_failed,
                    checks_warned,
                    checks_not_eval
                ],
                marker=dict(colors=['#00CC96', '#FF4B4B', '#FFA500', '#636EFA']),
                hole=0.4,
                textinfo='label+percent',
                textfont=dict(size=14),
                hovertemplate='<b>%{label}</b><br>Count: %{value}<br>Percentage: %{percent}<extra></extra>'
            )])
            
            fig_pie.update_layout(
                showlegend=True,
                height=350,
                margin=dict(t=20, b=20, l=20, r=20)
            )
            
            st.plotly_chart(fig_pie, use_container_width=True)
        
        with col2:
            st.subheader("Scan Performance")
            
            # Get recent scan performance
            perf_query = """
                SELECT 
                    scan_timestamp,
                    total_checks,
                    checks_passed,
                    checks_failed,
                    scan_duration_seconds
                FROM soda_scan_results
                WHERE scan_timestamp >= %s
                ORDER BY scan_timestamp DESC
                LIMIT 10
            """
            perf_data = db.query(perf_query, params=(date_filter,))
            
            if not perf_data.empty:
                fig_line = go.Figure()
                
                fig_line.add_trace(go.Scatter(
                    x=perf_data['scan_timestamp'],
                    y=perf_data['checks_passed'],
                    name='Passed',
                    mode='lines+markers',
                    line=dict(color='#00CC96', width=3),
                    marker=dict(size=8)
                ))
                
                fig_line.add_trace(go.Scatter(
                    x=perf_data['scan_timestamp'],
                    y=perf_data['checks_failed'],
                    name='Failed',
                    mode='lines+markers',
                    line=dict(color='#FF4B4B', width=3),
                    marker=dict(size=8)
                ))
                
                fig_line.update_layout(
                    xaxis_title="Scan Time",
                    yaxis_title="Check Count",
                    hovermode='x unified',
                    height=350,
                    margin=dict(t=20, b=20, l=20, r=20)
                )
                
                st.plotly_chart(fig_line, use_container_width=True)
        
        st.markdown("---")
        
        # Third row: Recent scans table
        st.subheader("📋 Recent Scans")
        
        recent_scans_query = """
            SELECT 
                scan_id,
                scan_timestamp,
                data_source,
                total_checks,
                checks_passed,
                checks_failed,
                checks_warned,
                ROUND((checks_passed::NUMERIC / NULLIF(total_checks, 0) * 100), 2) AS success_rate,
                scan_duration_seconds,
                scan_status
            FROM soda_scan_results
            WHERE scan_timestamp >= %s
            ORDER BY scan_timestamp DESC
            LIMIT 20
        """
        
        recent_scans = db.query(recent_scans_query, params=(date_filter,))
        
        if not recent_scans.empty:
            # Format for display
            display_df = recent_scans.copy()
            display_df['scan_timestamp'] = pd.to_datetime(display_df['scan_timestamp']).dt.strftime('%Y-%m-%d %H:%M:%S')
            display_df['success_rate'] = display_df['success_rate'].apply(lambda x: f"{x}%" if pd.notna(x) else "N/A")
            display_df['scan_duration_seconds'] = display_df['scan_duration_seconds'].apply(lambda x: f"{x:.2f}s" if pd.notna(x) else "N/A")
            
            # Rename columns for display
            display_df = display_df.rename(columns={
                'scan_id': 'Scan ID',
                'scan_timestamp': 'Timestamp',
                'data_source': 'Source',
                'total_checks': 'Total',
                'checks_passed': 'Passed',
                'checks_failed': 'Failed',
                'checks_warned': 'Warned',
                'success_rate': 'Success Rate',
                'scan_duration_seconds': 'Duration',
                'scan_status': 'Status'
            })
            
            st.dataframe(
                display_df,
                use_container_width=True,
                hide_index=True
            )
        else:
            st.info("ℹ️ No recent scans found for the selected time period.")

# =====================================================
# PAGE 2: FAILED CHECKS
# =====================================================
elif page == "🚨 Failed Checks":
    st.title("🚨 Failed Data Quality Checks")
    st.markdown("Detailed analysis of failing checks and affected records")
    
    # Get failed checks summary
    failed_checks_query = """
        SELECT 
            scr.check_id,
            scr.scan_id,
            sr.scan_timestamp,
            scr.check_name,
            scr.check_type,
            scr.table_name,
            scr.column_name,
            scr.check_outcome,
            scr.failure_message,
            scr.actual_value,
            scr.expected_value
        FROM soda_check_results scr
        JOIN soda_scan_results sr ON scr.scan_id = sr.scan_id
        WHERE scr.check_outcome IN ('FAIL', 'WARN')
            AND sr.scan_timestamp >= %s
        ORDER BY sr.scan_timestamp DESC, scr.check_outcome DESC
    """
    
    failed_checks = db.query(failed_checks_query, params=(date_filter,))
    
    if failed_checks.empty:
        st.success("✅ No failed checks found! All data quality checks are passing.")
    else:
        # Summary metrics
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.metric("Total Issues", len(failed_checks))
        
        with col2:
            critical_fails = len(failed_checks[failed_checks['check_outcome'] == 'FAIL'])
            st.metric("Critical Failures", critical_fails)
        
        with col3:
            warnings = len(failed_checks[failed_checks['check_outcome'] == 'WARN'])
            st.metric("Warnings", warnings)
        
        with col4:
            affected_tables = failed_checks['table_name'].nunique()
            st.metric("Affected Tables", affected_tables)
        
        st.markdown("---")
        
        # Filters
        col1, col2, col3 = st.columns(3)
        
        with col1:
            outcome_filter = st.multiselect(
                "Outcome",
                options=['FAIL', 'WARN'],
                default=['FAIL', 'WARN']
            )
        
        with col2:
            table_filter = st.multiselect(
                "Table",
                options=failed_checks['table_name'].unique().tolist(),
                default=failed_checks['table_name'].unique().tolist()
            )
        
        with col3:
            check_type_filter = st.multiselect(
                "Check Type",
                options=failed_checks['check_type'].unique().tolist(),
                default=failed_checks['check_type'].unique().tolist()
            )
        
        # Apply filters
        filtered_checks = failed_checks[
            (failed_checks['check_outcome'].isin(outcome_filter)) &
            (failed_checks['table_name'].isin(table_filter)) &
            (failed_checks['check_type'].isin(check_type_filter))
        ]
        
        st.markdown("---")
        
        # Failed checks by table
        col1, col2 = st.columns(2)
        
        with col1:
            st.subheader("Issues by Table")
            
            table_counts = filtered_checks.groupby('table_name').size().reset_index(name='count')
            
            fig_bar = px.bar(
                table_counts,
                x='table_name',
                y='count',
                color='count',
                color_continuous_scale='Reds',
                labels={'table_name': 'Table', 'count': 'Failed Checks'}
            )
            
            fig_bar.update_layout(
                showlegend=False,
                height=300,
                margin=dict(t=20, b=20, l=20, r=20)
            )
            
            st.plotly_chart(fig_bar, use_container_width=True)
        
        with col2:
            st.subheader("Issues by Outcome")
            
            outcome_counts = filtered_checks['check_outcome'].value_counts()
            
            fig_outcome = go.Figure(data=[go.Pie(
                labels=outcome_counts.index,
                values=outcome_counts.values,
                marker=dict(colors=['#FF4B4B', '#FFA500']),
                hole=0.4
            )])
            
            fig_outcome.update_layout(
                showlegend=True,
                height=300,
                margin=dict(t=20, b=20, l=20, r=20)
            )
            
            st.plotly_chart(fig_outcome, use_container_width=True)
        
        st.markdown("---")
        
        # Detailed failed checks table
        st.subheader("📋 Failed Checks Details")
        
        # Format for display
        display_df = filtered_checks.copy()
        display_df['scan_timestamp'] = pd.to_datetime(display_df['scan_timestamp']).dt.strftime('%Y-%m-%d %H:%M')
        
        # Add colored outcome badges
        def color_outcome(val):
            if val == 'FAIL':
                return 'background-color: #ff4b4b; color: white; padding: 5px; border-radius: 5px;'
            elif val == 'WARN':
                return 'background-color: #ffa500; color: white; padding: 5px; border-radius: 5px;'
            return ''
        
        # Display columns
        display_columns = [
            'scan_timestamp', 'table_name', 'check_name',
            'check_outcome', 'failure_message'
        ]
        
        st.dataframe(
            display_df[display_columns].rename(columns={
                'scan_timestamp': 'Timestamp',
                'table_name': 'Table',
                'check_name': 'Check',
                'check_outcome': 'Outcome',
                'failure_message': 'Message'
            }),
            use_container_width=True,
            hide_index=True
        )
        
        # Get failed rows if available
        failed_rows_query = """
            SELECT 
                sfr.failed_row_id,
                sfr.table_name,
                sfr.row_data,
                sfr.failure_reason,
                sfr.detected_at,
                sfr.remediation_status
            FROM soda_failed_rows sfr
            WHERE sfr.detected_at >= %s
            ORDER BY sfr.detected_at DESC
            LIMIT 100
        """
        
        failed_rows = db.query(failed_rows_query, params=(date_filter,))
        
        if not failed_rows.empty:
            st.markdown("---")
            st.subheader("🔍 Failed Rows Sample")
            
            st.dataframe(
                failed_rows[['table_name', 'failure_reason', 'remediation_status', 'detected_at']].rename(columns={
                    'table_name': 'Table',
                    'failure_reason': 'Reason',
                    'remediation_status': 'Status',
                    'detected_at': 'Detected At'
                }),
                use_container_width=True,
                hide_index=True
            )

# =====================================================
# PAGE 3: SCAN HISTORY & TRENDS
# =====================================================
elif page == "📈 Scan History":
    st.title("📈 Data Quality Trends")
    st.markdown("Historical analysis of data quality metrics over time")
    
    # Get trend data
    trend_query = """
        SELECT 
            DATE(scan_timestamp) AS scan_date,
            COUNT(DISTINCT scan_id) AS total_scans,
            SUM(total_checks) AS total_checks,
            SUM(checks_passed) AS total_passed,
            SUM(checks_failed) AS total_failed,
            SUM(checks_warned) AS total_warned,
            ROUND(AVG(checks_passed::NUMERIC / NULLIF(total_checks, 0) * 100), 2) AS avg_success_rate,
            ROUND(AVG(scan_duration_seconds), 2) AS avg_duration
        FROM soda_scan_results
        WHERE scan_timestamp >= %s
        GROUP BY DATE(scan_timestamp)
        ORDER BY scan_date DESC
    """
    
    trend_data = db.query(trend_query, params=(date_filter,))
    
    if trend_data.empty:
        st.warning("⚠️ No historical data available for the selected time period.")
    else:
        # Success rate trend
        st.subheader("Success Rate Trend")
        
        fig_success = go.Figure()
        
        fig_success.add_trace(go.Scatter(
            x=trend_data['scan_date'],
            y=trend_data['avg_success_rate'],
            mode='lines+markers',
            name='Success Rate',
            line=dict(color='#00CC96', width=3),
            marker=dict(size=10),
            fill='tozeroy',
            fillcolor='rgba(0, 204, 150, 0.2)'
        ))
        
        fig_success.add_hline(
            y=95,
            line_dash="dash",
            line_color="green",
            annotation_text="Target: 95%",
            annotation_position="right"
        )
        
        fig_success.update_layout(
            xaxis_title="Date",
            yaxis_title="Success Rate (%)",
            hovermode='x unified',
            height=400,
            yaxis_range=[0, 100]
        )
        
        st.plotly_chart(fig_success, use_container_width=True)
        
        st.markdown("---")
        
        # Pass/Fail trend
        col1, col2 = st.columns(2)
        
        with col1:
            st.subheader("Check Results Over Time")
            
            fig_checks = go.Figure()
            
            fig_checks.add_trace(go.Bar(
                x=trend_data['scan_date'],
                y=trend_data['total_passed'],
                name='Passed',
                marker_color='#00CC96'
            ))
            
            fig_checks.add_trace(go.Bar(
                x=trend_data['scan_date'],
                y=trend_data['total_failed'],
                name='Failed',
                marker_color='#FF4B4B'
            ))
            
            fig_checks.add_trace(go.Bar(
                x=trend_data['scan_date'],
                y=trend_data['total_warned'],
                name='Warned',
                marker_color='#FFA500'
            ))
            
            fig_checks.update_layout(
                barmode='stack',
                xaxis_title="Date",
                yaxis_title="Check Count",
                height=400,
                legend=dict(orientation="h", yanchor="bottom", y=1.02, xanchor="right", x=1)
            )
            
            st.plotly_chart(fig_checks, use_container_width=True)
        
        with col2:
            st.subheader("Scan Duration Trend")
            
            fig_duration = go.Figure()
            
            fig_duration.add_trace(go.Scatter(
                x=trend_data['scan_date'],
                y=trend_data['avg_duration'],
                mode='lines+markers',
                name='Avg Duration',
                line=dict(color='#636EFA', width=3),
                marker=dict(size=10)
            ))
            
            fig_duration.update_layout(
                xaxis_title="Date",
                yaxis_title="Duration (seconds)",
                hovermode='x unified',
                height=400
            )
            
            st.plotly_chart(fig_duration, use_container_width=True)
        
        st.markdown("---")
        
        # Historical data table
        st.subheader("📊 Historical Summary")
        
        display_df = trend_data.copy()
        display_df['scan_date'] = pd.to_datetime(display_df['scan_date']).dt.strftime('%Y-%m-%d')
        display_df['avg_success_rate'] = display_df['avg_success_rate'].round(2).astype(str) + '%'
        display_df['avg_duration'] = display_df['avg_duration'].round(2).astype(str) + 's'
        
        st.dataframe(
            display_df.rename(columns={
                'scan_date': 'Date',
                'total_scans': 'Scans',
                'total_checks': 'Total Checks',
                'total_passed': 'Passed',
                'total_failed': 'Failed',
                'total_warned': 'Warned',
                'avg_success_rate': 'Avg Success Rate',
                'avg_duration': 'Avg Duration'
            }),
            use_container_width=True,
            hide_index=True
        )

# =====================================================
# PAGE 4: FRAUD DETECTION INSIGHTS
# =====================================================
elif page == "🔎 Fraud Detection":
    st.title("🔎 Fraud Detection & Risk Insights")
    st.markdown("Identify high-risk users and suspicious patterns")
    
    # High-risk users
    high_risk_query = """
        SELECT * FROM v_high_risk_users
        ORDER BY failed_checks_count DESC
        LIMIT 50
    """
    
    high_risk_users = db.query(high_risk_query)
    
    if high_risk_users.empty:
        st.success("✅ No high-risk users detected!")
    else:
        # Risk summary
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.metric("High-Risk Users", len(high_risk_users[high_risk_users['risk_level'] == 'HIGH']))
        
        with col2:
            st.metric("Medium-Risk Users", len(high_risk_users[high_risk_users['risk_level'] == 'MEDIUM']))
        
        with col3:
            total_issues = high_risk_users['failed_checks_count'].sum()
            st.metric("Total Issues", int(total_issues))
        
        with col4:
            suspended = len(high_risk_users[high_risk_users['account_status'] == 'SUSPENDED'])
            st.metric("Suspended Accounts", suspended)
        
        st.markdown("---")
        
        # Risk distribution
        col1, col2 = st.columns(2)
        
        with col1:
            st.subheader("Risk Level Distribution")
            
            risk_counts = high_risk_users['risk_level'].value_counts()
            
            fig_risk = go.Figure(data=[go.Pie(
                labels=risk_counts.index,
                values=risk_counts.values,
                marker=dict(colors=['#FF4B4B', '#FFA500']),
                hole=0.4
            )])
            
            fig_risk.update_layout(height=300)
            st.plotly_chart(fig_risk, use_container_width=True)
        
        with col2:
            st.subheader("Top Issues by User")
            
            top_users = high_risk_users.nlargest(10, 'failed_checks_count')
            
            fig_top = px.bar(
                top_users,
                x='failed_checks_count',
                y='user_id',
                orientation='h',
                color='failed_checks_count',
                color_continuous_scale='Reds',
                labels={'failed_checks_count': 'Issues', 'user_id': 'User ID'}
            )
            
            fig_top.update_layout(height=300, showlegend=False)
            st.plotly_chart(fig_top, use_container_width=True)
        
        st.markdown("---")
        
        # High-risk users table
        st.subheader("🚨 High-Risk Users Details")
        
        display_df = high_risk_users.copy()
        
        st.dataframe(
            display_df[['user_id', 'first_name', 'last_name', 'email', 'risk_level', 'account_status', 'failed_checks_count']].rename(columns={
                'user_id': 'User ID',
                'first_name': 'First Name',
                'last_name': 'Last Name',
                'email': 'Email',
                'risk_level': 'Risk Level',
                'account_status': 'Status',
                'failed_checks_count': 'Issues'
            }),
            use_container_width=True,
            hide_index=True
        )
    
    st.markdown("---")
    
    # Expiring documents
    st.subheader("⏰ Expiring Documents")
    
    expiring_docs_query = """
        SELECT * FROM v_expiring_documents
        ORDER BY days_until_expiry ASC
        LIMIT 20
    """
    
    expiring_docs = db.query(expiring_docs_query)
    
    if expiring_docs.empty:
        st.success("✅ No documents expiring soon.")
    else:
        st.dataframe(
            expiring_docs[['user_id', 'first_name', 'last_name', 'document_type', 'expiry_date', 'days_until_expiry']].rename(columns={
                'user_id': 'User ID',
                'first_name': 'First Name',
                'last_name': 'Last Name',
                'document_type': 'Document Type',
                'expiry_date': 'Expiry Date',
                'days_until_expiry': 'Days Until Expiry'
            }),
            use_container_width=True,
            hide_index=True
        )

# =====================================================
# PAGE 5: SYSTEM INFORMATION
# =====================================================
elif page == "⚙️ System Info":
    st.title("⚙️ System Information")
    st.markdown("Database and system statistics")
    
    # Database statistics
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("📊 Database Statistics")
        
        # Table counts
        tables_query = """
            SELECT 
                'users' AS table_name,
                COUNT(*) AS row_count
            FROM users
            UNION ALL
            SELECT 
                'kyc_docs' AS table_name,
                COUNT(*) AS row_count
            FROM kyc_docs
            UNION ALL
            SELECT 
                'soda_scan_results' AS table_name,
                COUNT(*) AS row_count
            FROM soda_scan_results
            UNION ALL
            SELECT 
                'soda_check_results' AS table_name,
                COUNT(*) AS row_count
            FROM soda_check_results
        """
        
        table_stats = db.query(tables_query)
        
        if not table_stats.empty:
            st.dataframe(
                table_stats.rename(columns={
                    'table_name': 'Table',
                    'row_count': 'Row Count'
                }),
                use_container_width=True,
                hide_index=True
            )
    
    with col2:
        st.subheader("🔧 System Configuration")
        
        config_data = {
            'Setting': [
                'Database Host',
                'Database Name',
                'Database Port',
                'Environment',
                'Application Version'
            ],
            'Value': [
                os.getenv('POSTGRES_HOST', 'postgres'),
                os.getenv('POSTGRES_DB', 'kyc_platform'),
                os.getenv('POSTGRES_PORT', '5432'),
                os.getenv('ENVIRONMENT', 'production'),
                os.getenv('APP_VERSION', '1.0.0')
            ]
        }
        
        st.dataframe(
            pd.DataFrame(config_data),
            use_container_width=True,
            hide_index=True
        )
    
    st.markdown("---")
    
    # About
    st.subheader("ℹ️ About")
    
    st.markdown("""
    ### KYC Data Quality Monitoring Platform
    
    **Version:** 1.0.0  
    **Purpose:** Enterprise-grade data quality monitoring for KYC (Know Your Customer) data  
    **Technology Stack:**
    - PostgreSQL 15
    - Soda Core 3.3.2
    - Streamlit 1.31.0
    - Python 3.11
    
    **Features:**
    - ✅ Real-time data quality monitoring
    - ✅ Automated quality checks
    - ✅ Historical trend analysis
    - ✅ Fraud detection
    - ✅ Risk assessment
    - ✅ Compliance tracking
    
    **Support:** For issues or questions, contact your data engineering team.
    """)

# Footer
st.markdown("---")
st.markdown(
    """
    <div style='text-align: center; color: #666; padding: 20px;'>
        <p>KYC Data Quality Monitoring Platform © 2024 | Powered by Soda Core & Streamlit</p>
    </div>
    """,
    unsafe_allow_html=True
)

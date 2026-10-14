
from pathlib import Path

import pandas as pd
import streamlit as st
import altair as alt

# --------------------------------------------------
# Page configuration
# --------------------------------------------------

st.set_page_config(
    page_title="RevenueOps 360 | Sales Analytics",
    page_icon="",
    layout="wide",
    initial_sidebar_state="collapsed"
)

NAVY = "#17365D"
BLUE = "#3578B8"

st.markdown("""
<style>
    .block-container {
        max-width: 1200px;
        padding-top: 2rem;
        padding-bottom: 3rem;
    }

    h1, h2, h3 {
        letter-spacing: -0.025em;
    }

    div[data-testid="stMetric"] {
        background: rgba(130, 145, 165, 0.08);
        padding: 18px;
        border: 1px solid rgba(130,145,165,0.16);
        border-radius: 12px;
    }

    div[data-testid="stMetricLabel"] {
        font-weight: 500;
    }

    .section-note {
        opacity: 0.75;
        font-size: 0.9rem;
        margin-bottom: 1rem;
    }
</style>
""", unsafe_allow_html=True)

# --------------------------------------------------
# Data loading
# --------------------------------------------------

DATA_DIR = Path(__file__).parent / "data"

@st.cache_data
def load_data():
    revenue = pd.read_csv(
        DATA_DIR / "revenue_summary.csv"
    )
    sales = pd.read_csv(
        DATA_DIR / "sales_performance.csv"
    )

    revenue.columns = revenue.columns.str.lower()
    sales.columns = sales.columns.str.lower()

    return revenue, sales

try:
    revenue, sales = load_data()
except (FileNotFoundError, pd.errors.EmptyDataError) as e:
    st.error(f"Unable to load data: {e}")
    st.stop()

if len(revenue) != 1:
    st.error("Expected one company-wide revenue summary record.")
    st.stop()

summary = revenue.iloc[0]

# --------------------------------------------------
# Header
# --------------------------------------------------

st.title("RevenueOps 360")
st.markdown("### Sales Pipeline & Revenue Intelligence")

st.caption(
    "Sales Analytics Dashboard"
    "using Snowflake, dbt Core, SQL, Python, and Streamlit."
)

st.info(
    "Demonstration using synthetic business data. "
    "Dashboard figures are based on exported Snowflake "
    "reporting marts, not a live warehouse connection."
)

st.divider()

# --------------------------------------------------
# Executive overview
# --------------------------------------------------

st.subheader("Executive Overview")
st.markdown(
    '<div class="section-note">'
    'Company-wide commercial performance and collections.'
    '</div>',
    unsafe_allow_html=True
)

c1, c2, c3, c4 = st.columns(4)

c1.metric(
    "Won Deal Value",
    f"${summary['won_deal_value']:,.0f}",
    help="Value of opportunities marked Closed Won."
)

c2.metric(
    "Cash Collected",
    f"${summary['cash_collected']:,.0f}",
    help="Sum of recorded payment transactions."
)

c3.metric(
    "Open Pipeline",
    f"${summary['open_pipeline_value']:,.0f}",
    help="Value of opportunities not yet closed."
)

c4.metric(
    "Total Opportunities",
    f"{int(summary['total_opportunities']):,}"
)

st.divider()

# --------------------------------------------------
# Sales performance
# --------------------------------------------------

st.subheader("Sales Performance")

st.caption(
    "Compare closed-won deal value and open pipeline "
    "across sales representatives."
)

chart_df = sales[
    ["sales_rep", "won_deal_value", "open_pipeline_value"]
].rename(columns={
    "sales_rep": "Sales Representative",
    "won_deal_value": "Won Deal Value",
    "open_pipeline_value": "Open Pipeline"
})

long_df = chart_df.melt(
    id_vars="Sales Representative",
    var_name="Metric",
    value_name="Amount"
)

chart = (
    alt.Chart(long_df)
    .mark_bar(cornerRadiusEnd=3)
    .encode(
        x=alt.X(
            "Sales Representative:N",
            title=None,
            sort=["Leo", "Maya", "Noah"]
        ),
        y=alt.Y(
            "Amount:Q",
            title="Deal Value (USD)",
            axis=alt.Axis(format="$,.0f")
        ),
        color=alt.Color(
            "Metric:N",
            scale=alt.Scale(
                domain=["Won Deal Value", "Open Pipeline"],
                range=[NAVY, BLUE]
            ),
            legend=alt.Legend(
                orient="bottom",
                title=None
            )
        ),
        xOffset="Metric:N",
        tooltip=[
            "Sales Representative:N",
            "Metric:N",
            alt.Tooltip("Amount:Q", format="$,.0f")
        ]
    )
    .properties(height=330)
)

st.altair_chart(chart, use_container_width=True)

st.divider()

# --------------------------------------------------
# Sales representative details
# --------------------------------------------------

st.subheader("Sales Representative Details")

selected_rep = st.selectbox(
    "Select a sales representative",
    sorted(sales["sales_rep"].dropna().unique())
)

rep = sales.loc[
    sales["sales_rep"] == selected_rep
].iloc[0]

r1, r2, r3, r4 = st.columns(4)

r1.metric(
    "Total Opportunities",
    int(rep["total_opportunities"])
)

r2.metric(
    "Won Deals",
    int(rep["won_deals"])
)

r3.metric(
    "Win Rate",
    (
        f"{rep['win_rate_percent']:.1f}%"
        if pd.notna(rep["win_rate_percent"])
        else "N/A"
    )
)

r4.metric(
    "Open Pipeline",
    f"${rep['open_pipeline_value']:,.0f}"
)

# --------------------------------------------------
# Detailed data
# --------------------------------------------------

with st.expander("View Detailed Sales Data"):
    display_df = sales.drop(
        columns=["sales_rep_id"],
        errors="ignore"
    ).rename(columns={
        "sales_rep": "Sales Representative",
        "total_opportunities": "Opportunities",
        "won_deals": "Won Deals",
        "lost_deals": "Lost Deals",
        "won_deal_value": "Won Deal Value",
        "open_pipeline_value": "Open Pipeline",
        "win_rate_percent": "Win Rate (%)"
    })

    st.dataframe(
        display_df,
        use_container_width=True,
        hide_index=True
    )

st.divider()

# --------------------------------------------------
# Project explanation
# --------------------------------------------------


st.divider()

st.subheader("About This Project")

st.markdown("#### 1. Project Overview")

st.markdown("""
RevenueOps 360 is an analytics engineering project designed
to transform sales, customer, and payment data into reliable,
business-ready insights.

The project brings together sales pipeline activity, deal
performance, and payment information to provide a clearer
view of revenue operations.

Through interactive dashboards, users can explore sales
performance, monitor open opportunities, evaluate conversion
rates, and compare financial metrics to support more
informed business decisions.
""")
st.markdown("#### Key Business Metrics")

st.markdown("""
- **Won Deal Value:** Contract value associated with
  successfully closed sales opportunities.
- **Cash Collected:** Actual payments recorded in the
  payments dataset.
- **Open Pipeline:** Potential deal value associated
  with opportunities still in progress.
- **Win Rate:** Won opportunities divided by all
  resolved opportunities (won plus lost).
""")

st.markdown("####  Technical Implementation")

st.markdown("""
The solution uses **Snowflake, dbt Core, SQL, Python,
and Streamlit** to demonstrate a structured analytics workflow.

- **Data Storage:** Snowflake stores customer, opportunity,
  and payment datasets.
- **Data Transformation:** dbt organizes raw data into
  staging models, dimensional tables, and reporting marts.
- **Data Quality:** Automated tests check uniqueness,
  completeness, relationships, and financial consistency.
- **Analytics & Visualization:** Streamlit presents
  interactive KPIs and sales performance comparisons.

The project uses synthetic datasets, and the dashboard
displays exported analytical results rather than live
warehouse queries.
""")

st.divider()

st.caption(
    "RevenueOps 360 | " 
    "Snowflake · dbt Core · SQL · Python · Streamlit"
)

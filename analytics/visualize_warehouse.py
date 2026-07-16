"""
visualize_warehouse.py
=======================
Connects to the `DataWarehouse` PostgreSQL database (built by the
postgres-data-warehouse project), pulls data from the Gold layer views,
and produces a set of business-intelligence style visualizations.

Gold layer objects used:
    - gold.dim_customers
    - gold.dim_products
    - gold.fact_sales

Usage:
    python visualize_warehouse.py

Configuration is read from environment variables (see .env.example).
Charts are saved as PNG files in the ./charts directory.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path

import math
import matplotlib.pyplot as plt
import matplotlib.ticker as mticker
import pandas as pd
import seaborn as sns
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import Engine

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

load_dotenv()

DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "DataWarehouse")
DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")

CHARTS_DIR = Path("charts")

# ---------------------------------------------------------------------------
# Visual theme
# ---------------------------------------------------------------------------
# One place to control the look of every chart, so all five stay visually
# consistent instead of each picking its own palette/theme.

sns.set_theme(style="white", font_scale=1.05)
plt.rcParams.update(
    {
        "figure.dpi": 150,
        "savefig.dpi": 150,
        "savefig.bbox": "tight",
        "font.family": "sans-serif",
        "axes.titlesize": 15,
        "axes.titleweight": "bold",
        "axes.labelsize": 11,
        "axes.edgecolor": "#4d4d4d",
        "axes.labelcolor": "#333333",
        "text.color": "#333333",
        "xtick.color": "#4d4d4d",
        "ytick.color": "#4d4d4d",
    }
)

ACCENT = "#2563eb"          # primary bar/line color
PALETTE = "crest"           # sequential palette used for ranked bars
CATEGORICAL = sns.color_palette("Set2")


def _style_bar_axes(ax, *, xlabel: str, ylabel: str) -> None:
    """Shared cleanup for horizontal bar charts: strip clutter, keep gridlines
    that actually help (vertical, behind the bars, on the value axis only)."""
    ax.set_xlabel(xlabel, labelpad=8)
    ax.set_ylabel(ylabel, labelpad=8)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.spines["left"].set_visible(False)
    ax.grid(axis="x", color="#e5e5e5", linewidth=0.8)
    ax.set_axisbelow(True)
    ax.xaxis.set_major_formatter(mticker.FuncFormatter(lambda v, _: f"{v:,.0f}"))


def _annotate_bars(ax, *, fmt="{:,.0f}") -> None:
    """Put the value directly at the end of each horizontal bar, so the
    reader isn't stuck estimating against the gridlines."""
    for bar in ax.patches:
        width = bar.get_width()
        ax.annotate(
            fmt.format(width),
            xy=(width, bar.get_y() + bar.get_height() / 2),
            xytext=(6, 0),
            textcoords="offset points",
            va="center",
            ha="left",
            fontsize=9.5,
            color="#333333",
        )
    # Give the annotations room so they don't get clipped at the right edge.
    xmin, xmax = ax.get_xlim()
    ax.set_xlim(xmin, xmax * 1.12)


# ---------------------------------------------------------------------------
# Database connection
# ---------------------------------------------------------------------------

def get_engine() -> Engine:
    """Create a SQLAlchemy engine for the DataWarehouse database."""
    if not DB_PASSWORD:
        print(
            "Warning: DB_PASSWORD is not set. Set it via a .env file or "
            "environment variable before running this script.",
            file=sys.stderr,
        )

    conn_str = (
        f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}"
        f"@{DB_HOST}:{DB_PORT}/{DB_NAME}"
    )
    return create_engine(conn_str)


# ---------------------------------------------------------------------------
# Data access — Gold layer
# ---------------------------------------------------------------------------

def get_dim_customers(engine: Engine) -> pd.DataFrame:
    query = "SELECT * FROM gold.dim_customers;"
    return pd.read_sql(query, engine)


def get_dim_products(engine: Engine) -> pd.DataFrame:
    query = "SELECT * FROM gold.dim_products;"
    return pd.read_sql(query, engine)


def get_fact_sales(engine: Engine) -> pd.DataFrame:
    query = "SELECT * FROM gold.fact_sales;"
    return pd.read_sql(query, engine)


def get_sales_enriched(engine: Engine) -> pd.DataFrame:
    """
    Join fact_sales with dim_customers and dim_products so each sales
    row carries customer and product attributes for slicing/charting.
    """
    query = """
        SELECT
            fs.order_number,
            fs.order_date,
            fs.shipping_date,
            fs.due_date,
            fs.sales_amount,
            fs.quantity,
            fs.price,
            dc.country,
            dc.gender,
            dc.marital_status,
            dp.category,
            dp.sub_category,
            dp.product_name
        FROM gold.fact_sales fs
        LEFT JOIN gold.dim_customers dc ON fs.customer_key = dc.customer_key
        LEFT JOIN gold.dim_products dp ON fs.product_key = dp.product_key;
    """
    return pd.read_sql(query, engine)


# ---------------------------------------------------------------------------
# Visualizations
# ---------------------------------------------------------------------------

def plot_sales_by_country(df: pd.DataFrame) -> None:
    data = (
        df.groupby("country")["sales_amount"]
        .sum()
        .sort_values(ascending=True)  # ascending so the biggest bar is on top
    )
    total = data.sum()

    fig, ax = plt.subplots(figsize=(10, 6))
    sns.barplot(
        x=data.values, y=data.index, hue=data.index,
        palette=PALETTE, legend=False, ax=ax,
    )
    ax.set_title("Total Sales by Country", loc="left", pad=14)
    _style_bar_axes(ax, xlabel="Sales Amount", ylabel="")

    # Label each bar with both the raw amount and its share of total revenue —
    # a share on its own hides scale, and a raw number alone hides concentration.
    for bar, value in zip(ax.patches, data.values):
        share = value / total
        ax.annotate(
            f"{value:,.0f}  ({share:.0%})",
            xy=(bar.get_width(), bar.get_y() + bar.get_height() / 2),
            xytext=(6, 0),
            textcoords="offset points",
            va="center",
            ha="left",
            fontsize=9.5,
            color="#333333",
        )
    xmin, xmax = ax.get_xlim()
    ax.set_xlim(xmin, xmax * 1.2)

    fig.tight_layout()
    fig.savefig(CHARTS_DIR / "sales_by_country.png")
    plt.close(fig)


def plot_sales_by_category(df: pd.DataFrame) -> None:
    data = (
        df.groupby("category")["sales_amount"]
        .sum()
        .sort_values(ascending=False)
    )

    fig, ax = plt.subplots(figsize=(8, 8))
    wedges, _, autotexts = ax.pie(
        data.values,
        labels=None,
        autopct=lambda pct: f"{pct:.1f}%" if pct >= 3 else "",
        pctdistance=0.78,
        startangle=90,
        colors=CATEGORICAL,
        wedgeprops={"width": 0.42, "edgecolor": "white", "linewidth": 2},
    )
    plt.setp(autotexts, size=10, weight="bold", color="white")

    ax.set_title("Sales Share by Product Category", pad=16)
    ax.legend(
        wedges,
        [f"{name}  —  {value:,.0f}" for name, value in data.items()],
        title="Category (total sales)",
        loc="center left",
        bbox_to_anchor=(1.02, 0.5),
        frameon=False,
    )
    # Donut-hole label: the one number a reader usually wants first.
    ax.text(
        0, 0, f"{data.sum():,.0f}\ntotal sales",
        ha="center", va="center", fontsize=12, fontweight="bold",
    )
    ax.set_aspect("equal")

    fig.tight_layout()
    fig.savefig(CHARTS_DIR / "sales_by_category.png")
    plt.close(fig)


def plot_monthly_sales_trend(df: pd.DataFrame) -> None:
    trend_df = df.copy()
    trend_df["order_date"] = pd.to_datetime(trend_df["order_date"])
    trend_df["order_month"] = trend_df["order_date"].dt.to_period("M").dt.to_timestamp()

    data = trend_df.groupby("order_month")["sales_amount"].sum()

    fig, ax = plt.subplots(figsize=(12, 6))
    ax.plot(
        data.index, data.values,
        marker="o", markersize=5, linewidth=2.2, color=ACCENT,
    )
    ax.fill_between(data.index, data.values, color=ACCENT, alpha=0.08)

    # Call out the peak and trough — the two points a stakeholder actually
    # asks about — instead of leaving the reader to eyeball the line.
    peak_month, peak_val = data.idxmax(), data.max()
    low_month, low_val = data.idxmin(), data.min()
    ax.annotate(
        f"Peak: {peak_val:,.0f}\n{peak_month:%b %Y}",
        xy=(peak_month, peak_val), xytext=(0, 18),
        textcoords="offset points", ha="center", fontsize=9.5,
        fontweight="bold", color="#166534",
        arrowprops=dict(arrowstyle="-", color="#166534", lw=1),
    )
    ax.annotate(
        f"Low: {low_val:,.0f}\n{low_month:%b %Y}",
        xy=(low_month, low_val), xytext=(0, -28),
        textcoords="offset points", ha="center", fontsize=9.5,
        fontweight="bold", color="#991b1b",
        arrowprops=dict(arrowstyle="-", color="#991b1b", lw=1),
    )

    ax.set_title("Monthly Sales Trend", loc="left", pad=14)
    ax.set_xlabel("Month", labelpad=8)
    ax.set_ylabel("Sales Amount", labelpad=8)
    ax.yaxis.set_major_formatter(mticker.FuncFormatter(lambda v, _: f"{v:,.0f}"))
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)
    ax.grid(axis="y", color="#e5e5e5", linewidth=0.8)
    ax.set_axisbelow(True)
    fig.autofmt_xdate(rotation=45)

    fig.tight_layout()
    fig.savefig(CHARTS_DIR / "monthly_sales_trend.png")
    plt.close(fig)


def plot_top_products(df: pd.DataFrame, top_n: int = 10) -> None:
    data = (
        df.groupby("product_name")["sales_amount"]
        .sum()
        .sort_values(ascending=True)
        .tail(top_n)
    )

    fig, ax = plt.subplots(figsize=(10, 6))
    sns.barplot(
        x=data.values, y=data.index, hue=data.index,
        palette=PALETTE, legend=False, ax=ax,
    )
    ax.set_title(f"Top {top_n} Products by Sales", loc="left", pad=14)
    _style_bar_axes(ax, xlabel="Sales Amount", ylabel="")
    _annotate_bars(ax)

    fig.tight_layout()
    fig.savefig(CHARTS_DIR / "top_products.png")
    plt.close(fig)


def plot_customer_gender_distribution(customers_df: pd.DataFrame) -> None:
    data = customers_df["gender"].value_counts()
    total = data.sum()
 
    fig, ax = plt.subplots(figsize=(7.5, 6.5))
    wedges, _ = ax.pie(
        data.values,
        labels=None,
        startangle=90,
        colors=CATEGORICAL,
        wedgeprops={"width": 0.42, "edgecolor": "white", "linewidth": 2},
    )
 
    # Label each wedge by hand instead of relying on autopct: a slice like
    # "n/a" at a few percent is too thin to hold readable white text, so
    # anything under the threshold gets pulled outside on a leader line in
    # dark text instead of being crammed inside the wedge.
    SMALL_SLICE_THRESHOLD = 8  # percent
    for wedge, name, value in zip(wedges, data.index, data.values):
        pct = value / total * 100
        angle = math.radians((wedge.theta1 + wedge.theta2) / 2)
        x, y = math.cos(angle), math.sin(angle)
 
        if pct < SMALL_SLICE_THRESHOLD:
            ax.annotate(
                f"{name}\n{pct:.1f}%",
                xy=(x * 0.79, y * 0.79),
                xytext=(x * 1.4, y * 1.3),
                ha="center", va="center", fontsize=10, fontweight="bold",
                color="#333333",
                arrowprops=dict(arrowstyle="-", color="#999999", lw=1),
            )
        else:
            ax.text(
                x * 0.79, y * 0.79, f"{pct:.1f}%",
                ha="center", va="center", fontsize=11.5,
                fontweight="bold", color="white",
            )
            ax.text(
                x * 1.14, y * 1.14, name,
                ha="center", va="center", fontsize=10.5, color="#333333",
            )
 
    ax.set_title("Customer Distribution by Gender", pad=16)
    ax.text(
        0, 0, f"{total:,.0f}\ncustomers",
        ha="center", va="center", fontsize=12, fontweight="bold",
    )
    ax.set_aspect("equal")
    ax.set_xlim(-1.6, 1.6)
    ax.set_ylim(-1.5, 1.5)
 
    fig.tight_layout()
    fig.savefig(CHARTS_DIR / "customer_gender_distribution.png")
    plt.close(fig)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main() -> None:
    CHARTS_DIR.mkdir(exist_ok=True)

    engine = get_engine()

    print("Connecting to the database and pulling Gold layer data...")
    customers_df = get_dim_customers(engine)
    sales_df = get_sales_enriched(engine)

    print("Generating visualizations...")
    plot_sales_by_country(sales_df)
    plot_sales_by_category(sales_df)
    plot_monthly_sales_trend(sales_df)
    plot_top_products(sales_df)
    plot_customer_gender_distribution(customers_df)

    print(f"Done. Charts saved to: {CHARTS_DIR.resolve()}")


if __name__ == "__main__":
    main()